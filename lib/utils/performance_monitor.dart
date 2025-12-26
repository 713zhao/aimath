import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utility for tracking app metrics
class PerformanceMonitor {
  PerformanceMonitor._();
  static final PerformanceMonitor instance = PerformanceMonitor._();

  final Map<String, List<Duration>> _measurements = {};
  final Map<String, Stopwatch> _activeTimers = {};
  
  bool _isMonitoring = false;
  Timer? _frameRateTimer;
  final List<double> _frameRates = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  /// Start monitoring frame rate
  void startFrameRateMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameCount = 0;
    _lastFrameTime = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    
    _frameRateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastFrameTime != null) {
        final fps = _frameCount.toDouble();
        _frameRates.add(fps);
        if (_frameRates.length > 60) {
          _frameRates.removeAt(0);
        }
        _frameCount = 0;
        
        if (kDebugMode && fps < 55) {
          developer.log('Warning: Low frame rate detected: ${fps.toStringAsFixed(1)} FPS',
            name: 'PerformanceMonitor');
        }
      }
    });
  }

  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;
    _frameCount++;
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Stop monitoring frame rate
  void stopFrameRateMonitoring() {
    _isMonitoring = false;
    _frameRateTimer?.cancel();
    _frameRateTimer = null;
  }

  /// Get average frame rate over the monitoring period
  double get averageFrameRate {
    if (_frameRates.isEmpty) return 60.0;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }

  /// Get current frame rate
  double get currentFrameRate {
    return _frameRates.isNotEmpty ? _frameRates.last : 60.0;
  }

  /// Start timing an operation
  void startTimer(String operationName) {
    _activeTimers[operationName] = Stopwatch()..start();
  }

  /// Stop timing and record the measurement
  Duration? stopTimer(String operationName) {
    final stopwatch = _activeTimers.remove(operationName);
    if (stopwatch == null) return null;
    
    stopwatch.stop();
    final duration = stopwatch.elapsed;
    
    _measurements.putIfAbsent(operationName, () => []);
    _measurements[operationName]!.add(duration);
    
    // Keep only last 100 measurements
    if (_measurements[operationName]!.length > 100) {
      _measurements[operationName]!.removeAt(0);
    }
    
    if (kDebugMode) {
      developer.log('$operationName: ${duration.inMilliseconds}ms',
        name: 'PerformanceMonitor');
    }
    
    return duration;
  }

  /// Measure an async operation
  Future<T> measureAsync<T>(String operationName, Future<T> Function() operation) async {
    startTimer(operationName);
    try {
      return await operation();
    } finally {
      stopTimer(operationName);
    }
  }

  /// Measure a sync operation
  T measureSync<T>(String operationName, T Function() operation) {
    startTimer(operationName);
    try {
      return operation();
    } finally {
      stopTimer(operationName);
    }
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return null;
    
    final totalMicroseconds = measurements
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }

  /// Get performance report
  Map<String, dynamic> getReport() {
    final report = <String, dynamic>{
      'averageFrameRate': averageFrameRate,
      'currentFrameRate': currentFrameRate,
      'operations': <String, Map<String, dynamic>>{},
    };

    for (final entry in _measurements.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final avgMs = durations
            .map((d) => d.inMicroseconds)
            .reduce((a, b) => a + b) / durations.length / 1000;
        final maxMs = durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a > b ? a : b);
        final minMs = durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a < b ? a : b);
        
        report['operations'][entry.key] = {
          'averageMs': avgMs.toStringAsFixed(2),
          'maxMs': maxMs,
          'minMs': minMs,
          'sampleCount': durations.length,
        };
      }
    }

    return report;
  }

  /// Clear all measurements
  void clearMeasurements() {
    _measurements.clear();
    _frameRates.clear();
  }

  /// Check if operation meets performance target
  bool meetsTarget(String operationName, Duration target) {
    final avg = getAverageDuration(operationName);
    return avg == null || avg <= target;
  }
}

/// Performance targets for the app
class PerformanceTargets {
  PerformanceTargets._();

  static const Duration problemGeneration = Duration(milliseconds: 100);
  static const Duration appStartup = Duration(seconds: 2);
  static const Duration animationFrame = Duration(milliseconds: 16); // 60 FPS
  static const Duration storageRead = Duration(milliseconds: 50);
  static const Duration storageWrite = Duration(milliseconds: 100);
  static const double minFrameRate = 55.0;
}
