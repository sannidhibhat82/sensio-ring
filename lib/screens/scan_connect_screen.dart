import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/ble_service.dart';
import '../utils/ble_constants.dart';

class ScanConnectScreen extends StatefulWidget {
  const ScanConnectScreen({super.key});

  @override
  State<ScanConnectScreen> createState() => _ScanConnectScreenState();
}

class _ScanConnectScreenState extends State<ScanConnectScreen> {
  final BleService _ble = BleService.instance;
  final List<ScanResult> _results = [];
  bool _scanning = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _scanStopped = false;

  Future<void> _startScan() async {
    setState(() {
      _results.clear();
      _scanning = true;
      _scanStopped = false;
    });
    try {
      await _ble.startScan(timeout: const Duration(seconds: 15));
      _scanSub = _ble.scanResults.listen((list) {
        if (!mounted) return;
        setState(() {
          for (final r in list) {
            // if (!_isSensioDevice(r)) continue;
            if (!_results.any((e) => e.device.remoteId == r.device.remoteId)) {
              _results.add(r);
            }
          }
        });
      });
      await Future.delayed(const Duration(seconds: 15));
    } finally {
      _scanSub?.cancel();
      if (mounted) setState(() => _scanning = false);
      if (!_scanStopped) {
        _scanStopped = true;
        await _ble.stopScan();
      }
    }
  }

  /// True if this scan result is a SENSIO device (show only these in the list).
  bool _isSensioDevice(ScanResult r) {
    final adv = r.advertisementData;
    final advName = (adv.advName ?? adv.localName ?? '').trim();
    final name = advName.isEmpty
        ? (r.device.platformName.isEmpty ? '' : r.device.platformName)
        : advName;
    final displayName =
        name.isEmpty ? r.device.remoteId.toString() : name;
    return displayName.toUpperCase().contains(BleConstants.deviceNameFilter);
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _connecting = true);
    try {
      await _ble.connect(device);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connect failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    if (!_scanStopped) {
      _scanStopped = true;
      _ble.stopScan();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Connect'),
        actions: [
          if (_scanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _startScan,
              child: const Text('Scan'),
            ),
        ],
      ),
      body: _connecting
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && !_scanning
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No SENSIO devices found.\nOnly SENSIO devices are shown.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                final adv = r.advertisementData;
                final advName = (adv.advName ?? adv.localName ?? '').trim();
                final name = advName.isEmpty
                    ? (r.device.platformName.isEmpty
                        ? ''
                        : r.device.platformName)
                    : advName;
                final displayName = name.isEmpty ? r.device.remoteId.toString() : name;
                return ListTile(
                  leading: const Icon(
                    Icons.bluetooth,
                    color: Colors.green,
                  ),
                  title: Text(displayName),
                  subtitle: Text(r.device.remoteId.toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _connect(r.device),
                );
              },
            ),
    );
  }
}
