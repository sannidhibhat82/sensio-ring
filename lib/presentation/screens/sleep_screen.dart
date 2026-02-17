import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sleep_data.dart';
import '../../providers/connection_provider.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sleep_score_ring.dart';
import '../../widgets/sleep_stage_timeline.dart';
import '../../screens/scan_connect_screen.dart';

/// Sleep data is not streamed from device in current protocol;
/// show placeholder UI and structure for future stored sleep.
class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionStateProvider);

    return connection.when(
      data: (state) {
        if (!state.isConnected) {
          return Scaffold(
            body: EmptyState(
              icon: Icons.bedtime,
              title: 'Device disconnected',
              message: 'Connect your ring to view sleep data.',
              actionLabel: 'Scan & Connect',
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScanConnectScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    ref.read(connectionRefreshProvider.notifier).state++;
                  }
                });
              },
            ),
          );
        }
        return _SleepContent();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        body: EmptyState(
          icon: Icons.bluetooth_disabled,
          title: 'Connection error',
          actionLabel: 'Scan & Connect',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanConnectScreen(),
              ),
            ).then((result) {
              if (result == true) {
                ref.read(connectionRefreshProvider.notifier).state++;
              }
            });
          },
        ),
      ),
    );
  }
}

class _SleepContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const sleepData = SleepData(
      date: null,
      totalMinutes: null,
      qualityScore: null,
      stages: [],
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppTheme.spacingMd,
                AppTheme.spacingMd + MediaQuery.paddingOf(context).top,
                AppTheme.spacingMd,
                AppTheme.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep Quality',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Center(
                    child: SleepScoreRing(
                      score: null,
                      size: 160,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  if (sleepData.totalMinutes != null)
                    Center(
                      child: Text(
                        '${sleepData.totalMinutes! ~/ 60} hrs ${sleepData.totalMinutes! % 60} mins',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        'No sleep data yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep stages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  SleepStageTimeline(
                    segments: sleepData.stages,
                    height: 32,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  Text(
                    'Wear your ring during sleep to capture stages (Wake, REM, Light, Deep). Data will appear here when supported by the device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
