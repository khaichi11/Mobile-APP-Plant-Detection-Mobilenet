import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'logo_shapes.dart';

/// The Pandai mark by Team Terang Bulan: a sprout with a round head.
class PandaiLogo extends StatelessWidget {
  const PandaiLogo({super.key, this.size = 56, this.monochrome});

  final double size;

  /// Draws the whole mark in one color, for use on colored backgrounds.
  final Color? monochrome;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pandai logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: LogoPainter(monochrome: monochrome)),
      ),
    );
  }
}

/// The mark with the PANDAI name and tagline underneath.
class PandaiWordmark extends StatelessWidget {
  const PandaiWordmark({
    super.key,
    this.markSize = 96,
    this.showTagline = true,
  });

  final double markSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PandaiLogo(size: markSize),
        SizedBox(height: markSize * 0.12),
        Text(
          'PANDAI',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: markSize * 0.36,
            height: 1,
            letterSpacing: markSize * 0.01,
            color: AppColors.brandEmerald,
          ),
        ),
        if (showTagline) ...[
          SizedBox(height: markSize * 0.06),
          Text(
            'PLANT IDENTIFICATION WITH\nARTIFICIAL INTELLIGENCE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: (markSize * 0.11).clamp(10.0, 15.0),
              height: 1.2,
              color: AppColors.brandDeep,
            ),
          ),
        ],
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  LogoPainter({this.monochrome});

  final Color? monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s);

    final emerald = Paint()..color = monochrome ?? AppColors.brandEmerald;
    final deep = Paint()..color = monochrome ?? AppColors.brandDeep;
    const c = LogoShapes.circleCenter;

    // Ring, open on both sides.
    final ring = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(Rect.fromCircle(center: c, radius: LogoShapes.ringOuter))
        ..addOval(Rect.fromCircle(center: c, radius: LogoShapes.ringInner))
        ..fillType = PathFillType.evenOdd,
      Path()..addRect(
        Rect.fromLTRB(
          -1,
          c.dy - LogoShapes.gapAbove,
          2,
          c.dy + LogoShapes.gapBelow,
        ),
      ),
    );
    canvas.drawPath(ring, deep);
    canvas.drawCircle(c, LogoShapes.circleRadius, emerald);

    for (final shape in LogoShapes.stems) {
      canvas.drawPath(_shape(shape), deep);
    }
    for (final shape in LogoShapes.leaves) {
      canvas.drawPath(_shape(shape), emerald);
    }
    canvas.restore();
  }

  /// An outline with holes, drawn with smooth curves through the points.
  static Path _shape(List<List<Offset>> parts) {
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final points in parts) {
      if (points.length < 3) continue;
      final start = Offset.lerp(points.last, points.first, 0.5)!;
      path.moveTo(start.dx, start.dy);
      for (var i = 0; i < points.length; i++) {
        final current = points[i];
        final next = points[(i + 1) % points.length];
        final mid = Offset.lerp(current, next, 0.5)!;
        path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) =>
      oldDelegate.monochrome != monochrome;
}
