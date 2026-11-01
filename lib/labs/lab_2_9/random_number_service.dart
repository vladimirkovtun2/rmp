import 'dart:math';

/// Сервис лабораторной 2.9: отделяет логику генерации числа от UI,
/// что упрощает тестирование и поддержку.
class RandomNumberService {
  final _random = Random();

  /// Генерирует случайное число от [min] до [max] включительно.
  int generateRandomNumber(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
}
