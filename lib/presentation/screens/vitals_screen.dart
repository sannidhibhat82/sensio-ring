import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ble_service.dart';
import '../../utils/parsers/temperature_parser.dart';
import '../../utils/parsers/ppg_parser.dart';
import '../../providers/connection_provider.dart';
import '../../providers/realtime_metrics_provider.dart';
import '../../themes/app_theme.dart';
import '../../widgets/connection_banner.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/metric_line_chart.dart';
import '../../widgets/metric_bar_chart.dart';
import '../../screens/scan_connect_screen.dart';

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(connectionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals'),
        actions: [
          connection.when(
            data: (state) => state.isConnected
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ConnectionBanner(
                      compact: true,
                      onDisconnect: () async {
                        await ref.read(bleServiceProvider).disconnect();
                      },
                    ),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Skin Temp'),
            Tab(text: 'Activity'),
            Tab(text: 'HR-HRV'),
          ],
        ),
      ),
      body: connection.when(
        data: (state) {
          if (!state.isConnected) {
            return EmptyState(
              icon: Icons.bluetooth_disabled,
              title: 'Device disconnected',
              message: 'Connect your ring to view vitals.',
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
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _SkinTempTab(ble: ref.read(bleServiceProvider), ref: ref),
              _ActivityTab(ble: ref.read(bleServiceProvider), ref: ref),
              _HrHrvTab(ble: ref.read(bleServiceProvider), ref: ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyState(
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

class _SkinTempTab extends ConsumerStatefulWidget {
  const _SkinTempTab({required this.ble, required this.ref});

  final BleService ble;
  final WidgetRef ref;

  @override
  ConsumerState<_SkinTempTab> createState() => _SkinTempTabState();
}

class _SkinTempTabState extends ConsumerState<_SkinTempTab> {
  StreamSubscription<List<int>>? _sub;
  bool _streaming = false;
  String? _error;

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _error = null;
      _streaming = true;
    });
    try {
      await widget.ble.writeCustom('STARTTEMP ');
      _sub = widget.ble.customNotifications.listen((bytes) {
        final r = TemperatureParser.parse(bytes);
        if (r != null && mounted) {
          widget.ref.read(realtimeMetricsProvider.notifier).setTemperature(r.celsius);
          setState(() {});
        }
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _streaming = false;
      });
    }
  }

  Future<void> _stop() async {
    _sub?.cancel();
    _sub = null;
    try {
      await widget.ble.writeCustom('STOPTEMP ');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(realtimeMetricsProvider);

    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics.temperatureCelsius != null
                          ? '${metrics.temperatureCelsius!.toStringAsFixed(1)} °C'
                          : '-- °C',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Skin Temperature',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            MetricLineChart(
              points: metrics.tempHistory
                  .map((p) => (p.time, p.value))
                  .toList(),
              yLabelFormat: (v) => '${v.toStringAsFixed(1)}°',
              height: 220,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: AppTheme.spacingLg),
            FilledButton.icon(
              onPressed: _streaming ? null : _start,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start stream'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _streaming ? _stop : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop stream'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTab extends ConsumerStatefulWidget {
  const _ActivityTab({required this.ble, required this.ref});

  final BleService ble;
  final WidgetRef ref;

  @override
  ConsumerState<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<_ActivityTab> {
  StreamSubscription<List<int>>? _sub;
  bool _streaming = false;

  Future<void> _start() async {
    if (_streaming) return;
    setState(() => _streaming = true);
    await widget.ble.writeVitals('sigmot');
    _sub = widget.ble.vitalsNotifications.listen((bytes) {
      for (final v in bytes) {
        widget.ref.read(realtimeMetricsProvider.notifier).setActivityIntensity(v);
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _stop() async {
    _sub?.cancel();
    _sub = null;
    if (mounted) setState(() => _streaming = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(realtimeMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrics.activityIntensity?.toString() ?? '--',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Significant motion (per 30s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          MetricBarChart(
            points: metrics.stepsHistory,
            height: 220,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          FilledButton.icon(
            onPressed: _streaming ? null : _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start activity stream'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _streaming ? _stop : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop stream'),
          ),
        ],
      ),
    );
  }
}

class _HrHrvTab extends ConsumerStatefulWidget {
  const _HrHrvTab({required this.ble, required this.ref});

  final BleService ble;
  final WidgetRef ref;

  @override
  ConsumerState<_HrHrvTab> createState() => _HrHrvTabState();
}

class _HrHrvTabState extends ConsumerState<_HrHrvTab> {
  StreamSubscription<List<int>>? _sub;
  final List<int> _buffer = [];
  bool _streaming = false;
  String? _error;

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _error = null;
      _streaming = true;
      _buffer.clear();
    });
    try {
      await widget.ble.writeCustom('HRM_HRV');
      _sub = widget.ble.customNotifications.listen((bytes) {
        _buffer.addAll(bytes);
        if (_buffer.length >= PpgParser.minLength) {
          final d = PpgParser.parse(_buffer);
          if (d != null && mounted) {
            widget.ref.read(realtimeMetricsProvider.notifier).setHeartRate(d.heartRateBpm);
            widget.ref.read(realtimeMetricsProvider.notifier).setHrv(d.rmssdMs);
            setState(() {});
            _buffer.clear();
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _streaming = false;
      });
    }
  }

  Future<void> _stop() async {
    _sub?.cancel();
    _sub = null;
    try {
      await widget.ble.writeCustom('STOPHRM_HRV');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ref.watch(realtimeMetricsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${metrics.heartRateBpm ?? '--'} BPM',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'HRV (RMSSD): ${metrics.hrvMs ?? '--'} ms',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          MetricLineChart(
            points: metrics.hrHistory.map((p) => (p.time, p.value.toDouble())).toList(),
            yLabelFormat: (v) => '${v.toInt()}',
            height: 220,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: AppTheme.spacingLg),
          FilledButton.icon(
            onPressed: _streaming ? null : _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start HR/HRV stream'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _streaming ? _stop : null,
            icon: const Icon(Icons.stop),
            label: const Text('Stop stream'),
          ),
        ],
      ),
    );
  }
}
