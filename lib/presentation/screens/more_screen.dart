import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/connection_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../screens/tabs/temperature_screen.dart';
import '../../screens/tabs/vitals_tab_screen.dart';
import '../../screens/tabs/hrm_hrv_screen.dart';
import '../../screens/tabs/ecg_screen.dart';
import '../../screens/tabs/imu_screen.dart';
import '../../screens/tabs/sensor_hub_screen.dart';
import '../../widgets/hex_debug_sheet.dart';
import '../../utils/ble_logger.dart';
import '../../screens/scan_connect_screen.dart';

/// More / Settings: Connect, feature screens, debug.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ble = ref.watch(bleServiceProvider);
    final connection = ref.watch(connectionStateProvider);

    return Scaffold(
      body: connection.when(
        data: (state) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingMd + MediaQuery.paddingOf(context).top,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    if (!state.isConnected)
                      FilledButton.icon(
                        onPressed: () {
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
                        icon: const Icon(Icons.bluetooth_searching),
                        label: const Text('Scan & Connect'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ble.disconnect();
                        },
                        icon: const Icon(Icons.link_off),
                        label: const Text('Disconnect'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    const SizedBox(height: AppTheme.spacingXl),
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _NavTile(
                  title: 'Skin Temperature (legacy)',
                  icon: Icons.thermostat,
                  onTap: () => _pushIfConnected(context, ref, const TemperatureScreen()),
                ),
                _NavTile(
                  title: 'Vitals (STS40, SigMot, Stored)',
                  icon: Icons.ac_unit,
                  onTap: () => _pushIfConnected(context, ref, const VitalsTabScreen()),
                ),
                _NavTile(
                  title: 'Sensor Hub (PPG + Accel)',
                  icon: Icons.analytics,
                  onTap: () => _pushIfConnected(context, ref, const SensorHubScreen()),
                ),
                _NavTile(
                  title: 'ECG',
                  icon: Icons.favorite,
                  onTap: () => _pushIfConnected(context, ref, const EcgScreen()),
                ),
                _NavTile(
                  title: 'HRM / HRV (legacy)',
                  icon: Icons.monitor_heart,
                  onTap: () => _pushIfConnected(context, ref, const HrmHrvScreen()),
                ),
                _NavTile(
                  title: 'IMU (Accel & Gyro)',
                  icon: Icons.gesture,
                  onTap: () => _pushIfConnected(context, ref, const ImuScreen()),
                ),
                const Divider(height: 32),
                _NavTile(
                  title: 'Debug: Raw BLE log',
                  icon: Icons.bug_report,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => HexDebugSheet(logLines: BleLogger.lines),
                    );
                  },
                ),
              ]),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
          icon: Icons.bluetooth_disabled,
          title: 'Error',
          actionLabel: 'Scan & Connect',
          onAction: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ScanConnectScreen(),
            ),
          ),
        ),
      ),
    );
  }

  void _pushIfConnected(BuildContext context, WidgetRef ref, Widget screen) {
    if (!ref.read(bleServiceProvider).isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect your device first')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
