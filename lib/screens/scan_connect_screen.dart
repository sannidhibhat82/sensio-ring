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
                final isSensio = displayName.toUpperCase().contains(BleConstants.deviceNameFilter);
                return ListTile(
                  leading: Icon(
                    Icons.bluetooth,
                    color: isSensio ? Colors.green : null,
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
