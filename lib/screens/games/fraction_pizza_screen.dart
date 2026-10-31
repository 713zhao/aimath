import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../models/fraction.dart';
import '../../services/game_result_recorder.dart';
import '../../utils/colors.dart';

enum _RoundType { read, build, compare }

enum _Level {
  easy('Easy', [2, 3, 4]),
  medium('Medium', [2, 3, 4, 5, 6, 8]),
  hard('Hard', [3, 4, 5, 6, 8, 10, 12]);

  final String label;
  final List<int> denominators;
  const _Level(this.label, this.denominators);
}

const _pizzaColor = Color(0xFFFFB74D);
const _crustColor = Color(0xFFD9822B);
const _emptyColor = Color(0xFFFFF3E0);

/// Pizza Slices game: read, build and compare fractions shown as pizzas.
class FractionPizzaScreen extends StatefulWidget {
  const FractionPizzaScreen({super.key});

  @override
  State<FractionPizzaScreen> createState() => _FractionPizzaScreenState();
}

class _FractionPizzaScreenState extends State<FractionPizzaScreen> {
  static const _totalRounds = 10;

  final _random = Random();
  _Level _level = _Level.easy;

  int _round = 0;
  int _score = 0;
  int _streak = 0;
  bool _finished = false;
  DateTime _startedAt = DateTime.now();
  List<Achievement> _newAchievements = [];

  late _RoundType _type;
  late Fraction _target; // read/build: the fraction; compare: left pizza
  late Fraction _other; // compare: right pizza
  List<Fraction> _options = [];
  Set<int> _shaded = {}; // build mode: slices the student has shaded
  bool? _correct; // null until answered
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  Fraction _randomFraction({int? denominator}) {
    final d = denominator ??
        _level.denominators[_random.nextInt(_level.denominators.length)];
    return Fraction(_random.nextInt(d) + 1, d); // 1..d slices shaded
  }

  void _newGame() {
    _round = 0;
    _score = 0;
    _streak = 0;
    _finished = false;
    _startedAt = DateTime.now();
    _newAchievements = [];
    _nextRound(first: true);
  }

  void _nextRound({bool first = false}) {
    if (!first && _round + 1 >= _totalRounds) {
      setState(() => _finished = true);
      GameResultRecorder.record(
        gameId: 'pizza_slices',
        problems: _totalRounds,
        correct: _score,
        startedAt: _startedAt,
      ).then((unlocked) {
        if (mounted && unlocked.isNotEmpty) {
          setState(() => _newAchievements = unlocked);
        }
      });
      return;
    }
    setState(() {
      if (!first) _round++;
      _correct = null;
      _feedback = '';
      _shaded = {};
      _type = _RoundType.values[_random.nextInt(_RoundType.values.length)];
      switch (_type) {
        case _RoundType.read:
          _target = _randomFraction();
          _options = _buildOptions(_target);
          break;
        case _RoundType.build:
          _target = _randomFraction();
          break;
        case _RoundType.compare:
          _target = _randomFraction();
          do {
            _other = _randomFraction();
          } while (_other == _target);
          break;
      }
    });
  }

  /// The correct fraction plus three distinct-valued distractors, shuffled.
  List<Fraction> _buildOptions(Fraction answer) {
    final options = <Fraction>[answer];
    var guard = 0;
    while (options.length < 4 && guard++ < 100) {
      // Distractors share the denominator or the numerator, the classic
      // mix-ups, so students must read both parts.
      final candidate = _random.nextBool()
          ? Fraction(_random.nextInt(answer.denominator) + 1,
              answer.denominator)
          : Fraction(answer.numerator,
              _level.denominators[_random.nextInt(_level.denominators.length)]);
      if (candidate.numerator > candidate.denominator) continue;
      if (options.any((o) => o.equalsValue(candidate))) continue;
      options.add(candidate);
    }
    // Fallback for tiny denominators where distractors run out.
    for (var n = 1; options.length < 4 && n <= 12; n++) {
      final c = Fraction(min(n, 12), 12);
      if (!options.any((o) => o.equalsValue(c))) options.add(c);
    }
    options.shuffle(_random);
    return options;
  }

  void _record(bool correct, String wrongFeedback) {
    setState(() {
      _correct = correct;
      if (correct) {
        _score++;
        _streak++;
        _feedback = _streak >= 3 ? 'Correct! $_streak in a row!' : 'Correct!';
      } else {
        _streak = 0;
        _feedback = wrongFeedback;
      }
    });
  }

  void _answerRead(Fraction picked) {
    if (_correct != null) return;
    _record(picked == _target, 'Not quite. It was $_target.');
  }

  void _checkBuild() {
    if (_correct != null) return;
    final ok = _shaded.length == _target.numerator;
    if (!ok) {
      // Show the right answer on the pizza so the student can learn from it.
      setState(() => _shaded = {for (var i = 0; i < _target.numerator; i++) i});
    }
    _record(ok,
        '$_target means ${_target.numerator} of ${_target.denominator} slices.');
  }

