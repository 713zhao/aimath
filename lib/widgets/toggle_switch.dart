import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Custom toggle switch widget with smooth animation
/// Displays on/off state with visual feedback
class ToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  const ToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.successGreen,
    this.inactiveColor = AppColors.lightGray,
  }) : super(key: key);

  @override
  State<ToggleSwitch> createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final backgroundColor = Color.lerp(
            widget.inactiveColor,
            widget.activeColor,
            _animation.value,
          )!;

          return Container(
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: backgroundColor,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 2 + (_animation.value * 22),
                  top: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
