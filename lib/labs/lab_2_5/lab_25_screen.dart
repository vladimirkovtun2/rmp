import 'package:flutter/material.dart';

import 'lab25_fragment.dart';

/// Лабораторная работа №2.5 — фрагменты: создание и использование.
///
/// Во Flutter фрагментов нет — их роль выполняют виджеты. Экран
/// демонстрирует формулировку методички: виджеты динамически добавляются,
/// изменяются и удаляются из дерева интерфейса.
class Lab25Screen extends StatefulWidget {
  const Lab25Screen({super.key});

  @override
  State<Lab25Screen> createState() => _Lab25ScreenState();
}

class _Lab25ScreenState extends State<Lab25Screen> {
  // Встроенные в дерево экземпляры «фрагмента»
  final List<int> _fragments = [];

  void _addFragment() {
    setState(() => _fragments.add(_fragments.length + 1));
  }

  void _removeFragment() {
    if (_fragments.isEmpty) return;
    setState(() => _fragments.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №2.5')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Фрагменты (виджеты)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Каждый «фрагмент» — переиспользуемый виджет Lab25Fragment '
              'из отдельного файла. Добавляйте и удаляйте его из дерева — '
              'интерфейс перестраивается.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _addFragment,
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить фрагмент'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _fragments.isEmpty ? null : _removeFragment,
                    icon: const Icon(Icons.remove),
                    label: const Text('Убрать фрагмент'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _fragments.isEmpty
                  ? const Center(
                      child: Text(
                        'Фрагментов нет — нажмите «Добавить фрагмент»',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final n in _fragments)
                            Lab25Fragment(key: ValueKey(n), number: n),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
