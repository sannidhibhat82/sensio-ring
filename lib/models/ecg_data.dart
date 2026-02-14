import 'package:equatable/equatable.dart';

/// ECG raw sample (hex stream).
class EcgSample extends Equatable {
  const EcgSample({required this.values, required this.timestamp});
  final List<int> values;
  final DateTime timestamp;
  @override
  List<Object?> get props => [values, timestamp];
}

/// HR/HRV/R-R from ECG filtered stream (< 100 bytes).
class EcgHrHrvPacket extends Equatable {
  const EcgHrHrvPacket({
    required this.heartRateBpm,
    required this.hrvMs,
    required this.rrIntervalsMs,
    required this.timestamp,
  });
  final int heartRateBpm;
  final int hrvMs;
  final List<double> rrIntervalsMs;
  final DateTime timestamp;
  @override
  List<Object?> get props => [heartRateBpm, hrvMs, rrIntervalsMs, timestamp];
}

/// Impedance Z (4 bytes): contact quality.
class EcgImpedancePacket extends Equatable {
  const EcgImpedancePacket({required this.zValue, required this.timestamp});
  final int zValue;
  final DateTime timestamp;
  @override
  List<Object?> get props => [zValue, timestamp];
}
