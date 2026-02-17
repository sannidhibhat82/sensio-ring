import 'package:equatable/equatable.dart';

/// User-facing realtime metrics from device streams.
class RealtimeMetrics extends Equatable {
  const RealtimeMetrics({
    this.heartRateBpm,
    this.hrvMs,
    this.temperatureCelsius,
    this.steps,
    this.activityIntensity,
    this.lastUpdated,
    this.tempHistory = const [],
    this.hrHistory = const [],
    this.stepsHistory = const [],
  });

  final int? heartRateBpm;
  final int? hrvMs;
  final double? temperatureCelsius;
  final int? steps;
  final int? activityIntensity;
  final DateTime? lastUpdated;
  final List<TimeSeriesPoint<double>> tempHistory;
  final List<TimeSeriesPoint<int>> hrHistory;
  final List<TimeSeriesPoint<int>> stepsHistory;

  RealtimeMetrics copyWith({
    int? heartRateBpm,
    int? hrvMs,
    double? temperatureCelsius,
    int? steps,
    int? activityIntensity,
    DateTime? lastUpdated,
    List<TimeSeriesPoint<double>>? tempHistory,
    List<TimeSeriesPoint<int>>? hrHistory,
    List<TimeSeriesPoint<int>>? stepsHistory,
  }) {
    return RealtimeMetrics(
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      hrvMs: hrvMs ?? this.hrvMs,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      steps: steps ?? this.steps,
      activityIntensity: activityIntensity ?? this.activityIntensity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      tempHistory: tempHistory ?? this.tempHistory,
      hrHistory: hrHistory ?? this.hrHistory,
      stepsHistory: stepsHistory ?? this.stepsHistory,
    );
  }

  @override
  List<Object?> get props => [
        heartRateBpm,
        hrvMs,
        temperatureCelsius,
        steps,
        activityIntensity,
        lastUpdated,
        tempHistory,
        hrHistory,
        stepsHistory,
      ];
}

/// Single time-series point for charts.
class TimeSeriesPoint<T extends num> extends Equatable {
  const TimeSeriesPoint(this.time, this.value);

  final DateTime time;
  final T value;

  @override
  List<Object?> get props => [time, value];
}
