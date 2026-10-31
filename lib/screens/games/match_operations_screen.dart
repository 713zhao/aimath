import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/fraction.dart';
import '../../services/game_result_recorder.dart';
import '../../utils/colors.dart';
import '../../utils/enums.dart';

// Same choices as the Dice game's operation selector.
enum _MatchOp {
  add('+', Operation.add),
  subtract('−', Operation.subtract),
  multiply('×', Operation.multiply),
  divide('÷', Operation.divide),
  mix('Mix', null),
  fraction('Fraction', null);

  final String label;

  /// The single practice operation, or null for Mix and Fraction.
  final Operation? operation;
  const _MatchOp(this.label, this.operation);
}

class _Problem {
  final int id;
  final String expression;
  final double answer;
  final String answerLabel;

  /// Null for fraction problems, which have no matching [Operation].
  final Operation? op;

  _Problem({
    required this.id,
    required this.expression,
    required this.answer,
    required this.answerLabel,
    required this.op,
  });
}

class _AnswerTile {
  final int problemId;
  final String label;
  bool matched;

  _AnswerTile({required this.problemId, required this.label}) : matched = false;
}

/// Match Answers game: left column shows expressions, right column shows
/// shuffled answers. Tap one from each side to connect a matching pair.
class MatchOperationsScreen extends StatefulWidget {
  const MatchOperationsScreen({super.key});

  @override
  State<MatchOperationsScreen> createState() => _MatchOperationsScreenState();
}

class _MatchOperationsScreenState extends State<MatchOperationsScreen> {
  static const _defaultPairCount = 6;

  final _random = Random();
  _MatchOp _selectedOp = _MatchOp.mix;
  int _pairCount = _defaultPairCount;

  late List<_Problem> _problems;
  late List<_AnswerTile> _answers;
  int? _selectedProblemId;
  int? _selectedAnswerIndex;
  bool _wrongFlash = false;
  int _matches = 0;
  int _moves = 0;
  // Per-operation tap-pair attempts and first-try matches for this game.
  final Map<Operation, int> _opAttempts = {};
  final Map<Operation, int> _opCorrect = {};
  DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  Operation _resolveOp() {
    final single = _selectedOp.operation;
    if (single != null) return single;
    return Operation.values[_random.nextInt(Operation.values.length)];
  }

  _Problem _generateFractionProblem(int id) {
    final denominator = _random.nextInt(9) + 2; // 2-10
    final numerators = [
      _random.nextInt(denominator) + 1,
      _random.nextInt(denominator) + 1,
    ];
    final expr = FractionExpression.build(
      numerators,
      denominator,
      subtract: _random.nextBool(),
    );
    return _Problem(
      id: id,
      expression: expr.text,
      // Equal fractions divide to the exact same double, so this also
      // de-duplicates values like 2/6 and 1/3.
      answer: expr.answer.numerator / expr.answer.denominator,
      answerLabel: expr.answer.toSimplifiedString(),
      op: null,
    );
  }

  _Problem _generateProblem(int id) {
    if (_selectedOp == _MatchOp.fraction) return _generateFractionProblem(id);
    final op = _resolveOp();
    int a, b;
    double answer;
    String expr;
    switch (op) {
      case Operation.add:
        a = _random.nextInt(20) + 1;
        b = _random.nextInt(20) + 1;
        answer = (a + b).toDouble();
        expr = '$a + $b';
        break;
      case Operation.subtract:
        b = _random.nextInt(20);
        a = b + _random.nextInt(20) + 1;
        answer = (a - b).toDouble();
        expr = '$a − $b';
        break;
      case Operation.multiply:
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(10) + 1;
        answer = (a * b).toDouble();
        expr = '$a × $b';
        break;
      case Operation.divide:
        b = _random.nextInt(9) + 1;
        final quotient = _random.nextInt(10) + 1;
        a = b * quotient;
        answer = quotient.toDouble();
        expr = '$a ÷ $b';
        break;
    }
    return _Problem(
      id: id,
      expression: expr,
      answer: answer,
      answerLabel: _formatAnswer(answer),
      op: op,
    );
  }

