import 'package:hive_flutter/hive_flutter.dart';

import 'learner_model.dart';
import 'subject.dart';

/// Persistence for [LearnerModel]s, one per (student, subject).
abstract class LearnerModelStore {
  Future<LearnerModel> load(String studentId, Subject subject);
  Future<void> save(String studentId, Subject subject, LearnerModel model);

  static String keyFor(String studentId, Subject subject) => '$studentId::${subject.id}';
}

/// Hive-backed store. Opens its own box lazily so app start-up is unchanged.
class HiveLearnerModelStore implements LearnerModelStore {
  static const String boxName = 'learner_models';

  Future<Box<Map>> _box() async =>
      Hive.isBoxOpen(boxName) ? Hive.box<Map>(boxName) : await Hive.openBox<Map>(boxName);

  @override
  Future<LearnerModel> load(String studentId, Subject subject) async {
    final box = await _box();
    // Before subjects existed, math progress was stored under the bare id.
    final raw = box.get(LearnerModelStore.keyFor(studentId, subject)) ??
        (subject.id == 'math' ? box.get(studentId) : null);
    if (raw == null) return LearnerModel(subject.graph);
    try {
      return LearnerModel.fromJson(subject.graph, Map<String, dynamic>.from(raw));
    } catch (_) {
      return LearnerModel(subject.graph);
    }
  }

  @override
  Future<void> save(String studentId, Subject subject, LearnerModel model) async {
    await (await _box()).put(LearnerModelStore.keyFor(studentId, subject), model.toJson());
  }
}

/// In-memory store for tests.
class MemoryLearnerModelStore implements LearnerModelStore {
  final Map<String, Map<String, dynamic>> data = {};

  @override
  Future<LearnerModel> load(String studentId, Subject subject) async {
    final raw = data[LearnerModelStore.keyFor(studentId, subject)];
    return raw == null ? LearnerModel(subject.graph) : LearnerModel.fromJson(subject.graph, raw);
  }

  @override
  Future<void> save(String studentId, Subject subject, LearnerModel model) async {
    data[LearnerModelStore.keyFor(studentId, subject)] = model.toJson();
  }
}
