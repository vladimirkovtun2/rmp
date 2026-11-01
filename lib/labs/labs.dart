import 'package:flutter/material.dart';

import 'lab_09/lab_09_screen.dart';
import 'lab_10/lab_10_screen.dart';
import 'lab_11/lab_11_screen.dart';

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
];
