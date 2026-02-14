import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/hrm_hrv_data.dart';
import '../../services/ble_service.dart';
import '../../utils/parsers/ppg_parser.dart';
import '../../widgets/raw_data_drawer.dart';

class HrmHrvScreen extends StatefulWidget {
  const HrmHrvScreen({super.key});

  @override
  State<HrmHrvScreen> createState() => _HrmHrvScreenState();
}

class _HrmHrvScreenState extends State<HrmHrvScreen> {
  final BleService _ble = BleService.instance;
  StreamSubscription<List<int>>? _sub;
  HrmHrvData? _last;
  final List<String> _rawLogs = [];
  final List<int> _buffer = [];
  bool _streaming = false;
  String? _error;

  static const int _minPacketLength = 387;

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
      _last = null;
      _rawLogs.clear();
      _buffer.clear();
    });
    try {
      await _ble.writeCustom('HRM_HRV');
      _sub = _ble.customNotifications.listen((bytes) {
        final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        if (mounted) setState(() => _rawLogs.add('$hex  (${bytes.length} B)'));
        _buffer.addAll(bytes);
        if (_buffer.length >= _minPacketLength) {
          final d = PpgParser.parse(_buffer);
          if (d != null && mounted) {
            setState(() => _last = d);
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
      await _ble.writeCustom('STOPHRM_HRV');
    } catch (_) {}
    if (mounted) setState(() => _streaming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heart Rate / Heart Rate Variability')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('HR (BPM) and RMSSD (ms) from PPG. Wait ~30 s for data.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Heart Rate / HRV', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      _last != null ? 'Heart rate: ${_last!.heartRateBpm} BPM' : 'Heart rate: -- BPM',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _last != null ? 'RMSSD (HRV): ${_last!.rmssdMs} ms' : 'RMSSD (HRV): -- ms',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_last != null && _last!.hasError)
                      Text('Status: ${_last!.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                builder: (_) => RawDataDrawer(title: 'Raw data (Heart Rate / HRV)', rawLines: List.from(_rawLogs)),
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
