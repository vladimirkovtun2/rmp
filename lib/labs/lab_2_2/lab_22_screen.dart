import 'package:flutter/material.dart';

/// Лабораторная №2.2 — виджет рабочего стола Android.
///
/// Сам виджет — нативный компонент (AppWidgetProvider), он живёт на
/// домашнем экране устройства, а не внутри приложения. Этот экран —
/// интерактивное превью и инструкция по добавлению виджета.
class Lab22Screen extends StatefulWidget {
  const Lab22Screen({super.key});

  @override
  State<Lab22Screen> createState() => _Lab22ScreenState();
}

class _Lab22ScreenState extends State<Lab22Screen> {
  // Та же палитра, что в Lab22Widget.kt (COLORS)
  static const _palette = [
    (name: 'Голубой', color: Color(0xFF03A9F4)),
    (name: 'Фиолетовый', color: Color(0xFF9C27B0)),
    (name: 'Бирюзовый', color: Color(0xFF009688)),
    (name: 'Оранжевый', color: Color(0xFFFF5722)),
  ];

  int _colorIndex = 0;

  void _nextColor() {
    setState(() => _colorIndex = (_colorIndex + 1) % _palette.length);
  }

  @override
  Widget build(BuildContext context) {
    final current = _palette[_colorIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.2')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Виджет рабочего стола',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Виджет — нативный Android-компонент (наследник AppWidgetProvider): '
            'он размещается на домашнем экране устройства, а не внутри '
            'приложения. Ниже — превью: как и настоящий виджет, оно '
            'меняет цвет фона по нажатию.',
          ),
          const SizedBox(height: 16),

          // ==== Превью виджета ====
          Center(
            child: GestureDetector(
              onTap: _nextColor,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                color: current.color,
                child: const Text(
                  'Hello, Widget!',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Цвет фона: ${current.name} (нажмите на превью)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 24),

          // ==== Как добавить виджет ====
          const Text(
            'Как добавить виджет на рабочий стол',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('1. Нажмите и удерживайте пустое место рабочего стола.\n'
              '2. Выберите «Виджеты».\n'
              '3. Найдите виджет «rmp_9plus» и перетащите его на рабочий стол.\n'
              '4. Нажимайте на виджет — фон будет меняться по кругу.'),
          const SizedBox(height: 24),

          // ==== Нативная часть ====
          const Text(
            'Нативная часть (android/app/src/main)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• kotlin/com/example/rmp_9plus/Lab22Widget.kt — провайдер виджета\n'
            '• res/layout/lab22_widget_layout.xml — макет виджета\n'
            '• res/xml/lab22_widget_info.xml — параметры виджета\n'
            '• AndroidManifest.xml — регистрация <receiver>',
          ),
        ],
      ),
    );
  }
}
