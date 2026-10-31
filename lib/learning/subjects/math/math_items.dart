import '../../../utils/enums.dart';
import '../../core/learning_item.dart';

/// Mistake codes for arithmetic. Stored in the learner model — never rename.
abstract final class MathMistake {
  static const forgotCarry = 'forgotCarry';
  static const subtractedSmallerFromLarger = 'subtractedSmallerFromLarger';
  static const wrongOperation = 'wrongOperation';
  static const timesTableNeighbour = 'timesTableNeighbour';
  static const reversedDigits = 'reversedDigits';
  static const offByOne = 'offByOne';
}

/// "a op b = ?" with a whole-number answer. Division is always exact.
class ArithmeticItem extends LearningItem {
  @override
  final String skillId;
  final int a;
  final int b;
  final Operation op;

  ArithmeticItem({required this.skillId, required this.a, required this.b, required this.op});

  int get answer {
    switch (op) {
      case Operation.add:
        return a + b;
      case Operation.subtract:
        return a - b;
      case Operation.multiply:
        return a * b;
      case Operation.divide:
        return a ~/ b;
    }
  }

  String get expression => '$a ${op.symbol} $b';

  @override
  String get prompt => '$expression = ?';

  @override
  AnswerFormat get format => AnswerFormat.number;

  @override
  String get answerText => '$answer';

  @override
  bool isCorrect(String response) => int.tryParse(response.trim()) == answer;

  @override
  Diagnosis? diagnose(String response) {
    if (isCorrect(response)) return null;
    final n = int.tryParse(response.trim());
    if (n == null) return Diagnosis(Diagnosis.unknownCode, 'The answer is $answer.');
    return diagnoseArithmetic(this, n);
  }

  @override
  String toString() => '$expression = $answer [$skillId]';
}

// ---------------------------------------------------------------------------
// Mistake recognition
// ---------------------------------------------------------------------------

List<int> _digits(int n) {
  // least-significant first
  final d = <int>[];
  var x = n.abs();
  do {
    d.add(x % 10);
    x ~/= 10;
  } while (x > 0);
  return d;
}

int _fromDigits(List<int> d) {
  var n = 0;
  for (var i = d.length - 1; i >= 0; i--) {
    n = n * 10 + d[i];
  }
  return n;
}

/// Column-by-column sum that drops every carry (e.g. 38 + 47 → 75).
int _addWithoutCarry(int a, int b) {
  final da = _digits(a), db = _digits(b);
  final len = da.length > db.length ? da.length : db.length;
  return _fromDigits([
    for (var i = 0; i < len; i++) ((i < da.length ? da[i] : 0) + (i < db.length ? db[i] : 0)) % 10,
  ]);
}

/// Column-by-column "bigger minus smaller" (e.g. 62 − 27 → 45).
int _subtractSmallerFromLarger(int a, int b) {
  final da = _digits(a), db = _digits(b);
  final len = da.length > db.length ? da.length : db.length;
  return _fromDigits([
    for (var i = 0; i < len; i++) ((i < da.length ? da[i] : 0) - (i < db.length ? db[i] : 0)).abs(),
  ]);
}

class _Column {
  final int index, x, y;
  const _Column(this.index, this.x, this.y);
}

/// First column (ones = 0) whose digits satisfy [test]; falls back to ones.
_Column _firstColumn(int a, int b, bool Function(int x, int y) test) {
  final da = _digits(a), db = _digits(b);
  for (var i = 0; i < da.length; i++) {
    final x = da[i], y = i < db.length ? db[i] : 0;
    if (test(x, y)) return _Column(i, x, y);
  }
  return _Column(0, da[0], db[0]);
}

String _columnName(int i) => const ['ones', 'tens', 'hundreds', 'thousands'][i.clamp(0, 3)];

/// Classifies a wrong numeric [response] to [item]. Returns null if correct.
Diagnosis? diagnoseArithmetic(ArithmeticItem item, int response) {
  final a = item.a, b = item.b, answer = item.answer;
  if (response == answer) return null;

  switch (item.op) {
    case Operation.add:
      if (response == _addWithoutCarry(a, b)) {
        final c = _firstColumn(a, b, (x, y) => x + y >= 10);
        return Diagnosis(
          MathMistake.forgotCarry,
          'Look at the ${_columnName(c.index)}: ${c.x} + ${c.y} = ${c.x + c.y}. '
          'That is 10 or more — carry the 1 to the next column!',
        );
      }
      if (response == a - b) {
        return const Diagnosis(MathMistake.wrongOperation, 'Check the sign — this one is plus (+), so the answer gets bigger.');
      }
      break;
    case Operation.subtract:
      if (response == _subtractSmallerFromLarger(a, b)) {
        final c = _firstColumn(a, b, (x, y) => x < y);
        return Diagnosis(
          MathMistake.subtractedSmallerFromLarger,
          'In the ${_columnName(c.index)} you can\'t take ${c.y} from ${c.x}. '
          'Borrow from the next column: ${c.x} becomes ${c.x + 10}.',
        );
      }
      if (response == a + b) {
        return const Diagnosis(MathMistake.wrongOperation, 'Check the sign — this one is minus (−), so the answer gets smaller.');
      }
      break;
    case Operation.multiply:
      if (response == a + b) {
        return Diagnosis(MathMistake.wrongOperation, 'That\'s $a + $b. Times means $b groups of $a.');
      }
      if (response == a * (b - 1) || response == a * (b + 1) || response == (a - 1) * b || response == (a + 1) * b) {
        return Diagnosis(
          MathMistake.timesTableNeighbour,
          'So close — that\'s the next-door fact. Count up: $a, ${a * 2}, ${a * 3}… to $b groups.',
        );
      }
      break;
    case Operation.divide:
      if (response == a * b || response == a - b) {
        return Diagnosis(MathMistake.wrongOperation, '÷ means sharing $a into $b equal groups. How many in each?');
      }
      break;
  }

  if (answer >= 10 && response > 0) {
    final reversed = int.tryParse(response.toString().split('').reversed.join());
    if (reversed == answer) {
      return const Diagnosis(MathMistake.reversedDigits, 'You have the right digits — check which one is tens and which is ones.');
    }
  }

  if ((response - answer).abs() == 1) {
    return const Diagnosis(MathMistake.offByOne, 'Just 1 away! Count again carefully.');
  }

  return Diagnosis(Diagnosis.unknownCode, 'Not quite. The answer is $answer — try the next one slowly.');
}
