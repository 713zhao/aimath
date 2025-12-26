import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/game_provider.dart';
import '../providers/student_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';

/// Main practice session screen where students solve problems
class PracticeSessionScreen extends StatefulWidget {
  final int difficultyLevel;
  final List<Operation> operations;
  final int timeLimitSeconds; // 0 = no limit, default 180 (3 mins)
  final int minNumber;
  final int maxNumber;
  final VoidCallback? onSessionEnd;
  final bool showAppBar;

  const PracticeSessionScreen({
    Key? key,
    required this.difficultyLevel,
    required this.operations,
    this.timeLimitSeconds = 180,
    this.minNumber = 0,
    this.maxNumber = 10,
    this.onSessionEnd,
    this.showAppBar = false,
  }) : super(key: key);

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  late TextEditingController _answerController;
  late FocusNode _answerFocusNode;
  bool _isSubmitting = false;
  bool _showError = false;
  bool _sessionStarted = false;
  bool _navigatingToResults = false;
  bool _sessionEnded = false;
  
  // Session timer
  int _remainingSeconds = 0;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _answerFocusNode = FocusNode();
    
    // Start the session after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final gameProvider = context.read<GameProvider>();
    final studentProvider = context.read<StudentProvider>();
    
    await gameProvider.startNewSession(
      studentId: studentProvider.currentStudent?.id ?? 'guest',
      difficultyLevel: widget.difficultyLevel,
      selectedOperations: widget.operations,
      minNumber: widget.minNumber,
      maxNumber: widget.maxNumber,
    );
    
