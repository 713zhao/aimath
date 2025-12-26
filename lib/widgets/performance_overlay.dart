import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aimath/utils/performance_monitor.dart';

/// Debug overlay showing performance metrics
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  Timer? _updateTimer;
  double _fps = 60.0;
  Map<String, dynamic> _report = {};

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  @override
  void didUpdateWidget(PerformanceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _startMonitoring();
    } else if (!widget.enabled && oldWidget.enabled) {
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    PerformanceMonitor.instance.startFrameRateMonitoring();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _fps = PerformanceMonitor.instance.currentFrameRate;
          _report = PerformanceMonitor.instance.getReport();
        });
      }
    });
  }

  void _stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;
    PerformanceMonitor.instance.stopFrameRateMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: _buildOverlay(),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    final fpsColor = _fps >= 55 ? Colors.green : (_fps >= 30 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed, size: 14, color: fpsColor),
              const SizedBox(width: 4),
              Text(
                '${_fps.toStringAsFixed(1)} FPS',
                style: TextStyle(
                  color: fpsColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (_report['operations'] != null) ...[
            const SizedBox(height: 4),
            ..._buildOperationStats(),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildOperationStats() {
    final operations = _report['operations'] as Map<String, dynamic>;
    return operations.entries.take(3).map((entry) {
      final stats = entry.value as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '${entry.key}: ${stats['averageMs']}ms',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      );
    }).toList();
  }
}

/// Frame rate indicator widget
class FrameRateIndicator extends StatefulWidget {
  const FrameRateIndicator({super.key});

  @override
  State<FrameRateIndicator> createState() => _FrameRateIndicatorState();
}

class _FrameRateIndicatorState extends State<FrameRateIndicator> {
  Timer? _timer;
  double _fps = 60.0;

  @override
  void initState() {
    super.initState();
    PerformanceMonitor.instance.startFrameRateMonitoring();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _fps = PerformanceMonitor.instance.currentFrameRate;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _fps >= 55 ? Colors.green : (_fps >= 30 ? Colors.orange : Colors.red);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        '${_fps.toStringAsFixed(0)} FPS',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
