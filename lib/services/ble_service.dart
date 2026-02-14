import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../utils/ble_constants.dart';
import '../utils/ble_logger.dart';

/// Singleton BLE service for SENSIO Ring.
/// Handles scan, connect, MTU, subscribe, write, and reconnection.
class BleService {
  BleService._();
  static final BleService _instance = BleService._();
  static BleService get instance => _instance;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _charVitals;
  BluetoothCharacteristic? _charCustom;
  int _cachedMtu = 23;
  bool _cachedConnected = false;

  final StreamController<List<int>> _vitalsNotifications =
      StreamController<List<int>>.broadcast();
  final StreamController<List<int>> _customNotifications =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get vitalsNotifications => _vitalsNotifications.stream;
  Stream<List<int>> get customNotifications => _customNotifications.stream;

  BluetoothDevice? get device => _device;
  bool get isConnected => _cachedConnected && _device != null;
  int get mtu => _cachedMtu;

  /// Start scan for BLE devices. No name filter so all devices show (filter in UI for SENSIO).
  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) async {
    await FlutterBluePlus.startScan(
      timeout: timeout,
      // Don't use withNames so devices that advertise differently still appear
    );
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<void> connect(BluetoothDevice device) async {
    await _disconnectIfConnected();
    _device = device;

    BleLogger.log('Connecting to ${device.platformName} ${device.remoteId}');
    await device.connect(
      autoConnect: false,
      mtu: null,
    );

    await _requestMtu();
    await _discoverAndCacheCharacteristics();
    await _enableNotifications();

    _cachedConnected = true;
    BleLogger.log('Connected. MTU: $_cachedMtu');
  }

  Future<void> _requestMtu() async {
    if (_device == null) return;
    try {
      final newMtu = await _device!.requestMtu(BleConstants.requestedMtu);
      _cachedMtu = newMtu is int ? newMtu : 23;
      BleLogger.log('MTU set to $_cachedMtu');
    } catch (e) {
      BleLogger.log('MTU request failed (using default): $e');
    }
  }

  Future<void> _discoverAndCacheCharacteristics() async {
    if (_device == null) return;
    List<BluetoothService> services = await _device!.discoverServices();

    for (BluetoothService s in services) {
      final su = s.uuid.toString().toLowerCase();
      for (BluetoothCharacteristic c in s.characteristics) {
        final cu = c.uuid.toString().toLowerCase();
        if (su.contains('a0262760') && cu.contains('0001')) {
          _charVitals = c;
          BleLogger.log('Found vitals char: ${c.uuid}');
        }
        if (su.contains('4e771a15') && cu.contains('22222222')) {
          _charCustom = c;
          BleLogger.log('Found custom char: ${c.uuid}');
        }
      }
    }

    if (_charVitals == null && _charCustom == null) {
      BleLogger.log('WARNING: No expected characteristics found.');
    }
  }

  Future<void> _enableNotifications() async {
    if (_charVitals != null && _charVitals!.properties.notify) {
      await _charVitals!.setNotifyValue(true);
      _charVitals!.lastValueStream.listen((value) {
        BleLogger.logFromDevice('Vitals', value);
        _vitalsNotifications.add(value);
      });
    }
    if (_charCustom != null && _charCustom!.properties.notify) {
      await _charCustom!.setNotifyValue(true);
      _charCustom!.lastValueStream.listen((value) {
        BleLogger.logFromDevice('Custom', value);
        _customNotifications.add(value);
      });
    }
  }

  Future<void> writeVitals(String command) async {
    if (_charVitals == null) {
      throw StateError('Vitals characteristic not available');
    }
    final bytes = utf8.encode(command);
    await _charVitals!.write(bytes, withoutResponse: false);
    BleLogger.log('Write vitals: $command');
  }

  Future<void> writeCustom(String command) async {
    if (_charCustom == null) {
      throw StateError('Custom characteristic not available');
    }
    final bytes = utf8.encode(command);
    await _charCustom!.write(bytes, withoutResponse: false);
    BleLogger.log('Write custom: $command');
  }

  Future<void> disconnect() async {
    await _disconnectIfConnected();
    _device = null;
    _charVitals = null;
    _charCustom = null;
    _cachedConnected = false;
    BleLogger.log('Disconnected.');
  }

  Future<void> _disconnectIfConnected() async {
    if (_device == null) return;
    try {
      if (_charVitals != null) {
        await _charVitals!.setNotifyValue(false);
      }
      if (_charCustom != null) {
        await _charCustom!.setNotifyValue(false);
      }
    } catch (_) {}
    try {
      await _device!.disconnect();
    } catch (_) {}
  }

  Future<bool> reconnect() async {
    if (_device == null) return false;
    try {
      await _device!.connect(autoConnect: false);
      await _requestMtu();
      await _discoverAndCacheCharacteristics();
      await _enableNotifications();
      return true;
    } catch (e) {
      BleLogger.log('Reconnect failed: $e');
      return false;
    }
  }

  void dispose() {
    _vitalsNotifications.close();
    _customNotifications.close();
  }
}
