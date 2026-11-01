import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'star_sky_painter.dart';

class Lab09Screen extends StatefulWidget {
  const Lab09Screen({super.key});

  @override
  State<Lab09Screen> createState() => _Lab09ScreenState();
}

class _Lab09ScreenState extends State<Lab09Screen> {
  ui.Image? _spaceship;

  @override
  void initState() {
    super.initState();
    _loadSpaceship();
  }

  Future<void> _loadSpaceship() async {
    final data = await rootBundle.load('assets/images/spaceship.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() => _spaceship = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _spaceship;
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №9')),
      body: image == null
          ? const Center(child: CircularProgressIndicator())
          : CustomPaint(
              painter: StarSkyPainter(image),
              child: const SizedBox.expand(),
            ),
    );
  }
}
