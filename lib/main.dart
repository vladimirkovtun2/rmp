import 'package:flutter/material.dart';

import 'home/home_screen.dart';

void main() {
  runApp(const LabsApp());
}

class LabsApp extends StatelessWidget {
  const LabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторные работы',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
