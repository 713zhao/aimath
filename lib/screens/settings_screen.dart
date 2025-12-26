import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/audio_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AudioService _audioService;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _soundEnabled = _audioService.isMuted == false;
    });
  }

  void _toggleSound(bool value) {
    setState(() {
      _soundEnabled = value;
    });
    _audioService.toggleMute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.largePadding),
          child: Consumer<StudentProvider>(
            builder: (ctx, studentProvider, _) {
              final student = studentProvider.currentStudent;
              if (student == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Container(
                    padding: EdgeInsets.all(AppConstants.largePadding),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              student.name.isEmpty ? 'S' : student.name[0].toUpperCase(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.largePadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: AppConstants.smallPadding),
                              Text(
                                'Age: ${student.age}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 1.5),

                  // Settings Title
                  Text(
                    'Audio & Sound',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  
                  // Sound Toggle
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sound Effects',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: AppConstants.smallPadding / 2),
                            Text(
                              'Enable or disable sound',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        ToggleSwitch(value: _soundEnabled, onChanged: _toggleSound),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.largePadding * 2),

                  // App Info
                  Text(
                    'App Info',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppConstants.smallPadding),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
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
}
