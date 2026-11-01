import 'dart:math';

import 'package:flutter/material.dart';

/// Лабораторная работа №2.4 — Future как средство выполнения фоновых задач.
///
/// По п. 4 задания длительность фоновой задачи сделана случайной (1–5 с),
/// время выполнения показывается вместе с результатом.
class Lab24Screen extends StatefulWidget {
  const Lab24Screen({super.key});

  @override
  State<Lab24Screen> createState() => _Lab24ScreenState();
}

class _Lab24ScreenState extends State<Lab24Screen> {
  final _random = Random();

  // Переменная для хранения данных
  String? _data;
  int? _elapsedSeconds; // Случайное время выполнения задачи
  bool _isLoading = false;

  // Метод для асинхронной загрузки данных
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true; // Включаем индикатор загрузки
    });

    // Эмуляция запроса со случайной длительностью (п. 4 задания)
    final seconds = 1 + _random.nextInt(5);
    await Future.delayed(Duration(seconds: seconds));

    // Устанавливаем данные
    setState(() {
      _data = 'Данные успешно загружены!';
      _elapsedSeconds = seconds;
      _isLoading = false; // Отключаем индикатор загрузки
    });
  }

  // Метод для отображения интерфейса в зависимости от состояния
  Widget _buildBody() {
    // Показать индикатор, если идёт загрузка
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else if (_data != null) {
      // Показать текст, если данные загружены
      return Column(
        children: [
          Text(
            _data!,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Время выполнения: $_elapsedSeconds с',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      );
    } else {
      // Сообщение перед загрузкой
      return const Text(
        'Нажмите на кнопку для загрузки данных.',
        style: TextStyle(fontSize: 18),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Асинхронный пример'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Используем метод для отображения контента
            _buildBody(),
            const SizedBox(height: 20),
            ElevatedButton(
              // Запуск асинхронной задачи
              onPressed: _loadData,
              child: const Text('Загрузить данные'),
            ),
          ],
        ),
      ),
    );
  }
}
