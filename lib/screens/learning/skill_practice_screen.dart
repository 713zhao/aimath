import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../learning/core/learning_item.dart';
import '../../learning/core/skill_graph.dart';
import '../../providers/learning_provider.dart';
import '../../utils/colors.dart';
import 'answer_widgets.dart';

/// Practise one skill until it is mastered. Wrong answers get a hint aimed
/// at the specific mistake (forgot to carry, borrowed wrong, …).
class SkillPracticeScreen extends StatefulWidget {
  final String skillId;

  const SkillPracticeScreen({super.key, required this.skillId});

  @override
  State<SkillPracticeScreen> createState() => _SkillPracticeScreenState();
}

class _SkillPracticeScreenState extends State<SkillPracticeScreen> {
  late LearningItem _item;
  PracticeFeedback? _feedback;
  int _answered = 0;
  int _correct = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _item = context.read<LearningProvider>().nextItem(widget.skillId);
  }

  Future<void> _submit(String value) async {
    if (_busy) return;
    _busy = true;
    final fb = await context.read<LearningProvider>().answer(_item, value);
    if (!mounted) return;
    setState(() {
      _feedback = fb;
      _answered++;
      if (fb.correct) _correct++;
      _busy = false;
    });
    if (fb.correct && !fb.justMastered) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted && _feedback == fb) _next();
    }
  }

  void _next() {
    setState(() {
      _feedback = null;
      _item = context.read<LearningProvider>().nextItem(widget.skillId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningProvider>();
    final skill = provider.graph[widget.skillId];
    final mastery = provider.model?.of(widget.skillId).pKnown ?? 0;
    final fb = _feedback;

    return Scaffold(
      appBar: AppBar(title: Text(skill.name), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: fb != null && fb.justMastered
              ? _mastered(provider, skill)
              : Column(
                  children: [
                    _masteryBar(mastery),
                    const SizedBox(height: 4),
                    Text('$_correct / $_answered correct', style: const TextStyle(color: AppColors.secondaryText)),
                    const Spacer(),
                    ItemPrompt(_item),
                    const SizedBox(height: 16),
                    SizedBox(height: 110, child: _feedbackPanel(fb)),
                    const Spacer(),
                    ItemAnswerInput(
                      key: ValueKey(_answered),
                      item: _item,
                      enabled: fb == null,
                      onSubmit: _submit,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _masteryBar(double p) {
    return Row(
      children: [
        const Icon(Icons.star, color: AppColors.accentGold),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: (p / 0.95).clamp(0.0, 1.0),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
            color: AppColors.accentGold,
            backgroundColor: AppColors.lightGray,
          ),
        ),
      ],
    );
  }

  Widget _feedbackPanel(PracticeFeedback? fb) {
    if (fb == null) return const SizedBox.shrink();
    if (fb.correct) {
      return const Center(
        child: Text('✓ Correct!', style: TextStyle(fontSize: 26, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.negativeRed, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The answer is ${_item.answerText}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkText),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    fb.diagnosis?.hint ?? '',
                    style: const TextStyle(fontSize: 15, color: AppColors.darkText),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _next, child: const Text('Next')),
        ],
      ),
    );
  }

  Widget _mastered(LearningProvider provider, Skill skill) {
    final next = provider.model?.recommendedSkill;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.workspace_premium, size: 110, color: AppColors.accentGold),
        const SizedBox(height: 16),
        Text('You mastered\n${skill.name}!',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        if (_feedback!.unlocked.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'New: ${_feedback!.unlocked.map((id) => provider.graph[id].name).join(', ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.primaryBlue),
          ),
        ],
        const SizedBox(height: 32),
        if (next != null)
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SkillPracticeScreen(skillId: next)),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text('Next: ${provider.graph[next].name}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to skill map')),
      ],
    );
  }
}
