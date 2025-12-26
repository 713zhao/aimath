import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/student_provider.dart';
import '../providers/statistics_provider.dart';
import '../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final studentProvider = context.read<StudentProvider>();
    final statsProvider = context.read<StatisticsProvider>();
    final prefs = await SharedPreferences.getInstance();

    // Try to load last logged in user
    final lastUserId = prefs.getString('lastUserId') ?? 'student_1';
    await studentProvider.loadStudent(lastUserId);
    
    if (studentProvider.hasStudent) {
      // Save this user as the last logged in user
      await prefs.setString('lastUserId', studentProvider.currentStudent!.id);
      await statsProvider.loadStudentStats(studentProvider.currentStudent!.id);
    }

    if (!mounted) return;

    // Check if first run (no student profile)
    if (!studentProvider.hasStudent) {
      _showNameInputDialog();
    } else {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _showNameInputDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Welcome!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Let\'s get started!'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Enter your age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim()) ?? 7;
              if (name.isNotEmpty) {
                final studentId = 'student_${DateTime.now().millisecondsSinceEpoch}';
                await context.read<StudentProvider>().createStudent(
                  id: studentId,
                  name: name,
                  age: age.clamp(5, 18),
                );
                // Save as last logged in user
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('lastUserId', studentId);
                if (mounted) {
                  Navigator.pop(dialogContext);
                  _navigateToMain();
                }
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.calculate,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Math Practice',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
