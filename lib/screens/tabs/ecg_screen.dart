import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/ble_service.dart';
import '../../utils/parsers/ecg_parser.dart';
import '../../widgets/raw_data_drawer.dart';

class EcgScreen extends StatefulWidget {
  const EcgScreen({super.key});

  @override
  State<EcgScreen> createState() => _EcgScreenState();
}

class _EcgScreenState extends State<EcgScreen> {
  final BleService _ble = BleService.instance;
  StreamSubscription<List<int>>? _sub;
  int _hr = 0;
  int _hrv = 0;
  int _z = 0;
  final List<String> _rawLogs = [];
  bool _streaming = false;
  String _mode = 'STARTECG:200';
  String? _error;

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
      _rawLogs.clear();
    });
    try {
      await _ble.writeCustom(_mode);
      _sub = _ble.customNotifications.listen((bytes) {
        final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        if (mounted) setState(() => _rawLogs.add('$hex  (${bytes.length} B)'));
        EcgParser.parse(
          bytes,
          (_) {},
          (hrHrv) {
            if (mounted) setState(() {
              _hr = hrHrv.heartRateBpm;
              _hrv = hrHrv.hrvMs;
            });
          },
          (z) {
            if (mounted) setState(() => _z = z.zValue);
          },
        );
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
      await _ble.writeCustom('STOPECG');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ECG (Electrocardiogram)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Heart rate, HRV and R-R intervals from ECG.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _mode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'STARTECG:60', child: Text('60 Hz')),
                DropdownMenuItem(value: 'STARTECG:100', child: Text('100 Hz')),
                DropdownMenuItem(value: 'STARTECG:200', child: Text('200 Hz')),
                DropdownMenuItem(value: 'STARTECG:500', child: Text('500 Hz')),
                DropdownMenuItem(value: 'STARTECG_F:100', child: Text('Filtered 100 Hz')),
              ],
              onChanged: _streaming ? null : (v) => setState(() => _mode = v ?? _mode),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ECG (Electrocardiogram)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Heart rate: $_hr BPM', style: Theme.of(context).textTheme.titleMedium),
                    Text('HRV: $_hrv ms', style: Theme.of(context).textTheme.titleMedium),
                    Text('Impedance (Z): $_z', style: Theme.of(context).textTheme.bodyMedium),
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
                builder: (_) => RawDataDrawer(title: 'Raw data (ECG)', rawLines: List.from(_rawLogs)),
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
