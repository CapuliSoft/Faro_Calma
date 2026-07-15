import 'package:flutter/material.dart';
import '../widgets/spiders_canvas.dart';
import 'package:gtc6/features/progress/domain/services/progress_service.dart';

class SpidersScreen extends StatefulWidget {
  const SpidersScreen({super.key});

  @override
  State<SpidersScreen> createState() => _SpidersScreenState();
}

class _SpidersScreenState extends State<SpidersScreen> {
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void dispose() {
    final double elapsedMinutes = DateTime.now().difference(_startTime).inSeconds / 60.0;
    if (elapsedMinutes >= 0.05) {
      Future.microtask(() {
        ProgressService.instance.recordSession('spiders', elapsedMinutes);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arañas Relajantes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(
        child: SpidersCanvas(),
      ),
    );
  }
}
