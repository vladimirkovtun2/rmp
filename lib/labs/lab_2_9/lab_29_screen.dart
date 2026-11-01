import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'random_number_service.dart';

/// Лабораторная работа №2.9 — сервисы: генератор случайных чисел.
///
/// Сервис RandomNumberService предоставляется через Provider. В
/// отдельном приложении обёртка стояла бы в main() (MultiProvider),
/// здесь — на уровне экрана, чтобы лаборатории не зависели друг от друга.
class Lab29Screen extends StatefulWidget {
  const Lab29Screen({super.key});

  @override
  State<Lab29Screen> createState() => _Lab29ScreenState();
}

class _Lab29ScreenState extends State<Lab29Screen> {
  int? _randomNumber;

  void _generateNumber(BuildContext context) {
    final randomNumberService = context.read<RandomNumberService>();
    setState(() {
      _randomNumber = randomNumberService.generateRandomNumber(1, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<RandomNumberService>(
      create: (_) => RandomNumberService(),
      // Builder даёт контекст ПОД Provider — именно отсюда context.read
      // находит сервис (контекст самого State находится ВЫШЕ Provider)
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Лабораторная работа №2.9')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_randomNumber != null)
                  Text(
                    'Сгенерированное число: $_randomNumber',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _generateNumber(context),
                  child: const Text('Сгенерировать случайное число'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
