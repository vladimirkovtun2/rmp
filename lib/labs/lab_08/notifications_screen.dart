import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';

/// Глобальный плагин — аналог NotificationManager из лекции
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

class NotifyScreen extends StatefulWidget {
  const NotifyScreen({super.key});

  @override
  State<NotifyScreen> createState() => _NotifyScreenState();
}

class _NotifyScreenState extends State<NotifyScreen> {
  final _titleController = TextEditingController(text: 'Напоминание');
  final _bodyController = TextEditingController(
    text: 'Не забудь про важное дело!\nВторая строка сообщения',
  );

  final _picker = ImagePicker();
  String? _imagePath; // путь к выбранной картинке (null — без картинки)

  // Настройки уведомления (звук, вибрация, световая индикация)
  bool _sound = true;
  bool _vibration = true;
  bool _lights = false;

  int _notificationId = 0;

  // Плагин инициализируется при открытии экрана (в отдельном проекте
  // это делал main() до runApp). Инициализация не блокирует интерфейс:
  // если плагин недоступен (например, в тестах), экран всё равно работает

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );
      await notifications.initialize(initSettings);

      // Android 13+ (API 33): запрос разрешения на уведомления
      await notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Плагин недоступен (например, в тестах) — экран всё равно открывается
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ====== Выбор картинки ======

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  // ====== Канал уведомлений ======
  // В Android 8+ звук/вибрация/подсветка задаются на уровне канала,
  // поэтому для каждой комбинации настроек создаём свой канал
  // (аналог createChannelIfNeeded() из лекции).

  String get _channelId =>
      'notify_ch_s${_sound ? 1 : 0}_v${_vibration ? 1 : 0}_l${_lights ? 1 : 0}';

  Future<void> _ensureChannel() async {
    final androidPlugin = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        'Уведомления напоминалки',
        description: 'Звук: ${_sound ? "да" : "нет"}, '
            'вибрация: ${_vibration ? "да" : "нет"}, '
            'подсветка: ${_lights ? "да" : "нет"}',
        importance: Importance.high,
        playSound: _sound,
        enableVibration: _vibration,
        enableLights: _lights,
        ledColor: Colors.red,
      ),
    );
  }

  // ====== Показ уведомления (аналог notificationManager.notify()) ======

  Future<void> _deliver(NotificationDetails details) async {
    await _ensureChannel();

    final title = _titleController.text.trim().isEmpty
        ? 'Напоминание'
        : _titleController.text.trim();

    await notifications.show(
      ++_notificationId,
      title,
      _bodyController.text.trim(),
      details,
    );
    _showMessage('Уведомление показано');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  // ====== Тип 1: уведомление с кнопками ======

  Future<void> _showActionsNotification() async {
    await _deliver(
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Уведомления напоминалки',
          importance: Importance.high,
          priority: Priority.high,
          // До трёх кнопок — аналог addAction() из лекции
          actions: [
            AndroidNotificationAction('open', 'Открыть'),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ====== Тип 2: уведомление с длинным текстом ======

  Future<void> _showBigTextNotification() async {
    final body = _bodyController.text.trim();
    await _deliver(
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Уведомления напоминалки',
          importance: Importance.high,
          priority: Priority.high,
          // BigTextStyle — текст показывается полностью при раскрытии
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: _titleController.text.trim(),
            summaryText: 'Нажмите, чтобы развернуть',
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ====== Тип 3: уведомление с большой картинкой ======

  Future<void> _showBigPictureNotification() async {
    if (_imagePath == null) {
      _showMessage('Сначала выберите картинку — или используйте другой тип');
      return;
    }
    await _deliver(
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Уведомления напоминалки',
          importance: Importance.high,
          priority: Priority.high,
          // BigPictureStyle — аналог BigPictureStyle().bigPicture()
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(_imagePath!),
            largeIcon: FilePathAndroidBitmap(_imagePath!),
            contentTitle: _titleController.text.trim(),
            summaryText: 'Нажмите, чтобы развернуть',
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ====== Тип 4: уведомление в стиле Inbox ======

  Future<void> _showInboxNotification() async {
    // Каждая строка текста — отдельное сообщение списка
    final lines = _bodyController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (lines.isEmpty) lines.add('(пустое напоминание)');

    await _deliver(
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Уведомления напоминалки',
          importance: Importance.high,
          priority: Priority.high,
          // InboxStyle — список строк в стиле «Входящие»
          styleInformation: InboxStyleInformation(
            lines,
            contentTitle: _titleController.text.trim(),
            summaryText: '${lines.length} сообщ.',
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ====== Интерфейс ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминалка'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==== Текст уведомления ====
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Заголовок',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Текст (для Inbox каждая строка — пункт списка)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          // ==== Картинка (необязательно) ====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Миниатюра выбранной картинки или заглушка
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imagePath != null
                        ? Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _imagePath != null
                              ? 'Картинка выбрана'
                              : 'Без картинки',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _imagePath != null
                              ? 'Будет показана в уведомлении '
                                  '«Большая картинка»'
                              : 'Картинка необязательна — уведомления '
                                  'будут текстовыми',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    tooltip: 'Выбрать картинку',
                    onPressed: _pickImage,
                  ),
                  if (_imagePath != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Убрать картинку',
                      onPressed: () =>
                          setState(() => _imagePath = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ==== Настройки: звук, вибрация, световая индикация ====
          SwitchListTile(
            title: const Text('Звук'),
            subtitle: const Text('Звуковой сигнал при показе'),
            value: _sound,
            onChanged: (v) => setState(() => _sound = v),
          ),
          SwitchListTile(
            title: const Text('Вибрация'),
            subtitle: const Text('Виброотклик при показе'),
            value: _vibration,
            onChanged: (v) => setState(() => _vibration = v),
          ),
          SwitchListTile(
            title: const Text('Световая индикация'),
            subtitle: const Text('Мигание LED-индикатором (красным)'),
            value: _lights,
            onChanged: (v) => setState(() => _lights = v),
          ),
          const SizedBox(height: 20),

          // ==== Кнопки типов уведомлений ====
          const Text(
            'Тип уведомления',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _showActionsNotification,
                icon: const Icon(Icons.smart_button),
                label: const Text('С кнопками'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showBigTextNotification,
                icon: const Icon(Icons.notes),
                label: const Text('Длинный текст'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showBigPictureNotification,
                icon: const Icon(Icons.photo_size_select_large),
                label: const Text('Большая картинка'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showInboxNotification,
                icon: const Icon(Icons.inbox),
                label: const Text('Inbox'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
