import 'package:equatable/equatable.dart';

/// Single temperature reading in Celsius.
/// Raw from device: (byte1 << 8 | byte2) * 0.005
class TemperatureReading extends Equatable {
  const TemperatureReading({
    required this.celsius,
    required this.raw,
    required this.timestamp,
  });

  final double celsius;
  final int raw;
  final DateTime timestamp;

  @override
  List<Object?> get props => [celsius, raw, timestamp];
}
