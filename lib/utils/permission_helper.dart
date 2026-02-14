import 'package:permission_handler/permission_handler.dart';

/// BLE and location permissions for Android (and iOS if used).
class PermissionHelper {
  static Future<bool> requestBlePermissions() async {
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      return true;
    }
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      return true;
    }
    final location = await Permission.locationWhenInUse.request();
    return location.isGranted;
  }

  static Future<bool> get areBlePermissionsGranted async {
    final scan = await Permission.bluetoothScan.isGranted;
    final connect = await Permission.bluetoothConnect.isGranted;
    return scan && connect;
  }

  static Future<void> openSettings() => openAppSettings();
}
