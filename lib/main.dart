import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'labs/lab_2_6/lab_audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Лабораторная 2.6: медиахендлер создаётся один раз при старте
  // приложения (требование audio_service); сбой не мешает запуску
  await initLabAudioHandler();
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
