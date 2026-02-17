import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Circular progress ring for sleep quality score (0–100).
class SleepScoreRing extends StatelessWidget {
  const SleepScoreRing({
    super.key,
    required this.score,
    this.size = 160,
    this.strokeWidth = 12,
    this.animate = true,
  });

  final int? score;
  final double size;
  final double strokeWidth;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final value = score != null ? (score!.clamp(0, 100) / 100) : 0.0;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: animate ? const Duration(milliseconds: 1200) : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              backgroundColor: AppColors.chartGrid,
              progressColor: _scoreColor(value),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score != null ? score.toString() : '--',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    'Sleep Score',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _scoreColor(double value) {
    if (value >= 0.8) return AppColors.success;
    if (value >= 0.6) return AppColors.accent;
    if (value >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
