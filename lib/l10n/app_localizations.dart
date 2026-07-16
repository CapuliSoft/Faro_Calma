import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'GTC6'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Rutinas de regulación y bienestar sensorial'**
  String get appSubtitle;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Alternar Tema'**
  String get toggleThemeTooltip;

  /// No description provided for @tabRoutines.
  ///
  /// In es, this message translates to:
  /// **'Rutinas'**
  String get tabRoutines;

  /// No description provided for @tabSounds.
  ///
  /// In es, this message translates to:
  /// **'Sonidos'**
  String get tabSounds;

  /// No description provided for @tabRelaxation.
  ///
  /// In es, this message translates to:
  /// **'Relajación'**
  String get tabRelaxation;

  /// No description provided for @tabBreathing.
  ///
  /// In es, this message translates to:
  /// **'Respiración'**
  String get tabBreathing;

  /// No description provided for @tabProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get tabProgress;

  /// No description provided for @guideTitle.
  ///
  /// In es, this message translates to:
  /// **'🌿 ¿QUÉ PUEDES LOGRAR CON ESTA APP?'**
  String get guideTitle;

  /// No description provided for @guide1Title.
  ///
  /// In es, this message translates to:
  /// **'Calmar la Ansiedad al Instante'**
  String get guide1Title;

  /// No description provided for @guide1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Respiración Científica Guiada'**
  String get guide1Subtitle;

  /// No description provided for @guide1Desc.
  ///
  /// In es, this message translates to:
  /// **'Patrones con aval neurocientífico (4-7-8, Box Breathing, Huberman) para bajar el cortisol en minutos.'**
  String get guide1Desc;

  /// No description provided for @guide2Title.
  ///
  /// In es, this message translates to:
  /// **'Liberar Tensión Física'**
  String get guide2Title;

  /// No description provided for @guide2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Relajación Muscular Progresiva'**
  String get guide2Subtitle;

  /// No description provided for @guide2Desc.
  ///
  /// In es, this message translates to:
  /// **'Rutina Jacobson guiada paso a paso para soltar la rigidez en cuello, hombros, espalda y rostro.'**
  String get guide2Desc;

  /// No description provided for @guide3Title.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar tus Ondas Cerebrales'**
  String get guide3Title;

  /// No description provided for @guide3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Terapia de Sonido Binaural'**
  String get guide3Subtitle;

  /// No description provided for @guide3Desc.
  ///
  /// In es, this message translates to:
  /// **'Frecuencias curativas y ritmos binaurales diseñados para enfocar tu mente o conciliar el sueño profundo.'**
  String get guide3Desc;

  /// No description provided for @guide4Title.
  ///
  /// In es, this message translates to:
  /// **'Enfoque y Terapia de Arte Zen'**
  String get guide4Title;

  /// No description provided for @guide4Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Mindfulness Sensorial Activo'**
  String get guide4Subtitle;

  /// No description provided for @guide4Desc.
  ///
  /// In es, this message translates to:
  /// **'Colorea mandalas, revienta burbujas o traza telarañas para disipar el estrés táctil y mental en el presente.'**
  String get guide4Desc;

  /// No description provided for @routinesSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'RUTINAS DISPONIBLES'**
  String get routinesSectionTitle;

  /// No description provided for @twoColumnsBadge.
  ///
  /// In es, this message translates to:
  /// **'2 Columnas'**
  String get twoColumnsBadge;

  /// No description provided for @routineBreathingTitle.
  ///
  /// In es, this message translates to:
  /// **'Respiración Científica'**
  String get routineBreathingTitle;

  /// No description provided for @routineBreathingCat.
  ///
  /// In es, this message translates to:
  /// **'Sistema Nervioso'**
  String get routineBreathingCat;

  /// No description provided for @routineBreathingDesc.
  ///
  /// In es, this message translates to:
  /// **'Patrones con aval neurocientífico (4-7-8, Box Breathing, Huberman) para regular el ritmo vagal y bajar el cortisol.'**
  String get routineBreathingDesc;

  /// No description provided for @routinePaintTitle.
  ///
  /// In es, this message translates to:
  /// **'Arte Zen & Coloreo'**
  String get routinePaintTitle;

  /// No description provided for @routinePaintCat.
  ///
  /// In es, this message translates to:
  /// **'Mindfulness Táctil'**
  String get routinePaintCat;

  /// No description provided for @routinePaintDesc.
  ///
  /// In es, this message translates to:
  /// **'Lienzo de coloreo con pincel, borrador, grosor/espesor variable y plantillas zen para disipar la ansiedad.'**
  String get routinePaintDesc;

  /// No description provided for @routineRmpTitle.
  ///
  /// In es, this message translates to:
  /// **'Relajación Muscular'**
  String get routineRmpTitle;

  /// No description provided for @routineRmpCat.
  ///
  /// In es, this message translates to:
  /// **'Alivio Somático'**
  String get routineRmpCat;

  /// No description provided for @routineRmpDesc.
  ///
  /// In es, this message translates to:
  /// **'Rutina Jacobson guiada con animaciones bio-sensoriales y audio tonos para soltar la tensión física.'**
  String get routineRmpDesc;

  /// No description provided for @routineSoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Terapia de Sonido'**
  String get routineSoundTitle;

  /// No description provided for @routineSoundCat.
  ///
  /// In es, this message translates to:
  /// **'Ondas y Sincronía'**
  String get routineSoundCat;

  /// No description provided for @routineSoundDesc.
  ///
  /// In es, this message translates to:
  /// **'Frecuencias curativas y ritmos binaurales combinados para relajar la mente o conciliar el sueño.'**
  String get routineSoundDesc;

  /// No description provided for @routineBallsTitle.
  ///
  /// In es, this message translates to:
  /// **'Bolas Sensoriales'**
  String get routineBallsTitle;

  /// No description provided for @routineBallsCat.
  ///
  /// In es, this message translates to:
  /// **'Calma Visual'**
  String get routineBallsCat;

  /// No description provided for @routineBallsDesc.
  ///
  /// In es, this message translates to:
  /// **'Genera burbujas de colores que rebotan libremente y emiten sonidos suaves al tocar la pantalla.'**
  String get routineBallsDesc;

  /// No description provided for @routineBubblesTitle.
  ///
  /// In es, this message translates to:
  /// **'Pop-It / Burbujas'**
  String get routineBubblesTitle;

  /// No description provided for @routineBubblesCat.
  ///
  /// In es, this message translates to:
  /// **'Enfoque Táctil'**
  String get routineBubblesCat;

  /// No description provided for @routineBubblesDesc.
  ///
  /// In es, this message translates to:
  /// **'Presiona y revienta burbujas virtuales con respuestas táctiles suaves y sonidos relajantes.'**
  String get routineBubblesDesc;

  /// No description provided for @routineSpidersTitle.
  ///
  /// In es, this message translates to:
  /// **'Arañas Relajantes'**
  String get routineSpidersTitle;

  /// No description provided for @routineSpidersCat.
  ///
  /// In es, this message translates to:
  /// **'Tranquilidad Táctil'**
  String get routineSpidersCat;

  /// No description provided for @routineSpidersDesc.
  ///
  /// In es, this message translates to:
  /// **'Teje líneas y observa cómo las pequeñas arañas escalan y reparan sus redes en armonía visual.'**
  String get routineSpidersDesc;

  /// No description provided for @routineCockroachTitle.
  ///
  /// In es, this message translates to:
  /// **'Cucaracha Aplastada'**
  String get routineCockroachTitle;

  /// No description provided for @routineCockroachCat.
  ///
  /// In es, this message translates to:
  /// **'Descarga Activa'**
  String get routineCockroachCat;

  /// No description provided for @routineCockroachDesc.
  ///
  /// In es, this message translates to:
  /// **'Toca las cucarachas que corren por la pantalla para una rápida descarga motriz y reflejos.'**
  String get routineCockroachDesc;

  /// No description provided for @routineSpinnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Fidget Spinner'**
  String get routineSpinnerTitle;

  /// No description provided for @routineSpinnerCat.
  ///
  /// In es, this message translates to:
  /// **'Enfoque Cinético'**
  String get routineSpinnerCat;

  /// No description provided for @routineSpinnerDesc.
  ///
  /// In es, this message translates to:
  /// **'Gira el spinner virtual y experimenta una sensación continua de rotación con vibración háptica suave.'**
  String get routineSpinnerDesc;

  /// No description provided for @progressProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Progreso y Perfil'**
  String get progressProfileTitle;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la Aplicación'**
  String get languageSettingsTitle;

  /// No description provided for @languageSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el idioma para todas las rutinas y guías'**
  String get languageSettingsSubtitle;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español (ES)'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English (EN)'**
  String get languageEnglish;

  /// No description provided for @breathingIntroTitle.
  ///
  /// In es, this message translates to:
  /// **'Respiración Científica'**
  String get breathingIntroTitle;

  /// No description provided for @breathingIntroBanner.
  ///
  /// In es, this message translates to:
  /// **'Patrones con aval neurocientífico para estimular el nervio vago, regular el ritmo cardíaco y reducir el cortisol al instante.'**
  String get breathingIntroBanner;

  /// No description provided for @breathingBenefitLabel.
  ///
  /// In es, this message translates to:
  /// **'Avalo Científico y Beneficios:'**
  String get breathingBenefitLabel;

  /// No description provided for @breathingStructureLabel.
  ///
  /// In es, this message translates to:
  /// **'Estructura del Patrón:'**
  String get breathingStructureLabel;

  /// No description provided for @breathingCyclesLabel.
  ///
  /// In es, this message translates to:
  /// **'Ciclos de respiración:'**
  String get breathingCyclesLabel;

  /// No description provided for @breathingSoundLabel.
  ///
  /// In es, this message translates to:
  /// **'Sonido guía (Platillo)'**
  String get breathingSoundLabel;

  /// No description provided for @breathingHapticLabel.
  ///
  /// In es, this message translates to:
  /// **'Vibración suave al cambiar'**
  String get breathingHapticLabel;

  /// No description provided for @breathingStartBtn.
  ///
  /// In es, this message translates to:
  /// **'Comenzar Respiración'**
  String get breathingStartBtn;

  /// No description provided for @breathingMinutes.
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get breathingMinutes;

  /// No description provided for @phaseInhaleLabel.
  ///
  /// In es, this message translates to:
  /// **'Inhalar'**
  String get phaseInhaleLabel;

  /// No description provided for @phaseInhaleDesc.
  ///
  /// In es, this message translates to:
  /// **'inhalación profunda y suave por la nariz'**
  String get phaseInhaleDesc;

  /// No description provided for @phaseHoldInLabel.
  ///
  /// In es, this message translates to:
  /// **'Sostener'**
  String get phaseHoldInLabel;

  /// No description provided for @phaseHoldInDesc.
  ///
  /// In es, this message translates to:
  /// **'mantén el aire con calma en los pulmones'**
  String get phaseHoldInDesc;

  /// No description provided for @phaseExhaleLabel.
  ///
  /// In es, this message translates to:
  /// **'Exhalar'**
  String get phaseExhaleLabel;

  /// No description provided for @phaseExhaleDesc.
  ///
  /// In es, this message translates to:
  /// **'libera el aire lenta y controladamente'**
  String get phaseExhaleDesc;

  /// No description provided for @phaseHoldOutLabel.
  ///
  /// In es, this message translates to:
  /// **'Pausa'**
  String get phaseHoldOutLabel;

  /// No description provided for @phaseHoldOutDesc.
  ///
  /// In es, this message translates to:
  /// **'descansa con los pulmones vacíos en quietud'**
  String get phaseHoldOutDesc;

  /// No description provided for @breathing_478_name.
  ///
  /// In es, this message translates to:
  /// **'Respiración 4-7-8'**
  String get breathing_478_name;

  /// No description provided for @breathing_478_subtitle.
  ///
  /// In es, this message translates to:
  /// **'El Tranquilizante Natural'**
  String get breathing_478_subtitle;

  /// No description provided for @breathing_478_benefit.
  ///
  /// In es, this message translates to:
  /// **'Activa fuertemente el tono vagal y el sistema nervioso parasimpático, reduciendo el cortisol y facilitando el sueño profundo en menos de 60 segundos.'**
  String get breathing_478_benefit;

  /// No description provided for @breathing_478_category.
  ///
  /// In es, this message translates to:
  /// **'Relajación y Sueño'**
  String get breathing_478_category;

  /// No description provided for @breathing_478_phase_1.
  ///
  /// In es, this message translates to:
  /// **'Inhala suave por la nariz llenando el vientre...'**
  String get breathing_478_phase_1;

  /// No description provided for @breathing_478_phase_2.
  ///
  /// In es, this message translates to:
  /// **'Sostén el aire en total calma sin tensar...'**
  String get breathing_478_phase_2;

  /// No description provided for @breathing_478_phase_3.
  ///
  /// In es, this message translates to:
  /// **'Exhala por la boca haciendo un suave sonido de soplido...'**
  String get breathing_478_phase_3;

  /// No description provided for @breathing_box_name.
  ///
  /// In es, this message translates to:
  /// **'Respiración Cuadrada (Box)'**
  String get breathing_box_name;

  /// No description provided for @breathing_box_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Enfoque Táctico y Control'**
  String get breathing_box_subtitle;

  /// No description provided for @breathing_box_benefit.
  ///
  /// In es, this message translates to:
  /// **'El patrón simétrico de 4 segundos regula la presión arterial, estabiliza la amígdala cerebral y restaura la claridad mental bajo presión y ansiedad.'**
  String get breathing_box_benefit;

  /// No description provided for @breathing_box_category.
  ///
  /// In es, this message translates to:
  /// **'Enfoque y Anti-Estrés'**
  String get breathing_box_category;

  /// No description provided for @breathing_box_phase_1.
  ///
  /// In es, this message translates to:
  /// **'Inhala profunda y pausadamente...'**
  String get breathing_box_phase_1;

  /// No description provided for @breathing_box_phase_2.
  ///
  /// In es, this message translates to:
  /// **'Conserva el aire con serenidad...'**
  String get breathing_box_phase_2;

  /// No description provided for @breathing_box_phase_3.
  ///
  /// In es, this message translates to:
  /// **'Vacía tus pulmones con total suavidad...'**
  String get breathing_box_phase_3;

  /// No description provided for @breathing_box_phase_4.
  ///
  /// In es, this message translates to:
  /// **'Pausa en vacío observando la quietud interior...'**
  String get breathing_box_phase_4;

  /// No description provided for @breathing_coherent_name.
  ///
  /// In es, this message translates to:
  /// **'Respiración Coherente'**
  String get breathing_coherent_name;

  /// No description provided for @breathing_coherent_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Sincronización Cardíaca'**
  String get breathing_coherent_subtitle;

  /// No description provided for @breathing_coherent_benefit.
  ///
  /// In es, this message translates to:
  /// **'Respirar a 5.5 ciclos por minuto sincroniza las ondas cerebrales con la variabilidad cardíaca, logrando homeostasis general.'**
  String get breathing_coherent_benefit;

  /// No description provided for @breathing_coherent_category.
  ///
  /// In es, this message translates to:
  /// **'Coherencia y Equilibrio'**
  String get breathing_coherent_category;

  /// No description provided for @breathing_coherent_phase_1.
  ///
  /// In es, this message translates to:
  /// **'Inhala lento por la nariz expandiendo el diafragma...'**
  String get breathing_coherent_phase_1;

  /// No description provided for @breathing_coherent_phase_2.
  ///
  /// In es, this message translates to:
  /// **'Exhala sin esfuerzo liberando toda tensión acumulada...'**
  String get breathing_coherent_phase_2;

  /// No description provided for @breathing_sigh_name.
  ///
  /// In es, this message translates to:
  /// **'Suspiro Huberman'**
  String get breathing_sigh_name;

  /// No description provided for @breathing_sigh_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Alivio del Pánico en Tiempo Real'**
  String get breathing_sigh_subtitle;

  /// No description provided for @breathing_sigh_benefit.
  ///
  /// In es, this message translates to:
  /// **'Una doble inhalación seguida de exhalación larga reabre los alvéolos colapsados y descarga el exceso de CO₂ instantáneamente.'**
  String get breathing_sigh_benefit;

  /// No description provided for @breathing_sigh_category.
  ///
  /// In es, this message translates to:
  /// **'Alivio Instantáneo'**
  String get breathing_sigh_category;

  /// No description provided for @breathing_sigh_phase_1.
  ///
  /// In es, this message translates to:
  /// **'Inhala profundo por la nariz al 80%...'**
  String get breathing_sigh_phase_1;

  /// No description provided for @breathing_sigh_phase_2.
  ///
  /// In es, this message translates to:
  /// **'¡Inhala un sorbo extra rápido para llenar al máximo!'**
  String get breathing_sigh_phase_2;

  /// No description provided for @breathing_sigh_phase_3.
  ///
  /// In es, this message translates to:
  /// **'Exhala largo y relajado soltando todo por la boca...'**
  String get breathing_sigh_phase_3;

  /// No description provided for @breathing_46_name.
  ///
  /// In es, this message translates to:
  /// **'Respiración Calma 4-6'**
  String get breathing_46_name;

  /// No description provided for @breathing_46_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Alivio Fisiológico Rápido'**
  String get breathing_46_subtitle;

  /// No description provided for @breathing_46_benefit.
  ///
  /// In es, this message translates to:
  /// **'Prolongar la exhalación respecto a la inhalación frena inmediatamente el ritmo cardíaco mediante estimulación vagal.'**
  String get breathing_46_benefit;

  /// No description provided for @breathing_46_category.
  ///
  /// In es, this message translates to:
  /// **'Calma Rápida'**
  String get breathing_46_category;

  /// No description provided for @breathing_46_phase_1.
  ///
  /// In es, this message translates to:
  /// **'Inhala con tranquilidad por la nariz...'**
  String get breathing_46_phase_1;

  /// No description provided for @breathing_46_phase_2.
  ///
  /// In es, this message translates to:
  /// **'Suelta el aire muy despacio relajando hombros y rostro...'**
  String get breathing_46_phase_2;

  /// No description provided for @breathingSessionCycle.
  ///
  /// In es, this message translates to:
  /// **'Ciclo'**
  String get breathingSessionCycle;

  /// No description provided for @breathingSessionFinished.
  ///
  /// In es, this message translates to:
  /// **'¡Sesión Completada!'**
  String get breathingSessionFinished;

  /// No description provided for @breathingSessionFinishedDesc.
  ///
  /// In es, this message translates to:
  /// **'Has completado la rutina de respiración científica. Tu sistema nervioso está más regulado y en equilibrio.'**
  String get breathingSessionFinishedDesc;

  /// No description provided for @breathingSessionFinishedBtn.
  ///
  /// In es, this message translates to:
  /// **'Volver a Inicio'**
  String get breathingSessionFinishedBtn;

  /// No description provided for @rmpIntroTitle.
  ///
  /// In es, this message translates to:
  /// **'Relajación Muscular'**
  String get rmpIntroTitle;

  /// No description provided for @rmpIntroBanner.
  ///
  /// In es, this message translates to:
  /// **'La técnica de Jacobson consiste en tensar conscientemente grupos musculares y luego soltarlos para liberar estrés físico acumulado.'**
  String get rmpIntroBanner;

  /// No description provided for @rmpRoutineLabel.
  ///
  /// In es, this message translates to:
  /// **'Elige una rutina:'**
  String get rmpRoutineLabel;

  /// No description provided for @rmpDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'Duración por fase (segundos):'**
  String get rmpDurationLabel;

  /// No description provided for @rmpSoundLabel.
  ///
  /// In es, this message translates to:
  /// **'Efectos de sonido programados'**
  String get rmpSoundLabel;

  /// No description provided for @rmpSoundSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tocar tonos auditivos al inicio de la contracción y al soltar.'**
  String get rmpSoundSubtitle;

  /// No description provided for @rmpStartBtn.
  ///
  /// In es, this message translates to:
  /// **'Comenzar Relajación'**
  String get rmpStartBtn;

  /// No description provided for @rmpZones.
  ///
  /// In es, this message translates to:
  /// **'zonas'**
  String get rmpZones;

  /// No description provided for @rmp_routine_cuerpoCompleto_title.
  ///
  /// In es, this message translates to:
  /// **'Cuerpo Completo'**
  String get rmp_routine_cuerpoCompleto_title;

  /// No description provided for @rmp_routine_cuerpoCompleto_desc.
  ///
  /// In es, this message translates to:
  /// **'Todas las 14 zonas musculares para una relajación profunda y total del organismo.'**
  String get rmp_routine_cuerpoCompleto_desc;

  /// No description provided for @rmp_routine_express_title.
  ///
  /// In es, this message translates to:
  /// **'Express (Básico)'**
  String get rmp_routine_express_title;

  /// No description provided for @rmp_routine_express_desc.
  ///
  /// In es, this message translates to:
  /// **'4 zonas principales (manos, frente, hombros, pies) ideal para calma rápida.'**
  String get rmp_routine_express_desc;

  /// No description provided for @rmp_routine_superior_title.
  ///
  /// In es, this message translates to:
  /// **'Tren Superior'**
  String get rmp_routine_superior_title;

  /// No description provided for @rmp_routine_superior_desc.
  ///
  /// In es, this message translates to:
  /// **'8 zonas superiores (brazos, hombros, cara, cuello) para liberar tensión acumulada.'**
  String get rmp_routine_superior_desc;

  /// No description provided for @rmp_routine_inferior_title.
  ///
  /// In es, this message translates to:
  /// **'Tren Inferior'**
  String get rmp_routine_inferior_title;

  /// No description provided for @rmp_routine_inferior_desc.
  ///
  /// In es, this message translates to:
  /// **'6 zonas inferiores (torso, piernas, pantorrillas y pies) para descansar el cuerpo.'**
  String get rmp_routine_inferior_desc;

  /// No description provided for @rmpSessionPhaseTension.
  ///
  /// In es, this message translates to:
  /// **'¡Tensa!'**
  String get rmpSessionPhaseTension;

  /// No description provided for @rmpSessionPhaseRelaxation.
  ///
  /// In es, this message translates to:
  /// **'¡Relaja!'**
  String get rmpSessionPhaseRelaxation;

  /// No description provided for @rmpSessionFinished.
  ///
  /// In es, this message translates to:
  /// **'¡Relajación Completada!'**
  String get rmpSessionFinished;

  /// No description provided for @rmpSessionFinishedDesc.
  ///
  /// In es, this message translates to:
  /// **'Has liberado la tensión muscular acumulada en tu cuerpo. Siente la ligereza física.'**
  String get rmpSessionFinishedDesc;

  /// No description provided for @rmpSessionFinishedBtn.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get rmpSessionFinishedBtn;

  /// No description provided for @soundTherapyTitle.
  ///
  /// In es, this message translates to:
  /// **'Terapia de Sonido'**
  String get soundTherapyTitle;

  /// No description provided for @soundTherapyIntro.
  ///
  /// In es, this message translates to:
  /// **'Frecuencias curativas y tonos binaurales diseñados para sincronizar tus ondas cerebrales y calmar el estrés.'**
  String get soundTherapyIntro;

  /// No description provided for @soundDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'DURACIÓN'**
  String get soundDurationLabel;

  /// No description provided for @soundVolumeLabel.
  ///
  /// In es, this message translates to:
  /// **'VOLUMEN'**
  String get soundVolumeLabel;

  /// No description provided for @soundStartBtn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Terapia'**
  String get soundStartBtn;

  /// No description provided for @soundStopBtn.
  ///
  /// In es, this message translates to:
  /// **'Detener Terapia'**
  String get soundStopBtn;

  /// No description provided for @soundInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Sobre la Terapia de Sonido'**
  String get soundInfoTitle;

  /// No description provided for @soundInfoContent.
  ///
  /// In es, this message translates to:
  /// **'La terapia de sonido utiliza frecuencias específicas para inducir estados de relajación, enfoque o sueño profundo:\n\n• Ondas Solfeggio: Frecuencias antiguas asociadas al equilibrio corporal y mental.\n• Ritmos Binaurales: Generan una tercera frecuencia en el cerebro al escuchar tonos ligeramente diferentes en cada oído. Se recomienda usar auriculares.'**
  String get soundInfoContent;

  /// No description provided for @paintTitle.
  ///
  /// In es, this message translates to:
  /// **'Arte Zen & Coloreo'**
  String get paintTitle;

  /// No description provided for @paintBrushSize.
  ///
  /// In es, this message translates to:
  /// **'Grosor Pincel'**
  String get paintBrushSize;

  /// No description provided for @paintOpacity.
  ///
  /// In es, this message translates to:
  /// **'Espesor/Opacidad'**
  String get paintOpacity;

  /// No description provided for @paintClearBtn.
  ///
  /// In es, this message translates to:
  /// **'Limpiar Lienzo'**
  String get paintClearBtn;

  /// No description provided for @paintEraserMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Borrador'**
  String get paintEraserMode;

  /// No description provided for @paintBrushMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Pincel'**
  String get paintBrushMode;

  /// No description provided for @sensoryBallsTitle.
  ///
  /// In es, this message translates to:
  /// **'Bolas Sensoriales'**
  String get sensoryBallsTitle;

  /// No description provided for @sensoryBallsSoundOn.
  ///
  /// In es, this message translates to:
  /// **'Sonido: Activado'**
  String get sensoryBallsSoundOn;

  /// No description provided for @sensoryBallsSoundOff.
  ///
  /// In es, this message translates to:
  /// **'Sonido: Desactivado'**
  String get sensoryBallsSoundOff;

  /// No description provided for @popitTitle.
  ///
  /// In es, this message translates to:
  /// **'Pop-It / Burbujas'**
  String get popitTitle;

  /// No description provided for @popitSoundOption.
  ///
  /// In es, this message translates to:
  /// **'Sonido de explosión'**
  String get popitSoundOption;

  /// No description provided for @popitInfiniteOption.
  ///
  /// In es, this message translates to:
  /// **'Burbujas infinitas'**
  String get popitInfiniteOption;

  /// No description provided for @popitSoundTypeOption.
  ///
  /// In es, this message translates to:
  /// **'Tono de burbuja (Sensorial)'**
  String get popitSoundTypeOption;

  /// No description provided for @popitSoundSynth.
  ///
  /// In es, this message translates to:
  /// **'Sintetizador Suave'**
  String get popitSoundSynth;

  /// No description provided for @popitSoundReal.
  ///
  /// In es, this message translates to:
  /// **'Sonido de Burbuja'**
  String get popitSoundReal;

  /// No description provided for @spidersTitle.
  ///
  /// In es, this message translates to:
  /// **'Arañas Relajantes'**
  String get spidersTitle;

  /// No description provided for @spidersSpeedLabel.
  ///
  /// In es, this message translates to:
  /// **'Velocidad de reparación'**
  String get spidersSpeedLabel;

  /// No description provided for @spidersTapInstruction.
  ///
  /// In es, this message translates to:
  /// **'Toca la pantalla para tejer nuevas telas'**
  String get spidersTapInstruction;

  /// No description provided for @cockroachTitle.
  ///
  /// In es, this message translates to:
  /// **'Cucaracha Aplastada'**
  String get cockroachTitle;

  /// No description provided for @cockroachScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get cockroachScore;

  /// No description provided for @cockroachTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get cockroachTime;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
