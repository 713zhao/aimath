import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../models/fraction.dart';
import '../../providers/student_provider.dart';
import '../../services/game_result_recorder.dart';
import '../../utils/colors.dart';
import '../../utils/enums.dart';

// New values go last: the selected index is persisted per student, and Mix
// draws from the first four.
enum _DiceOp { add, subtract, multiply, divide, mix, fraction }

extension _DiceOpLabel on _DiceOp {
  /// The practice operation this maps to, or null for fractions (which have
  /// no matching [Operation]). Never called for [_DiceOp.mix], which is
  /// resolved to a concrete op before a round starts.
  Operation? get operation {
    switch (this) {
      case _DiceOp.add:
        return Operation.add;
      case _DiceOp.subtract:
        return Operation.subtract;
      case _DiceOp.multiply:
        return Operation.multiply;
      case _DiceOp.divide:
        return Operation.divide;
      case _DiceOp.fraction:
        return null;
      case _DiceOp.mix:
        throw StateError('mix is not a single operation');
    }
  }

  String get label {
    switch (this) {
      case _DiceOp.add:
        return '+';
      case _DiceOp.subtract:
        return '−';
      case _DiceOp.multiply:
        return '×';
      case _DiceOp.divide:
        return '÷';
      case _DiceOp.mix:
        return 'Mix';
      case _DiceOp.fraction:
        return 'Fraction';
    }
  }
}

/// Pip positions on a 3x3 grid (row, col) for each die face, like a real die.
const Map<int, Set<(int, int)>> _pipPositions = {
  1: {(1, 1)},
  2: {(0, 0), (2, 2)},
  3: {(0, 0), (1, 1), (2, 2)},
  4: {(0, 0), (0, 2), (2, 0), (2, 2)},
  5: {(0, 0), (0, 2), (1, 1), (2, 0), (2, 2)},
  6: {(0, 0), (0, 2), (1, 0), (1, 2), (2, 0), (2, 2)},
};

/// Math Dice Game: roll a configurable number of six-sided dice and answer
/// a quiz question built from the roll using the selected operation.
class DiceGameScreen extends StatefulWidget {
  const DiceGameScreen({super.key});

  @override
  State<DiceGameScreen> createState() => _DiceGameScreenState();
}

