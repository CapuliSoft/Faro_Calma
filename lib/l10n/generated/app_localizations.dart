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
/// import 'generated/app_localizations.dart';
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
