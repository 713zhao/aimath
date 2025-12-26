/// Performance configuration and thresholds
class PerformanceConfig {
  PerformanceConfig._();

  // Problem generation
  static const int problemBatchSize = 20;
  static const int minQueueSize = 5;
  static const Duration maxProblemGenerationTime = Duration(milliseconds: 100);

  // App startup
  static const Duration maxStartupTime = Duration(seconds: 2);
  static const Duration splashMinDuration = Duration(milliseconds: 500);

  // Animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const double targetFrameRate = 60.0;
  static const double minAcceptableFrameRate = 55.0;

  // Storage
  static const Duration maxStorageReadTime = Duration(milliseconds: 50);
  static const Duration maxStorageWriteTime = Duration(milliseconds: 100);
  static const int maxCachedSessions = 50;
  static const int maxCachedAttempts = 500;

  // Memory
  static const int maxProblemHistorySize = 100;
  static const int maxFrameRateSamples = 60;

  // Lazy loading
  static const int sessionsPageSize = 20;
  static const Duration cacheExpiration = Duration(minutes: 5);

  // Debounce/throttle
  static const Duration inputDebounce = Duration(milliseconds: 300);
  static const Duration saveDebounce = Duration(seconds: 1);
}
