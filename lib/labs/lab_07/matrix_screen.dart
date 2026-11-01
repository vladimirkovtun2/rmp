import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================
//   ЗАДАЧА: Дана матрица K(m,n). Найти максимальный элемент
//   в каждой строке и заменить его заданным числом.
// ============================================================

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  // ВАЖНО: контроллеры и данные хранятся в полях State.
  // В отличие от Android (лекция, п. 3.6–3.7), во Flutter при
  // повороте экрана State НЕ пересоздаётся, поэтому введённые
  // данные и результаты расчёта сохраняются автоматически —
  // onSaveInstanceState() здесь не нужен.

  final _mController = TextEditingController(text: '3');
  final _nController = TextEditingController(text: '4');
  final _replaceController = TextEditingController(text: '0');
  final _random = Random();

  int _rows = 0;
  int _cols = 0;
  bool _matrixCreated = false;

  // Контроллеры ячеек матрицы (ручной ввод)
  List<List<TextEditingController>> _cellControllers = [];

  // Результат расчёта: матрица после замены + флаги заменённых ячеек
  List<List<int>>? _result;
  List<List<bool>>? _replaced;

  String? _error;

  // ====== Создание / изменение размера матрицы ======

  void _createMatrix() {
    final m = int.tryParse(_mController.text.trim());
    final n = int.tryParse(_nController.text.trim());

    if (m == null || n == null || m < 1 || n < 1 || m > 30 || n > 30) {
      setState(() {
        _error = 'Размеры m и n должны быть целыми числами от 1 до 30';
      });
      return;
    }

    setState(() {
      // Если размер не изменился — оставляем уже введённые значения
      if (!_matrixCreated || _rows != m || _cols != n) {
        for (var row in _cellControllers) {
          for (var c in row) {
            c.dispose();
          }
        }
        _cellControllers = List.generate(
          m,
              (i) => List.generate(
            n,
                (j) => TextEditingController(
              // При увеличении размера сохраняем пересекающиеся ячейки
              text: (_matrixCreated && i < _rows && j < _cols)
                  ? _cellControllers[i][j].text
                  : '0',
            ),
          ),
        );
        _rows = m;
        _cols = n;
        _matrixCreated = true;
      }
      _result = null;
      _replaced = null;
      _error = null;
    });
  }

  // ====== Случайное заполнение ======

  void _fillRandom() {
    if (!_matrixCreated) {
      _createMatrix();
      if (!_matrixCreated) return; // размеры некорректны
    }
    setState(() {
      for (var row in _cellControllers) {
        for (var c in row) {
          c.text = (_random.nextInt(199) - 99).toString(); // от -99 до 99
        }
      }
      _result = null;
      _replaced = null;
      _error = null;
    });
  }

  // ====== Расчёт: максимум в каждой строке → заданное число ======

  void _calculate() {
    if (!_matrixCreated) {
      setState(() => _error = 'Сначала создайте матрицу');
      return;
    }

    final replace = int.tryParse(_replaceController.text.trim());
    if (replace == null) {
      setState(() => _error = 'Введите целое число для замены');
      return;
    }

    // Считываем матрицу из ячеек
    final matrix = <List<int>>[];
    for (var i = 0; i < _rows; i++) {
      matrix.add([
        for (var j = 0; j < _cols; j++)
          int.tryParse(_cellControllers[i][j].text.trim()) ?? 0,
      ]);
    }

    final result = <List<int>>[];
    final replaced = <List<bool>>[];
    for (var i = 0; i < _rows; i++) {
      // Максимальный элемент в строке
      var maxValue = matrix[i][0];
      for (var v in matrix[i]) {
        if (v > maxValue) maxValue = v;
      }
      // Заменяем все вхождения максимума на заданное число
      result.add([for (var v in matrix[i]) v == maxValue ? replace : v]);
      replaced.add([for (var v in matrix[i]) v == maxValue]);
    }

    setState(() {
      _result = result;
      _replaced = replaced;
      _error = null;
    });
  }

  // ====== Освобождение ресурсов ======

  @override
  void dispose() {
    _mController.dispose();
    _nController.dispose();
    _replaceController.dispose();
    for (var row in _cellControllers) {
      for (var c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // ====== Интерфейс с разной разметкой для ориентаций ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Матрица K(m,n)'),
        centerTitle: true,
      ),
      // OrientationBuilder — аналог папок layout-port / layout-land
      // из лекции: выбираем разметку под текущую ориентацию экрана
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            // АЛЬБОМНАЯ: панель управления слева, данные справа
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: _buildControlPanel(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: _buildDataPanel(),
                  ),
                ),
              ],
            );
          }

          // ПОРТРЕТНАЯ: всё друг за другом сверху вниз
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildControlPanel(),
                const SizedBox(height: 16),
                _buildDataPanel(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---- Панель управления (ввод размеров, числа, кнопки) ----

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Строк m',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Столбцов n',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _replaceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Число для замены максимума',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _createMatrix,
                  icon: const Icon(Icons.grid_on),
                  label: const Text('Создать'),
                ),
                OutlinedButton.icon(
                  onPressed: _fillRandom,
                  icon: const Icon(Icons.casino),
                  label: const Text('Случайно'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Вычислить'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- Панель данных (матрица для ввода + результат) ----

  Widget _buildDataPanel() {
    if (!_matrixCreated) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Укажите размеры матрицы и нажмите «Создать».\n'
                'Элементы можно ввести вручную или заполнить случайными числами.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ==== Исходная матрица (ручной ввод) ====
        Text(
          'Исходная матрица K($_rows×$_cols)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInputGrid(),

        // ==== Результат ====
        if (_result != null && _replaced != null) ...[
          const SizedBox(height: 16),
          Text(
            'Результат (максимум каждой строки заменён на '
                '${_replaceController.text.trim()})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildResultGrid(),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text('— заменённые максимальные элементы'),
            ],
          ),
        ],
      ],
    );
  }

  // Сетка ячеек для ручного ввода
  Widget _buildInputGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cols,
        mainAxisExtent: 48,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _rows * _cols,
      itemBuilder: (context, index) {
        final i = index ~/ _cols;
        final j = index % _cols;
        return TextField(
          controller: _cellControllers[i][j],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }

  // Сетка результата с выделением заменённых ячеек
  Widget _buildResultGrid() {
    final result = _result!;
    final replaced = _replaced!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _cols,
        mainAxisExtent: 40,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _rows * _cols,
      itemBuilder: (context, index) {
        final i = index ~/ _cols;
        final j = index % _cols;
        return Container(
          decoration: BoxDecoration(
            color: replaced[i][j] ? Colors.green.shade200 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '${result[i][j]}',
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }
}
