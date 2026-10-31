import 'dart:math';

import 'learning_item.dart';
import 'skill_graph.dart';

/// Adaptive placement test over a [SkillGraph].
///
/// Instead of starting every child at level 1, it probes skills and uses the
/// prerequisite structure to infer the rest:
///  * pass a skill → its prerequisites are assumed known too;
///  * fail a skill → skills that build on it are assumed not known.
/// Each probe picks the undetermined skill whose outcome settles the most
/// skills either way (a binary search over the graph), so a child is placed
/// in a handful of questions.
///
/// A skill is passed with 2 correct out of up to 3 items and failed with 2
/// wrong, which absorbs a single slip or lucky guess.
class PlacementTest {
  final SkillGraph graph;
  final int maxQuestions;
  final Random _rng;

  final Map<String, bool> _determined = {};
  String? _probe;
  int _probeCorrect = 0;
  int _probeWrong = 0;
  int _asked = 0;
  LearningItem? _current;

  PlacementTest(this.graph, {int? maxQuestions, Random? rng})
      : maxQuestions = maxQuestions ?? max(6, (graph.skills.length * 1.5).ceil()),
        _rng = rng ?? Random() {
    _probe = _chooseProbe();
  }

  int get questionsAsked => _asked;

  bool get isFinished => _probe == null || _asked >= maxQuestions;

  /// Rough progress for a progress bar, 0..1.
  double get progress {
    if (isFinished) return 1;
    final settled = _determined.length / graph.skills.length;
    final budget = _asked / maxQuestions;
    return max(settled, budget).clamp(0.0, 0.99);
  }

  /// The item to show now, or null when the test is over.
  LearningItem? get currentItem {
    if (isFinished) return null;
    return _current ??= graph[_probe!].generate(_rng);
  }

  /// Record the child's answer to [currentItem].
  void submit(String response) {
    final item = currentItem;
    if (item == null) throw StateError('Placement test is finished');
    _asked++;
    _current = null;
    if (item.isCorrect(response)) {
      _probeCorrect++;
    } else {
      _probeWrong++;
    }

    if (_probeCorrect >= 2) {
      _settle(_probe!, true);
    } else if (_probeWrong >= 2) {
      _settle(_probe!, false);
    }
  }

  void _settle(String skillId, bool known) {
    _determined[skillId] = known;
    final implied = known ? graph.ancestorsOf(skillId) : graph.descendantsOf(skillId);
    for (final id in implied) {
      _determined.putIfAbsent(id, () => known);
    }
    _probeCorrect = 0;
    _probeWrong = 0;
    _probe = _chooseProbe();
  }

  String? _chooseProbe() {
    String? best;
    var bestScore = -1;
    for (final id in graph.topologicalOrder) {
      if (_determined.containsKey(id)) continue;
      final ifPass = 1 + graph.ancestorsOf(id).where((a) => !_determined.containsKey(a)).length;
      final ifFail = 1 + graph.descendantsOf(id).where((d) => !_determined.containsKey(d)).length;
      final score = min(ifPass, ifFail);
      if (score > bestScore) {
        best = id;
        bestScore = score;
      }
    }
    return best;
  }

  /// Skills judged as known. Anything left undetermined when the question
  /// budget runs out is treated as not known (practice will sort it out).
  Set<String> get knownSkills => {
        for (final e in _determined.entries)
          if (e.value) e.key,
      };
}
