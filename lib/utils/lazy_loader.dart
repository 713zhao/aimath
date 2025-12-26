import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lazy loader for deferred data loading
class LazyLoader<T> {
  final Future<T> Function() _loader;
  T? _value;
  bool _isLoading = false;
  bool _hasLoaded = false;
  Completer<T>? _completer;

  LazyLoader(this._loader);

  /// Check if data has been loaded
  bool get hasLoaded => _hasLoaded;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Get value, loading if necessary
  Future<T> get() async {
    if (_hasLoaded && _value != null) {
      return _value!;
    }

    if (_isLoading && _completer != null) {
      return _completer!.future;
    }

    _isLoading = true;
    _completer = Completer<T>();

    try {
      _value = await _loader();
      _hasLoaded = true;
      _completer!.complete(_value);
      return _value!;
    } catch (e) {
      _completer!.completeError(e);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Get value synchronously (returns null if not loaded)
  T? getSync() => _value;

  /// Invalidate cache and force reload on next get
  void invalidate() {
    _value = null;
    _hasLoaded = false;
    _completer = null;
  }

  /// Preload data in background
  void preload() {
    if (!_hasLoaded && !_isLoading) {
      get().catchError((_) {});
    }
  }
}

/// Paginated lazy loader for large datasets
class PaginatedLazyLoader<T> {
  final Future<List<T>> Function(int page, int pageSize) _loader;
  final int pageSize;
  
  final List<T> _items = [];
  int _currentPage = 0;
  bool _hasMorePages = true;
  bool _isLoading = false;

  PaginatedLazyLoader(this._loader, {this.pageSize = 20});

  /// Get all loaded items
  List<T> get items => List.unmodifiable(_items);

  /// Check if more pages available
  bool get hasMorePages => _hasMorePages;

  /// Check if currently loading
  bool get isLoading => _isLoading;

  /// Load next page
  Future<List<T>> loadNextPage() async {
    if (_isLoading || !_hasMorePages) {
      return [];
    }

    _isLoading = true;
    try {
      final newItems = await _loader(_currentPage, pageSize);
      
      if (newItems.length < pageSize) {
        _hasMorePages = false;
      }
      
      _items.addAll(newItems);
      _currentPage++;
      
      return newItems;
    } finally {
      _isLoading = false;
    }
  }

  /// Reset and reload from beginning
  Future<void> reset() async {
    _items.clear();
    _currentPage = 0;
    _hasMorePages = true;
    await loadNextPage();
  }

  /// Get item at index, loading more if needed
  Future<T?> getAt(int index) async {
    while (index >= _items.length && _hasMorePages) {
      await loadNextPage();
    }
    
    if (index < _items.length) {
      return _items[index];
    }
    return null;
  }
}

/// Cache with expiration
class ExpiringCache<K, V> {
  final Duration expiration;
  final Map<K, _CacheEntry<V>> _cache = {};

  ExpiringCache({this.expiration = const Duration(minutes: 5)});

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }

  /// Set value in cache
  void set(K key, V value) {
    _cache[key] = _CacheEntry(value, DateTime.now().add(expiration));
  }

  /// Remove value from cache
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear all cached values
  void clear() {
    _cache.clear();
  }

  /// Remove expired entries
  void cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
