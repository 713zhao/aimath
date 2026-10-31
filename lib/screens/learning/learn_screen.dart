import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../learning/core/learner_model.dart';
import '../../learning/core/skill_graph.dart';
import '../../providers/learning_provider.dart';
import '../../providers/student_provider.dart';
import '../../utils/colors.dart';
import 'placement_screen.dart';
import 'skill_practice_screen.dart';

/// "Learn" tab: the child's skill map, the next recommended skill, and the
/// placement test.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = context.watch<StudentProvider>().currentStudent?.id ?? 'default';
    final provider = context.read<LearningProvider>();
    if (provider.studentId != id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => provider.load(id));
    }
  }

  void _open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningProvider>();
    final model = provider.model;

    return Scaffold(
      appBar: AppBar(
        title: Text('${provider.subject.emoji} ${provider.subject.name}'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (model != null && model.placementDone)
            IconButton(
              tooltip: 'Find my level again',
              icon: const Icon(Icons.explore),
              onPressed: () => _open(const PlacementScreen()),
            ),
        ],
      ),
      body: model == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.subjects.length > 1) _subjectPicker(provider),
                if (!model.placementDone) _placementCard() else _nextCard(provider, model),
                const SizedBox(height: 8),
                Text(
                  '${model.masteredCount} of ${provider.graph.skills.length} skills mastered',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
                for (final strand in provider.graph.strands) ..._strandSection(provider, model, strand),
              ],
            ),
    );
  }

  Widget _subjectPicker(LearningProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final s in provider.subjects)
            ChoiceChip(
              label: Text('${s.emoji} ${s.name}', style: const TextStyle(fontSize: 16)),
              selected: s.id == provider.subject.id,
              onSelected: (_) => provider.selectSubject(s.id),
            ),
        ],
      ),
    );
  }

  Widget _placementCard() {
    return _HeroCard(
      color: AppColors.primaryBlue,
      icon: Icons.explore,
      title: 'Find my level',
      subtitle: 'A quick quiz so you start at just the right place.',
      onTap: () => _open(const PlacementScreen()),
      secondary: TextButton(
        onPressed: () {
          final next = context.read<LearningProvider>().model?.recommendedSkill;
          if (next != null) _open(SkillPracticeScreen(skillId: next));
        },
        child: const Text('Skip — start from the beginning', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _nextCard(LearningProvider provider, LearnerModel model) {
    final next = model.recommendedSkill;
    if (next == null) {
      return const _HeroCard(
        color: AppColors.accentGold,
        icon: Icons.emoji_events,
        title: 'Every skill mastered!',
        subtitle: 'Amazing work. Keep sharp with Practice and Games.',
      );
    }
    final skill = provider.graph[next];
    final tip = model.commonMistake(next);
    return _HeroCard(
      color: AppColors.successGreen,
      icon: Icons.play_arrow_rounded,
      title: 'Next: ${skill.name}',
      subtitle: tip == null ? skill.description : '${skill.description}\nWe\'ll work on the tricky part together.',
      onTap: () => _open(SkillPracticeScreen(skillId: next)),
    );
  }

  List<Widget> _strandSection(LearningProvider provider, LearnerModel model, String strand) {
    final skills = [
      for (final id in provider.graph.topologicalOrder)
        if (provider.graph[id].strand == strand) provider.graph[id],
    ];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(strand, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      for (final s in skills) _skillTile(provider, model, s),
    ];
  }

  Widget _skillTile(LearningProvider provider, LearnerModel model, Skill skill) {
    final status = model.statusOf(skill.id);
    final m = model.of(skill.id);
    final (IconData icon, Color color) = switch (status) {
      SkillStatus.mastered => (Icons.star, AppColors.accentGold),
      SkillStatus.learning => (Icons.trending_up, AppColors.primaryBlue),
      SkillStatus.ready => (Icons.play_circle_outline, AppColors.successGreen),
      SkillStatus.locked => (Icons.lock_outline, Colors.grey),
    };
    final missing = skill.prerequisites.where((p) => !model.isMastered(p)).map((p) => provider.graph[p].name);
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          skill.name,
          style: TextStyle(color: status == SkillStatus.locked ? Colors.grey : null, fontWeight: FontWeight.w600),
        ),
        subtitle: status == SkillStatus.locked
            ? Text('First: ${missing.join(', ')}')
            : status == SkillStatus.mastered
                ? Text(m.placed ? 'Already known' : 'Mastered')
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(
                      value: (m.pKnown / LearnerModel.masteryThreshold).clamp(0.0, 1.0),
                      color: color,
                      backgroundColor: AppColors.lightGray,
                    ),
                  ),
        trailing: status == SkillStatus.locked ? null : const Icon(Icons.chevron_right),
        onTap: status == SkillStatus.locked ? null : () => _open(SkillPracticeScreen(skillId: skill.id)),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? secondary;

  const _HeroCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 56, color: Colors.white),
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9))),
              if (secondary != null) secondary!,
            ],
          ),
        ),
      ),
    );
  }
}
