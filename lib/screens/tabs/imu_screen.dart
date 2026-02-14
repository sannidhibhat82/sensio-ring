import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/imu_data.dart';
import '../../services/ble_service.dart';
import '../../utils/parsers/imu_parser.dart';
import '../../widgets/raw_data_drawer.dart';

class ImuScreen extends StatefulWidget {
  const ImuScreen({super.key});

  @override
  State<ImuScreen> createState() => _ImuScreenState();
}

class _ImuScreenState extends State<ImuScreen> {
  final BleService _ble = BleService.instance;
  StreamSubscription<List<int>>? _sub;
  final List<AccelSample> _accSamples = [];
  final List<ImuSample> _gyroSamples = [];
  final List<String> _rawLogs = [];
  bool _streaming = false;
  String _command = 'STARTIMU:0x08_0x01_0x01_0x0';
  String? _error;

  static const int maxSamples = 500;

  @override
  void dispose() {
    _sub?.cancel();
    _stop();
    super.dispose();
  }

  Future<void> _start() async {
    if (_streaming) return;
    setState(() {
      _error = null;
      _streaming = true;
      _accSamples.clear();
      _gyroSamples.clear();
      _rawLogs.clear();
    });
    try {
      await _ble.writeCustom(_command);
      _sub = _ble.customNotifications.listen((bytes) {
        final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        if (mounted) setState(() => _rawLogs.add('$hex  (${bytes.length} B)'));
        if (bytes.length >= 12) {
          // STARTIMU data is big-endian (overview): 6 bytes acc + 6 bytes gyro per sample.
          // Use parseImu only; do not use parseAcc here (that is for STARTACC, little-endian).
          final imu = ImuParser.parseImu(bytes);
          if (mounted) {
            setState(() {
              _gyroSamples.addAll(imu);
              for (final s in imu) {
                _accSamples.add(AccelSample(x: s.accX, y: s.accY, z: s.accZ, timestamp: s.timestamp));
              }
              while (_gyroSamples.length > maxSamples) _gyroSamples.removeAt(0);
              while (_accSamples.length > maxSamples) _accSamples.removeAt(0);
            });
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
      await _ble.writeCustom('STOPIMU');
    } catch (_) {}
    try {
      await _ble.writeCustom('STOPACC');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    final acc = _accSamples.isNotEmpty ? _accSamples.last : null;
    final gyro = _gyroSamples.isNotEmpty ? _gyroSamples.last : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Accelerometer & Gyroscope (IMU)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Inertial Measurement Unit: acceleration (g) and angular velocity (°/s)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            if (acc != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Accelerometer (last)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('X: ${acc.x.toStringAsFixed(2)} g  Y: ${acc.y.toStringAsFixed(2)} g  Z: ${acc.z.toStringAsFixed(2)} g'),
                    ],
                  ),
                ),
              ),
            if (gyro != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gyroscope (last)', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('X: ${gyro.gyroX.toStringAsFixed(2)} °/s  Y: ${gyro.gyroY.toStringAsFixed(2)} °/s  Z: ${gyro.gyroZ.toStringAsFixed(2)} °/s'),
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
                builder: (_) => RawDataDrawer(title: 'Raw data (IMU)', rawLines: List.from(_rawLogs)),
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
