import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Banner widget shown when student levels up
class LevelUpBanner extends StatefulWidget {
  final int newLevel;
  final int nextLevelThreshold;

  const LevelUpBanner({
    Key? key,
    required this.newLevel,
    required this.nextLevelThreshold,
  }) : super(key: key);

  @override
  State<LevelUpBanner> createState() => _LevelUpBannerState();
}

class _LevelUpBannerState extends State<LevelUpBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getLevelEmoji(int level) {
    switch (level) {
      case 1:
        return '🟢';
      case 2:
        return '🟡';
      case 3:
        return '🔴';
      case 4:
        return '⭐';
      default:
        return '✨';
    }
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      case 4:
        return 'Expert';
      default:
        return 'Master';
    }
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Numbers 1-9';
      case 2:
        return 'Numbers 10-99';
      case 3:
        return 'Numbers 100-999';
      case 4:
        return 'Numbers 1000+';
      default:
        return 'Elite';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.successGreen.withValues(alpha: 0.9),
                AppColors.successGreen.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: AppColors.successGreen,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.successGreen.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji animation
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _getLevelEmoji(widget.newLevel),
                  style: const TextStyle(fontSize: 40),
                ),
              ),

              const SizedBox(width: AppConstants.defaultPadding),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level Up!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.tinyPadding),
                    Text(
                      'You reached ${_getLevelName(widget.newLevel)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getLevelDescription(widget.newLevel),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Star burst animation
              Text(
                '⭐',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.yellow.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
