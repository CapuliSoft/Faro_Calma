import 'package:flutter/material.dart';
import 'package:gtc6/features/games/balls/presentation/widgets/bouncing_balls_canvas.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';
import 'package:gtc6/l10n/app_localizations.dart';

class BallsScreen extends StatefulWidget {
  const BallsScreen({super.key});

  @override
  State<BallsScreen> createState() => _BallsScreenState();
}

class _BallsScreenState extends State<BallsScreen> {
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    final double elapsedMinutes =
        DateTime.now().difference(_startTime).inSeconds / 60.0;
    // Log playtime session (min duration 0.05m to ignore accidental clicks)
    if (elapsedMinutes >= 0.05) {
      Future.microtask(() {
        ProgressService.instance.recordSession('balls', elapsedMinutes);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.routineBallsTitle ??
              'Bolas Sensoriales',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(child: BouncingBallsCanvas()),
    );
  }
}
