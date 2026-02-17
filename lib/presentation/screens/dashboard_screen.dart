import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/realtime_metrics.dart';
import '../../providers/connection_provider.dart';
import '../../providers/realtime_metrics_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/quick_insight_card.dart';
import '../../screens/scan_connect_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionStateProvider);
    final metrics = ref.watch(realtimeMetricsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd + MediaQuery.paddingOf(context).top,
                AppTheme.spacingMd,
                AppTheme.spacingSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  connection.when(
                    data: (state) => ConnectionBanner(
                      onDisconnect: state.isConnected
                          ? () async {
                              await ref.read(bleServiceProvider).disconnect();
                            }
                          : null,
                      compact: false,
                    ),
                    loading: () => const ConnectionBanner(compact: true),
                    error: (_, __) => const ConnectionBanner(compact: true),
                  ),
                ],
              ),
            ),
          ),
          connection.when(
            data: (state) {
              if (!state.isConnected) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.bluetooth_disabled,
                    title: 'Device disconnected',
                    message:
                        'Connect your SENSIO Ring to see live metrics and insights.',
                    actionLabel: 'Scan & Connect',
                    onAction: () => _openScan(context, ref),
                  ),
                );
              }
              return _QuickInsightsSection(metrics: metrics);
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.bluetooth_disabled,
                title: 'Connection error',
                message: 'Check Bluetooth and try again.',
                actionLabel: 'Scan & Connect',
                onAction: () => _openScan(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openScan(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScanConnectScreen(),
      ),
    ).then((result) {
      if (result == true) {
        ref.read(connectionRefreshProvider.notifier).state++;
      }
    });
  }
}

class _QuickInsightsSection extends StatelessWidget {
  const _QuickInsightsSection({
    required this.metrics,
  });

  final RealtimeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            'Quick Insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Wrap(
            spacing: AppTheme.spacingMd,
            runSpacing: AppTheme.spacingMd,
            children: [
              QuickInsightCard(
                label: 'Heart Rate',
                value: metrics.heartRateBpm?.toString() ?? '--',
                unit: 'BPM',
                icon: Icons.favorite,
                iconColor: Colors.red.shade300,
              ),
              QuickInsightCard(
                label: 'HRV',
                value: metrics.hrvMs?.toString() ?? '--',
                unit: 'ms',
                icon: Icons.monitor_heart,
              ),
              QuickInsightCard(
                label: 'Temperature',
                value: metrics.temperatureCelsius != null
                    ? metrics.temperatureCelsius!.toStringAsFixed(1)
                    : '--',
                unit: '°C',
                icon: Icons.thermostat,
              ),
              QuickInsightCard(
                label: 'Activity',
                value: metrics.steps?.toString() ??
                    metrics.activityIntensity?.toString() ??
                    '--',
                unit: metrics.steps != null ? 'steps' : null,
                icon: Icons.directions_walk,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Text(
            'Open Vitals to stream live data from your ring. Data appears here as you use Skin Temperature, HR-HRV, or Activity.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
      ),
    );
  }
}
