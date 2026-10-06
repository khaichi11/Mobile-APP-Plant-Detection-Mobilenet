import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A plant with roots, stem, leaves, a flower and a fruit, used by the
/// Build a Plant game. Part positions are given as fractions of the size.
class PlantDiagramPainter extends CustomPainter {
  const PlantDiagramPainter();

  static const groundLevel = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ground = h * groundLevel;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0, 0, w, ground),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFFE5F3FA),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, ground - 20, w, ground),
      Paint()..color = const Color(0xFFE5F3FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(0, ground, w, h),
        bottomLeft: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
      ),
      Paint()..color = const Color(0xFF9C6B47),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, ground - 3, w, ground + 8),
      Paint()..color = const Color(0xFF7DBB6E),
    );

    final cx = w * 0.5;
    final stem =
        Paint()
          ..color = const Color(0xFF4F9A5A)
          ..strokeWidth = w * 0.035
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    // Roots.
    final root =
        Paint()
          ..color = const Color(0xFFF1E3C8)
          ..strokeWidth = w * 0.014
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    final rootDepth = h - ground;
    canvas.drawLine(
      Offset(cx, ground),
      Offset(cx, ground + rootDepth * 0.82),
      root,
    );
    for (var i = 0; i < 3; i++) {
      final y = ground + rootDepth * (0.18 + i * 0.22);
      final spread = w * (0.2 - i * 0.04);
      canvas.drawPath(
        Path()
          ..moveTo(cx, y)
          ..quadraticBezierTo(
            cx - spread * 0.5,
            y + 4,
            cx - spread,
            y + rootDepth * 0.16,
          ),
        root,
      );
      canvas.drawPath(
        Path()
          ..moveTo(cx, y)
          ..quadraticBezierTo(
            cx + spread * 0.5,
            y + 4,
            cx + spread,
            y + rootDepth * 0.16,
          ),
        root,
      );
    }

    // Stem.
    final top = h * 0.16;
    canvas.drawPath(
      Path()
        ..moveTo(cx, ground)
        ..quadraticBezierTo(cx - w * 0.04, (ground + top) / 2, cx, top),
      stem,
    );
    // Side branch with fruit.
    final branchEnd = Offset(w * 0.72, h * 0.34);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 2, h * 0.44)
        ..quadraticBezierTo(w * 0.62, h * 0.42, branchEnd.dx, branchEnd.dy),
      stem..strokeWidth = w * 0.02,
    );
    canvas.drawCircle(
      branchEnd + Offset(0, w * 0.06),
      w * 0.065,
      Paint()..color = const Color(0xFFD0573F),
    );
    canvas.drawCircle(
      branchEnd + Offset(-w * 0.02, w * 0.04),
      w * 0.015,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    // Leaves.
    _leaf(
      canvas,
      Offset(cx - 2, h * 0.5),
      w * 0.26,
      math.pi + 0.45,
      const Color(0xFF66B06B),
    );
    _leaf(
      canvas,
      Offset(cx - 2, h * 0.6),
      w * 0.2,
      -0.35,
      const Color(0xFF3F8A4E),
    );

    // Flower.
    final flower = Offset(cx, top);
    final petal = Paint()..color = const Color(0xFFF07C6B);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      canvas.drawCircle(
        flower + Offset(math.cos(angle), math.sin(angle)) * w * 0.06,
        w * 0.045,
        petal,
      );
    }
    canvas.drawCircle(
      flower,
      w * 0.04,
      Paint()..color = const Color(0xFFF7C948),
    );
  }

  void _leaf(
    Canvas canvas,
    Offset origin,
    double length,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.5, -length * 0.4, length, 0)
        ..quadraticBezierTo(length * 0.5, length * 0.4, 0, 0)
        ..close(),
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(PlantDiagramPainter oldDelegate) => false;
}
