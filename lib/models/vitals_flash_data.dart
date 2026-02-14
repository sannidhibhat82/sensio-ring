import 'package:equatable/equatable.dart';

/// GETVITALS: first frame = 4 bytes (frame counts).
class VitalsFrameCounts extends Equatable {
  const VitalsFrameCounts({
    required this.sigMotFrames,
    required this.stepsFrames,
    required this.temperatureFrames,
    required this.heartRateFrames,
  });
  final int sigMotFrames;
  final int stepsFrames;
  final int temperatureFrames;
  final int heartRateFrames;
  @override
  List<Object?> get props =>
      [sigMotFrames, stepsFrames, temperatureFrames, heartRateFrames];
}

/// Parsed vitals from flash: SigMot, Steps, Temp, HR.
class VitalsFlashData extends Equatable {
  const VitalsFlashData({
    required this.sigMotValues,
    required this.stepValues,
    required this.temperaturesCelsius,
    required this.heartRateValues,
  });
  final List<int> sigMotValues;
  final List<int> stepValues;
  final List<double> temperaturesCelsius;
  final List<int> heartRateValues;
  @override
  List<Object?> get props =>
      [sigMotValues, stepValues, temperaturesCelsius, heartRateValues];
}
