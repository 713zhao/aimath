/// How the child answers an item; the UI picks the input widget from this.
enum AnswerFormat {
  /// Whole number, typed on the number pad.
  number,

  /// Pick one of [LearningItem.choices].
  choice,

  /// Free text, typed on a keyboard.
  text,
}

/// A recognised mistake and a hint aimed at it.
///
/// [code] is a short, stable identifier (e.g. `forgotCarry`) that is stored
/// in the learner model, so never rename codes once released.
class Diagnosis {
  final String code;
  final String hint;

  const Diagnosis(this.code, this.hint);

  /// Code used when a wrong answer matches no known mistake pattern.
  static const String unknownCode = 'unknown';
}

/// One question for one skill, in any subject.
///
/// Subjects implement this for their own content (an arithmetic sum, a
/// spelling choice, a vocabulary question…). The engine only ever talks to
/// items through this interface.
abstract class LearningItem {
  /// The skill this item practises.
  String get skillId;

  /// The question as shown to the child, e.g. "38 + 47 = ?".
  String get prompt;

  /// Optional extra line under the prompt, e.g. an instruction.
  String? get instruction => null;

  AnswerFormat get format;

  /// The options for [AnswerFormat.choice] items; null otherwise.
  List<String>? get choices => null;

  /// The correct answer, as it should be shown to the child.
  String get answerText;

  /// Whether [response] is correct. The default compares trimmed,
  /// case-insensitive text; override for anything smarter.
  bool isCorrect(String response) => response.trim().toLowerCase() == answerText.trim().toLowerCase();

  /// Explain a wrong [response]. Return null when the answer is correct.
  /// The default gives a generic hint; override to recognise specific
  /// mistakes for this kind of item.
  Diagnosis? diagnose(String response) {
    if (isCorrect(response)) return null;
    return Diagnosis(Diagnosis.unknownCode, 'Not quite. The answer is $answerText.');
  }
}
