import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';

/// Device connection state for UI.
class DeviceConnectionState {
  const DeviceConnectionState({
    required this.isConnected,
    this.deviceName,
    this.deviceId,
    this.mtu = 0,
    this.adapterOn = false,
  });

  final bool isConnected;
  final String? deviceName;
  final String? deviceId;
  final int mtu;
  final bool adapterOn;

  static const disconnected = DeviceConnectionState(isConnected: false, adapterOn: false);
}

final bleServiceProvider = Provider<BleService>((ref) => BleService.instance);

/// Bump this after connecting so connectionStateProvider re-builds its stream
/// with the new device (otherwise the stream was created when device was null).
final connectionRefreshProvider = StateProvider<int>((ref) => 0);

final connectionStateProvider = StreamProvider<DeviceConnectionState>((ref) {
  ref.watch(connectionRefreshProvider);
  final ble = ref.watch(bleServiceProvider);
  final adapterState = FlutterBluePlus.adapterState;
  final device = ble.device;

  if (device == null) {
    return adapterState.map((s) => DeviceConnectionState(
          isConnected: false,
          adapterOn: s == BluetoothAdapterState.on,
        ));
  }

  return device.connectionState.asyncMap((state) async {
    final adapterOn = FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;
    if (state != BluetoothConnectionState.connected) {
      return DeviceConnectionState(isConnected: false, adapterOn: adapterOn);
    }
    return DeviceConnectionState(
      isConnected: true,
      deviceName: device.platformName.isNotEmpty ? device.platformName : device.remoteId.toString(),
      deviceId: device.remoteId.toString(),
      mtu: ble.mtu,
      adapterOn: adapterOn,
    );
  });
});
