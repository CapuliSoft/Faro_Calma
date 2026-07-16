import 'package:flutter/material.dart';
import 'package:gtc6/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/i18n/locale_controller.dart';
import 'features/home/presentation/screens/app_shell.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressService.instance.init();
  await LocaleController.instance.loadLocale();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeModeNotifier,
      builder: (context, currentMode, child) {
        return ListenableBuilder(
          listenable: LocaleController.instance,
          builder: (context, _) {
            return MaterialApp(
              onGenerateTitle: (context) {
                final l10n = AppLocalizations.of(context);
                return l10n?.appTitle ?? 'GTC6';
              },
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              locale: LocaleController.instance.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AppShell(),
            );
          },
        );
      },
    );
  }
}
