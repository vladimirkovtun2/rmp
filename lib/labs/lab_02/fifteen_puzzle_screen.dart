import 'dart:math';

import 'package:flutter/material.dart';

class FifteenPuzzleScreen extends StatefulWidget {
  const FifteenPuzzleScreen({super.key});

  @override
  State<FifteenPuzzleScreen> createState() => _FifteenPuzzleScreenState();
}

class _FifteenPuzzleScreenState extends State<FifteenPuzzleScreen> {
  // Размер поля 4×4
  static const int _size = 4;

  // Поле в виде плоского списка из 16 элементов.
  // 0 — пустая ячейка.
  // Пример правильной конфигурации: [1..15, 0]
  List<int> _board = [];

  // Индекс плитки, которая была передвинута последней — для подсветки.
  int? _lastMovedIndex;

  // Счётчик ходов
  int _moves = 0;

  // Правильная финальная конфигурация
  final List<int> _solvedBoard = List<int>.generate(_size * _size, (i) {
    return (i == _size * _size - 1) ? 0 : i + 1;
  });

  @override
  void initState() {
    super.initState();
    _board = List<int>.from(_solvedBoard);
  }

  // ====== Проверка: можно ли сделать ход в ячейку index ======
  //
  // Ход возможен, если ячейка соседствует с пустой (0)
  // сверху, снизу, слева или справа.
  bool _canMove(int index) {
    final zeroIndex = _board.indexOf(0);
    final row = index ~/ _size;
    final col = index % _size;
    final zeroRow = zeroIndex ~/ _size;
    final zeroCol = zeroIndex % _size;

    // Соседство по горизонтали (одна строка, столбцы рядом)
    final sameRow = (row == zeroRow) && ((col - zeroCol).abs() == 1);
    // Соседство по вертикали (один столбец, строки рядом)
    final sameCol = (col == zeroCol) && ((row - zeroRow).abs() == 1);

    return sameRow || sameCol;
  }

  // ====== Обработка нажатия на плитку ======
  void _onTilePressed(int index) {
    if (_board[index] == 0) return; // на пустую ячейку жать бессмысленно
    if (!_canMove(index)) return;    // нельзя двигать — не сосед с пустой

    setState(() {
      final zeroIndex = _board.indexOf(0);
      // Меняем местами плитку и пустую ячейку
      _board[zeroIndex] = _board[index];
      _board[index] = 0;

      // Запоминаем, куда переехала плитка (её новое положение)
      _lastMovedIndex = zeroIndex;
      _moves++;
    });

    // Проверяем победу
    if (_isSolved()) {
      _showWinDialog();
    }
  }

  // ====== Проверка победы ======
  bool _isSolved() {
    for (int i = 0; i < _board.length; i++) {
      if (_board[i] != _solvedBoard[i]) return false;
    }
    return true;
  }

  // ====== Перемешать поле случайным образом ======
  //
  // Просто random-перестановка не годится: может получиться
  // нерешаемая конфигурация (когда перестановок нечётное число).
  // Надёжный способ — сделать много случайных допустимых ходов
  // из собранного состояния. Тогда поле гарантированно решаемо.
  void _shuffleBoard() {
    setState(() {
      _board = List<int>.from(_solvedBoard);
      _lastMovedIndex = null;
      _moves = 0;

      final random = Random();
      int prevZeroIndex = -1;

      // 200 случайных ходов более чем достаточно для перемешивания
      for (int step = 0; step < 200; step++) {
        final zeroIndex = _board.indexOf(0);
        final row = zeroIndex ~/ _size;
        final col = zeroIndex % _size;

        // Собираем всех соседей пустой ячейки
        final neighbors = <int>[];
        if (row > 0) neighbors.add(zeroIndex - _size); // сверху
        if (row < _size - 1) neighbors.add(zeroIndex + _size); // снизу
        if (col > 0) neighbors.add(zeroIndex - 1); // слева
        if (col < _size - 1) neighbors.add(zeroIndex + 1); // справа

        // Убираем ячейку, откуда только что пришли — чтобы не топтаться
        if (prevZeroIndex != -1) neighbors.remove(prevZeroIndex);

        final pick = neighbors[random.nextInt(neighbors.length)];

        // Меняем местами
        _board[zeroIndex] = _board[pick];
        _board[pick] = 0;
        prevZeroIndex = zeroIndex;
      }
    });
  }

