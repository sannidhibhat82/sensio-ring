import '../../models/hrm_hrv_data.dart';
import '../ble_constants.dart';

/// Parses HRM_HRV: error byte, 384 bytes PPG, HR, RMSSD, R-R. ms = (RR*0.04)/60
class PpgParser {
  static const Map<int, String> errorMessages = {
    0x00: 'OK',
    0x01: 'POOR_SKIN_CONTACT',
    0x02: 'PPG_NOT_FOUND',
    0x14: 'OUT_OF_TOLERANCE',
    0x24: 'LOW_PEAK_COUNT',
    0x44: 'HIGH_VARIANCE',
  };

  /// Minimum length: error(1) + PPG(384) + HR(1) + RMSSD(1) = 387 (overview: 0-based byte 385=HR, 386=RMSSD).
  static const int minLength = 387;

  static HrmHrvData? parse(List<int> bytes) {
    if (bytes.length < minLength) return null;
    final errorCode = bytes[0];
    final hex = errorCode.toRadixString(16);
    final errorMessage = errorMessages[errorCode] ?? 'Unknown (0x$hex)';

    final ppgSamples = <int>[];
    for (int i = 1; i + 2 <= 384 && i + 2 < bytes.length; i += 3) {
      final flag = (bytes[i] >> 4) & 0x0F;
      final low = (bytes[i] & 0x0F) << 16;
      final mid = bytes[i + 1] << 8;
      final high = bytes[i + 2];
      ppgSamples.add(low | mid | high);
    }

    // Overview (0-based): byte 385 = HR, byte 386 = RMSSD
    final heartRateBpm = bytes[385];
    final rmssdMs = bytes[386];
    final rrIntervalsMs = <double>[];
    for (int i = 387; i < bytes.length; i++) {
      final rr = bytes[i];
      final ms = (rr * BleConstants.hrmRrScale) / BleConstants.hrmRrDivisor;
      rrIntervalsMs.add(ms);
    }

    return HrmHrvData(
      errorCode: errorCode,
      errorMessage: errorMessage,
      ppgSamples: ppgSamples,
      heartRateBpm: heartRateBpm,
      rmssdMs: rmssdMs,
      rrIntervalsMs: rrIntervalsMs,
      timestamp: DateTime.now(),
    );
  }
}
