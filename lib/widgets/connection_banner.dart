import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connection_provider.dart';
import '../themes/app_theme.dart';
import '../themes/app_colors.dart';

/// Shows device connection status for app bar or dashboard.
class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({
    super.key,
    this.onDisconnect,
    this.compact = false,
  });

  final VoidCallback? onDisconnect;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionStateProvider);
    return connection.when(
      data: (state) => _buildContent(context, state),
      loading: () => _buildContent(context, DeviceConnectionState.disconnected),
      error: (_, __) => _buildContent(context, DeviceConnectionState.disconnected),
    );
  }

  Widget _buildContent(BuildContext context, DeviceConnectionState state) {
    if (state.isConnected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success,
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              state.deviceName ?? 'Connected',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          if (onDisconnect != null) ...[
            const SizedBox(width: AppTheme.spacingSm),
            TextButton(
              onPressed: onDisconnect,
              child: Text(
                'Disconnect',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            ),
          ],
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            'Disconnected',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ],
    );
  }
}
