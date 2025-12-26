import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget for displaying animated feedback (correct/incorrect)
class FeedbackAnimation extends StatefulWidget {
  final bool isCorrect;
  final Duration duration;

  const FeedbackAnimation({
    Key? key,
    required this.isCorrect,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<FeedbackAnimation> createState() => _FeedbackAnimationState();
}

class _FeedbackAnimationState extends State<FeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Large icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isCorrect
                        ? AppColors.successGreen.withValues(alpha: 0.1)
                        : AppColors.errorRed.withValues(alpha: 0.1),
                    border: Border.all(
                      color: widget.isCorrect
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isCorrect ? Icons.check : Icons.close,
                      size: 60,
                      color: widget.isCorrect
                          ? AppColors.successGreen
                          : AppColors.errorRed,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Message
                Text(
                  widget.isCorrect ? 'Correct!' : 'Not Quite!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: widget.isCorrect
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Confetti particle for celebration
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.drawCircle(
        particle.offset,
        particle.size,
        Paint()..color = particle.color.withValues(alpha: particle.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.particles != particles;
  }
}

/// Single confetti particle
class Particle {
  final Offset offset;
  final double size;
  final Color color;
  final double opacity;

  Particle({
    required this.offset,
    required this.size,
    required this.color,
    required this.opacity,
  });
}
