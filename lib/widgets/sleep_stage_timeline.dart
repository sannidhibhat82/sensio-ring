import 'package:flutter/material.dart';
import '../domain/entities/sleep_data.dart';
import '../themes/app_colors.dart';
import '../themes/app_theme.dart';

/// Horizontal timeline of sleep stages (Wake, REM, Light, Deep).
class SleepStageTimeline extends StatelessWidget {
  const SleepStageTimeline({
    super.key,
    required this.segments,
    this.startTime,
    this.endTime,
    this.height = 32,
  });

  final List<SleepStageSegment> segments;
  final DateTime? startTime;
  final DateTime? endTime;
  final double height;

  static Color stageColor(SleepStage stage) {
    switch (stage) {
      case SleepStage.wake:
        return AppColors.sleepWake;
      case SleepStage.rem:
        return AppColors.sleepRem;
      case SleepStage.light:
        return AppColors.sleepLight;
      case SleepStage.deep:
        return AppColors.sleepDeep;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        ),
        child: Center(
          child: Text(
            'No sleep stage data',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ),
      );
    }

    final start = startTime ?? segments.first.start;
    final end = endTime ?? segments.last.end;
    final totalMs = end.difference(start).inMilliseconds.toDouble();
    if (totalMs <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendItem(SleepStage.wake),
            _LegendItem(SleepStage.rem),
            _LegendItem(SleepStage.light),
            _LegendItem(SleepStage.deep),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          child: SizedBox(
            height: height,
            child: Row(
              children: segments.map((seg) {
                final durationMs =
                    seg.end.difference(seg.start).inMilliseconds;
                final flex = durationMs > 0 ? durationMs : 1;
                return Expanded(
                  flex: flex,
                  child: Container(
                    color: stageColor(seg.stage),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(start),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            Text(
              _formatTime(end),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.stage);

  final SleepStage stage;

  @override
  Widget build(BuildContext context) {
    final color = SleepStageTimeline.stageColor(stage);
    final label = switch (stage) {
      SleepStage.wake => 'Wake',
      SleepStage.rem => 'REM',
      SleepStage.light => 'Light',
      SleepStage.deep => 'Deep',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

