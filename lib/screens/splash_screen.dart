import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_initializer.dart';
import '../providers/student_provider.dart';
import '../config/routes.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

/// Splash screen shown during app initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AppInitializer _initializer = AppInitializer();
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeApp();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    await _initializer.initializeServices();

    if (!mounted) return;

    final isFirstRun = await _initializer.isFirstRun();
    final hasProfile = await _initializer.hasUserProfile();

    if (!mounted) return;

    // If first run, show onboarding
    if (isFirstRun && !hasProfile) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _showOnboarding = true);
      return;
    }

    // Load existing profile if available
    if (hasProfile) {
      final profile = await _initializer.loadExistingProfile();
      if (!mounted) return;

      if (profile != null) {
        // Load profile into provider
        final studentProvider = context.read<StudentProvider>();
        studentProvider.setCurrentStudent(profile);
      }
    }

    // Navigate to home after splash
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    AppRoutes.goToHome(context);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return _buildOnboarding();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.8),
              AppColors.primaryBlue.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Icon(
                      Icons.calculate_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Math Practice',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn Math with Fun!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboarding() {
    return OnboardingScreen(initializer: _initializer);
  }
}

/// Onboarding screen for first-time users
class OnboardingScreen extends StatefulWidget {
  final AppInitializer initializer;

  const OnboardingScreen({
    Key? key,
    required this.initializer,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    final ageStr = _ageController.text.trim();

    if (name.isEmpty || ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final age = int.tryParse(ageStr);
    if (age == null || age < 5 || age > 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age (5-18)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create profile
      final profile = await widget.initializer.initializeApp(
        studentName: name,
        studentAge: age,
      );

      if (!mounted) return;

      if (profile != null) {
        // Load into provider
        final studentProvider = context.read<StudentProvider>();
        studentProvider.setCurrentStudent(profile);
      }

      // Navigate to home
      AppRoutes.goToHome(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.1),
              AppColors.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppConstants.largePadding),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            size: 50,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: AppConstants.largePadding),
                        Text(
                          'Welcome to Math Practice!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Let\'s get to know you first',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 2),

                  // Name Input
                  Text(
                    'What\'s your name?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                    enabled: !_isLoading,
                  ),
                  SizedBox(height: AppConstants.largePadding),

                  // Age Input
                  Text(
                    'How old are you?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your age (5-18)',
                      prefixIcon: const Icon(Icons.cake),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                  SizedBox(height: AppConstants.largePadding * 2),

                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeOnboarding,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Get Started',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
