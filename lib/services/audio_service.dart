import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Service for managing audio and sound effects
/// Implements singleton pattern with mute control and volume management
class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  // Audio players for different sound categories
  late AudioPlayer _effectsPlayer;
  bool _isInitialized = false;
  bool _isMuted = false;
  double _volume = 0.8;

  // Asset paths for sounds
  static const String _correctSoundPath = 'assets/sounds/correct.mp3';
  static const String _incorrectSoundPath = 'assets/sounds/incorrect.mp3';
  static const String _levelUpSoundPath = 'assets/sounds/level_up.mp3';
  static const String _clickSoundPath = 'assets/sounds/click.mp3';
  static const String _achievementSoundPath = 'assets/sounds/achievement.mp3';
  static const String _streakSoundPath = 'assets/sounds/streak.mp3';

  // Sound duration cache
  final Map<String, Duration> _soundDurations = {};

  bool get isMuted => _isMuted;
  double get volume => _volume;
  bool get isInitialized => _isInitialized;

  /// Initialize audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _effectsPlayer = AudioPlayer();

      // Set up volume
      await _effectsPlayer.setVolume(_volume);

      // Pre-load sound durations for better UX
      _preloadSoundDurations();

      _isInitialized = true;
      print('AudioService initialized successfully');
    } catch (e) {
      print('Error initializing AudioService: $e');
      if (kDebugMode) rethrow;
    }
  }

  /// Pre-load sound durations for all audio assets
  Future<void> _preloadSoundDurations() async {
    final paths = [
      _correctSoundPath,
      _incorrectSoundPath,
      _levelUpSoundPath,
      _clickSoundPath,
      _achievementSoundPath,
      _streakSoundPath,
    ];

    for (final path in paths) {
      try {
        await _effectsPlayer.setAsset(path);
        _soundDurations[path] = _effectsPlayer.duration ?? Duration.zero;
      } catch (e) {
        print('Error pre-loading sound $path: $e');
        // Continue with other sounds
      }
    }
  }

  /// Play correct answer sound
  Future<void> playCorrectSound() async {
    await _playSound(_correctSoundPath, volume: 1.0);
  }

  /// Play incorrect answer sound
  Future<void> playIncorrectSound() async {
    await _playSound(_incorrectSoundPath, volume: 0.9);
  }

  /// Play level up sound
  Future<void> playLevelUpSound() async {
    await _playSound(_levelUpSoundPath, volume: 1.0);
  }

  /// Play button click sound
  Future<void> playClickSound() async {
    await _playSound(_clickSoundPath, volume: 0.6);
  }

  /// Play achievement unlocked sound
  Future<void> playAchievementSound() async {
    await _playSound(_achievementSoundPath, volume: 1.0);
  }

  /// Play streak milestone sound
  Future<void> playStreakSound() async {
    await _playSound(_streakSoundPath, volume: 1.0);
  }

  /// Internal method to play sound with error handling
  Future<void> _playSound(
    String assetPath, {
    double volume = 1.0,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isMuted) {
      return; // Don't play if muted
    }

    try {
      // Set volume for this specific playback
      final effectiveVolume = (volume * _volume).clamp(0.0, 1.0);
      await _effectsPlayer.setVolume(effectiveVolume);

      // Load and play the sound
      await _effectsPlayer.setAsset(assetPath);
      await _effectsPlayer.play();
    } catch (e) {
      print('Error playing sound $assetPath: $e');
      // Silently fail - app should continue working without audio
    }
  }

  /// Toggle mute on/off
  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    print('Audio mute: $_isMuted');
  }

  /// Set mute state explicitly
  Future<void> setMute(bool muted) async {
    _isMuted = muted;
    print('Audio mute set to: $_isMuted');
  }

  /// Set volume level (0.0 to 1.0)
  Future<void> setVolume(double newVolume) async {
    if (!_isInitialized) {
      await initialize();
    }

    _volume = newVolume.clamp(0.0, 1.0);

    try {
      await _effectsPlayer.setVolume(_volume);
      print('Volume set to: $_volume');
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Get current volume
  double getVolume() => _volume;

  /// Get sound duration by path
  Duration? getSoundDuration(String assetPath) {
    return _soundDurations[assetPath];
  }

  /// Check if audio is currently playing
  bool get isPlaying => _effectsPlayer.playing;

  /// Stop current playback
  Future<void> stop() async {
    if (_isInitialized) {
      try {
        await _effectsPlayer.stop();
      } catch (e) {
        print('Error stopping audio: $e');
      }
    }
  }

  /// Pause current playback
  Future<void> pause() async {
    if (_isInitialized) {
      try {
        await _effectsPlayer.pause();
      } catch (e) {
        print('Error pausing audio: $e');
      }
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (_isInitialized) {
      try {
        await _effectsPlayer.play();
      } catch (e) {
        print('Error resuming audio: $e');
      }
    }
  }

  /// Dispose of audio resources (call on app shutdown)
  Future<void> dispose() async {
    try {
      await _effectsPlayer.dispose();
      _isInitialized = false;
      print('AudioService disposed');
    } catch (e) {
      print('Error disposing AudioService: $e');
    }
  }

  /// Get audio status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isMuted': _isMuted,
      'volume': _volume,
      'isPlaying': isPlaying,
      'soundsLoaded': _soundDurations.length,
    };
  }
}
