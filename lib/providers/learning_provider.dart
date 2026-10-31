import 'dart:math';

import 'package:flutter/foundation.dart';

import '../learning/core/learner_model.dart';
import '../learning/core/learner_model_store.dart';
import '../learning/core/learning_item.dart';
import '../learning/core/placement_test.dart';
import '../learning/core/skill_graph.dart';
import '../learning/core/subject.dart';
import '../learning/subjects/subjects.dart';

/// Result of answering one practice item.
class PracticeFeedback {
  final bool correct;
  final Diagnosis? diagnosis;
  final bool justMastered;

  /// Skills that became available because of this answer.
  final List<String> unlocked;

  const PracticeFeedback({
    required this.correct,
    this.diagnosis,
    this.justMastered = false,
    this.unlocked = const [],
  });
}

/// Owns the current student's [LearnerModel] for the selected [Subject] and
/// runs placement and skill practice against it.
class LearningProvider extends ChangeNotifier {
  final List<Subject> subjects;
  final LearnerModelStore _store;
  final Random _rng;

  LearningProvider({List<Subject>? subjects, LearnerModelStore? store, Random? rng})
      : subjects = subjects ?? allSubjects,
        _store = store ?? HiveLearnerModelStore(),
        _rng = rng ?? Random() {
    if (this.subjects.isEmpty) throw ArgumentError('At least one subject is required');
    _subject = this.subjects.first;
  }

  late Subject _subject;
  String? _studentId;
  LearnerModel? _model;
  bool _loading = false;

  Subject get subject => _subject;
  SkillGraph get graph => _subject.graph;
  LearnerModel? get model => _model;
  bool get isLoading => _loading;
  String? get studentId => _studentId;

  /// Load [studentId]'s progress in the current subject.
  Future<void> load(String studentId) => _loadFor(studentId, _subject);

  /// Switch subject, keeping the same student.
  Future<void> selectSubject(String subjectId) async {
    final next = subjects.firstWhere((s) => s.id == subjectId);
    if (next.id == _subject.id && _model != null) return;
    _subject = next;
    final id = _studentId;
    if (id == null) {
      _model = null;
      notifyListeners();
    } else {
      await _loadFor(id, next, force: true);
    }
  }

  Future<void> _loadFor(String studentId, Subject subject, {bool force = false}) async {
    if (!force && _studentId == studentId && _model != null) return;
    _loading = true;
    _studentId = studentId;
    _model = null;
    notifyListeners();
    final model = await _store.load(studentId, subject);
    // Ignore a stale load if the subject or student changed meanwhile.
    if (_subject.id != subject.id || _studentId != studentId) return;
    _model = model;
    _loading = false;
    notifyListeners();
  }

  PlacementTest startPlacement() => PlacementTest(graph, rng: _rng);

  Future<void> finishPlacement(PlacementTest test) async {
    final m = _model;
    if (m == null || test.graph != graph) return;
    m.applyPlacement(test.knownSkills);
    await _save();
    notifyListeners();
  }

  LearningItem nextItem(String skillId) => graph[skillId].generate(_rng);

  Future<PracticeFeedback> answer(LearningItem item, String response) async {
    final m = _model;
    if (m == null) throw StateError('Learner model not loaded');
    final before = m.frontier.toSet();
    final correct = item.isCorrect(response);
    final diagnosis = correct ? null : item.diagnose(response);
    final mastered = m.recordAnswer(item.skillId, correct: correct, mistake: diagnosis?.code);
    final unlocked = m.frontier.where((id) => !before.contains(id) && id != item.skillId).toList();
    await _save();
    notifyListeners();
    return PracticeFeedback(
      correct: correct,
      diagnosis: diagnosis,
      justMastered: mastered,
      unlocked: unlocked,
    );
  }

  Future<void> _save() async {
    final id = _studentId, m = _model;
    if (id != null && m != null) await _store.save(id, _subject, m);
  }
}
