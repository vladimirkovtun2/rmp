import 'package:flutter/material.dart';

/// «Фрагмент» по лабораторной 2.5 — переиспользуемый виджет в отдельном
/// файле (аналог фрагмента в Android): его можно сколько угодно раз
/// встраивать в дерево, добавлять и удалять динамически.
class Lab25Fragment extends StatelessWidget {
  final int number;

  const Lab25Fragment({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[number % Colors.primaries.length];
    return Card(
      color: color.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.shade400,
              child: Text('$number'),
            ),
            const SizedBox(width: 12),
            Text(
              'Фрагмент №$number',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
