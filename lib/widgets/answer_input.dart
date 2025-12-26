import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Widget for numeric answer input with large, touch-friendly buttons
class AnswerInput extends StatefulWidget {
  final Function(String answer) onSubmit;
  final VoidCallback onSkip;
  final TextEditingController? controller;
  final bool isSubmitting;

  const AnswerInput({
    Key? key,
    required this.onSubmit,
    required this.onSkip,
    this.controller,
    this.isSubmitting = false,
  }) : super(key: key);

  @override
  State<AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<AnswerInput> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input field
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            border: Border.all(
              color: _controller.text.isEmpty 
                ? AppColors.lightGray 
                : AppColors.primaryBlue,
              width: _controller.text.isEmpty ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // Only allow digits and minus sign
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                  ],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.lightGray,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              // Clear button
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () => _controller.clear(),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.clear,
                      color: AppColors.errorRed,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Action buttons
        Row(
          children: [
            // Skip button
            Expanded(
              child: ElevatedButton(
                onPressed: widget.isSubmitting ? null : widget.onSkip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppConstants.smallPadding),

            // Submit button
            Expanded(
              child: ElevatedButton(
                onPressed: widget.isSubmitting || _controller.text.isEmpty
                  ? null
                  : () => widget.onSubmit(_controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
