import 'package:flutter/material.dart';

// ============================================================
//              НАСТРОЙКИ ВНЕШНЕГО ВИДА (модель)
// ============================================================

/// Хранит выбор пользователя. Один объект "черновика" живёт в
/// CalculatorScreen и передаётся в экран настроек, поэтому
/// при повторном открытии «Настроек» выбор сохраняется.
class AppSettings {
  Color backgroundColor;      // цвет фона главного экрана
  Color displayTextColor;     // цвет текста дисплея
  String appBarTitle;         // заголовок главной активности

  AppSettings({
    this.backgroundColor = Colors.white,
    this.displayTextColor = Colors.black87,
    this.appBarTitle = 'Калькулятор',
  });
}

// ============================================================
//                    ЭКРАН КАЛЬКУЛЯТОРА
// ============================================================

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Применённые настройки (то, что видно на экране прямо сейчас)
  late AppSettings _appliedSettings = AppSettings();

  // "Черновик" настроек: сюда экран настроек записывает выбор
  // при нажатии «Применить». Именно он передаётся при повторном
  // открытии настроек, поэтому пользовательский выбор сохраняется.
  late AppSettings _draftSettings = AppSettings();

  // То, что видно на дисплее
  String _display = '0';

  // Первый операнд
  double? _firstOperand;

  // Текущая операция: + - × ÷
  String? _operation;

  // Ждём ли ввода второго числа (после нажатия операции)
  bool _waitingForSecondOperand = false;

  // Только что нажали "=" — следующий ввод цифры начнёт новое число
  bool _justEvaluated = false;

  // ====== Переход на экран настроек ======

  /// Аналог startActivityForResult() из лекции: запускаем экран
  /// настроек и ждём результат. Возврат происходит через
  /// Navigator.pop(result) — аналог setResult() + finish().
  Future<void> _openSettings() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<AppSettings>(
        builder: (_) => SettingsScreen(initial: _draftSettings),
      ),
    );

    // Если настройки были применены (пользователь нажал «Применить»)
    if (result != null) {
      setState(() {
        _appliedSettings = result; // применяем настройки к главному экрану
        _draftSettings = result;   // запоминаем выбор для следующего раза
      });
    }
    // Если вернулись кнопкой «Назад» — ничего не меняем,
    // настройки главного экрана остаются прежними.
  }

  // ====== Обработка нажатий ======

  void _onDigitPressed(String digit) {
    setState(() {
      if (_waitingForSecondOperand || _justEvaluated) {
        _display = digit;
        _waitingForSecondOperand = false;
        _justEvaluated = false;
      } else {
        if (_display == '0') {
          _display = digit;
        } else {
          _display += digit;
        }
      }
    });
  }

  void _onDotPressed() {
    setState(() {
      if (_waitingForSecondOperand || _justEvaluated) {
        _display = '0.';
        _waitingForSecondOperand = false;
        _justEvaluated = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operation = null;
      _waitingForSecondOperand = false;
      _justEvaluated = false;
    });
  }

  void _onToggleSignPressed() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _onPercentPressed() {
    setState(() {
      final value = double.tryParse(_display) ?? 0;
      final result = value / 100;
      _display = _formatNumber(result);
    });
  }

  void _onOperationPressed(String op) {
    final current = double.tryParse(_display) ?? 0;

    // Если уже была операция и пользователь ввёл второе число —
    // сначала выполняем предыдущую операцию (цепочка вычислений)
    if (_operation != null && !_waitingForSecondOperand) {
      final result = _performCalculation(_firstOperand!, current, _operation!);

      // Проверка деления на ноль
      if (result == null) {
        _showDivisionByZeroDialog();
        return;
      }

      setState(() {
        _display = _formatNumber(result);
        _firstOperand = result;
      });
    } else {
      setState(() {
        _firstOperand = current;
      });
    }

    setState(() {
      _operation = op;
      _waitingForSecondOperand = true;
      _justEvaluated = false;
    });
  }

  void _onEqualsPressed() {
    if (_operation == null || _firstOperand == null) return;

    final current = double.tryParse(_display) ?? 0;
    final result = _performCalculation(_firstOperand!, current, _operation!);

    // Проверка деления на ноль
    if (result == null) {
      _showDivisionByZeroDialog();
      return;
    }

    setState(() {
      _display = _formatNumber(result);
      _firstOperand = null;
      _operation = null;
      _waitingForSecondOperand = false;
      _justEvaluated = true;
    });
  }

  // ====== Сами вычисления ======

  /// Возвращает null при делении на ноль
  double? _performCalculation(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return null;
    }
  }

  /// Красивое форматирование: убираем лишние нули после запятой
  String _formatNumber(double value) {
    if (value.isNaN || value.isInfinite) return 'Ошибка';

    // Если число целое — показываем как целое
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    // Иначе — до 10 знаков, убираем хвостовые нули
    String s = value.toStringAsFixed(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // ====== Всплывающее окно при делении на ноль ======
  void _showDivisionByZeroDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Ошибка'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Деление на ноль невозможно!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Сбрасываем состояние после закрытия диалога
                setState(() {
                  _display = '0';
                  _firstOperand = null;
                  _operation = null;
                  _waitingForSecondOperand = false;
                  _justEvaluated = false;
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ====== Сборка интерфейса ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appliedSettings.backgroundColor,
      appBar: AppBar(
        title: Text(_appliedSettings.appBarTitle),
        centerTitle: true,
        actions: [
          // Кнопка перехода на экран настроек
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ==== ДИСПЛЕЙ ====
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: _appliedSettings.displayTextColor,
                    ),
                  ),
                ),
              ),
            ),

            // ==== КЛАВИАТУРА ====
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Ряд 1: AC, +/-, %, ÷
                    Expanded(child: _buildRow([
                      _CalcButton(
                        label: 'AC',
                        onPressed: _onClearPressed,
                        color: Colors.grey.shade300,
                        textColor: Colors.black,
                      ),
                      _CalcButton(
                        label: '+/-',
                        onPressed: _onToggleSignPressed,
                        color: Colors.grey.shade300,
                        textColor: Colors.black,
                      ),
                      _CalcButton(
                        label: '%',
                        onPressed: _onPercentPressed,
                        color: Colors.grey.shade300,
                        textColor: Colors.black,
                      ),
                      _CalcButton(
                        label: '÷',
                        onPressed: () => _onOperationPressed('÷'),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ])),

                    // Ряд 2: 7 8 9 ×
                    Expanded(child: _buildRow([
                      _CalcButton(label: '7', onPressed: () => _onDigitPressed('7')),
                      _CalcButton(label: '8', onPressed: () => _onDigitPressed('8')),
                      _CalcButton(label: '9', onPressed: () => _onDigitPressed('9')),
                      _CalcButton(
                        label: '×',
                        onPressed: () => _onOperationPressed('×'),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ])),

                    // Ряд 3: 4 5 6 -
                    Expanded(child: _buildRow([
                      _CalcButton(label: '4', onPressed: () => _onDigitPressed('4')),
                      _CalcButton(label: '5', onPressed: () => _onDigitPressed('5')),
                      _CalcButton(label: '6', onPressed: () => _onDigitPressed('6')),
                      _CalcButton(
                        label: '-',
                        onPressed: () => _onOperationPressed('-'),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ])),

                    // Ряд 4: 1 2 3 +
                    Expanded(child: _buildRow([
                      _CalcButton(label: '1', onPressed: () => _onDigitPressed('1')),
                      _CalcButton(label: '2', onPressed: () => _onDigitPressed('2')),
                      _CalcButton(label: '3', onPressed: () => _onDigitPressed('3')),
                      _CalcButton(
                        label: '+',
                        onPressed: () => _onOperationPressed('+'),
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ])),

                    // Ряд 5: 0 (широкая), . , =
                    Expanded(child: _buildRow([
                      _CalcButton(
                        label: '0',
                        onPressed: () => _onDigitPressed('0'),
                        flex: 2,
                      ),
                      _CalcButton(label: '.', onPressed: _onDotPressed),
                      _CalcButton(
                        label: '=',
                        onPressed: _onEqualsPressed,
                        color: Colors.orange,
                        textColor: Colors.white,
                      ),
                    ])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map(
            (child) => Expanded(
          flex: (child is _CalcButton) ? child.flex : 1,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: child,
          ),
        ),
      )
          .toList(),
    );
  }
}

// ============================================================
//                    ЭКРАН НАСТРОЕК
// ============================================================

class SettingsScreen extends StatefulWidget {
  /// Текущий "черновик" настроек — на его основе заполняется экран,
  /// поэтому при повторном вызове выбор пользователя сохраняется.
  final AppSettings initial;

  const SettingsScreen({super.key, required this.initial});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Варианты цвета фона главного экрана
  static const List<({String name, Color color})> _backgroundOptions = [
    (name: 'Белый', color: Colors.white),
    (name: 'Светло-серый', color: Color(0xFFEFEFEF)),
    (name: 'Голубой', color: Color(0xFFE3F2FD)),
    (name: 'Мятный', color: Color(0xFFE8F5E9)),
  ];

  // Варианты цвета текста дисплея
  static const List<({String name, Color color})> _textColorOptions = [
    (name: 'Чёрный', color: Colors.black87),
    (name: 'Тёмно-синий', color: Color(0xFF1A237E)),
    (name: 'Тёмно-зелёный', color: Color(0xFF1B5E20)),
    (name: 'Бордовый', color: Color(0xFF880E4F)),
  ];

  late Color _backgroundColor;
  late Color _displayTextColor;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    // Инициализация из переданных настроек — здесь и происходит
    // "сохранение" пользовательского выбора при повторном вызове
    _backgroundColor = widget.initial.backgroundColor;
    _displayTextColor = widget.initial.displayTextColor;
    _titleController = TextEditingController(text: widget.initial.appBarTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// записываем выбор в общий объект настроек и возвращаемся
  /// на главный экран, передав его как результат.
  void _apply() {
    widget.initial.backgroundColor = _backgroundColor;
    widget.initial.displayTextColor = _displayTextColor;

    final title = _titleController.text.trim();
    widget.initial.appBarTitle = title.isEmpty ? 'Калькулятор' : title;

    Navigator.of(context).pop(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Настройка 1: цвет фона =====
          const _SectionTitle('Цвет фона'),
          RadioGroup<Color>(
            groupValue: _backgroundColor,
            onChanged: (value) =>
                setState(() => _backgroundColor = value as Color),
            child: Column(
              children: [
                ..._backgroundOptions.map(
                  (option) => RadioListTile<Color>(
                    title: Text(option.name),
                    value: option.color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== Настройка 2: цвет текста дисплея =====
          const _SectionTitle('Цвет текста дисплея'),
          RadioGroup<Color>(
            groupValue: _displayTextColor,
            onChanged: (value) =>
                setState(() => _displayTextColor = value as Color),
            child: Column(
              children: [
                ..._textColorOptions.map(
                  (option) => RadioListTile<Color>(
                    title: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: option.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(option.name),
                      ],
                    ),
                    value: option.color,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===== Настройка 3: заголовок активности =====
          const _SectionTitle('Заголовок главного экрана'),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Введите заголовок',
            ),
          ),

          const SizedBox(height: 32),

          // ===== Кнопка «Применить» =====
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Применить', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Заголовок секции на экране настроек
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ============================================================
//                    КНОПКА КАЛЬКУЛЯТОРА
// ============================================================

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final int flex;

  const _CalcButton({
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Colors.grey.shade100;
    final fg = textColor ?? Colors.black87;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: fg,
          ),
        ),
      ),
    );
  }
}
