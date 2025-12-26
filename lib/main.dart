import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'utils/theme.dart';
import 'config/routes.dart';
import 'providers/student_provider.dart';
import 'providers/game_provider.dart';
import 'providers/statistics_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Initialize Hive for local storage
  await Hive.initFlutter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
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
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
