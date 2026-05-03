import 'dart:math' as math;

import 'package:flutter/material.dart';

class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.strokeWidth = 1.8,
  });

  final List<double> data;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox.shrink();
    return CustomPaint(
      painter: _SparklinePainter(
        data: data,
        color: color,
        strokeWidth: strokeWidth,
      ),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });

  final List<double> data;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double minVal = data.reduce(math.min);
    final double maxVal = data.reduce(math.max);
    final double range = maxVal - minVal;
    if (range == 0 || size.isEmpty) return;

    final List<Offset> pts = List<Offset>.generate(data.length, (int i) {
      final double x = i / (data.length - 1) * size.width;
      final double y = size.height * (1 - (data[i] - minVal) / range);
      return Offset(x, y);
    });

    final Path linePath = _buildSmoothPath(pts);
    final Path fillPath = Path()
      ..moveTo(pts.first.dx, size.height)
      ..addPath(linePath, Offset.zero)
      ..lineTo(pts.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  Path _buildSmoothPath(List<Offset> pts) {
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final double cpX = (pts[i].dx + pts[i + 1].dx) / 2;
      path.cubicTo(cpX, pts[i].dy, cpX, pts[i + 1].dy, pts[i + 1].dx, pts[i + 1].dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color || old.strokeWidth != strokeWidth;
}
