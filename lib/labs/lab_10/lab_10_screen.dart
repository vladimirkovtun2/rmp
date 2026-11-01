import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'star_sky_animated_painter.dart';

class Lab10Screen extends StatefulWidget {
  const Lab10Screen({super.key});

  @override
  State<Lab10Screen> createState() => _Lab10ScreenState();
}

class _Lab10ScreenState extends State<Lab10Screen>
    with TickerProviderStateMixin {
  late final AnimationController _space;
  late final AnimationController _cuckoo;
  ui.Image? _spaceship;
  ui.Image? _cuckooImage;
  double _prevSpaceValue = 0;

  @override
  void initState() {
    super.initState();
    _space = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _cuckoo = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    // Часовая стрелка проходит «12» (начало часа) — выпускаем кукушку
    _space.addListener(_watchHourHand);
    _loadImages();
  }

  void _watchHourHand() {
    if (_space.value < _prevSpaceValue) {
      _cuckoo.forward(from: 0);
    }
    _prevSpaceValue = _space.value;
  }

  Future<void> _loadImages() async {
    Future<ui.Image> load(String path) async {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      return (await codec.getNextFrame()).image;
    }

    final images = await Future.wait([
      load('assets/images/spaceship2.png'),
      load('assets/images/cuckoo.png'),
    ]);
    if (mounted) {
      setState(() {
        _spaceship = images[0];
        _cuckooImage = images[1];
      });
    }
  }

  @override
  void dispose() {
    _space
      ..removeListener(_watchHourHand)
      ..dispose();
    _cuckoo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaceship = _spaceship;
    final cuckooImage = _cuckooImage;
    return Scaffold(
      appBar: AppBar(title: const Text('Лабораторная работа №10')),
      body: spaceship == null || cuckooImage == null
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: Listenable.merge([_space, _cuckoo]),
              builder: (context, _) => CustomPaint(
                painter: StarSkyAnimatedPainter(
                  spaceship: spaceship,
                  cuckoo: cuckooImage,
                  spaceValue: _space.value,
                  cuckooValue: _cuckoo.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
    );
  }
}
