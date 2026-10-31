import 'learning_item.dart';
import 'skill_graph.dart';

/// Where a child stands on a single skill.
enum SkillStatus { locked, ready, learning, mastered }

/// Per-skill evidence, updated with Bayesian Knowledge Tracing (BKT).
///
/// BKT keeps a probability that the skill is known and updates it after each
/// answer, allowing for lucky guesses and careless slips. A skill counts as
/// mastered once that probability passes [LearnerModel.masteryThreshold].
class SkillMastery {
  double pKnown;
  int attempts;
  int correct;

  /// True when mastery was inferred by the placement test rather than earned
  /// through practice on this exact skill.
  bool placed;
  /// Mistake code (see [Diagnosis.code]) → how often it happened.
  final Map<String, int> mistakes;
  DateTime? lastPracticed;

  SkillMastery({
    this.pKnown = LearnerModel.priorKnown,
    this.attempts = 0,
    this.correct = 0,
    this.placed = false,
    Map<String, int>? mistakes,
    this.lastPracticed,
  }) : mistakes = mistakes ?? {};

  Map<String, dynamic> toJson() => {
        'pKnown': pKnown,
        'attempts': attempts,
        'correct': correct,
        'placed': placed,
        'mistakes': mistakes,
        if (lastPracticed != null) 'lastPracticed': lastPracticed!.toIso8601String(),
      };

  factory SkillMastery.fromJson(Map<String, dynamic> json) {
    final rawMistakes = Map<String, dynamic>.from(json['mistakes'] as Map? ?? {});
    return SkillMastery(
      pKnown: (json['pKnown'] as num?)?.toDouble() ?? LearnerModel.priorKnown,
      attempts: json['attempts'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      placed: json['placed'] as bool? ?? false,
      mistakes: {for (final e in rawMistakes.entries) e.key: e.value as int},
      lastPracticed: json['lastPracticed'] == null ? null : DateTime.tryParse(json['lastPracticed'] as String),
    );
  }
}

/// What the learner knows across the whole [SkillGraph].
class LearnerModel {
  static const double priorKnown = 0.1;
  static const double pLearn = 0.1; // chance of learning from one practice item
  static const double pSlip = 0.1; // knows it but answers wrong
  static const double pGuess = 0.2; // right without knowing it (easy items, counting on fingers)
  static const double masteryThreshold = 0.95;

  final SkillGraph graph;
  final Map<String, SkillMastery> _skills;
  bool placementDone;

  LearnerModel(this.graph, {Map<String, SkillMastery>? skills, this.placementDone = false})
      : _skills = skills ?? {};

  SkillMastery of(String skillId) => _skills.putIfAbsent(skillId, () => SkillMastery());

  bool isMastered(String skillId) => of(skillId).pKnown >= masteryThreshold;

  bool prerequisitesMet(String skillId) => graph[skillId].prerequisites.every(isMastered);

  SkillStatus statusOf(String skillId) {
    if (isMastered(skillId)) return SkillStatus.mastered;
    if (!prerequisitesMet(skillId)) return SkillStatus.locked;
    return of(skillId).attempts > 0 ? SkillStatus.learning : SkillStatus.ready;
  }

  /// Skills the child is ready to learn now: not mastered, all prerequisites
  /// mastered. In curriculum order.
  List<String> get frontier => [
        for (final id in graph.topologicalOrder)
          if (!isMastered(id) && prerequisitesMet(id)) id,
      ];

  /// The single skill we would suggest practising next. Prefers a skill
  /// already in progress so children finish what they started.
  String? get recommendedSkill {
    final f = frontier;
    if (f.isEmpty) return null;
    return f.firstWhere((id) => of(id).attempts > 0, orElse: () => f.first);
  }

  int get masteredCount => graph.skills.where((s) => isMastered(s.id)).length;

  /// Update the model after one practice answer. Returns true when this
  /// answer pushed the skill over the mastery threshold.
  bool recordAnswer(String skillId, {required bool correct, String? mistake, DateTime? at}) {
    final m = of(skillId);
    final wasMastered = isMastered(skillId);
    final p = m.pKnown;

    // Posterior given the observation…
    final posterior = correct
        ? p * (1 - pSlip) / (p * (1 - pSlip) + (1 - p) * pGuess)
        : p * pSlip / (p * pSlip + (1 - p) * (1 - pGuess));
    // …then the chance the child learned it from this item.
    m.pKnown = posterior + (1 - posterior) * pLearn;

    m.attempts++;
    if (correct) m.correct++;
    if (mistake != null) m.mistakes[mistake] = (m.mistakes[mistake] ?? 0) + 1;
    m.lastPracticed = at ?? DateTime.now();
    if (!correct) m.placed = false;

    return !wasMastered && isMastered(skillId);
  }

  /// Apply a placement result: [known] skills become mastered (placed), all
  /// other skills are reset to the prior unless already practised.
  void applyPlacement(Set<String> known) {
    for (final s in graph.skills) {
      final m = of(s.id);
      if (known.contains(s.id)) {
        if (m.pKnown < 0.97) m.pKnown = 0.97;
        m.placed = true;
      } else if (m.attempts == 0) {
        m.pKnown = priorKnown;
        m.placed = false;
      }
    }
    placementDone = true;
  }

  /// The mistake this child makes most often on [skillId], if any.
  String? commonMistake(String skillId) {
    final entries = of(skillId).mistakes.entries.where((e) => e.key != Diagnosis.unknownCode).toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return entries.isEmpty || entries.first.value < 2 ? null : entries.first.key;
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'placementDone': placementDone,
        'skills': {for (final e in _skills.entries) e.key: e.value.toJson()},
      };

  factory LearnerModel.fromJson(SkillGraph graph, Map<String, dynamic> json) {
    final raw = Map<String, dynamic>.from(json['skills'] as Map? ?? {});
    return LearnerModel(
      graph,
      placementDone: json['placementDone'] as bool? ?? false,
      skills: {
        for (final e in raw.entries)
          if (graph.contains(e.key)) e.key: SkillMastery.fromJson(Map<String, dynamic>.from(e.value as Map)),
      },
    );
  }
}
