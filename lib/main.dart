import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'utils/theme.dart';
import 'providers/student_provider.dart';
import 'providers/game_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/learning_provider.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'screens/progress_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize services (using factory constructors)
  final storageService = StorageService();
  await storageService.initialize();
  
  final audioService = AudioService();
  await audioService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LearningProvider(),
        ),
      ],
      child: const MathPracticeApp(),
    ),
  );
}

class MathPracticeApp extends StatelessWidget {
  const MathPracticeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Practice App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      // Always boot through the splash screen and replace it with the main
      // shell. Opening the web URL "#/main" directly would otherwise stack
      // [Splash, MainShell], giving the home screen a back arrow that pops
      // to a splash screen that never navigates again.
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      ],
      routes: {
        '/main': (context) => const MainShell(),
        '/progress': (context) => const ProgressDashboardScreen(),
      },
    );
  }
}
