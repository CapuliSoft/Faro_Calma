import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/presentation/screens/app_shell.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'GTC6 - Sensory Relaxation',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const AppShell(),
        );
      },
    );
  }
}
