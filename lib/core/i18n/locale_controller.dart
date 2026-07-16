import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static final LocaleController instance = LocaleController._();
  LocaleController._();

  static const String _prefsKey = 'app_locale';
  Locale _locale = const Locale('es'); // Default Spanish

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? langCode = prefs.getString(_prefsKey);
      if (langCode != null && (langCode == 'es' || langCode == 'en')) {
        _locale = Locale(langCode);
        notifyListeners();
      }
    } catch (e) {
      // Fallback to default es
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, newLocale.languageCode);
    } catch (e) {
      // Ignore save errors
    }
  }

  void toggleLocale() {
    if (_locale.languageCode == 'es') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('es'));
    }
  }
}
