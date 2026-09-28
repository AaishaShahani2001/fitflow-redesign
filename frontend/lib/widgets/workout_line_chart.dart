import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/progress_data.dart';

/// Lightweight line chart drawn with [CustomPainter] — no chart package.
class WorkoutLineChart extends StatelessWidget {
  const WorkoutLineChart({super.key, required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.85,
          child: Semantics(
            label: 'Workouts chart',
            value: points.map((p) => '${p.label} ${p.value.round()}').join(', '),
            child: CustomPaint(
              painter: _WorkoutLineChartPainter(
                values: [for (final point in points) point.value],
                lineColor: AppColors.primary,
                gridColor: AppColors.border,
                dotColor: AppColors.progressAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final point in points)
              Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WorkoutLineChartPainter extends CustomPainter {
  _WorkoutLineChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.dotColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color dotColor;

  static const int _gridLines = 4;
  static const double _inset = 8;
  static const double _dotRadius = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final chart = Rect.fromLTWH(
      _inset,
      _inset,
      math.max(0, size.width - _inset * 2),
      math.max(0, size.height - _inset * 2),
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= _gridLines; i++) {
      final y = chart.top + chart.height * i / _gridLines;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    final maxValue = values.reduce(math.max).clamp(1, double.infinity);
    Offset pointFor(int index) {
      final t = values.length == 1 ? 0.5 : index / (values.length - 1);
      final x = chart.left + chart.width * t;
      final y = chart.bottom - (values[index] / maxValue) * chart.height;
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointFor(0).dx, pointFor(0).dy);
    for (var i = 1; i < values.length; i++) {
      final point = pointFor(i);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final fill = Paint()..color = dotColor;
    final outline = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < values.length; i++) {
      final point = pointFor(i);
      canvas.drawCircle(point, _dotRadius, fill);
      canvas.drawCircle(point, _dotRadius, outline);
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.dotColor != dotColor;
  }
}
