import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../themes/app_colors.dart';

/// One metric card for Quick Insights (HR, HRV, Temp, Steps).
class QuickInsightCard extends StatelessWidget {
  const QuickInsightCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.trend,
    this.iconColor,
  });

  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final double? trend;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final displayValue = unit != null ? '$value $unit' : value;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.accent,
              ),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                displayValue,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              if (trend != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Icon(
                  trend! >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 20,
                  color: trend! >= 0 ? AppColors.success : AppColors.error,
                ),
                Text(
                  '${trend!.abs().toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: trend! >= 0 ? AppColors.success : AppColors.error,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