class _DiceGameScreenState extends State<DiceGameScreen>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  final _answerController = TextEditingController();
  final _answerFocusNode = FocusNode();

  int _diceCount = 2;
  int _sides = 6;
  _DiceOp _selectedOp = _DiceOp.add;

  List<int> _dice = [];
  _DiceOp _roundOp = _DiceOp.add;
  double _correctAnswer = 0;
  // Fraction rounds: dice are numerators over [_sides]; the text is what's
  // shown (e.g. "2/6 + 4/6") and the answer is compared by value.
  Fraction? _correctFraction;
  String? _fractionExpression;
  bool? _isCorrect;
  int _score = 0;
  int _streak = 0;
  int _rounds = 0;

  // Dice Math never ends, so answers are saved in batches (and on exit).
  static const _batchSize = 10;
  int _unsavedRounds = 0;
  int _unsavedCorrect = 0;
  final Map<Operation, OperationResult> _unsavedOps = {};
  DateTime _batchStartedAt = DateTime.now();

  late final AnimationController _spinController;
  Timer? _rollTicker;
  bool _isRolling = false;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final studentId = context.read<StudentProvider>().currentStudent?.id;
    _studentId = studentId;
    if (studentId != null) {
      final prefs = await SharedPreferences.getInstance();
      final savedCount = prefs.getInt('dice_count_$studentId');
      final savedSides = prefs.getInt('dice_sides_$studentId');
      final savedOpIndex = prefs.getInt('dice_op_$studentId');
      if (!mounted) return;
      setState(() {
        if (savedCount != null) _diceCount = savedCount;
        if (savedSides == 6 || savedSides == 10) _sides = savedSides!;
        if (savedOpIndex != null && savedOpIndex < _DiceOp.values.length) {
          _selectedOp = _DiceOp.values[savedOpIndex];
        }
        if (_selectedOp == _DiceOp.fraction && _diceCount < 2) _diceCount = 2;
      });
    }
    _rollDice();
  }

  Future<void> _saveSettings() async {
    final studentId = _studentId;
    if (studentId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dice_count_$studentId', _diceCount);
    await prefs.setInt('dice_sides_$studentId', _sides);
    await prefs.setInt('dice_op_$studentId', _selectedOp.index);
  }

  void _flushResults() {
    if (_unsavedRounds == 0) return;
    GameResultRecorder.record(
      gameId: 'dice_math',
      problems: _unsavedRounds,
      correct: _unsavedCorrect,
      startedAt: _batchStartedAt,
      operations: Map.of(_unsavedOps),
    );
    _unsavedOps.clear();
    _unsavedRounds = 0;
    _unsavedCorrect = 0;
    _batchStartedAt = DateTime.now();
  }

  @override
  void dispose() {
    _flushResults();
    _spinController.dispose();
    _rollTicker?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  /// Plays a rolling animation with randomly-flickering faces, then
  /// finalizes the real roll and next question.
  void _animateRoll() {
    if (_isRolling) return;
    if (_dice.isEmpty) {
      // First roll on screen load: no need to animate from nothing.
      _rollDice();
      return;
    }
    setState(() => _isRolling = true);
    _spinController.forward(from: 0);
    _rollTicker = Timer.periodic(const Duration(milliseconds: 70), (_) {
      setState(() {
        _dice = List.generate(_diceCount, (_) => _random.nextInt(_sides) + 1);
      });
    });
    Future.delayed(_spinController.duration!, () {
      _rollTicker?.cancel();
      if (!mounted) return;
      setState(() => _isRolling = false);
      _rollDice();
    });
  }

  void _rollDice() {
    final dice = List.generate(_diceCount, (_) => _random.nextInt(_sides) + 1);
    final op = _selectedOp == _DiceOp.mix
        ? _DiceOp.values[_random.nextInt(4)]
        : _selectedOp;

    if (op == _DiceOp.fraction) {
      final expr = FractionExpression.build(
        dice,
        _sides,
        subtract: _random.nextBool(),
      );
      setState(() {
        _dice = dice;
        _roundOp = op;
        _fractionExpression = expr.text;
        _correctFraction = expr.answer;
        _correctAnswer = 0;
        _isCorrect = null;
        _answerController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _answerFocusNode.requestFocus();
      });
      return;
    }

    double result;
    switch (op) {
      case _DiceOp.add:
        result = dice.fold<int>(0, (a, b) => a + b).toDouble();
        break;
      case _DiceOp.subtract:
        result =
            dice.skip(1).fold<double>(dice.first.toDouble(), (a, b) => a - b);
        break;
      case _DiceOp.multiply:
        result = dice.fold<int>(1, (a, b) => a * b).toDouble();
        break;
      case _DiceOp.divide:
        result =
            dice.skip(1).fold<double>(dice.first.toDouble(), (a, b) => a / b);
        result = double.parse(result.toStringAsFixed(2));
        break;
      case _DiceOp.mix:
      case _DiceOp.fraction:
        result = 0; // unreachable, both resolved above
        break;
    }

    setState(() {
      _dice = dice;
      _roundOp = op;
      _fractionExpression = null;
      _correctFraction = null;
      _correctAnswer = result;
      _isCorrect = null;
      _answerController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  void _submit() {
    if (_isCorrect != null) {
      _animateRoll();
      return;
    }
    final bool correct;
    if (_roundOp == _DiceOp.fraction) {
      final input = Fraction.tryParse(_answerController.text);
      if (input == null) return;
      correct = input.equalsValue(_correctFraction!);
    } else {
      final input = double.tryParse(_answerController.text.trim());
      if (input == null) return;
      correct = (input - _correctAnswer).abs() < 0.01;
    }
    setState(() {
      _isCorrect = correct;
      _rounds++;
      if (correct) {
        _score++;
        _streak++;
      } else {
        _streak = 0;
      }
    });
    _unsavedRounds++;
    if (correct) _unsavedCorrect++;
    final op = _roundOp.operation;
    if (op != null) {
      final prev = _unsavedOps[op] ?? (attempts: 0, correct: 0);
      _unsavedOps[op] = (
        attempts: prev.attempts + 1,
        correct: prev.correct + (correct ? 1 : 0),
      );
    }
    if (_unsavedRounds >= _batchSize) _flushResults();
  }

  /// "6/6 = 1" style text when the answer simplifies, otherwise just "5/6".
  String _fractionAnswerText() {
    final f = _correctFraction!;
    final simple = f.toSimplifiedString();
    return simple == '$f' ? simple : '$f = $simple';
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final expression = _roundOp == _DiceOp.fraction
        ? (_fractionExpression ?? '')
        : _dice.map((d) => d.toString()).join(' ${_roundOp.label} ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Math'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildConfigPanel(),
              const SizedBox(height: 20),
              _buildScoreRow(),
              const SizedBox(height: 24),
              _buildDiceRow(),
              const SizedBox(height: 8),
              Text(
                'Tap the dice to roll',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (_roundOp == _DiceOp.fraction)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Dice are the tops of the fractions; the bottom is $_sides',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                '$expression = ?',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildAnswerArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Number of dice',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          _diceCount > (_selectedOp == _DiceOp.fraction ? 2 : 1)
                              ? () {
                                  setState(() => _diceCount--);
                                  _saveSettings();
                                  _animateRoll();
                                }
                              : null,
                    ),
                    Text('$_diceCount',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _diceCount < 5
                          ? () {
                              setState(() => _diceCount++);
                              _saveSettings();
                              _animateRoll();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Dice Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [6, 10].map((sides) {
                final selected = _sides == sides;
                return ChoiceChip(
                  label: Text('$sides-sided'),
                  selected: selected,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() => _sides = sides);
                    _saveSettings();
                    _animateRoll();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Text('Operation',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _DiceOp.values.map((op) {
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
                    setState(() {
                      _selectedOp = op;
                      // A fraction needs at least two terms.
                      if (op == _DiceOp.fraction && _diceCount < 2) {
                        _diceCount = 2;
                      }
                    });
                    _saveSettings();
                    _animateRoll();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statChip(Icons.check_circle, 'Score', '$_score/$_rounds',
            AppColors.successGreen),
        _statChip(Icons.local_fire_department, 'Streak', '$_streak',
            AppColors.warningOrange),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text('$label: $value'),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildDiceRow() {
    return GestureDetector(
      onTap: _animateRoll,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(_dice.length, (index) {
            return AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                final t = _spinController.value;
                final rolling = _isRolling;
                final angleX =
                    rolling ? t * 2 * pi * (1.4 + index * 0.25) : 0.0;
                final angleY =
                    rolling ? t * 2 * pi * (1.0 + index * 0.18) : 0.0;
                final bounce = rolling ? (1 - 0.18 * sin(t * pi)) : 1.0;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0025)
                    ..rotateX(angleX)
                    ..rotateY(angleY)
                    ..scaleByDouble(bounce, bounce, bounce, 1),
                  child: child,
                );
              },
              child: _DieFace(value: _dice[index], sides: _sides),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnswerArea() {
    Color? feedbackColor;
    String? feedbackText;
    if (_isCorrect != null) {
      feedbackColor = _isCorrect! ? AppColors.successGreen : AppColors.errorRed;
      final answer = _roundOp == _DiceOp.fraction
          ? _fractionAnswerText()
          : _formatNumber(_correctAnswer);
      feedbackText = _isCorrect! ? 'Correct!' : 'Answer: $answer';
    }

    return Column(
      children: [
        SizedBox(
          width: 160,
          child: TextField(
            controller: _answerController,
            focusNode: _answerFocusNode,
            enabled: _isCorrect == null,
            textAlign: TextAlign.center,
            keyboardType: _roundOp == _DiceOp.fraction
                ? TextInputType.text
                : const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
            inputFormatters: _roundOp == _DiceOp.fraction
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]'))]
                : null,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: _roundOp == _DiceOp.fraction ? 'e.g. 5/6' : 'Answer',
              filled: true,
              fillColor:
                  feedbackColor?.withValues(alpha: 0.1) ?? AppColors.lightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 12),
        if (feedbackText != null)
          Text(
            feedbackText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: feedbackColor,
            ),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _isRolling ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(_isCorrect == null ? 'Submit' : 'Roll Again'),
        ),
      ],
    );
  }
}

/// A single die face rendered with a 3D-looking gradient and beveled shadow.
/// Six-sided dice show raised pips like a real die; ten-sided dice show a
/// bold numeral, since real d10s use digits rather than pips.
class _DieFace extends StatelessWidget {
  final int value;
  final int sides;

  const _DieFace({required this.value, required this.sides});

  @override
  Widget build(BuildContext context) {
    // A ten-sided die's characteristic kite/trapezohedron faces are
    // suggested with an angular shape instead of the six-sided die's
    // rounded square.
    final shapeRadius = sides == 6 ? 14.0 : 10.0;

    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(shapeRadius),
        gradient: sides == 6
            ? const LinearGradient(
                colors: [Colors.white, Color(0xFFD7DEE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(3, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: sides == 6 ? _buildPipGrid() : _buildNumeral(),
    );
  }

  Widget _buildPipGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (col) {
            final active = _pipPositions[value]!.contains((row, col));
            return SizedBox(
              width: 12,
              height: 12,
              child: active ? _buildPip() : null,
            );
          }),
        );
      }),
    );
  }

  Widget _buildNumeral() {
    return Center(
      child: Text(
        '$value',
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7A3B00),
        ),
      ),
    );
  }

  Widget _buildPip() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF0A0A0A)],
          center: Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 1.5,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
    );
  }
}
