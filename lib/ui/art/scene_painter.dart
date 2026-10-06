import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../models/story.dart';

/// Flat illustrations for the story, drawn in code. [t] runs from 0 to 1 and
/// loops, for gentle motion such as rain and swaying leaves.
class ScenePainter extends CustomPainter {
  ScenePainter(this.scene, this.t);

  final StoryScene scene;
  final double t;

  static const _skyDay = Color(0xFFCFE9F5);
  static const _skyRain = Color(0xFFB9CBD6);
  static const _grass = Color(0xFF7DBB6E);
  static const _soilTop = Color(0xFF9C6B47);
  static const _soilDeep = Color(0xFF7A5135);
  static const _seed = Color(0xFFE9B949);
  static const _seedShade = Color(0xFFC9932B);
  static const _stem = Color(0xFF4F9A5A);
  static const _leaf = Color(0xFF66B06B);
  static const _leafDark = Color(0xFF3F8A4E);
  static const _water = Color(0xFF5AB3E0);
  static const _petal = Color(0xFFF07C6B);

  double get _wave => math.sin(t * 2 * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    switch (scene) {
      case StoryScene.seedSleeping:
        _ground(canvas, size, rain: false, groundLevel: 0.48);
        _sun(canvas, size, Offset(size.width * 0.82, size.height * 0.16));
        _seedCharacter(canvas, size, Offset(0.5, 0.74), mood: _Mood.sleepy);
      case StoryScene.seedRain:
        _ground(canvas, size, rain: true, groundLevel: 0.48);
        _cloud(
          canvas,
          Offset(size.width * 0.3, size.height * 0.14),
          size.width * 0.2,
        );
        _cloud(
          canvas,
          Offset(size.width * 0.72, size.height * 0.1),
          size.width * 0.16,
        );
        _rain(canvas, size, bottom: size.height * 0.48);
        _soakDots(canvas, size);
        _seedCharacter(canvas, size, Offset(0.5, 0.74), mood: _Mood.happy);
      case StoryScene.seedSprouting:
        _ground(canvas, size, rain: false, groundLevel: 0.55);
        _sun(canvas, size, Offset(size.width * 0.84, size.height * 0.16));
        _roots(
          canvas,
          size,
          Offset(size.width * 0.5, size.height * 0.75),
          0.55,
        );
        _sprout(
          canvas,
          size,
          base: Offset(size.width * 0.5, size.height * 0.72),
          height: size.height * 0.4,
        );
        _seedCharacter(
          canvas,
          size,
          Offset(0.5, 0.76),
          mood: _Mood.happy,
          scale: 0.8,
        );
      case StoryScene.rootsDrinking:
        _ground(canvas, size, rain: false, groundLevel: 0.36);
        _sun(canvas, size, Offset(size.width * 0.86, size.height * 0.12));
        _sprout(
          canvas,
          size,
          base: Offset(size.width * 0.5, size.height * 0.4),
          height: size.height * 0.28,
          leaves: 3,
        );
        _roots(canvas, size, Offset(size.width * 0.5, size.height * 0.4), 1);
        _waterDropsInSoil(canvas, size);
      case StoryScene.stemPipes:
        _ground(canvas, size, rain: false, groundLevel: 0.8);
        _sun(canvas, size, Offset(size.width * 0.86, size.height * 0.14));
        _stemCutaway(canvas, size);
      case StoryScene.leafKitchen:
        _plainSky(canvas, size, _skyDay);
        _sun(canvas, size, Offset(size.width * 0.16, size.height * 0.2));
        _bigLeaf(canvas, size);
        _sunRaysToLeaf(canvas, size);
        _bubble(
          canvas,
          Offset(size.width * 0.86, size.height * 0.2),
          'CO2',
          const Color(0xFF8C9AA3),
        );
        _bubble(
          canvas,
          Offset(size.width * 0.84, size.height * 0.78),
          'O2',
          AppColors.sky,
        );
        _drop(
          canvas,
          Offset(size.width * 0.2, size.height * 0.82),
          size.shortestSide * 0.05,
        );
      case StoryScene.flowerBee:
        _ground(canvas, size, rain: false, groundLevel: 0.82, showSoil: false);
        _sun(canvas, size, Offset(size.width * 0.85, size.height * 0.15));
        _flower(
          canvas,
          Offset(size.width * 0.38, size.height * 0.4),
          size.shortestSide * 0.16,
          base: size.height * 0.85,
        );
        _flower(
          canvas,
          Offset(size.width * 0.7, size.height * 0.55),
          size.shortestSide * 0.11,
          base: size.height * 0.85,
          color: const Color(0xFFF2B84B),
        );
        _bee(canvas, size);
      case StoryScene.forest:
        _forest(canvas, size);
      case StoryScene.plantingTree:
        _ground(canvas, size, rain: false, groundLevel: 0.68, showSoil: false);
        _sun(canvas, size, Offset(size.width * 0.82, size.height * 0.17));
        _tree(
          canvas,
          Offset(size.width * 0.14, size.height * 0.7),
          size.height * 0.5,
          _leafDark,
        );
        _mound(canvas, size);
        _sprout(
          canvas,
          size,
          base: Offset(size.width * 0.5, size.height * 0.7),
          height: size.height * 0.26,
          leaves: 3,
        );
        _wateringCan(canvas, size);
    }
  }

