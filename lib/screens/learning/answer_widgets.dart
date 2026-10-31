import 'package:flutter/material.dart';

import '../../learning/core/learning_item.dart';
import '../../utils/colors.dart';

/// Big, touch-friendly number pad for young children. Shows the typed answer
/// and calls [onSubmit] with the parsed number.
class NumberPad extends StatefulWidget {
  final ValueChanged<int> onSubmit;
  final bool enabled;
  final int maxDigits;

  const NumberPad({super.key, required this.onSubmit, this.enabled = true, this.maxDigits = 4});

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  String _value = '';

  void _tap(String key) {
    if (!widget.enabled) return;
    setState(() {
      if (key == '⌫') {
        if (_value.isNotEmpty) _value = _value.substring(0, _value.length - 1);
      } else if (key == '✓') {
        final n = int.tryParse(_value);
        if (n != null) {
          widget.onSubmit(n);
          _value = '';
        }
      } else if (_value.length < widget.maxDigits) {
        _value = _value == '0' ? key : _value + key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', '✓'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64,
          width: 180,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue, width: 2),
          ),
          child: Text(
            _value.isEmpty ? '?' : _value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: _value.isEmpty ? AppColors.secondaryText : AppColors.darkText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              for (final k in keys)
                ElevatedButton(
                  onPressed: widget.enabled ? () => _tap(k) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: k == '✓'
                        ? AppColors.successGreen
                        : k == '⌫'
                            ? AppColors.warningOrange
                            : Colors.white,
                    foregroundColor: k == '✓' || k == '⌫' ? Colors.white : AppColors.darkText,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(k, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The item's question, shown large, with its optional instruction.
class ItemPrompt extends StatelessWidget {
  final LearningItem item;

  const ItemPrompt(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final short = item.prompt.length <= 16;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (short)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.prompt,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          )
        else
          Text(
            item.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
        if (item.instruction != null) ...[
          const SizedBox(height: 8),
          Text(
            item.instruction!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.secondaryText),
          ),
        ],
      ],
    );
  }
}

/// Picks the right input for the item's [AnswerFormat].
class ItemAnswerInput extends StatelessWidget {
  final LearningItem item;
  final ValueChanged<String> onSubmit;
  final bool enabled;

  const ItemAnswerInput({super.key, required this.item, required this.onSubmit, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    switch (item.format) {
      case AnswerFormat.number:
        return NumberPad(enabled: enabled, onSubmit: (n) => onSubmit('$n'));
      case AnswerFormat.choice:
        return ChoiceButtons(choices: item.choices ?? const [], enabled: enabled, onSubmit: onSubmit);
      case AnswerFormat.text:
        return TextAnswer(enabled: enabled, onSubmit: onSubmit);
    }
  }
}

/// Big tappable options, one per row.
class ChoiceButtons extends StatelessWidget {
  final List<String> choices;
  final ValueChanged<String> onSubmit;
  final bool enabled;

  const ChoiceButtons({super.key, required this.choices, required this.onSubmit, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: enabled ? () => onSubmit(c) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.darkText,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(c, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
        ],
      ),
    );
  }
}

/// A text box with a big check button, for typed answers.
class TextAnswer extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool enabled;

  const TextAnswer({super.key, required this.onSubmit, this.enabled = true});

  @override
  State<TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<TextAnswer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (!widget.enabled || text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: 'type here',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: widget.enabled ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('✓', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