    if (mounted) {
      setState(() {
        _sessionStarted = true;
        _remainingSeconds = widget.timeLimitSeconds;
      });
      
      // Start session timer if time limit is set
      if (widget.timeLimitSeconds > 0) {
        _startSessionTimer();
      }
      
      // Request focus on answer input after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _answerFocusNode.requestFocus();
        }
      });
    }
  }
  
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        timer.cancel();
        // Time's up - end session
        _navigateToResults();
      }
    });
  }
  
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _isSubmitting) return;

    final userAnswer = int.tryParse(answer);
    if (userAnswer == null) {
      setState(() => _showError = true);
      return;
    }

    final gameProvider = context.read<GameProvider>();
    final currentProblem = gameProvider.currentProblem;
    
    if (currentProblem == null) return;

    // Check if answer is correct
    final isCorrect = currentProblem.isAnswerCorrect(userAnswer);

    if (isCorrect) {
      // Correct answer - submit and move to next immediately
      setState(() {
        _isSubmitting = true;
        _showError = false;
      });
      
      gameProvider.submitAnswer(userAnswer);
      
      // Clear input and prepare for next problem
      _answerController.clear();
      
      // Check if session ended after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _isSubmitting = false);
          
          // Check if session has ended or no more problems
          if (!gameProvider.isSessionActive || !gameProvider.hasCurrentProblem) {
            _navigateToResults();
          } else {
            // Focus on input for next problem
            _answerFocusNode.requestFocus();
          }
        }
      });
    } else {
      // Incorrect answer - show error and let user try again
      setState(() {
        _showError = true;
      });
      
      // Select all text for easy replacement
      _answerController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _answerController.text.length,
      );
      _answerFocusNode.requestFocus();
    }
  }

  void _navigateToResults() {
    if (_navigatingToResults) return;
    _navigatingToResults = true;
    _sessionEnded = true;
    _sessionTimer?.cancel();
    
    final gameProvider = context.read<GameProvider>();
    final studentProvider = context.read<StudentProvider>();
    
    // Get session summary before ending
    final summary = gameProvider.getSessionSummary();
    
    // End the session and get summary
    gameProvider.endSession(studentProvider.currentStudent?.id ?? 'guest');
    
    // Update student stats with session results
    if (summary.isNotEmpty) {
      studentProvider.updateStudentStats(
        sessionPoints: summary['totalPoints'] as int? ?? 0,
        sessionProblems: summary['totalProblems'] as int? ?? 0,
        sessionCorrectAnswers: summary['correctAnswers'] as int? ?? 0,
        sessionAccuracy: (summary['accuracy'] as num?)?.toDouble() ?? 0.0,
      );
      
      // Check for level up: 85%+ accuracy and at least 10 problems
      final accuracy = (summary['accuracy'] as num?)?.toDouble() ?? 0.0;
      final totalProblems = summary['totalProblems'] as int? ?? 0;
      final currentLevel = studentProvider.currentStudent?.currentDifficultyLevel ?? 1;
      
      if (accuracy >= 85.0 && totalProblems >= 10 && currentLevel < 4) {
        // Unlock next level
        studentProvider.unlockNextLevel();
      }
    }
    
    // If we have a callback (embedded in bottom nav), use it
    if (widget.onSessionEnd != null) {
      // Show results dialog then return to practice start screen
      _showResultsDialog(summary);
    } else {
      // Navigate to results screen (standalone mode)
      final session = gameProvider.currentSession;
      if (session != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.sessionResults,
          arguments: {
            'session': session,
            'leveledUp': false,
            'newLevel': null,
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }
  
  void _showResultsDialog(Map<String, dynamic> summary) {
    final totalProblems = summary['totalProblems'] as int? ?? 0;
    final correctAnswers = summary['correctAnswers'] as int? ?? 0;
    final accuracy = (summary['accuracy'] as num?)?.toDouble() ?? 0.0;
    final totalPoints = summary['totalPoints'] as int? ?? 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              accuracy >= 85 ? Icons.emoji_events : Icons.check_circle,
              color: accuracy >= 85 ? AppColors.accentGold : AppColors.successGreen,
            ),
            const SizedBox(width: 8),
            const Text('Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow('Problems', '$correctAnswers / $totalProblems'),
            _buildResultRow('Accuracy', '${accuracy.toStringAsFixed(1)}%'),
            _buildResultRow('Points Earned', '+$totalPoints'),
            if (accuracy >= 85 && totalProblems >= 10)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, color: AppColors.successGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Level Up!',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSessionEnd?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _skipProblem() {
    if (_isSubmitting) return;
    
    final gameProvider = context.read<GameProvider>();
    gameProvider.skipProblem();
    _answerController.clear();
    setState(() => _showError = false);
    
    // Check if session ended after skip
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        if (!gameProvider.isSessionActive || !gameProvider.hasCurrentProblem) {
          _navigateToResults();
        } else {
          _answerFocusNode.requestFocus();
        }
      }
    });
  }

  void _exitSession() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.cancelSession();
    Navigator.pop(context);
  }

  String _getOperatorSymbol(Operation operation) {
    switch (operation) {
      case Operation.add:
        return '+';
      case Operation.subtract:
        return '−';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Session?'),
            content: const Text('Your progress will be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continue'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('End'),
              ),
            ],
          ),
        );
        
        if (shouldPop == true) {
          _sessionTimer?.cancel();
          widget.onSessionEnd?.call();
        }
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: const Text('Practice'),
                centerTitle: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    final shouldEnd = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('End Session?'),
                        content: const Text('Your progress will be saved.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Continue'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('End'),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldEnd == true) {
                      _sessionTimer?.cancel();
                      widget.onSessionEnd?.call();
                    }
                  },
                ),
              )
            : null,
        body: SafeArea(
          child: Consumer2<GameProvider, StudentProvider>(
            builder: (context, gameProvider, studentProvider, child) {
              // Session not started yet
              if (!_sessionStarted) {
                return _buildLoading('Starting your practice session...');
              }
              
              // Session has ended - navigate to results
              if (_sessionEnded) {
                return _buildLoading('Finishing up...');
              }
              
              // Session ended by game controller (all problems done)
              if (!gameProvider.isSessionActive && _sessionStarted) {
                // Auto navigate to results
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_navigatingToResults) {
                    _navigateToResults();
                  }
                });
                return _buildLoading('Finishing up...');
              }

              final problem = gameProvider.currentProblem;
              
              // No problem available - session might have ended
              if (problem == null) {
                // Auto navigate to results
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_navigatingToResults) {
                    _navigateToResults();
                  }
                });
                return _buildLoading('Finishing up...');
              }

              final currentIndex = gameProvider.currentProblemIndex;
              final totalProblems = gameProvider.totalProblems;

              return Column(
                children: [
                  // Progress bar
                  LinearProgressIndicator(
                    value: (currentIndex - 1) / totalProblems,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
                  ),
                  
                  // Top info bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Problem counter
                        Text(
                          'Problem $currentIndex of $totalProblems',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        
                        // Timer display (if time limit is set)
                        if (widget.timeLimitSeconds > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _remainingSeconds <= 30 
                                  ? AppColors.errorRed.withOpacity(0.2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _remainingSeconds <= 30 
                                    ? AppColors.errorRed 
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: _remainingSeconds <= 30 
                                      ? AppColors.errorRed 
                                      : AppColors.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: TextStyle(
                                    color: _remainingSeconds <= 30 
                                        ? AppColors.errorRed 
                                        : AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Points
                        Row(
                          children: [
                            const Text('💎 ', style: TextStyle(fontSize: 16)),
                            Text(
                              '${gameProvider.sessionPoints}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        // Streak
                        if (gameProvider.currentStreak > 0)
                          Row(
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 16)),
                              Text(
                                '${gameProvider.currentStreak}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  // Main content - Question and Answer on same row
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Question with inline answer input
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _showError ? AppColors.errorRed : Colors.grey[300]!,
                                    width: _showError ? 2 : 1,
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // First number
                                      Text(
                                        '${problem.firstNumber}',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      
                                      // Operator
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          _getOperatorSymbol(problem.operation),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                      
                                      // Second number
                                      Text(
                                        '${problem.secondNumber}',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      
                                      // Equals sign
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          '=',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                      
                                      // Answer input box
                                      Container(
                                        width: 120,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: _showError 
                                              ? AppColors.errorRed.withOpacity(0.1)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _showError 
                                                ? AppColors.errorRed 
                                                : AppColors.primaryBlue,
                                            width: 2,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _answerController,
                                          focusNode: _answerFocusNode,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          autofocus: true,
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: _showError 
                                                ? AppColors.errorRed 
                                                : AppColors.darkText,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 12,
                                            ),
                                            hintText: '?',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 36,
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                                            LengthLimitingTextInputFormatter(6),
                                          ],
                                          onChanged: (value) {
                                            if (_showError) {
                                              setState(() => _showError = false);
                                            }
                                          },
                                          onSubmitted: (_) => _submitAnswer(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Error message
                              if (_showError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    'Not quite right. Try again! 🤔',
                                    style: TextStyle(
                                      color: AppColors.errorRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 32),
                              
                              // Submit and Skip buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Skip button
                                  OutlinedButton(
                                    onPressed: _skipProblem,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      side: BorderSide(color: Colors.grey[400]!),
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Submit button
                                  ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitAnswer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.successGreen,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Hint text
                              Text(
                                'Press Enter to submit your answer',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
