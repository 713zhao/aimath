import 'package:flutter/material.dart';
import '../models/math_problem.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

/// Widget to display the current math problem
class ProblemDisplay extends StatelessWidget {
  final MathProblem problem;
  final int currentIndex;
  final int totalProblems;

  const ProblemDisplay({
    Key? key,
    required this.problem,
    required this.currentIndex,
    required this.totalProblems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Problem counter
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Problem ',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '$currentIndex/$totalProblems',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),

        // Large problem display in dark container
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            padding: const EdgeInsets.all(AppConstants.largePadding),
            decoration: BoxDecoration(
              color: AppColors.darkText.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main problem display: operand1 operator operand2
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // First operand
                    Text(
                      problem.firstNumber.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: AppConstants.defaultPadding),

                    // Operator
                    Text(
                      problem.operation.symbol,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: AppConstants.defaultPadding),

                    // Second operand
                    Text(
                      problem.secondNumber.toString(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Divider line
                Container(
                  height: 4,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.darkText.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Question mark
                Text(
                  '?',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppConstants.largePadding),
      ],
    );
  }
}
