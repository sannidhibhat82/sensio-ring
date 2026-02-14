import '../../models/vitals_flash_data.dart';
import '../ble_constants.dart';

/// GETVITALS: first frame 4 bytes (counts), then chunks up to 60 bytes.
class VitalsParser {
  static VitalsFrameCounts? parseFrameCounts(List<int> bytes) {
    if (bytes.length < 4) return null;
    return VitalsFrameCounts(
      sigMotFrames: bytes[0],
      stepsFrames: bytes[1],
      temperatureFrames: bytes[2],
      heartRateFrames: bytes[3],
    );
  }

  static VitalsFlashData buildFromChunks(
    List<int> sigMotFrames,
    List<int> stepsFrames,
    List<int> tempFrames,
    List<int> hrFrames,
  ) {
    return VitalsFlashData(
      sigMotValues: sigMotFrames,
      stepValues: stepsFrames,
      temperaturesCelsius: tempFrames
          .map((b) => (b + BleConstants.tempOffset) / BleConstants.tempDivisor)
          .toList(),
      heartRateValues: hrFrames,
    );
  }
}
