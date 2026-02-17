import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

/// Time-series line chart for HR or Temperature.
/// Pass points with numeric values (int or double).
class MetricLineChart extends StatelessWidget {
  const MetricLineChart({
    super.key,
    required this.points,
    this.yMin,
    this.yMax,
    this.yLabelFormat,
    this.xLabelFormat,
    this.lineColor = AppColors.chartLine,
    this.showFill = true,
    this.height = 200,
  });

  /// Points: use metric.tempHistory or convert hrHistory to double, e.g. hrHistory.map((p) => (p.time, p.value.toDouble()))
  final List<(DateTime time, double value)> points;
  final double? yMin;
  final double? yMax;
  final String Function(num)? yLabelFormat;
  final String Function(DateTime)? xLabelFormat;
  final Color lineColor;
  final bool showFill;
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

    final values = points.map((e) => e.$2).toList();
    final minVal = yMin ?? (values.reduce((a, b) => a < b ? a : b) - 2);
    final maxVal = yMax ?? (values.reduce((a, b) => a > b ? a : b) + 2);
    final firstTime = points.first.$1.millisecondsSinceEpoch.toDouble();
    final lastTime = points.last.$1.millisecondsSinceEpoch.toDouble();
    final range = lastTime - firstTime;
    final xMin = range > 0 ? firstTime - range * 0.02 : firstTime - 1;
    final xMax = range > 0 ? lastTime + range * 0.02 : lastTime + 1;

    final spots = points
        .map((p) => FlSpot(
              p.$1.millisecondsSinceEpoch.toDouble(),
              p.$2,
            ))
        .toList();

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: lineColor,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: showFill,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.3),
            lineColor.withValues(alpha: 0.0),
          ],
        ),
      ),
    );

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: xMin,
          maxX: xMax,
          minY: minVal,
          maxY: maxVal,
          lineBarsData: [lineBarData],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxVal - minVal) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.chartGrid,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: (maxVal - minVal) / 4,
                getTitlesWidget: (value, meta) {
                  final label = yLabelFormat != null
                      ? yLabelFormat!(value)
                      : value.toStringAsFixed(0);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (xMax - xMin) / 4,
                getTitlesWidget: (value, meta) {
                  final dt = DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.surfaceElevated,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                final dt = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                final yLabel = yLabelFormat != null
                    ? yLabelFormat!(s.y)
                    : s.y.toStringAsFixed(1);
                return LineTooltipItem(
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}\n$yLabel',
                  const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                );
              }).toList(),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}
