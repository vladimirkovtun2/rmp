import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class StarSkyAnimatedPainter extends CustomPainter {
  StarSkyAnimatedPainter({
    required this.spaceship,
    required this.cuckoo,
    required this.spaceValue,
    required this.cuckooValue,
  });

  final ui.Image spaceship;
  final ui.Image cuckoo;

  /// Позиция в «космическом» цикле: 0..1 за 60 секунд (повторяется).
  final double spaceValue;

  /// Позиция в цикле появления кукушки: 0..1 (0 — скрыта).
  final double cuckooValue;

  double get _elapsed => spaceValue * 60;

  /// Непрозрачность кукушки: fade in за первую четверть цикла,
  /// fade out за последнюю, между ними полностью видима.
  double get cuckooOpacity {
    final v = cuckooValue;
    if (v <= 0 || v >= 1) return 0;
    const riseEnd = 0.25;
    const fadeStart = 0.75;
    if (v < riseEnd) return v / riseEnd;
    if (v > fadeStart) return 1 - (v - fadeStart) / (1 - fadeStart);
    return 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawStars(canvas, size);
    _drawMoon(canvas, size);
    _drawClock(canvas, size);
    _drawCuckoo(canvas, size);
    _drawShip(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF030614), Color(0xFF101736), Color(0xFF232047)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, skyPaint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = math.Random(9);
    for (var i = 0; i < 140; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height * 0.9,
      );
      final radius = 0.6 + random.nextDouble() * 2.0;
      final warm = random.nextDouble() < 0.25;
      final cool = !warm && random.nextDouble() < 0.25;
      // Каждая звезда мерцает со своим числом оборотов за 60 с
      // (период 7.5–60 с) и своей фазой — синхронного мигания нет.
      final turns = 1 + random.nextInt(8);
      final phase = random.nextDouble() * 2 * math.pi;
      final wave = math.sin(2 * math.pi * turns * spaceValue + phase);
      final alpha = 0.2 + 0.55 * (0.5 + 0.5 * wave);
      final paint = Paint()
        ..color = (warm
                ? const Color(0xFFFFE9A8)
                : cool
                    ? const Color(0xFFAFC4FF)
                    : Colors.white)
            .withValues(alpha: alpha);
      if (radius > 1.8) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, radius);
      }
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawMoon(Canvas canvas, Size size) {
    // Фазы: вырезающий круг ездит через диск, цикл 12 с (5 циклов за 60 с,
    // стык у 0/60 с непрерывен). Крайние положения = полная луна,
    // центральное = новолуние.
    final moonCenter = Offset(size.width * 0.78, size.height * 0.2);
    final moonRadius = size.shortestSide * 0.11;
    final phase = math.cos(2 * math.pi * _elapsed / 12);
    final cutCenter = moonCenter + Offset(phase * moonRadius * 2.2, 0);
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(
        moonCenter,
        moonRadius,
        Paint()..color = const Color(0xFFF6E7B8),
      )
      ..drawCircle(
        cutCenter,
        moonRadius * 1.02,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = Colors.black,
      )
      ..restore();
  }

  void _drawClock(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.3);
    final r = size.shortestSide * 0.15;

    // Тень
    canvas.drawCircle(
      center + Offset(r * 0.06, r * 0.09),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );

    // Циферблат и ободок
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF1A2038));
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0xFFF6E7B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );

    // Засечки
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final cardinal = i % 3 == 0;
      final tickLen = cardinal ? r * 0.16 : r * 0.09;
      tickPaint
        ..color = const Color(0xFFF6E7B8)
        ..strokeWidth = cardinal ? r * 0.035 : r * 0.02;
      final dir = Offset(math.sin(i * math.pi / 6), -math.cos(i * math.pi / 6));
      canvas.drawLine(
        center + dir * (r * 0.82),
        center + dir * (r * 0.82 - tickLen),
        tickPaint,
      );
    }

    // Стрелки: pivot — центр циферблата.
    // Минутная — полный оборот за 60 с, часовая в 12 раз медленнее.
    _drawHand(canvas, center, 2 * math.pi * spaceValue, r * 0.78, r * 0.045,
        Colors.white);
    _drawHand(canvas, center, 2 * math.pi * spaceValue / 12, r * 0.55,
        r * 0.075, const Color(0xFFF6E7B8));

    // Ось
    canvas.drawCircle(center, r * 0.06, Paint()..color = const Color(0xFFF6E7B8));
  }

  void _drawHand(Canvas canvas, Offset center, double angle, double length,
      double width, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..drawLine(Offset(0, width * 1.5), Offset(0, -length), paint)
      ..restore();
  }

  void _drawCuckoo(Canvas canvas, Size size) {
    final opacity = cuckooOpacity;
    if (opacity <= 0) return;

    final clockCenter = Offset(size.width * 0.5, size.height * 0.3);
    final r = size.shortestSide * 0.15;
    final birdHeight = r * 0.9;
    final birdWidth = birdHeight * cuckoo.width / cuckoo.height;
    // Кукушка поднимается из-за верхней кромки часов, пока проявляется
    final rise = (1 - opacity) * birdHeight * 0.5;
    final birdCenter = clockCenter - Offset(0, r + birdHeight * 0.35 + rise);
    final birdRect = Rect.fromCenter(
      center: birdCenter,
      width: birdWidth,
      height: birdHeight,
    );

    // Прозрачность — через saveLayer: слой накладывается с нужной альфой
    canvas
      ..saveLayer(
        birdRect,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      )
      ..drawImageRect(
        cuckoo,
        Rect.fromLTWH(0, 0, cuckoo.width.toDouble(), cuckoo.height.toDouble()),
        birdRect,
        Paint(),
      )
      ..restore();
  }

  void _drawShip(Canvas canvas, Size size) {
    // Движение слева направо по синусоиде, полный проход 20 с
    // (3 прохода за 60 с — стык непрерывен). Нос повёрнут по курсу.
    final shipHeight = size.height * 0.22;
    final shipWidth = shipHeight * spaceship.width / spaceship.height;
    final margin = shipWidth;
    final track = size.width + 2 * margin;
    final t = (_elapsed % 20) / 20;
    final x = -margin + track * t;
    final baseY = size.height * 0.72;
    final amplitude = size.height * 0.06;
    final y = baseY + amplitude * math.sin(2 * math.pi * 3 * t);
    final slope = amplitude * 2 * math.pi * 3 / track * math.cos(2 * math.pi * 3 * t);
    final angle = math.pi / 2 + math.atan(slope);

    canvas
      ..save()
      ..translate(x, y)
      ..rotate(angle)
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
  bool shouldRepaint(covariant StarSkyAnimatedPainter oldDelegate) =>
      oldDelegate.spaceship != spaceship ||
      oldDelegate.cuckoo != cuckoo ||
      oldDelegate.spaceValue != spaceValue ||
      oldDelegate.cuckooValue != cuckooValue;
}
