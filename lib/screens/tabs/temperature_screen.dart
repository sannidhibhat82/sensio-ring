import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/temperature_reading.dart';
import '../../services/ble_service.dart';
import '../../providers/realtime_metrics_provider.dart';
import '../../utils/ble_logger.dart';
import '../../utils/parsers/temperature_parser.dart';
import '../../widgets/raw_data_drawer.dart';

class TemperatureScreen extends ConsumerStatefulWidget {
  const TemperatureScreen({super.key});

  @override
  ConsumerState<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends ConsumerState<TemperatureScreen> {
  final BleService _ble = BleService.instance;
  StreamSubscription<List<int>>? _sub;
  TemperatureReading? _last;
  final List<String> _rawLogs = [];
  bool _streaming = false;
  String? _error;

  @override
  void dispose() {
    _stopStreaming();
    super.dispose();
  }

  Future<void> _startStreaming() async {
    if (_streaming) return;
    setState(() {
      _error = null;
      _streaming = true;
      _rawLogs.clear();
    });
    try {
      // Use Custom characteristic (48837cb0...) to match nRF Connect; device may expect "STARTTEMP " with trailing space
      await _ble.writeCustom('STARTTEMP ');
      _sub = _ble.customNotifications.listen((bytes) {
        BleLogger.logFromDevice('Custom (after STARTTEMP)', bytes);
        final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        final r = TemperatureParser.parse(bytes);
        if (mounted) {
          setState(() {
            _rawLogs.add('$hex  (${bytes.length} B)${r != null ? ' → ${r.celsius.toStringAsFixed(2)} °C (raw: ${r.raw})' : ''}');
            if (r != null) _last = r;
          });
          if (r != null) ref.read(realtimeMetricsProvider.notifier).setTemperature(r.celsius);
        }
      });
    } catch (e) {
      BleLogger.log('Error starting temperature streaming: $e');
      if (mounted) setState(() {
        _error = e.toString();
        _streaming = false;
      });
    }
  }

  Future<void> _stopStreaming() async {
    _sub?.cancel();
    _sub = null;
    try {
      await _ble.writeCustom('STOPTEMP ');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skin Temperature')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skin Temperature', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _last != null ? '${_last!.celsius.toStringAsFixed(2)} °C' : '-- °C',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (_last != null)
                      Text('Raw value: ${_last!.raw}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _streaming ? null : _startStreaming,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _streaming ? _stopStreaming : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => RawDataDrawer(title: 'Raw data (Skin Temperature)', rawLines: List.from(_rawLogs)),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('View raw data'),
            ),
          ],
        ),
      ),
    );
  }
}
