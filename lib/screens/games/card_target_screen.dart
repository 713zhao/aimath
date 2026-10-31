import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/game_result_recorder.dart';
import '../../utils/colors.dart';
import '../../utils/enums.dart';

class _CardItem {
  final int id;
  final int value;
  bool matched;

  _CardItem({required this.id, required this.value})
      : matched = false;
}

/// Target 10 card game: tap two visible number cards whose sum is 10.
class CardTargetScreen extends StatefulWidget {
  const CardTargetScreen({super.key});

  @override
  State<CardTargetScreen> createState() => _CardTargetScreenState();
}

class _CardTargetScreenState extends State<CardTargetScreen> {
  static const _spacing = 12.0;
  static const _minCellSize = 68.0;

  final _random = Random();
  List<_CardItem> _cards = [];
  int _pairCount = 8; // recomputed to fit the screen before the first game
  int _crossAxisCount = 4;
  bool _sizeInitialized = false;
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _wrongFlash = false;
  int _moves = 0;
  int _matches = 0;
  DateTime _startedAt = DateTime.now();
  late Stopwatch _stopwatch;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Picks a grid size (columns/rows -> pair count) that fills the given
  /// area with comfortably-sized cards, so the board never needs to scroll.
  void _initializeGridSize(double width, double height) {
    int cols = ((width + _spacing) / (_minCellSize + _spacing))
        .floor()
        .clamp(3, 6);
    int rows = ((height + _spacing) / (_minCellSize + _spacing))
        .floor()
        .clamp(3, 6);
    int total = cols * rows;
    if (total.isOdd) total -= 1;
    total = total.clamp(12, 36);

    _crossAxisCount = cols;
    _pairCount = total ~/ 2;
    _sizeInitialized = true;
  }

  void _newGame() {
    final pairs = <int>[];
    for (int i = 0; i < _pairCount; i++) {
      final a = _random.nextInt(11); // 0-10
      pairs.add(a);
      pairs.add(10 - a);
    }
    pairs.shuffle(_random);

    setState(() {
      _cards = List.generate(
        pairs.length,
        (i) => _CardItem(id: i, value: pairs[i]),
      );
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
      _wrongFlash = false;
      _moves = 0;
      _matches = 0;
      _elapsed = Duration.zero;
      _startedAt = DateTime.now();
    });

    _ticker?.cancel();
    _stopwatch.reset();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  void _onTapCard(int index) {
    final card = _cards[index];
    if (card.matched || index == _firstSelectedIndex || _secondSelectedIndex != null) {
      return;
    }

    if (_firstSelectedIndex == null) {
      setState(() => _firstSelectedIndex = index);
      return;
    }

    setState(() => _secondSelectedIndex = index);
    _moves++;
    final first = _cards[_firstSelectedIndex!];
    final second = _cards[index];

    if (first.value + second.value == 10) {
      setState(() {
        first.matched = true;
        second.matched = true;
        _matches++;
        _firstSelectedIndex = null;
        _secondSelectedIndex = null;
      });
      if (_matches == _pairCount) {
        _stopwatch.stop();
        _ticker?.cancel();
        // Every pair counts as one problem; each wrong attempt is a miss.
        GameResultRecorder.record(
          gameId: 'target_10',
          problems: _moves,
          correct: _pairCount,
          startedAt: _startedAt,
          operations: {
            Operation.add: (attempts: _moves, correct: _pairCount),
          },
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
      }
    } else {
      setState(() => _wrongFlash = true);
      Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _wrongFlash = false;
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
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
        content: Text(
            'You matched all $_pairCount pairs in $_moves moves and ${_formatDuration(_elapsed)}.'),
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target 10'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _newGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statChip(Icons.timer, _formatDuration(_elapsed), AppColors.primaryBlue),
                  _statChip(Icons.touch_app, '$_moves moves', AppColors.warningOrange),
                  _statChip(Icons.check_circle, '$_matches/$_pairCount', AppColors.successGreen),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap two cards that add up to 10',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_sizeInitialized) {
          _initializeGridSize(constraints.maxWidth, constraints.maxHeight);
          WidgetsBinding.instance.addPostFrameCallback((_) => _newGame());
          return const Center(child: CircularProgressIndicator());
        }
        if (_cards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final cols = _crossAxisCount;
        final rows = (_cards.length / cols).ceil();
        final cellWidth = (constraints.maxWidth - _spacing * (cols - 1)) / cols;
        final cellHeight = (constraints.maxHeight - _spacing * (rows - 1)) / rows;
        final aspectRatio = cellWidth / cellHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) => _buildCard(index),
        );
      },
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    final isSelected = index == _firstSelectedIndex || index == _secondSelectedIndex;
    final isWrong = _wrongFlash && isSelected;

    Color bgColor = Colors.white;
    Color borderColor = AppColors.primaryBlue.withValues(alpha: 0.3);
    if (card.matched) {
      bgColor = AppColors.successGreen.withValues(alpha: 0.15);
      borderColor = AppColors.successGreen;
    } else if (isWrong) {
      bgColor = AppColors.errorRed.withValues(alpha: 0.15);
      borderColor = AppColors.errorRed;
    } else if (isSelected) {
      bgColor = AppColors.primaryBlue.withValues(alpha: 0.15);
      borderColor = AppColors.primaryBlue;
    }

    return GestureDetector(
      onTap: card.matched ? null : () => _onTapCard(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: card.matched ? 0.35 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: card.matched
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${card.value}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: card.matched ? AppColors.successGreen : AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}
