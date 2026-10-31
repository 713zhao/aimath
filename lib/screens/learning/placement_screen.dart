import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../learning/core/placement_test.dart';
import '../../providers/learning_provider.dart';
import '../../utils/colors.dart';
import 'answer_widgets.dart';

/// "Find my level": a short adaptive quiz that places the child on the
/// skill map. No right/wrong feedback, so a hard question never feels like
/// failing.
class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  late final PlacementTest _test;
  bool _started = false;
  bool _saving = false;

  static const _cheers = ['Nice!', 'Got it!', 'Next one!', 'Keep going!', 'Great thinking!'];

  @override
  void initState() {
    super.initState();
    _test = context.read<LearningProvider>().startPlacement();
  }

  Future<void> _submit(String value) async {
    setState(() => _test.submit(value));
    if (_test.isFinished && !_saving) {
      _saving = true;
      final provider = context.read<LearningProvider>();
      await provider.finishPlacement(_test);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${context.read<LearningProvider>().subject.name}: find my level'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: !_started
              ? _intro()
              : _test.isFinished
                  ? _done()
                  : _question(),
        ),
      ),
    );
  }

  Widget _intro() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.explore, size: 96, color: AppColors.primaryBlue),
        const SizedBox(height: 24),
        const Text(
          'Let\'s find where to start!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Answer ${context.read<LearningProvider>().subject.placementLengthHint} questions. '
          'Some will be easy and some tricky — that\'s on purpose. '
          'If you don\'t know one, just make your best guess.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => setState(() => _started = true),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start', style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _question() {
    final item = _test.currentItem!;
    final asked = _test.questionsAsked;
    return Column(
      children: [
        LinearProgressIndicator(
          value: _test.progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text(
          asked == 0 ? 'Here we go!' : _cheers[asked % _cheers.length],
          style: const TextStyle(fontSize: 18, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        ItemPrompt(item),
        const Spacer(),
        ItemAnswerInput(key: ValueKey(asked), item: item, onSubmit: _submit),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _done() {
    final model = context.watch<LearningProvider>().model;
    final known = _test.knownSkills.length;
    final next = model?.recommendedSkill;
    final graph = context.read<LearningProvider>().graph;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 96, color: AppColors.accentGold),
        const SizedBox(height: 16),
        const Text('All done!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          known == 0
              ? 'We\'ll start right at the beginning.'
              : 'You already know $known skill${known == 1 ? '' : 's'}!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
        if (next != null) ...[
          const SizedBox(height: 8),
          Text(
            'Next up: ${graph[next].name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text('See my skill map', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
