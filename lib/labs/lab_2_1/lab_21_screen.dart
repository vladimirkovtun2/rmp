import 'package:flutter/material.dart';

/// Лабораторная работа №2.1 — диалоги: все описанные в методичке виды.
class Lab21Screen extends StatefulWidget {
  const Lab21Screen({super.key});

  @override
  State<Lab21Screen> createState() => _Lab21ScreenState();
}

class _Lab21ScreenState extends State<Lab21Screen> {
  static const List<String> _items = ['Пункт 1', 'Пункт 2', 'Пункт 3'];

  // Состояние одиночного выбора (-1 — ничего не выбрано)
  int _checkedItem = -1;

  // Состояние множественного выбора
  final List<bool> _checkedItems = List.filled(_items.length, false);

  // Контроллер поля пользовательского диалога (живёт вместе с экраном,
  // чтобы не освобождать его, пока TextField может перестраиваться)
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  // ====== 1. AlertDialog с кнопками Да / Нет / Отмена ======

  void _showExitDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info),
        title: const Text('Выход'),
        content: const Text('Вы хотите сохранить данные перед выходом?'),
        actions: [
          TextButton(
            onPressed: () {
              // Метод сохранения данных
              messenger.showSnackBar(
                const SnackBar(content: Text('Данные сохранены')),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Да'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  // ====== 2. AlertDialog со списком ======

  void _showListDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выберите элемент'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _items.map((item) {
              return ListTile(
                title: Text(item),
                onTap: () {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Вы выбрали: $item')),
                  );
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  // ====== 3. AlertDialog со списком с единственным выбором ======

  void _showSingleChoiceDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Выберите элемент'),
          content: SingleChildScrollView(
            child: RadioGroup<int>(
              groupValue: _checkedItem,
              onChanged: (value) =>
                  setDialogState(() => _checkedItem = value as int),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return RadioListTile<int>(
                    title: Text(item),
                    value: index,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() => _checkedItem = -1); // Сброс выбора
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (_checkedItem == -1) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Выберите элемент')),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Вы выбрали: ${_items[_checkedItem]}'),
                    ),
                  );
                  setDialogState(() => _checkedItem = -1); // Сброс после выбора
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Да'),
            ),
          ],
        ),
      ),
    );
  }

  // ====== 4. AlertDialog со списком с множественным выбором ======

  void _showMultiChoiceDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Выберите элементы'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return CheckboxListTile(
                  title: Text(item),
                  value: _checkedItems[index],
                  onChanged: (value) => setDialogState(
                    () => _checkedItems[index] = value ?? false,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final selected = <String>[];
                for (var i = 0; i < _checkedItems.length; i++) {
                  if (_checkedItems[i]) selected.add(_items[i]);
                }

                if (selected.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Выберите хотя бы один элемент'),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Вы выбрали: ${selected.join(', ')}')),
                  );
                  setDialogState(
                    () => _checkedItems.fillRange(0, _checkedItems.length, false),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Да'),
            ),
          ],
        ),
      ),
    );
  }

  // ====== 5. Пользовательский диалог с полем ввода ======

  void _showCustomDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Пользовательский диалог'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Это пользовательский диалог'),
              const SizedBox(height: 20),
              TextField(
                controller: _customController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Текст',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              messenger.showSnackBar(
                SnackBar(content: Text('Вы ввели: ${_customController.text}')),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Да'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  // ====== 6. TimePickerDialog ======

  Future<void> _pickTime() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
      messenger.showSnackBar(
        SnackBar(content: Text('Вы выбрали: $formatted')),
      );
    }
  }

  // ====== 7. DatePickerDialog ======

  Future<void> _pickDate() async {
    final messenger = ScaffoldMessenger.of(context);
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000), // Минимальная дата
      lastDate: DateTime(2101),  // Максимальная дата
    );

    if (picked != null && mounted) {
      final formatted = '${picked.day}/${picked.month}/${picked.year}';
      messenger.showSnackBar(
        SnackBar(content: Text('Вы выбрали: $formatted')),
      );
    }
  }

  // ====== Интерфейс ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.1')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Диалоги',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _showExitDialog,
            child: const Text('AlertDialog: Да / Нет / Отмена'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _showListDialog,
            child: const Text('AlertDialog со списком'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _showSingleChoiceDialog,
            child: const Text('AlertDialog: одиночный выбор'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _showMultiChoiceDialog,
            child: const Text('AlertDialog: множественный выбор'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _showCustomDialog,
            child: const Text('Пользовательский диалог'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _pickTime,
            child: const Text('TimePickerDialog'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _pickDate,
            child: const Text('DatePickerDialog'),
          ),
        ],
      ),
    );
  }
}