  // --- Backgrounds -----------------------------------------------------------

  void _plainSky(Canvas canvas, Size size, Color color) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
  }

  void _ground(
    Canvas canvas,
    Size size, {
    required bool rain,
    required double groundLevel,
    bool showSoil = true,
  }) {
    _plainSky(canvas, size, rain ? _skyRain : _skyDay);
    final top = size.height * groundLevel;
    _hills(canvas, size, top);
    if (!showSoil) {
      canvas.drawRect(
        Rect.fromLTRB(0, top, size.width, size.height),
        Paint()..color = _grass,
      );
      return;
    }
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, size.height),
      Paint()..color = _soilTop,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        0,
        top + (size.height - top) * 0.55,
        size.width,
        size.height,
      ),
      Paint()..color = _soilDeep,
    );
    // Grass strip.
    canvas.drawRect(
      Rect.fromLTRB(0, top - 4, size.width, top + size.height * 0.035),
      Paint()..color = _grass,
    );
    // Little stones.
    final stone = Paint()..color = const Color(0xFFB98A64);
    for (final p in const [
      Offset(0.12, 0.7),
      Offset(0.82, 0.66),
      Offset(0.24, 0.92),
      Offset(0.9, 0.9),
    ]) {
      final y =
          top + (size.height - top) * (p.dy - groundLevel) / (1 - groundLevel);
      if (y > top + 10) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * p.dx, y),
            width: 16,
            height: 10,
          ),
          stone,
        );
      }
    }
  }

  void _hills(Canvas canvas, Size size, double top) {
    final paint = Paint()..color = const Color(0xFFA9D49A);
    final path =
        Path()
          ..moveTo(0, top)
          ..quadraticBezierTo(
            size.width * 0.2,
            top - size.height * 0.12,
            size.width * 0.45,
            top,
          )
          ..quadraticBezierTo(
            size.width * 0.7,
            top - size.height * 0.16,
            size.width,
            top - 2,
          )
          ..lineTo(size.width, top + 2)
          ..lineTo(0, top + 2)
          ..close();
    canvas.drawPath(path, paint);
  }

  void _sun(Canvas canvas, Size size, Offset center) {
    final r = size.shortestSide * 0.08;
    final rays =
        Paint()
          ..color = const Color(0xFFF7C948)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + t * math.pi / 4;
      final from =
          center + Offset(math.cos(angle), math.sin(angle)) * (r * 1.35);
      final to = center + Offset(math.cos(angle), math.sin(angle)) * (r * 1.75);
      canvas.drawLine(from, to, rays);
    }
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF7C948));
  }

  void _cloud(Canvas canvas, Offset center, double width) {
    final paint = Paint()..color = Colors.white;
    final shift = Offset(_wave * 6, 0);
    final c = center + shift;
    canvas.drawCircle(c + Offset(-width * 0.28, 0), width * 0.22, paint);
    canvas.drawCircle(c + Offset(0, -width * 0.1), width * 0.3, paint);
    canvas.drawCircle(c + Offset(width * 0.3, 0), width * 0.2, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, width * 0.1),
          width: width * 1.1,
          height: width * 0.3,
        ),
        Radius.circular(width * 0.15),
      ),
      paint,
    );
  }

  void _rain(Canvas canvas, Size size, {required double bottom}) {
    final paint =
        Paint()
          ..color = _water
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
    final random = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final x = random.nextDouble() * size.width;
      final start = size.height * 0.2;
      final span = bottom - start;
      final y = start + ((random.nextDouble() + t) % 1) * span;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + 10), paint);
    }
  }

  // --- Seed and sprout -------------------------------------------------------

  void _seedCharacter(
    Canvas canvas,
    Size size,
    Offset relative, {
    required _Mood mood,
    double scale = 1,
  }) {
    final center = Offset(size.width * relative.dx, size.height * relative.dy);
    final w = size.shortestSide * 0.26 * scale;
    final h = w * 0.62;
    final body = Rect.fromCenter(center: center, width: w, height: h);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.12 + (mood == _Mood.sleepy ? _wave * 0.03 : 0));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawOval(
      body.shift(const Offset(0, 4)),
      Paint()..color = _seedShade,
    );
    canvas.drawOval(body, Paint()..color = _seed);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-w * 0.18, -h * 0.2),
        width: w * 0.28,
        height: h * 0.16,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    final eyeY = center.dy - h * 0.02;
    final eyePaint =
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    for (final dx in [-w * 0.14, w * 0.14]) {
      final eye = Offset(center.dx + dx, eyeY);
      if (mood == _Mood.sleepy) {
        canvas.drawArc(
          Rect.fromCenter(center: eye, width: w * 0.12, height: w * 0.08),
          0.2,
          math.pi - 0.4,
          false,
          eyePaint,
        );
      } else {
        canvas.drawCircle(eye, w * 0.04, Paint()..color = AppColors.ink);
        canvas.drawCircle(
          eye + Offset(w * 0.012, -w * 0.012),
          w * 0.013,
          Paint()..color = Colors.white,
        );
      }
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, eyeY + h * 0.16),
        width: w * 0.16,
        height: h * 0.14,
      ),
      0.2,
      math.pi - 0.4,
      false,
      eyePaint,
    );
    // Rosy cheeks.
    final cheek =
        Paint()..color = const Color(0xFFF29E7D).withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(center.dx - w * 0.25, eyeY + h * 0.12),
      w * 0.045,
      cheek,
    );
    canvas.drawCircle(
      Offset(center.dx + w * 0.25, eyeY + h * 0.12),
      w * 0.045,
      cheek,
    );
    canvas.restore();

    if (mood == _Mood.sleepy) {
      final style = TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.9),
      );
      _text(
        canvas,
        'z',
        center + Offset(w * 0.55, -h * 0.9 - _wave * 4),
        style.copyWith(fontSize: w * 0.16),
      );
      _text(
        canvas,
        'z',
        center + Offset(w * 0.75, -h * 1.3 - _wave * 4),
        style.copyWith(fontSize: w * 0.22),
      );
    }
  }

  void _soakDots(Canvas canvas, Size size) {
    final paint = Paint()..color = _water.withValues(alpha: 0.7);
    final random = math.Random(3);
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.3 + random.nextDouble() * 0.4);
      final baseY = size.height * (0.52 + random.nextDouble() * 0.12);
      final y = baseY + ((t + random.nextDouble()) % 1) * size.height * 0.08;
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  void _roots(Canvas canvas, Size size, Offset top, double length) {
    final paint =
        Paint()
          ..color = const Color(0xFFF1E3C8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final depth = size.height * 0.5 * length;
    final main =
        Path()
          ..moveTo(top.dx, top.dy)
          ..cubicTo(
            top.dx - 8,
            top.dy + depth * 0.3,
            top.dx + 10,
            top.dy + depth * 0.6,
            top.dx,
            top.dy + depth,
          );
    canvas.drawPath(main, paint);
    paint.strokeWidth = 2;
    for (var i = 1; i <= 4; i++) {
      final y = top.dy + depth * i / 5;
      final side = i.isEven ? 1 : -1;
      final branch =
          Path()
            ..moveTo(top.dx, y)
            ..quadraticBezierTo(
              top.dx + side * 20 * length,
              y + 6,
              top.dx + side * 38 * length,
              y + 18 * length,
            );
      canvas.drawPath(branch, paint);
    }
  }

  void _sprout(
    Canvas canvas,
    Size size, {
    required Offset base,
    required double height,
    int leaves = 2,
  }) {
    final sway = _wave * 4;
    final tip = Offset(base.dx + sway, base.dy - height);
    final stem =
        Paint()
          ..color = _stem
          ..strokeWidth = math.max(3, size.shortestSide * 0.018)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx - 6,
          base.dy - height * 0.5,
          tip.dx,
          tip.dy,
        ),
      stem,
    );
    final leafSize = size.shortestSide * 0.12;
    _leafShape(canvas, tip, leafSize, -0.6, _leaf);
    _leafShape(canvas, tip, leafSize, math.pi + 0.6, _leafDark);
    if (leaves > 2) {
      final mid = Offset(base.dx - 3 + sway * 0.5, base.dy - height * 0.5);
      _leafShape(canvas, mid, leafSize * 0.8, -0.3, _leaf);
    }
  }

  /// A leaf that starts at [origin] and points in [angle] (radians).
  void _leafShape(
    Canvas canvas,
    Offset origin,
    double length,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path =
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(length * 0.5, -length * 0.42, length, 0)
          ..quadraticBezierTo(length * 0.5, length * 0.42, 0, 0)
          ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawLine(
      Offset.zero,
      Offset(length * 0.85, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  void _waterDropsInSoil(Canvas canvas, Size size) {
    final random = math.Random(11);
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.2 + random.nextDouble() * 0.6);
      final y = size.height * (0.55 + random.nextDouble() * 0.35);
      final pull = ((t + i / 7) % 1);
      final towardRoot =
          Offset.lerp(
            Offset(x, y),
            Offset(size.width * 0.5, y - 10),
            pull * 0.6,
          )!;
      _drop(canvas, towardRoot, size.shortestSide * 0.022);
    }
  }

  void _drop(Canvas canvas, Offset center, double r) {
    final path =
        Path()
          ..moveTo(center.dx, center.dy - r * 1.8)
          ..quadraticBezierTo(
            center.dx + r * 1.2,
            center.dy - r * 0.2,
            center.dx,
            center.dy + r,
          )
          ..quadraticBezierTo(
            center.dx - r * 1.2,
            center.dy - r * 0.2,
            center.dx,
            center.dy - r * 1.8,
          )
          ..close();
    canvas.drawPath(path, Paint()..color = _water);
  }

  void _stemCutaway(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final top = size.height * 0.18;
    final bottom = size.height * 0.86;
    final w = size.shortestSide * 0.16;
    final tube = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - w / 2, top, cx + w / 2, bottom),
      Radius.circular(w / 2),
    );
    canvas.drawRRect(tube, Paint()..color = _stem);
    canvas.drawRRect(
      tube.deflate(w * 0.14),
      Paint()..color = const Color(0xFFDFF0D8),
    );
    // Two pipes with water moving up.
    for (final dx in [-w * 0.16, w * 0.16]) {
      final x = cx + dx;
      canvas.drawLine(
        Offset(x, top + w * 0.3),
        Offset(x, bottom - w * 0.2),
        Paint()
          ..color = _water.withValues(alpha: 0.35)
          ..strokeWidth = w * 0.14
          ..strokeCap = StrokeCap.round,
      );
      for (var i = 0; i < 6; i++) {
        final progress = 1 - ((t + i / 6) % 1);
        final y = top + w * 0.3 + (bottom - top - w * 0.5) * progress;
        canvas.drawCircle(Offset(x, y), w * 0.07, Paint()..color = _water);
      }
    }
    _leafShape(
      canvas,
      Offset(cx - w / 2, top + size.height * 0.12),
      size.shortestSide * 0.24,
      math.pi + 0.5,
      _leafDark,
    );
    _leafShape(
      canvas,
      Offset(cx + w / 2, top + size.height * 0.2),
      size.shortestSide * 0.24,
      -0.5,
      _leaf,
    );
    // Arrow pointing up.
    final arrow =
        Paint()
          ..color = AppColors.forestDark
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final ax = cx + w * 1.4;
    canvas.drawLine(Offset(ax, bottom - 20), Offset(ax, top + 40), arrow);
    canvas.drawPath(
      Path()
        ..moveTo(ax - 9, top + 52)
        ..lineTo(ax, top + 40)
        ..lineTo(ax + 9, top + 52),
      arrow,
    );
  }

  void _bigLeaf(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.55);
    final length = size.shortestSide * 0.7;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.5 + _wave * 0.03);
    final path =
        Path()
          ..moveTo(-length / 2, 0)
          ..quadraticBezierTo(0, -length * 0.45, length / 2, 0)
          ..quadraticBezierTo(0, length * 0.45, -length / 2, 0)
          ..close();
    canvas.drawPath(path, Paint()..color = _leaf);
    final vein =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-length / 2, 0), Offset(length * 0.45, 0), vein);
    vein.strokeWidth = 2;
    for (var i = 1; i < 5; i++) {
      final x = -length / 2 + length * i / 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + length * 0.1, -length * 0.13),
        vein,
      );
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + length * 0.1, length * 0.13),
        vein,
      );
    }
    // Stalk.
    canvas.drawLine(
      Offset(-length / 2, 0),
      Offset(-length * 0.68, length * 0.06),
      Paint()
        ..color = _stem
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _sunRaysToLeaf(Canvas canvas, Size size) {
    final from = Offset(size.width * 0.16, size.height * 0.2);
    final paint =
        Paint()
          ..color = const Color(0xFFF7C948).withValues(alpha: 0.85)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final target = Offset(
        size.width * (0.38 + i * 0.1),
        size.height * (0.46 + i * 0.04),
      );
      final direction = target - from;
      final start = from + direction * 0.3;
      final dashT = (t + i * 0.2) % 1;
      final a = start + (target - start) * (dashT * 0.7);
      final b = start + (target - start) * (dashT * 0.7 + 0.3);
      canvas.drawLine(a, b, paint);
    }
  }

  void _bubble(Canvas canvas, Offset center, String label, Color color) {
    final bob = Offset(0, _wave * 4);
    canvas.drawCircle(
      center + bob,
      24,
      Paint()..color = color.withValues(alpha: 0.25),
    );
    canvas.drawCircle(
      center + bob,
      24,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _text(
      canvas,
      label,
      center + bob,
      const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }

  // --- Flowers, bees, trees --------------------------------------------------

  void _flower(
    Canvas canvas,
    Offset center,
    double r, {
    required double base,
    Color color = _petal,
  }) {
    final stem =
        Paint()
          ..color = _stem
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, base), stem);
    _leafShape(
      canvas,
      Offset(center.dx, base - (base - center.dy) * 0.35),
      r * 1.2,
      -0.5,
      _leaf,
    );
    _leafShape(
      canvas,
      Offset(center.dx, base - (base - center.dy) * 0.55),
      r,
      math.pi + 0.5,
      _leafDark,
    );
    final petal = Paint()..color = color;
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + _wave * 0.05;
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * r * 0.62,
        r * 0.48,
        petal,
      );
    }
    canvas.drawCircle(
      center,
      r * 0.42,
      Paint()..color = const Color(0xFFF7C948),
    );
    canvas.drawCircle(
      center,
      r * 0.42,
      Paint()
        ..color = const Color(0xFFE0A52E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _bee(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final center = Offset(
      size.width * 0.55 + math.cos(angle) * size.width * 0.16,
      size.height * 0.28 + math.sin(angle * 2) * size.height * 0.06,
    );
    final r = size.shortestSide * 0.05;
    // Dotted flight trail.
    final trail = Paint()..color = AppColors.ink.withValues(alpha: 0.25);
    for (var i = 1; i <= 6; i++) {
      final a = angle - i * 0.25;
      canvas.drawCircle(
        Offset(
          size.width * 0.55 + math.cos(a) * size.width * 0.16,
          size.height * 0.28 + math.sin(a * 2) * size.height * 0.06,
        ),
        2,
        trail,
      );
    }
    final wing = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(-r * 0.3, -r * 0.9),
        width: r * 1.1,
        height: r * 0.8,
      ),
      wing,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(r * 0.4, -r * 0.9),
        width: r * 1.1,
        height: r * 0.8,
      ),
      wing,
    );
    final body = Rect.fromCenter(
      center: center,
      width: r * 2.2,
      height: r * 1.5,
    );
    canvas.drawOval(body, Paint()..color = const Color(0xFFF7C948));
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    final stripe = Paint()..color = AppColors.ink;
    for (final dx in [-0.3, 0.25]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: center + Offset(r * dx, 0),
          width: r * 0.3,
          height: r * 2,
        ),
        stripe,
      );
    }
    canvas.restore();
    canvas.drawCircle(
      center + Offset(r * 0.75, -r * 0.15),
      r * 0.12,
      Paint()..color = AppColors.ink,
    );
  }

  void _tree(Canvas canvas, Offset base, double height, Color color) {
    final trunk = Paint()..color = const Color(0xFF8A5A3B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          base.dx - height * 0.05,
          base.dy - height * 0.45,
          height * 0.1,
          height * 0.45,
        ),
        const Radius.circular(4),
      ),
      trunk,
    );
    final crown = Paint()..color = color;
    final sway = _wave * height * 0.01;
    canvas.drawCircle(
      Offset(base.dx + sway, base.dy - height * 0.65),
      height * 0.28,
      crown,
    );
    canvas.drawCircle(
      Offset(base.dx - height * 0.18 + sway, base.dy - height * 0.5),
      height * 0.2,
      crown,
    );
    canvas.drawCircle(
      Offset(base.dx + height * 0.18 + sway, base.dy - height * 0.5),
      height * 0.2,
      crown,
    );
  }

  void _forest(Canvas canvas, Size size) {
    _plainSky(canvas, size, _skyDay);
    _sun(canvas, size, Offset(size.width * 0.8, size.height * 0.18));
    final hill = Paint()..color = const Color(0xFFA9D49A);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.62)
        ..quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.42,
          size.width * 0.6,
          size.height * 0.6,
        )
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.48,
          size.width,
          size.height * 0.58,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      hill,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.8, size.width, size.height),
      Paint()..color = _grass,
    );
    const colors = [Color(0xFF3F8A4E), Color(0xFF5FA36A), Color(0xFF2E6B57)];
    for (var i = 0; i < 7; i++) {
      final x = size.width * (0.06 + i * 0.145);
      final h = size.height * (0.42 + (i % 3) * 0.08);
      _tree(
        canvas,
        Offset(x, size.height * (0.84 + (i % 2) * 0.05)),
        h,
        colors[i % 3],
      );
    }
    final bird =
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.7)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.22 + i * 0.1 + t * 0.1);
      final y = size.height * (0.16 + (i % 2) * 0.05);
      final flap = _wave * 3;
      canvas.drawPath(
        Path()
          ..moveTo(x - 8, y - flap)
          ..quadraticBezierTo(x - 4, y - 5, x, y)
          ..quadraticBezierTo(x + 4, y - 5, x + 8, y - flap),
        bird,
      );
    }
  }

  void _mound(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.72),
        width: size.width * 0.34,
        height: size.height * 0.12,
      ),
      Paint()..color = _soilTop,
    );
  }

  void _wateringCan(Canvas canvas, Size size) {
    final s = size.shortestSide * 0.0022;
    final origin = Offset(size.width * 0.66, size.height * 0.2);
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(0.35 + _wave * 0.04);
    canvas.scale(s);
    final body = Paint()..color = const Color(0xFF5AA9C9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 70, 52),
        const Radius.circular(10),
      ),
      body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, 18)
        ..lineTo(-46, 4)
        ..lineTo(-46, 12)
        ..lineTo(0, 30)
        ..close(),
      body,
    );
    canvas.drawArc(
      const Rect.fromLTWH(14, -26, 44, 52),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF3F88A6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    canvas.restore();
    // Water stream.
    final spout = origin + Offset(-40 * s, 40 * s);
    for (var i = 0; i < 6; i++) {
      final progress = (t + i / 6) % 1;
      final p = Offset(
        spout.dx - progress * size.width * 0.05,
        spout.dy + progress * size.height * 0.32,
      );
      _drop(canvas, p, size.shortestSide * 0.012);
    }
  }

  void _text(Canvas canvas, String text, Offset center, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(ScenePainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.t != t;
}

enum _Mood { sleepy, happy }
