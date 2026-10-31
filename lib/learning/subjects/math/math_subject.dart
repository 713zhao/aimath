import 'dart:math';

import '../../../utils/enums.dart';
import '../../core/skill_graph.dart';
import '../../core/subject.dart';
import 'math_items.dart';

// ---------------------------------------------------------------------------
// Default primary-school arithmetic curriculum
// ---------------------------------------------------------------------------

int _between(Random rng, int min, int max) => min + rng.nextInt(max - min + 1);

/// Two numbers whose ones digits do (or do not) carry when added.
ArithmeticItem _addMultiDigit(Random rng, String id, int digits, {required bool carry}) {
  final lo = pow(10, digits - 1).toInt();
  final hi = pow(10, digits).toInt() - 1;
  while (true) {
    final a = _between(rng, lo, hi);
    final b = _between(rng, lo, hi);
    final onesCarry = (a % 10) + (b % 10) >= 10;
    if (a + b > hi && digits < 3) continue; // keep result within digit range
    if (onesCarry == carry) {
      return ArithmeticItem(skillId: id, a: a, b: b, op: Operation.add);
    }
  }
}

/// a − b with a > b, where the ones column does (or does not) need borrowing.
ArithmeticItem _subMultiDigit(Random rng, String id, int digits, {required bool borrow}) {
  final lo = pow(10, digits - 1).toInt();
  final hi = pow(10, digits).toInt() - 1;
  while (true) {
    final a = _between(rng, lo, hi);
    final b = _between(rng, lo, a - 1 < lo ? lo : a - 1);
    if (b >= a) continue;
    final needsBorrow = (a % 10) < (b % 10);
    if (needsBorrow == borrow) {
      return ArithmeticItem(skillId: id, a: a, b: b, op: Operation.subtract);
    }
  }
}

const _addition = 'Adding';
const _subtraction = 'Taking away';
const _multiplication = 'Times tables';
const _division = 'Sharing (division)';

