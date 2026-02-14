import '../../models/ecg_data.dart';
import '../ble_constants.dart';

/// Parses ECG notifications: >200 bytes = ECG data; <100 bytes = HR/HRV or Z.
/// R-R formula: ((RR[i+1] - RR[i]) / 128) * 1000 ms
class EcgParser {
  /// Classify and parse: ECG raw, HR/HRV, or Z.
  static void parse(
    List<int> bytes,
    void Function(EcgSample) onEcg,
    void Function(EcgHrHrvPacket) onHrHrv,
    void Function(EcgImpedancePacket) onZ,
  ) {
    if (bytes.length > 200) {
      onEcg(EcgSample(
        values: List.from(bytes),
        timestamp: DateTime.now(),
      ));
      return;
    }
    if (bytes.length == 4) {
      final z = (bytes[0] << 16) | (bytes[1] << 8) | bytes[2];
      onZ(EcgImpedancePacket(zValue: z, timestamp: DateTime.now()));
      return;
    }
    if (bytes.length > 4 && bytes.length < 100) {
      final hr = bytes[0];
      final hrv = bytes[1];
      final rrRaw = <int>[];
      for (int i = 2; i + 1 < bytes.length; i += 2) {
        rrRaw.add((bytes[i] << 8) | bytes[i + 1]);
      }
      final rrMs = _rrRawToMs(rrRaw);
      onHrHrv(EcgHrHrvPacket(
        heartRateBpm: hr,
        hrvMs: hrv,
        rrIntervalsMs: rrMs,
        timestamp: DateTime.now(),
      ));
    }
  }

  static List<double> _rrRawToMs(List<int> rrRaw) {
    final out = <double>[];
    for (int i = 0; i < rrRaw.length - 1; i++) {
      final delta = rrRaw[i + 1] - rrRaw[i];
      final ms = (delta / BleConstants.ecgRRBaseHz) *
          (BleConstants.ecgRRMsMultiplier / 1);
      out.add(ms);
    }
    return out;
  }
}
