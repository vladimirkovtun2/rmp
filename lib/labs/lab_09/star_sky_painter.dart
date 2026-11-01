import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class StarSkyPainter extends CustomPainter {
  StarSkyPainter(this.spaceship);

  final ui.Image spaceship;

  @override
  void paint(Canvas canvas, Size size) {
    // Ночное небо — тёмный фон с градиентом
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF030614), Color(0xFF101736), Color(0xFF232047)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Звёзды — окружности разного размера и оттенков
    final random = math.Random(9);
    for (var i = 0; i < 140; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.9,
      );
      final radius = 0.6 + random.nextDouble() * 2.0;
      final warm = random.nextDouble() < 0.25;
      final cool = !warm && random.nextDouble() < 0.25;
      final paint = Paint()
        ..color = (warm
                ? const Color(0xFFFFE9A8)
                : cool
                    ? const Color(0xFFAFC4FF)
                    : Colors.white)
            .withValues(alpha: 0.35 + random.nextDouble() * 0.65);
      if (radius > 1.8) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius);
      }
      canvas.drawCircle(center, radius, paint);
    }

    // Месяц-серп: полный круг минус пересекающийся вырез (BlendMode.dstOut)
    final moonCenter = Offset(size.width * 0.78, size.height * 0.2);
    final moonRadius = size.shortestSide * 0.11;
    final moonPaint = Paint()..color = const Color(0xFFF6E7B8);
    final cutCenter = moonCenter +
        Offset(moonRadius * 0.45, -moonRadius * 0.32);
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(moonCenter, moonRadius, moonPaint)
      ..drawCircle(
        cutCenter,
        moonRadius * 0.92,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = Colors.black,
      )
      ..restore();

    // Космический корабль — изображение из assets, слегка наклонён
    final shipHeight = size.height * 0.34;
    final shipWidth = shipHeight * spaceship.width / spaceship.height;
    canvas
      ..save()
      ..translate(size.width * 0.5, size.height * 0.72)
      ..rotate(-0.22)
      ..drawImageRect(
        spaceship,
        Rect.fromLTWH(
          0,
          0,
          spaceship.width.toDouble(),
          spaceship.height.toDouble(),
        ),
        Rect.fromCenter(
          center: Offset.zero,
          width: shipWidth,
          height: shipHeight,
        ),
        Paint(),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant StarSkyPainter oldDelegate) =>
      oldDelegate.spaceship != spaceship;
}