/// Primary-school arithmetic, from adding within 5 to 2-digit division.
final Subject mathSubject = Subject(
  id: 'math',
  name: 'Math',
  description: 'Adding, taking away, times tables and sharing',
  emoji: '🔢',
  graph: SkillGraph([
  // ---- Addition ----------------------------------------------------------
  Skill(
    id: 'add_within_5',
    name: 'Add within 5',
    description: 'Small sums like 2 + 3',
    strand: _addition,
    prerequisites: const [],
    generate: (rng) {
      final a = _between(rng, 0, 5);
      return ArithmeticItem(skillId: 'add_within_5', a: a, b: _between(rng, 0, 5 - a), op: Operation.add);
    },
  ),
  Skill(
    id: 'add_within_10',
    name: 'Add within 10',
    description: 'Sums up to 10 like 6 + 4',
    strand: _addition,
    prerequisites: const ['add_within_5'],
    generate: (rng) {
      while (true) {
        final a = _between(rng, 1, 9);
        final b = _between(rng, 1, 10 - a);
        if (a + b > 5) {
          return ArithmeticItem(skillId: 'add_within_10', a: a, b: b, op: Operation.add);
        }
      }
    },
  ),
  Skill(
    id: 'add_bridge_10',
    name: 'Add past 10',
    description: 'Single digits that make more than 10, like 8 + 5',
    strand: _addition,
    prerequisites: const ['add_within_10'],
    generate: (rng) {
      final a = _between(rng, 2, 9);
      final b = _between(rng, 11 - a, 9);
      return ArithmeticItem(skillId: 'add_bridge_10', a: a, b: b, op: Operation.add);
    },
  ),
  Skill(
    id: 'add_2d_no_carry',
    name: '2-digit add (no carry)',
    description: 'Like 34 + 25',
    strand: _addition,
    prerequisites: const ['add_within_10'],
    generate: (rng) => _addMultiDigit(rng, 'add_2d_no_carry', 2, carry: false),
  ),
  Skill(
    id: 'add_2d_carry',
    name: '2-digit add (carrying)',
    description: 'Like 38 + 47',
    strand: _addition,
    prerequisites: const ['add_2d_no_carry', 'add_bridge_10'],
    generate: (rng) => _addMultiDigit(rng, 'add_2d_carry', 2, carry: true),
  ),
  Skill(
    id: 'add_3d',
    name: '3-digit add',
    description: 'Like 457 + 286',
    strand: _addition,
    prerequisites: const ['add_2d_carry'],
    generate: (rng) => _addMultiDigit(rng, 'add_3d', 3, carry: true),
  ),

  // ---- Subtraction -------------------------------------------------------
  Skill(
    id: 'sub_within_10',
    name: 'Take away within 10',
    description: 'Like 9 − 4',
    strand: _subtraction,
    prerequisites: const ['add_within_10'],
    generate: (rng) {
      final a = _between(rng, 2, 10);
      return ArithmeticItem(skillId: 'sub_within_10', a: a, b: _between(rng, 1, a), op: Operation.subtract);
    },
  ),
  Skill(
    id: 'sub_bridge_10',
    name: 'Take away past 10',
    description: 'Like 13 − 7',
    strand: _subtraction,
    prerequisites: const ['sub_within_10', 'add_bridge_10'],
    generate: (rng) {
      final a = _between(rng, 11, 18);
      final b = _between(rng, a - 9, 9);
      return ArithmeticItem(skillId: 'sub_bridge_10', a: a, b: b, op: Operation.subtract);
    },
  ),
  Skill(
    id: 'sub_2d_no_borrow',
    name: '2-digit take away (no borrow)',
    description: 'Like 58 − 23',
    strand: _subtraction,
    prerequisites: const ['sub_within_10', 'add_2d_no_carry'],
    generate: (rng) => _subMultiDigit(rng, 'sub_2d_no_borrow', 2, borrow: false),
  ),
  Skill(
    id: 'sub_2d_borrow',
    name: '2-digit take away (borrowing)',
    description: 'Like 62 − 27',
    strand: _subtraction,
    prerequisites: const ['sub_2d_no_borrow', 'sub_bridge_10'],
    generate: (rng) => _subMultiDigit(rng, 'sub_2d_borrow', 2, borrow: true),
  ),
  Skill(
    id: 'sub_3d',
    name: '3-digit take away',
    description: 'Like 523 − 278',
    strand: _subtraction,
    prerequisites: const ['sub_2d_borrow'],
    generate: (rng) => _subMultiDigit(rng, 'sub_3d', 3, borrow: true),
  ),

  // ---- Multiplication ----------------------------------------------------
  Skill(
    id: 'mul_2_5_10',
    name: '×2, ×5, ×10',
    description: 'The easy times tables',
    strand: _multiplication,
    prerequisites: const ['add_bridge_10'],
    generate: (rng) {
      const tables = [2, 5, 10];
      final t = tables[rng.nextInt(tables.length)];
      final n = _between(rng, 1, 10);
      final swap = rng.nextBool();
      return ArithmeticItem(skillId: 'mul_2_5_10', a: swap ? n : t, b: swap ? t : n, op: Operation.multiply);
    },
  ),
  Skill(
    id: 'mul_facts',
    name: 'All times tables',
    description: 'Facts up to 9 × 9',
    strand: _multiplication,
    prerequisites: const ['mul_2_5_10'],
    generate: (rng) => ArithmeticItem(
      skillId: 'mul_facts',
      a: _between(rng, 3, 9),
      b: _between(rng, 3, 9),
      op: Operation.multiply,
    ),
  ),
  Skill(
    id: 'mul_2d_by_1d',
    name: '2-digit × 1-digit',
    description: 'Like 34 × 6',
    strand: _multiplication,
    prerequisites: const ['mul_facts', 'add_2d_carry'],
    generate: (rng) => ArithmeticItem(
      skillId: 'mul_2d_by_1d',
      a: _between(rng, 12, 99),
      b: _between(rng, 2, 9),
      op: Operation.multiply,
    ),
  ),

  // ---- Division ----------------------------------------------------------
  Skill(
    id: 'div_facts',
    name: 'Division facts',
    description: 'Like 42 ÷ 6',
    strand: _division,
    prerequisites: const ['mul_facts'],
    generate: (rng) {
      final b = _between(rng, 2, 9);
      final q = _between(rng, 2, 9);
      return ArithmeticItem(skillId: 'div_facts', a: b * q, b: b, op: Operation.divide);
    },
  ),
  Skill(
    id: 'div_2d_by_1d',
    name: '2-digit ÷ 1-digit',
    description: 'Like 72 ÷ 4 (no remainder)',
    strand: _division,
    prerequisites: const ['div_facts', 'mul_2d_by_1d'],
    generate: (rng) {
      while (true) {
        final b = _between(rng, 2, 9);
        final q = _between(rng, 11, 49);
        if (b * q <= 99) {
          return ArithmeticItem(skillId: 'div_2d_by_1d', a: b * q, b: b, op: Operation.divide);
        }
      }
    },
  ),
]),
);
