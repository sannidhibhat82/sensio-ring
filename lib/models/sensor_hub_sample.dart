import 'package:equatable/equatable.dart';

/// One 44-byte Sensor Hub raw sample: PPG (18) + Acc (6) + metadata.
class SensorHubSample extends Equatable {
  const SensorHubSample({
    required this.greenPd1,
    required this.greenPd2,
    required this.irPd1,
    required this.irPd2,
    required this.redPd1,
    required this.redPd2,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.operatingMode,
    required this.hr,
    required this.hrConf,
    required this.rr,
    required this.rrConf,
    required this.activityClass,
    required this.r,
    required this.spo2Conf,
    required this.spo2,
    required this.percentComplete,
    required this.lowSignalQualityFlag,
    required this.motionFlag,
    required this.lowPiFlag,
    required this.unreliableFlag,
    required this.scdContactState,
    this.timestamp,
  });

  final int greenPd1;
  final int greenPd2;
  final int irPd1;
  final int irPd2;
  final int redPd1;
  final int redPd2;
  final int accX;
  final int accY;
  final int accZ;
  final int operatingMode;
  final int hr;
  final int hrConf;
  final int rr;
  final int rrConf;
  final int activityClass;
  final int r;
  final int spo2Conf;
  final int spo2;
  final int percentComplete;
  final int lowSignalQualityFlag;
  final int motionFlag;
  final int lowPiFlag;
  final int unreliableFlag;
  final int scdContactState;
  final DateTime? timestamp;

  @override
  List<Object?> get props => [
        greenPd1,
        greenPd2,
        irPd1,
        irPd2,
        redPd1,
        redPd2,
        accX,
        accY,
        accZ,
        hr,
        rr,
        spo2,
      ];
}
