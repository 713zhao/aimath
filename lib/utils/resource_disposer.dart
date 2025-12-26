import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mixin for managing disposable resources
mixin DisposableMixin {
  final List<_DisposableEntry> _disposables = [];
  bool _isDisposed = false;

  /// Check if disposed
  bool get isDisposed => _isDisposed;

  /// Register a stream subscription for auto-disposal
  StreamSubscription<T> registerSubscription<T>(StreamSubscription<T> subscription) {
    _disposables.add(_DisposableEntry(
      dispose: () => subscription.cancel(),
      name: 'StreamSubscription<$T>',
    ));
    return subscription;
  }

  /// Register a timer for auto-disposal
  Timer registerTimer(Timer timer) {
    _disposables.add(_DisposableEntry(
      dispose: () => timer.cancel(),
      name: 'Timer',
    ));
    return timer;
  }

  /// Register a ChangeNotifier for auto-disposal
  T registerNotifier<T extends ChangeNotifier>(T notifier) {
    _disposables.add(_DisposableEntry(
      dispose: () => notifier.dispose(),
      name: notifier.runtimeType.toString(),
    ));
    return notifier;
  }

  /// Register a custom disposable
  void registerDisposable(VoidCallback dispose, {String? name}) {
    _disposables.add(_DisposableEntry(
      dispose: dispose,
      name: name ?? 'Custom',
    ));
  }

  /// Dispose all registered resources
  @mustCallSuper
  void disposeResources() {
    if (_isDisposed) return;
    _isDisposed = true;

    for (final entry in _disposables.reversed) {
      try {
        entry.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('Error disposing ${entry.name}: $e');
        }
      }
    }
    _disposables.clear();
  }
}

class _DisposableEntry {
  final VoidCallback dispose;
  final String name;

  _DisposableEntry({required this.dispose, required this.name});
}

/// Controller base class with automatic resource disposal
abstract class DisposableController with DisposableMixin {
  void dispose() {
    disposeResources();
  }
}

/// Memory-efficient list that automatically shrinks
class ShrinkingList<T> {
  List<T> _items = [];
  final int maxSize;
  final int shrinkThreshold;

  ShrinkingList({
    this.maxSize = 1000,
    this.shrinkThreshold = 100,
  });

  List<T> get items => _items;
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;

  void add(T item) {
    _items.add(item);
    _shrinkIfNeeded();
  }

  void addAll(Iterable<T> items) {
    _items.addAll(items);
    _shrinkIfNeeded();
  }

  void _shrinkIfNeeded() {
    if (_items.length > maxSize + shrinkThreshold) {
      _items = _items.sublist(_items.length - maxSize);
    }
  }

  void clear() {
    _items = [];
  }

  T operator [](int index) => _items[index];
}
