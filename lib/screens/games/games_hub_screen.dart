import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'dice_game_screen.dart';
import 'card_target_screen.dart';
import 'match_operations_screen.dart';
import 'fraction_pizza_screen.dart';

/// Games tab landing page - lets the student pick a mini-game.
class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            _GameCard(
              title: 'Dice Math',
              subtitle: 'Roll the dice and solve the quiz',
              icon: Icons.casino,
              colors: [AppColors.primaryBlue, const Color(0xFF64B5F6)],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DiceGameScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _GameCard(
              title: 'Target 10',
              subtitle: 'Match two number cards that add up to 10',
              icon: Icons.style,
              colors: [AppColors.successGreen, const Color(0xFF81C784)],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CardTargetScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _GameCard(
              title: 'Match Answers',
              subtitle: 'Match each expression with its correct answer',
              icon: Icons.compare_arrows,
              colors: [AppColors.warningOrange, const Color(0xFFFFB74D)],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MatchOperationsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _GameCard(
              title: 'Pizza Slices',
              subtitle: 'Read, build and compare fractions of a pizza',
              icon: Icons.pie_chart,
              colors: [const Color(0xFFE64A19), const Color(0xFFFF8A65)],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FractionPizzaScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
