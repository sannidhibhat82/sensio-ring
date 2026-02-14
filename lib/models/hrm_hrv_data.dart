import 'package:equatable/equatable.dart';

/// HRM_HRV notification: error byte, PPG, HR, RMSSD, R-R.
class HrmHrvData extends Equatable {
  const HrmHrvData({
    required this.errorCode,
    required this.errorMessage,
    required this.ppgSamples,
    required this.heartRateBpm,
    required this.rmssdMs,
    required this.rrIntervalsMs,
    required this.timestamp,
  });

  final int errorCode;
  final String errorMessage;
  final List<int> ppgSamples;
  final int heartRateBpm;
  final int rmssdMs;
  final List<double> rrIntervalsMs;
  final DateTime timestamp;

  bool get hasError => errorCode != 0x00;

  @override
  List<Object?> get props =>
      [errorCode, ppgSamples, heartRateBpm, rmssdMs, rrIntervalsMs, timestamp];
}
