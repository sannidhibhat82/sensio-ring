import 'package:equatable/equatable.dart';

enum SleepStage { wake, rem, light, deep }

/// One segment of sleep stage for timeline.
class SleepStageSegment extends Equatable {
  const SleepStageSegment({
    required this.stage,
    required this.start,
    required this.end,
  });

  final SleepStage stage;
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [stage, start, end];
}

/// Sleep summary for a night (from device or placeholder).
class SleepData extends Equatable {
  const SleepData({
    this.date,
    this.totalMinutes,
    this.qualityScore,
    this.stages = const [],
  });

  final DateTime? date;
  final int? totalMinutes;
  final int? qualityScore;
  final List<SleepStageSegment> stages;

  bool get hasData =>
      (totalMinutes != null && totalMinutes! > 0) ||
      (qualityScore != null) ||
      stages.isNotEmpty;

  @override
  List<Object?> get props => [date, totalMinutes, qualityScore, stages];
}
