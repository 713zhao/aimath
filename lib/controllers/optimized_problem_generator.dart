import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:aimath/models/math_problem.dart';
import 'package:aimath/config/difficulty_config.dart';
import 'package:aimath/utils/enums.dart';
import 'package:aimath/utils/performance_monitor.dart';

/// Optimized problem generator with batch pre-generation
class OptimizedProblemGenerator {
  final Random _random = Random();
  
  // Pre-generated problem queues per difficulty and operation
  final Map<String, Queue<MathProblem>> _problemQueues = {};
  
  // Track used problems to avoid repeats within session
  final Set<String> _usedProblemsInSession = {};
  
  // Batch size for pre-generation
  static const int _batchSize = 20;
  
  // Minimum queue size before triggering refill
  static const int _minQueueSize = 5;

  /// Get a unique key for problem queue
  String _getQueueKey(int levelId, Operation operation) {
    return '${levelId}_${operation.name}';
  }

  /// Pre-generate problems for a difficulty level and operations
  Future<void> preGenerateProblems(
    int levelId,
    List<Operation> operations,
  ) async {
    final monitor = PerformanceMonitor.instance;
    
    await monitor.measureAsync('preGenerateProblems', () async {
      for (final operation in operations) {
        final key = _getQueueKey(levelId, operation);
        _problemQueues.putIfAbsent(key, () => Queue<MathProblem>());
        
        // Generate batch of problems
        await _fillQueue(key, levelId, operation);
      }
    });
  }

  /// Fill a queue with pre-generated problems
  Future<void> _fillQueue(
    String key,
    int levelId,
    Operation operation,
  ) async {
    final queue = _problemQueues[key]!;
    final level = DifficultyConfig.getLevelById(levelId);
    if (level == null) return;
    
    // Use isolate-friendly approach - generate in small chunks
    for (int i = 0; i < _batchSize; i++) {
      final problem = _generateSingleProblem(level, operation);
      if (problem != null && !_usedProblemsInSession.contains(problem.id)) {
        queue.add(problem);
      }
      
      // Yield to prevent UI blocking
      if (i % 5 == 0) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  /// Generate a single problem
  MathProblem? _generateSingleProblem(
    DifficultyLevel level,
    Operation operation,
  ) {
    int firstNumber, secondNumber;
    
    switch (operation) {
      case Operation.add:
        firstNumber = _randomInRange(level.minNumber, level.maxNumber);
        secondNumber = _randomInRange(level.minNumber, level.maxNumber);
        break;
        
      case Operation.subtract:
        // Ensure positive result
        firstNumber = _randomInRange(level.minNumber, level.maxNumber);
        secondNumber = _randomInRange(level.minNumber, firstNumber);
        break;
        
      case Operation.multiply:
        // Use smaller range for multiplication to keep answers reasonable
        final maxMultiplier = (level.maxNumber ~/ 10).clamp(2, 12);
        firstNumber = _randomInRange(level.minNumber, level.maxNumber);
        secondNumber = _randomInRange(1, maxMultiplier);
        break;
        
      case Operation.divide:
        // Generate division that results in whole numbers
        secondNumber = _randomInRange(1, 12); // divisor
        final answer = _randomInRange(level.minNumber, level.maxNumber ~/ secondNumber.clamp(1, 12));
        firstNumber = answer * secondNumber; // dividend
        break;
    }

    return MathProblem(
      id: '${firstNumber}_${operation.symbol}_$secondNumber',
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      operation: operation,
      difficultyLevelId: level.id,
      createdAt: DateTime.now(),
    );
  }

  int _randomInRange(int min, int max) {
    if (min >= max) return min;
    return min + _random.nextInt(max - min + 1);
  }

  /// Get next problem (instant - from pre-generated queue)
  MathProblem getNextProblem(
    int levelId,
    List<Operation> operations,
  ) {
    final monitor = PerformanceMonitor.instance;
    
    return monitor.measureSync('getNextProblem', () {
      // Select random operation
      final operation = operations[_random.nextInt(operations.length)];
      final key = _getQueueKey(levelId, operation);
      
      // Ensure queue exists and has problems
      if (!_problemQueues.containsKey(key) || _problemQueues[key]!.isEmpty) {
        // Fallback: generate on-demand (should rarely happen)
        final level = DifficultyConfig.getLevelById(levelId)!;
        final problem = _generateSingleProblem(level, operation)!;
        _usedProblemsInSession.add(problem.id);
        return problem;
      }
      
      // Get from queue
      MathProblem? problem;
      final queue = _problemQueues[key]!;
      
      // Find unused problem
      while (queue.isNotEmpty) {
        final candidate = queue.removeFirst();
        if (!_usedProblemsInSession.contains(candidate.id)) {
          problem = candidate;
          break;
        }
      }
      
      // Fallback if all were used
      if (problem == null) {
        final level = DifficultyConfig.getLevelById(levelId)!;
        problem = _generateSingleProblem(level, operation)!;
      }
      
      _usedProblemsInSession.add(problem.id);
      
      // Trigger background refill if queue is low
      if (queue.length < _minQueueSize) {
        _scheduleRefill(key, levelId, operation);
      }
      
      return problem;
    });
  }

  /// Schedule background queue refill
  void _scheduleRefill(String key, int levelId, Operation operation) {
    // Use microtask to avoid blocking
    Future.microtask(() => _fillQueue(key, levelId, operation));
  }

  /// Clear session history (call at start of new session)
  void startNewSession() {
    _usedProblemsInSession.clear();
  }

  /// Clear all pre-generated problems
  void clearAll() {
    _problemQueues.clear();
    _usedProblemsInSession.clear();
  }

  /// Get queue statistics (for debugging)
  Map<String, int> getQueueStats() {
    return _problemQueues.map((key, queue) => MapEntry(key, queue.length));
  }
}
