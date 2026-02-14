import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/sensor_hub_sample.dart';
import '../../services/ble_service.dart';
import '../../utils/parsers/sensor_hub_parser.dart';
import '../../widgets/raw_data_drawer.dart';

class SensorHubScreen extends StatefulWidget {
  const SensorHubScreen({super.key});

  @override
  State<SensorHubScreen> createState() => _SensorHubScreenState();
}

class _SensorHubScreenState extends State<SensorHubScreen> {
  final BleService _ble = BleService.instance;
  StreamSubscription<List<int>>? _sub;
  final List<SensorHubSample> _samples = [];
  double? _lastTemp;
  final List<String> _rawLogs = [];
  final List<int> _buffer = [];
  bool _streaming = false;
  String? _error;

  static const int maxSamples = 200;
  static const int sampleBytes = 44;

  @override
  void dispose() {
    _sub?.cancel();
    _stop();
    super.dispose();
  }

  void _processBuffer() {
    while (_buffer.length >= sampleBytes) {
      final s = SensorHubParser.parseSample(_buffer, 0);
      if (s != null) {
        _samples.add(s);
        if (_samples.length > maxSamples) _samples.removeAt(0);
      }
      _buffer.removeRange(0, sampleBytes);
    }
  }

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _error = null;
      _streaming = true;
      _samples.clear();
      _lastTemp = null;
      _rawLogs.clear();
      _buffer.clear();
    });
    try {
      await _ble.writeCustom('STARTSHRD');
      _sub = _ble.customNotifications.listen((bytes) {
        final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        if (mounted) {
          setState(() => _rawLogs.add('$hex  (${bytes.length} B)'));
          _buffer.addAll(bytes);
          _processBuffer();
          if (_buffer.length == 1) {
            final t = (_buffer[0] + 200) / 10.0;
            setState(() => _lastTemp = t);
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
      await _ble.writeCustom('STOPSHRD');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final last = _samples.isNotEmpty ? _samples.last : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Hub (PPG + Accelerometer)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('PPG (heart rate, SpO2) and accelerometer. 44 bytes/sample.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            if (last != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last sample', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Heart rate: ${last.hr} BPM  SpO2: ${last.spo2}%  RR: ${last.rr}'),
                      Text('Accelerometer: X= ${last.accX}  Y= ${last.accY}  Z= ${last.accZ}'),
                      if (_lastTemp != null) Text('Temperature: ${_lastTemp!.toStringAsFixed(1)} °C'),
                    ],
                  ),
                ),
              ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _streaming ? null : _start, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: _streaming ? _stop : null, icon: const Icon(Icons.stop), label: const Text('Stop')),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => RawDataDrawer(title: 'Raw data (Sensor Hub)', rawLines: List.from(_rawLogs)),
              ),
              icon: const Icon(Icons.code),
              label: const Text('View raw data'),
            ),
          ],
        ),
      ),
    );
  }
}
