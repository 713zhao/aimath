import '../core/subject.dart';
import 'math/math_subject.dart';
import 'spelling/spelling_subject.dart';

/// Every subject the app offers, in picker order.
///
/// To add a subject: build a [Subject] under `lib/learning/subjects/<name>/`
/// and add it here. See `docs/adding-a-subject.md`.
final List<Subject> allSubjects = [
  mathSubject,
  spellingSubject,
];