  void _answerCompare(int choice) {
    // choice: -1 left is bigger, 0 equal, 1 right is bigger
    if (_correct != null) return;
    final actual = _target.compareTo(_other).sign;
    final expected = -actual; // left bigger -> -1
    final ok = choice == expected;
    final relation = actual > 0 ? '>' : (actual < 0 ? '<' : '=');
    _record(ok, 'Not quite: $_target $relation $_other.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Slices'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<_Level>(
            icon: const Icon(Icons.tune),
            tooltip: 'Level',
            onSelected: (l) {
              _level = l;
              _newGame();
            },
            itemBuilder: (_) => [
              for (final l in _Level.values)
                CheckedPopupMenuItem(
                  value: l,
                  checked: l == _level,
                  child: Text(l.label),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _finished ? _buildResults() : _buildRound(),
      ),
    );
  }

  Widget _buildRound() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Round ${_round + 1}/$_totalRounds',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Score: $_score'),
              Text('Streak: $_streak'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (_round + 1) / _totalRounds),
          const SizedBox(height: 16),
          Text(_prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: Center(child: _buildBoard())),
          _buildFeedback(),
          const SizedBox(height: 12),
          _buildControls(),
        ],
      ),
    );
  }

  String get _prompt {
    switch (_type) {
      case _RoundType.read:
        return 'What fraction of the pizza is shaded?';
      case _RoundType.build:
        return 'Tap slices to shade $_target of the pizza';
      case _RoundType.compare:
        return 'Which pizza has more shaded?';
    }
  }

  Widget _buildBoard() {
    switch (_type) {
      case _RoundType.read:
        return _Pizza(
          slices: _target.denominator,
          shaded: {for (var i = 0; i < _target.numerator; i++) i},
        );
      case _RoundType.build:
        return _Pizza(
          slices: _target.denominator,
          shaded: _shaded,
          onTapSlice: _correct == null
              ? (i) => setState(() {
                    if (!_shaded.add(i)) _shaded.remove(i);
                  })
              : null,
        );
      case _RoundType.compare:
        return Row(
          children: [
            Expanded(child: _comparePizza(_target, -1)),
            const SizedBox(width: 12),
            Expanded(child: _comparePizza(_other, 1)),
          ],
        );
    }
  }

  Widget _comparePizza(Fraction f, int choice) {
    return GestureDetector(
      onTap: () => _answerCompare(choice),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: _Pizza(
              slices: f.denominator,
              shaded: {for (var i = 0; i < f.numerator; i++) i},
            ),
          ),
          const SizedBox(height: 8),
          // Reveal the fractions only after answering so the label doesn't
          // give the answer away.
          Text(_correct == null ? ' ' : '$f',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    if (_correct == null) return const SizedBox(height: 40);
    final color = _correct! ? AppColors.successGreen : AppColors.errorRed;
    return Container(
      width: double.infinity,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _correct! ? AppColors.positiveGreen : AppColors.negativeRed,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(_feedback,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildControls() {
    if (_correct != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextRound,
          child: Text(_round + 1 >= _totalRounds ? 'Finish' : 'Next'),
        ),
      );
    }
    switch (_type) {
      case _RoundType.read:
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final o in _options)
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => _answerRead(o),
                  child: Text('$o', style: const TextStyle(fontSize: 20)),
                ),
              ),
          ],
        );
      case _RoundType.build:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkBuild,
            child: const Text('Check'),
          ),
        );
      case _RoundType.compare:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _answerCompare(0),
            child: const Text('They are equal'),
          ),
        );
    }
  }

  Widget _buildResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: AppColors.accentGold),
            const SizedBox(height: 16),
            Text('You scored $_score / $_totalRounds',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            for (final a in _newAchievements) ...[
              const SizedBox(height: 12),
              Text('${a.icon} Achievement unlocked: ${a.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _newGame, child: const Text('Play again')),
          ],
        ),
      ),
    );
  }
}

/// A pizza cut into [slices] equal wedges; wedges in [shaded] are filled.
/// Wedge 0 starts at the top and indices run clockwise.
class _Pizza extends StatelessWidget {
  final int slices;
  final Set<int> shaded;
  final ValueChanged<int>? onTapSlice;

  const _Pizza({required this.slices, required this.shaded, this.onTapSlice});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, box) {
          return GestureDetector(
            onTapDown: onTapSlice == null
                ? null
                : (d) {
                    final c = Offset(box.maxWidth / 2, box.maxHeight / 2);
                    final v = d.localPosition - c;
                    if (v.distance > box.maxWidth / 2) return;
                    // atan2 measured clockwise from the top.
                    var angle = atan2(v.dx, -v.dy);
                    if (angle < 0) angle += 2 * pi;
                    onTapSlice!((angle / (2 * pi) * slices).floor() % slices);
                  },
            child: CustomPaint(
              painter: _PizzaPainter(slices, Set.of(shaded)),
            ),
          );
        },
      ),
    );
  }
}

class _PizzaPainter extends CustomPainter {
  final int slices;
  final Set<int> shaded;

  _PizzaPainter(this.slices, this.shaded);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 2;
    final oval = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * pi / slices;
    const start = -pi / 2;

    final fill = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < slices; i++) {
      fill.color = shaded.contains(i) ? _pizzaColor : _emptyColor;
      canvas.drawArc(oval, start + i * sweep, sweep, true, fill);
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _crustColor;
    for (var i = 0; i < slices; i++) {
      canvas.drawArc(oval, start + i * sweep, sweep, true, line);
    }
    canvas.drawCircle(
        center, radius, line..strokeWidth = 4); // crust ring
  }

  @override
  bool shouldRepaint(_PizzaPainter old) =>
      old.slices != slices || !_setEquals(old.shaded, shaded);

  static bool _setEquals(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);
}
