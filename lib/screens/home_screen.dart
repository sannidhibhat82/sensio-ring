import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/ble_service.dart';
import '../utils/ble_constants.dart';
import '../utils/ble_logger.dart';
import '../utils/permission_helper.dart';
import 'scan_connect_screen.dart';
import 'tabs/temperature_screen.dart';
import 'tabs/ecg_screen.dart';
import 'tabs/hrm_hrv_screen.dart';
import 'tabs/imu_screen.dart';
import 'tabs/sensor_hub_screen.dart';
import 'tabs/vitals_tab_screen.dart';
import '../widgets/hex_debug_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _ble = BleService.instance;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;

  @override
  void initState() {
    super.initState();
    _adapterState = FlutterBluePlus.adapterStateNow;
    FlutterBluePlus.adapterState.listen((s) {
      if (mounted) setState(() => _adapterState = s);
    });
    _listenToConnection();
  }

  void _listenToConnection() {
    _connectionSub?.cancel();
    final device = _ble.device;
    if (device != null) {
      _connectionSub = device.connectionState.listen((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }

  Future<void> _ensurePermissionsAndOpenScan() async {
    final ok = await PermissionHelper.requestBlePermissions();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permissions required')),
      );
      return;
    }
    if (_adapterState != BluetoothAdapterState.on && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please turn Bluetooth ON')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScanConnectScreen(),
      ),
    ).then((_) {
      if (!mounted) return;
      _listenToConnection();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final connected = _ble.isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SENSIO Ring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => HexDebugSheet(logLines: BleLogger.lines),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(
            connected: connected,
            adapterState: _adapterState,
            deviceName: _ble.device?.platformName,
            deviceId: _ble.device?.remoteId.toString(),
            mtu: _ble.mtu,
          ),
          const SizedBox(height: 16),
          if (!connected)
            ElevatedButton.icon(
              onPressed: _ensurePermissionsAndOpenScan,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text('Scan & Connect'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
          else ...[
            OutlinedButton.icon(
              onPressed: () async {
                await _ble.disconnect();
                if (mounted) setState(() {});
              },
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect'),
            ),
            const SizedBox(height: 24),
            const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _NavTile(title: 'Skin Temperature', icon: Icons.thermostat, onTap: () => _push(const TemperatureScreen())),
            _NavTile(title: 'Vitals (STS40, SigMot, Stored)', icon: Icons.ac_unit, onTap: () => _push(const VitalsTabScreen())),
            _NavTile(title: 'Sensor Hub (PPG + Accelerometer)', icon: Icons.analytics, onTap: () => _push(const SensorHubScreen())),
            _NavTile(title: 'ECG (Electrocardiogram)', icon: Icons.favorite, onTap: () => _push(const EcgScreen())),
            _NavTile(title: 'Heart Rate / HRV', icon: Icons.monitor_heart, onTap: () => _push(const HrmHrvScreen())),
            _NavTile(title: 'Accelerometer & Gyroscope (IMU)', icon: Icons.gesture, onTap: () => _push(const ImuScreen())),
          ],
        ],
      ),
    );
  }

  void _push(Widget screen) {
    if (!_ble.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not connected')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.connected,
    required this.adapterState,
    this.deviceName,
    this.deviceId,
    required this.mtu,
  });

  final bool connected;
  final BluetoothAdapterState adapterState;
  final String? deviceName;
  final String? deviceId;
  final int mtu;

  @override
  Widget build(BuildContext context) {
    final stateText = connected ? 'Connected' : 'Disconnected';
    final stateColor = connected ? Colors.green : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: stateColor, size: 32),
                const SizedBox(width: 12),
                Text(stateText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: stateColor)),
              ],
            ),
            if (deviceName != null) Text('Device: $deviceName'),
            if (deviceId != null) Text('ID: $deviceId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (connected) Text('MTU: $mtu'),
            const SizedBox(height: 4),
            Text('Bluetooth: ${adapterState.name}'),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.title, required this.icon, required this.onTap});

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
