import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';
import 'package:gtc6/l10n/app_localizations.dart';

enum BreathingPhaseType {
  inhale(
    'Inhalar',
    'inhalación profunda y suave por la nariz',
    Icons.arrow_upward_rounded,
  ),
  holdIn(
    'Sostener',
    'mantén el aire con calma en los pulmones',
    Icons.pause_circle_outline_rounded,
  ),
  exhale(
    'Exhalar',
    'libera el aire lenta y controladamente',
    Icons.arrow_downward_rounded,
  ),
  holdOut(
    'Pausa',
    'descansa con los pulmones vacíos en quietud',
    Icons.stop_circle_outlined,
  );

  final String label;
  final String description;
  final IconData icon;
  const BreathingPhaseType(this.label, this.description, this.icon);
}

class BreathingPhase {
  final BreathingPhaseType type;
  final int durationSeconds;
  final String instruction;

  const BreathingPhase({
    required this.type,
    required this.durationSeconds,
    required this.instruction,
  });
}

class BreathingPattern {
  final String id;
  final String name;
  final String subtitle;
  final String scientificBenefit;
  final String category;
  final List<BreathingPhase> phases;
  final int recommendedCycles;
  final Color color;
  final IconData icon;

  const BreathingPattern({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.scientificBenefit,
    required this.category,
    required this.phases,
    required this.recommendedCycles,
    required this.color,
    required this.icon,
  });

  int get cycleDurationSeconds =>
      phases.fold(0, (sum, phase) => sum + phase.durationSeconds);

  int get totalDurationSeconds => cycleDurationSeconds * recommendedCycles;
}

final List<BreathingPattern> kBreathingPatterns = [
  const BreathingPattern(
    id: '4-7-8',
    name: 'Respiración 4-7-8',
    subtitle: 'El Tranquilizante Natural del Sistema Nervioso',
    scientificBenefit:
        'Desarrollada por el Dr. Andrew Weil en Harvard. Activa fuertemente el tono vagal y el sistema nervioso parasimpático, reduciendo el cortisol y facilitando el sueño profundo en menos de 60 segundos.',
    category: 'Relajación y Sueño',
    recommendedCycles: 4,
    color: SensoryColors.zenTeal,
    icon: Icons.nightlight_round,
    phases: [
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 4,
        instruction: 'Inhala suave por la nariz llenando el vientre...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.holdIn,
        durationSeconds: 7,
        instruction: 'Sostén el aire en total calma sin tensar...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.exhale,
        durationSeconds: 8,
        instruction:
            'Exhala por la boca haciendo un suave sonido de soplido...',
      ),
    ],
  ),
  const BreathingPattern(
    id: 'box',
    name: 'Respiración Cuadrada (Box Breathing)',
    subtitle: 'Enfoque Táctico y Control del Estrés',
    scientificBenefit:
        'Utilizada por cirujanos y equipos Navy SEALs. El patrón simétrico de 4 segundos regula la presión arterial, estabiliza la amígdala cerebral y restaura la claridad mental bajo presión y ansiedad.',
    category: 'Enfoque y Anti-Estrés',
    recommendedCycles: 6,
    color: SensoryColors.zenIndigo,
    icon: Icons.crop_square_rounded,
    phases: [
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 4,
        instruction: 'Inhala profunda y pausadamente...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.holdIn,
        durationSeconds: 4,
        instruction: 'Conserva el aire con serenidad...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.exhale,
        durationSeconds: 4,
        instruction: 'Vacía tus pulmones con total suavidad...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.holdOut,
        durationSeconds: 4,
        instruction: 'Pausa en vacío observando la quietud interior...',
      ),
    ],
  ),
  const BreathingPattern(
    id: 'coherent',
    name: 'Respiración Coherente (0.1 Hz)',
    subtitle: 'Sincronización Cardíaca y Vagal',
    scientificBenefit:
        'Investigada por el Dr. Stephen Porges (Teoría Polivagal). Respirar a 5.5 ciclos por minuto sincroniza las ondas cerebrales con la variabilidad cardíaca (HRV máxima), logrando homeostasis general en el organismo.',
    category: 'Coherencia y Equilibrio',
    recommendedCycles: 6,
    color: SensoryColors.zenSage,
    icon: Icons.favorite_rounded,
    phases: [
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 5,
        instruction: 'Inhala lento por la nariz expandiendo el diafragma...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.exhale,
        durationSeconds: 6,
        instruction: 'Exhala sin esfuerzo liberando toda tensión acumulada...',
      ),
    ],
  ),
  const BreathingPattern(
    id: 'sigh',
    name: 'Suspiro Fisiológico Huberman',
    subtitle: 'Alivio Instantáneo del Pánico en Tiempo Real',
    scientificBenefit:
        'Validado clínicamente en Stanford por el laboratorio neurobiológico del Dr. Andrew Huberman. Una doble inhalación seguida de exhalación larga reabre los alvéolos colapsados y descarga el exceso de CO₂ instantáneamente.',
    category: 'Alivio Instantáneo',
    recommendedCycles: 5,
    color: SensoryColors.zenAmber,
    icon: Icons.bolt_rounded,
    phases: [
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 3,
        instruction: 'Inhala profundo por la nariz al 80% de capacidad...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 1,
        instruction:
            '¡Inhala un sorbo extra rápido de aire por la nariz para llenar al máximo!',
      ),
      BreathingPhase(
        type: BreathingPhaseType.exhale,
        durationSeconds: 6,
        instruction:
            'Exhala largo, relajado y continuo por la boca soltando todo...',
      ),
    ],
  ),
  const BreathingPattern(
    id: '4-6',
    name: 'Respiración Calma 4-6',
    subtitle: 'Relajación Fisiológica Rápida',
    scientificBenefit:
        'La neurociencia demuestra que prolongar la exhalación respecto a la inhalación frena inmediatamente el ritmo cardíaco mediante la estimulación del nervio vago y la inhibición simpática.',
    category: 'Calma Rápida',
    recommendedCycles: 8,
    color: SensoryColors.zenCyan,
    icon: Icons.self_improvement_rounded,
    phases: [
      BreathingPhase(
        type: BreathingPhaseType.inhale,
        durationSeconds: 4,
        instruction: 'Inhala con tranquilidad por la nariz...',
      ),
      BreathingPhase(
        type: BreathingPhaseType.exhale,
        durationSeconds: 6,
        instruction: 'Selta el aire muy despacio relajando hombros y rostro...',
      ),
    ],
  ),
];

