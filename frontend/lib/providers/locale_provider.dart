import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('selected_language_code');
    if (languageCode != null) {
      if (languageCode == 'hi_HR') {
        _locale = const Locale('hi', 'HR');
      } else {
        _locale = Locale(languageCode);
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (locale.languageCode == 'hi' && locale.countryCode == 'HR') {
      await prefs.setString('selected_language_code', 'hi_HR');
    } else {
      await prefs.setString('selected_language_code', locale.languageCode);
    }
  }
}
