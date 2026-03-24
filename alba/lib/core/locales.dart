import 'package:flutter/material.dart';
import 'package:lucid_validation/lucid_validation.dart';

class LucidLocalizationDelegate extends LocalizationsDelegate<Culture> {
  const LucidLocalizationDelegate();

  static final delegate = LucidLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return LucidValidation.global.languageManager.isSupported(
      locale.languageCode,
      locale.countryCode,
    );
  }

  @override
  Future<Culture> load(Locale locale) async {
    print(locale);
    final culture = Culture(locale.languageCode, locale.countryCode ?? '');
    LucidValidation.global.culture = culture;
    return culture;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Culture> old) {
    return true;
  }
}
