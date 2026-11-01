import 'package:flutter/material.dart';

import 'lab_02/fifteen_puzzle_screen.dart';
import 'lab_06/calculator_screen.dart';
import 'lab_07/matrix_screen.dart';
import 'lab_08/notifications_screen.dart';
import 'lab_09/lab_09_screen.dart';
import 'lab_10/lab_10_screen.dart';
import 'lab_11/lab_11_screen.dart';
import 'lab_2_1/lab_21_screen.dart';
import 'lab_2_2/lab_22_screen.dart';
import 'lab_2_3/lab_23_screen.dart';
import 'lab_2_4/lab_24_screen.dart';
import 'lab_2_5/lab_25_screen.dart';
import 'lab_2_6/lab_26_screen.dart';
import 'lab_2_7/lab_27_screen.dart';
import 'lab_2_8/lab_28_screen.dart';
import 'lab_2_9/lab_29_screen.dart';

/// Описание одной лабораторной работы для главного экрана.
class LabInfo {
  const LabInfo({
    required this.number,
    required this.title,
    required this.description,
    required this.builder,
  });

  final String number;
  final String title;
  final String description;
  final WidgetBuilder builder;
}

/// Реестр всех лабораторных работ. Порядок в списке = порядок на главном экране.
///
/// Чтобы добавить новую лабораторную:
/// 1. Создайте папку lib/labs/lab_NN/ с экраном работы.
/// 2. Добавьте её в список ниже.
final List<LabInfo> labs = [
  LabInfo(
    number: '02',
    title: 'Лабораторная работа №2',
    description: 'Пятнашки 4×4',
    builder: (_) => const FifteenPuzzleScreen(),
  ),
  LabInfo(
    number: '06',
    title: 'Лабораторная работа №6',
    description: 'Калькулятор с настройками',
    builder: (_) => const CalculatorScreen(),
  ),
  LabInfo(
    number: '07',
    title: 'Лабораторная работа №7',
    description: 'Обработка матрицы K(m,n)',
    builder: (_) => const MatrixScreen(),
  ),
  LabInfo(
    number: '08',
    title: 'Лабораторная работа №8',
    description: 'Локальные уведомления',
    builder: (_) => const NotifyScreen(),
  ),
  LabInfo(
    number: '09',
    title: 'Лабораторная работа №9',
    description: 'Звёздное небо — CustomPainter',
    builder: (_) => const Lab09Screen(),
  ),
  LabInfo(
    number: '10',
    title: 'Лабораторная работа №10',
    description: 'Звёздное небо — анимации',
    builder: (_) => const Lab10Screen(),
  ),
  LabInfo(
    number: '11',
    title: 'Лабораторная работа №11',
    description: 'Поиск места на картах',
    builder: (_) => const Lab11Screen(),
  ),
  LabInfo(
    number: '2.1',
    title: 'Лабораторная работа №2.1',
    description: 'Диалоги',
    builder: (_) => const Lab21Screen(),
  ),
  LabInfo(
    number: '2.2',
    title: 'Лабораторная работа №2.2',
    description: 'Виджет рабочего стола (Android)',
    builder: (_) => const Lab22Screen(),
  ),
  LabInfo(
    number: '2.3',
    title: 'Лабораторная работа №2.3',
    description: 'Адаптеры: список товаров',
    builder: (_) => const Lab23Screen(),
  ),
  LabInfo(
    number: '2.4',
    title: 'Лабораторная работа №2.4',
    description: 'Future: фоновая задача',
    builder: (_) => const Lab24Screen(),
  ),
  LabInfo(
    number: '2.5',
    title: 'Лабораторная работа №2.5',
    description: 'Фрагменты (виджеты)',
    builder: (_) => const Lab25Screen(),
  ),
  LabInfo(
    number: '2.6',
    title: 'Лабораторная работа №2.6',
    description: 'Мультимедиа: аудиоплеер',
    builder: (_) => const Lab26Screen(),
  ),
  LabInfo(
    number: '2.7',
    title: 'Лабораторная работа №2.7',
    description: 'Работа с файлами',
    builder: (_) => const Lab27Screen(),
  ),
  LabInfo(
    number: '2.8',
    title: 'Лабораторная работа №2.8',
    description: 'SQLite: CRUD',
    builder: (_) => const Lab28Screen(),
  ),
  LabInfo(
    number: '2.9',
    title: 'Лабораторная работа №2.9',
    description: 'Сервисы: Provider',
    builder: (_) => const Lab29Screen(),
  ),
];
