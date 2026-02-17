import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../domain/entities/realtime_metrics.dart';
import '../themes/app_colors.dart';

/// Bar chart for activity / steps over time.
class MetricBarChart extends StatelessWidget {
  const MetricBarChart({
    super.key,
    required this.points,
    this.yMax,
    this.xLabelFormat,
    this.barColor = AppColors.accent,
    this.height = 200,
  });

  final List<TimeSeriesPoint<int>> points;
  final double? yMax;
  final String Function(DateTime)? xLabelFormat;
  final Color barColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data yet',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    final maxVal = yMax ??
        points.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final yCeil = (maxVal * 1.1).clamp(10.0, double.infinity);

    final barGroups = points.asMap().entries.map((e) {
      final i = e.key;
      final p = e.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: p.value.toDouble(),
            color: barColor,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: yCeil,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yCeil / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.chartGrid,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: yCeil / 4,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (points.length / 4).clamp(1, points.length).toDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt().clamp(0, points.length - 1);
                  if (idx >= points.length) return const SizedBox();
                  final dt = points[idx].time;
                  final label = xLabelFormat != null
                      ? xLabelFormat!(dt)
                      : '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  return Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surfaceElevated,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final p = points[group.x];
                return BarTooltipItem(
                  '${p.time.hour.toString().padLeft(2, '0')}:${p.time.minute.toString().padLeft(2, '0')}\n${rod.toY.toDouble().toInt()}',
                  const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
