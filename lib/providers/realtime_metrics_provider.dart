import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/realtime_metrics.dart';

/// Holds latest realtime metrics and time-series for charts.
/// Screens that start BLE streams update this via the notifier.
class RealtimeMetricsNotifier extends StateNotifier<RealtimeMetrics> {
  RealtimeMetricsNotifier() : super(const RealtimeMetrics());

  static const int maxHistoryLength = 120;

  void setHeartRate(int bpm) {
    final now = DateTime.now();
    final newHr = [...state.hrHistory, TimeSeriesPoint(now, bpm)];
    if (newHr.length > maxHistoryLength) newHr.removeAt(0);
    state = state.copyWith(
      heartRateBpm: bpm,
      lastUpdated: now,
      hrHistory: newHr,
    );
  }

  void setHrv(int ms) {
    state = state.copyWith(hrvMs: ms, lastUpdated: DateTime.now());
  }

  void setTemperature(double celsius) {
    final now = DateTime.now();
    final newTemp = [...state.tempHistory, TimeSeriesPoint(now, celsius)];
    if (newTemp.length > maxHistoryLength) newTemp.removeAt(0);
    state = state.copyWith(
      temperatureCelsius: celsius,
      lastUpdated: now,
      tempHistory: newTemp,
    );
  }

  void setSteps(int steps) {
    state = state.copyWith(steps: steps, lastUpdated: DateTime.now());
  }

  void setActivityIntensity(int intensity) {
    final now = DateTime.now();
    final newSteps = [...state.stepsHistory, TimeSeriesPoint(now, intensity)];
    if (newSteps.length > maxHistoryLength) newSteps.removeAt(0);
    state = state.copyWith(
      activityIntensity: intensity,
      lastUpdated: now,
      stepsHistory: newSteps,
    );
  }

  void clear() {
    state = const RealtimeMetrics();
  }
}

final realtimeMetricsProvider =
    StateNotifierProvider<RealtimeMetricsNotifier, RealtimeMetrics>((ref) {
  return RealtimeMetricsNotifier();
});