  // ====== Диалог победы ======
  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Победа!'),
          ],
        ),
        content: Text(
          'Вы собрали пятнашки за $_moves ходов.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shuffleBoard();
            },
            child: const Text('Ещё раз'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ====== Диалог пользовательской настройки поля ======
  //
  // По заданию начальную конфигурацию можно задавать пользователем.
  // Реализуем ввод 16 чисел через запятую: 1,2,3,...,15,0
  void _showCustomSetupDialog() {
    final controller = TextEditingController(
      text: _board.join(','),
    );
    String? error;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Своя конфигурация'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Введите 16 чисел через запятую.\n'
                        'Числа 1..15 — плитки, 0 — пустая ячейка.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    // Парсим ввод
                    final parts = controller.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (parts.length != _size * _size) {
                      setDialogState(() {
                        error = 'Нужно ровно 16 чисел';
                      });
                      return;
                    }

                    final parsed = <int>[];
                    for (final p in parts) {
                      final v = int.tryParse(p);
                      if (v == null || v < 0 || v > 15) {
                        setDialogState(() {
                          error = 'Все числа должны быть от 0 до 15';
                        });
                        return;
                      }
                      parsed.add(v);
                    }

                    // Проверяем, что каждое число встречается ровно один раз
                    final sorted = List<int>.from(parsed)..sort();
                    final expected = List<int>.generate(16, (i) => i);
                    if (!_listEquals(sorted, expected)) {
                      setDialogState(() {
                        error = 'Числа 0..15 должны встречаться по одному разу';
                      });
                      return;
                    }

                    // Применяем конфигурацию
                    setState(() {
                      _board = parsed;
                      _lastMovedIndex = null;
                      _moves = 0;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Применить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ====== Кнопка "Сбросить в собранное состояние" ======
  void _resetToSolved() {
    setState(() {
      _board = List<int>.from(_solvedBoard);
      _lastMovedIndex = null;
      _moves = 0;
    });
  }

  // ====== Сборка интерфейса ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пятнашки'),
        centerTitle: true,
        actions: [
          // Меню из трёх точек, как в предыдущей лекции
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'shuffle':
                  _shuffleBoard();
                  break;
                case 'custom':
                  _showCustomSetupDialog();
                  break;
                case 'reset':
                  _resetToSolved();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Перемешать'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'custom',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Своя конфигурация'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restart_alt),
                  title: Text('Собрать заново'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ==== Строка статистики ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ходов: $_moves',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const _Legend(),
                ],
              ),
              const SizedBox(height: 16),

              // ==== Игровое поле 4×4 ====
              // Аналог TableLayout: Column из Row.
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1, // квадратное поле
                    child: Column(
                      children: List.generate(_size, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(_size, (col) {
                              final index = row * _size + col;
                              return Expanded(
                                child: _buildTile(index),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==== Кнопки управления ====
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shuffleBoard,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Перемешать'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showCustomSetupDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Своё поле'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== Отрисовка одной ячейки поля ======

  Widget _buildTile(int index) {
    final value = _board[index];

    // Пустая ячейка
    if (value == 0) {
      return Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    // Определяем, как подсветить плитку
    final isMovable = _canMove(index);          // можно ли сейчас сходить
    final isLastMoved = (index == _lastMovedIndex); // последний ход

    // Цвет фона:
    //  — оранжевый, если это последняя передвинутая плитка
    //  — зелёный, если плитка доступна для хода
    //  — серо-синий, обычная плитка
    Color bgColor;
    Color fgColor = Colors.white;

    if (isLastMoved) {
      bgColor = Colors.orange.shade700;
    } else if (isMovable) {
      bgColor = Colors.green.shade600;
    } else {
      bgColor = Colors.blueGrey.shade700;
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isMovable ? () => _onTilePressed(index) : null,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: fgColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
//                     ЛЕГЕНДА ЦВЕТОВ
// ============================================================

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: Colors.green, label: 'ход'),
        SizedBox(width: 8),
        _LegendDot(color: Colors.orange, label: 'последний'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