extension LocalizedBreathingPattern on BreathingPattern {
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (id == '4-7-8') return l10n?.breathing_478_name ?? name;
    if (id == 'box') return l10n?.breathing_box_name ?? name;
    if (id == 'coherent') return l10n?.breathing_coherent_name ?? name;
    if (id == 'sigh') return l10n?.breathing_sigh_name ?? name;
    if (id == '4-6') return l10n?.breathing_46_name ?? name;
    return name;
  }

  String getLocalizedSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (id == '4-7-8') return l10n?.breathing_478_subtitle ?? subtitle;
    if (id == 'box') return l10n?.breathing_box_subtitle ?? subtitle;
    if (id == 'coherent') return l10n?.breathing_coherent_subtitle ?? subtitle;
    if (id == 'sigh') return l10n?.breathing_sigh_subtitle ?? subtitle;
    if (id == '4-6') return l10n?.breathing_46_subtitle ?? subtitle;
    return subtitle;
  }

  String getLocalizedBenefit(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (id == '4-7-8') return l10n?.breathing_478_benefit ?? scientificBenefit;
    if (id == 'box') return l10n?.breathing_box_benefit ?? scientificBenefit;
    if (id == 'coherent')
      return l10n?.breathing_coherent_benefit ?? scientificBenefit;
    if (id == 'sigh') return l10n?.breathing_sigh_benefit ?? scientificBenefit;
    if (id == '4-6') return l10n?.breathing_46_benefit ?? scientificBenefit;
    return scientificBenefit;
  }

  String getLocalizedCategory(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (id == '4-7-8') return l10n?.breathing_478_category ?? category;
    if (id == 'box') return l10n?.breathing_box_category ?? category;
    if (id == 'coherent') return l10n?.breathing_coherent_category ?? category;
    if (id == 'sigh') return l10n?.breathing_sigh_category ?? category;
    if (id == '4-6') return l10n?.breathing_46_category ?? category;
    return category;
  }
}

extension LocalizedBreathingPhaseType on BreathingPhaseType {
  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case BreathingPhaseType.inhale:
        return l10n?.phaseInhaleLabel ?? label;
      case BreathingPhaseType.holdIn:
        return l10n?.phaseHoldInLabel ?? label;
      case BreathingPhaseType.exhale:
        return l10n?.phaseExhaleLabel ?? label;
      case BreathingPhaseType.holdOut:
        return l10n?.phaseHoldOutLabel ?? label;
    }
  }

  String getLocalizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case BreathingPhaseType.inhale:
        return l10n?.phaseInhaleDesc ?? description;
      case BreathingPhaseType.holdIn:
        return l10n?.phaseHoldInDesc ?? description;
      case BreathingPhaseType.exhale:
        return l10n?.phaseExhaleDesc ?? description;
      case BreathingPhaseType.holdOut:
        return l10n?.phaseHoldOutDesc ?? description;
    }
  }
}

extension LocalizedBreathingPhase on BreathingPhase {
  String getLocalizedInstruction(
    BuildContext context,
    String patternId,
    int phaseIndex,
  ) {
    final l10n = AppLocalizations.of(context);
    if (patternId == '4-7-8') {
      if (phaseIndex == 0) return l10n?.breathing_478_phase_1 ?? instruction;
      if (phaseIndex == 1) return l10n?.breathing_478_phase_2 ?? instruction;
      if (phaseIndex == 2) return l10n?.breathing_478_phase_3 ?? instruction;
    }
    if (patternId == 'box') {
      if (phaseIndex == 0) return l10n?.breathing_box_phase_1 ?? instruction;
      if (phaseIndex == 1) return l10n?.breathing_box_phase_2 ?? instruction;
      if (phaseIndex == 2) return l10n?.breathing_box_phase_3 ?? instruction;
      if (phaseIndex == 3) return l10n?.breathing_box_phase_4 ?? instruction;
    }
    if (patternId == 'coherent') {
      if (phaseIndex == 0)
        return l10n?.breathing_coherent_phase_1 ?? instruction;
      if (phaseIndex == 1)
        return l10n?.breathing_coherent_phase_2 ?? instruction;
    }
    if (patternId == 'sigh') {
      if (phaseIndex == 0) return l10n?.breathing_sigh_phase_1 ?? instruction;
      if (phaseIndex == 1) return l10n?.breathing_sigh_phase_2 ?? instruction;
      if (phaseIndex == 2) return l10n?.breathing_sigh_phase_3 ?? instruction;
    }
    if (patternId == '4-6') {
      if (phaseIndex == 0) return l10n?.breathing_46_phase_1 ?? instruction;
      if (phaseIndex == 1) return l10n?.breathing_46_phase_2 ?? instruction;
    }
    return instruction;
  }
}
