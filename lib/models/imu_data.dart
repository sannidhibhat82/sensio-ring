import 'package:equatable/equatable.dart';

/// Single IMU sample: accel (X,Y,Z) and gyro (X,Y,Z), optionally mag.
class ImuSample extends Equatable {
  const ImuSample({
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    this.timestamp,
  });

  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [accX, accY, accZ, gyroX, gyroY, gyroZ];
}

/// Accelerometer-only sample (STARTACC).
class AccelSample extends Equatable {
  const AccelSample({
    required this.x,
    required this.y,
    required this.z,
    this.timestamp,
  });
  final double x;
  final double y;
  final double z;
  final DateTime? timestamp;
  @override
  List<Object?> get props => [x, y, z];
}

/// Magnetometer sample (STARTBMM).
class MagSample extends Equatable {
  const MagSample({
    required this.x,
    required this.y,
    required this.z,
    this.timestamp,
  });
  final double x;
  final double y;
  final double z;
  final DateTime? timestamp;
  @override
  List<Object?> get props => [x, y, z];
}