  String _formatAnswer(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  void _newGame() {
    final usedAnswers = <double>{};
    final problems = <_Problem>[];
    for (int i = 0; i < _pairCount; i++) {
      _Problem problem;
      var attempts = 0;
      do {
        problem = _generateProblem(i);
        attempts++;
      } while (usedAnswers.contains(problem.answer) && attempts < 30);
      usedAnswers.add(problem.answer);
      problems.add(problem);
    }
    final answers = problems
        .map((p) => _AnswerTile(problemId: p.id, label: p.answerLabel))
        .toList()
      ..shuffle(_random);

    setState(() {
      _problems = problems;
      _answers = answers;
      _selectedProblemId = null;
      _selectedAnswerIndex = null;
      _wrongFlash = false;
      _matches = 0;
      _moves = 0;
      _opAttempts.clear();
      _opCorrect.clear();
      _startedAt = DateTime.now();
    });
  }

  void _onTapProblem(int problemId) {
    final alreadyMatched =
        _answers.any((a) => a.problemId == problemId && a.matched);
    if (alreadyMatched) return;
    setState(() {
      _selectedProblemId = _selectedProblemId == problemId ? null : problemId;
    });
    _tryMatch();
  }

  void _onTapAnswer(int index) {
    if (_answers[index].matched) return;
    setState(() {
      _selectedAnswerIndex = _selectedAnswerIndex == index ? null : index;
    });
    _tryMatch();
  }

  void _tryMatch() {
    if (_selectedProblemId == null || _selectedAnswerIndex == null) return;
    _moves++;
    final answerTile = _answers[_selectedAnswerIndex!];
    final op = _problems.firstWhere((p) => p.id == _selectedProblemId).op;
    if (op != null) _opAttempts[op] = (_opAttempts[op] ?? 0) + 1;

    if (answerTile.problemId == _selectedProblemId) {
      if (op != null) _opCorrect[op] = (_opCorrect[op] ?? 0) + 1;
      setState(() {
        answerTile.matched = true;
        _matches++;
        _selectedProblemId = null;
        _selectedAnswerIndex = null;
      });
      if (_matches == _pairCount) {
        GameResultRecorder.record(
          gameId: 'match_answers',
          problems: _moves,
          correct: _pairCount,
          startedAt: _startedAt,
          operations: {
            for (final e in _opAttempts.entries)
              e.key: (attempts: e.value, correct: _opCorrect[e.key] ?? 0),
          },
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
      }
    } else {
      setState(() => _wrongFlash = true);
      Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _wrongFlash = false;
          _selectedProblemId = null;
          _selectedAnswerIndex = null;
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 All matched!'),
        content: Text('You matched all $_pairCount pairs in $_moves moves.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Answers'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _newGame,
            tooltip: 'New Set',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildConfigPanel(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(Icons.touch_app, '$_moves moves',
                      AppColors.warningOrange),
                  _statChip(Icons.check_circle, '$_matches/$_pairCount',
                      AppColors.successGreen),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProblemColumn()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnswerColumn()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Operation',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _MatchOp.values.map((op) {
                final selected = _selectedOp == op;
                return ChoiceChip(
                  label: Text(op.label),
                  selected: selected,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedOp = op);
                    _newGame();
                  },
                );
              }).toList(),
            ),
            Row(
              children: [
                const Text('Pairs:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _pairCount > 3
                      ? () {
                          setState(() => _pairCount--);
                          _newGame();
                        }
                      : null,
                ),
                Text('$_pairCount'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _pairCount < 8
                      ? () {
                          setState(() => _pairCount++);
                          _newGame();
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildProblemColumn() {
    return ListView(
      children: _problems.map((p) {
        final matched = _answers.any((a) => a.problemId == p.id && a.matched);
        final selected = _selectedProblemId == p.id;
        return _buildTile(
          label: p.expression,
          matched: matched,
          selected: selected,
          wrong: _wrongFlash && selected,
          onTap: () => _onTapProblem(p.id),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerColumn() {
    return ListView(
      children: List.generate(_answers.length, (index) {
        final a = _answers[index];
        final selected = _selectedAnswerIndex == index;
        return _buildTile(
          label: a.label,
          matched: a.matched,
          selected: selected,
          wrong: _wrongFlash && selected,
          onTap: () => _onTapAnswer(index),
        );
      }),
    );
  }

  Widget _buildTile({
    required String label,
    required bool matched,
    required bool selected,
    required bool wrong,
    required VoidCallback onTap,
  }) {
    Color bgColor = Colors.white;
    Color borderColor = AppColors.primaryBlue.withValues(alpha: 0.3);
    if (matched) {
      bgColor = AppColors.successGreen.withValues(alpha: 0.15);
      borderColor = AppColors.successGreen;
    } else if (wrong) {
      bgColor = AppColors.errorRed.withValues(alpha: 0.15);
      borderColor = AppColors.errorRed;
    } else if (selected) {
      bgColor = AppColors.warningOrange.withValues(alpha: 0.15);
      borderColor = AppColors.warningOrange;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: matched ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: matched ? 0.4 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: matched ? AppColors.successGreen : AppColors.darkText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
