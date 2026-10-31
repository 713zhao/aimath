/// Immutable fraction with integer numerator and positive denominator.
class Fraction implements Comparable<Fraction> {
  final int numerator;
  final int denominator;

  const Fraction(this.numerator, this.denominator)
      : assert(denominator > 0, 'denominator must be positive');

  static int _gcd(int a, int b) => b == 0 ? a.abs() : _gcd(b, a % b);

  Fraction simplify() {
    final g = _gcd(numerator, denominator);
    return g <= 1 ? this : Fraction(numerator ~/ g, denominator ~/ g);
  }

  /// Compares by value using cross-multiplication (no floating point).
  @override
  int compareTo(Fraction other) =>
      (numerator * other.denominator).compareTo(other.numerator * denominator);

  bool equalsValue(Fraction other) => compareTo(other) == 0;

  @override
  bool operator ==(Object other) =>
      other is Fraction &&
      other.numerator == numerator &&
      other.denominator == denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);

  /// Simplified text: "1/3", or just "2" when the value is whole.
  String toSimplifiedString() {
    final f = simplify();
    return f.denominator == 1
        ? '${f.numerator}'
        : '${f.numerator}/${f.denominator}';
  }

  /// Parses "a/b" or a whole number (e.g. "4/3", "2"). Returns null for
  /// anything else, including a zero denominator.
  static Fraction? tryParse(String text) {
    final match = RegExp(r'^\s*(-?\d+)\s*(?:/\s*(\d+))?\s*$').firstMatch(text);
    if (match == null) return null;
    final n = int.parse(match.group(1)!);
    final d = match.group(2) == null ? 1 : int.parse(match.group(2)!);
    return d == 0 ? null : Fraction(n, d);
  }

  @override
  String toString() => '$numerator/$denominator';
}

/// A sum or difference of fractions that share a denominator,
/// e.g. "2/6 + 4/6" with answer 6/6.
class FractionExpression {
  final String text;
  final Fraction answer;

  const FractionExpression(this.text, this.answer);

  /// Builds an expression from [numerators] over a common [denominator].
  /// When [subtract] is set the largest numerator goes first and the rest
  /// are subtracted; if that would go negative it falls back to addition so
  /// answers stay non-negative.
  factory FractionExpression.build(
    List<int> numerators,
    int denominator, {
    bool subtract = false,
  }) {
    final nums = List<int>.of(numerators);
    if (subtract) {
      nums.sort((a, b) => b.compareTo(a));
      final result = nums.first - nums.skip(1).fold<int>(0, (a, b) => a + b);
      if (result >= 0) {
        return FractionExpression(
          nums.map((n) => '$n/$denominator').join(' − '),
          Fraction(result, denominator),
        );
      }
    }
    return FractionExpression(
      numerators.map((n) => '$n/$denominator').join(' + '),
      Fraction(numerators.fold<int>(0, (a, b) => a + b), denominator),
    );
  }
}
