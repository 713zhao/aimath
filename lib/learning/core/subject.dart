import 'skill_graph.dart';

/// A subject the app can teach: a curriculum ([graph]) plus how to present it.
///
/// To add a subject, create one of these (see `lib/learning/subjects/`) and
/// register it in `lib/learning/subjects/subjects.dart`.
class Subject {
  /// Stable id used as a storage key; never change it once released.
  final String id;
  final String name;
  final String description;

  /// Emoji shown on the subject picker.
  final String emoji;
  final SkillGraph graph;

  /// Rough number of placement questions, shown on the intro screen.
  String get placementLengthHint {
    final n = graph.skills.length;
    if (n <= 4) return 'a few';
    if (n <= 8) return 'about 10';
    return 'about 15';
  }

  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.graph,
  });
}
