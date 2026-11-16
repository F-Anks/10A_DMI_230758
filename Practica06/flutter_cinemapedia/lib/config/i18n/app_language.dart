import 'package:flutter/material.dart';

/// Idioma disponible en CinePedia.
class AppLanguage {
  final String country;
  final String nativeName;
  final Locale locale;

  const AppLanguage({
    required this.country,
    required this.nativeName,
    required this.locale,
  });

  String get code => locale.languageCode;
  String get apiCode => '${locale.languageCode}-${locale.countryCode}';

  String get label => '$country ($nativeName)';
}

class AppLanguages {
  static const mexico = AppLanguage(
    country: 'MX',
    nativeName: 'Español',
    locale: Locale('es', 'MX'),
  );

  static const unitedStates = AppLanguage(
    country: 'US',
    nativeName: 'English',
    locale: Locale('en', 'US'),
  );

  static const germany = AppLanguage(
    country: 'DE',
    nativeName: 'Deutsch',
    locale: Locale('de', 'DE'),
  );

  static const china = AppLanguage(
    country: 'CN',
    nativeName: '中文',
    locale: Locale('zh', 'CN'),
  );

  static const egypt = AppLanguage(
    country: 'EG',
    nativeName: 'العربية',
    locale: Locale('ar', 'EG'),
  );

  static const all = <AppLanguage>[
    mexico,
    unitedStates,
    germany,
    china,
    egypt,
  ];

  static const defaultLanguage = mexico;

  static AppLanguage fromApiCode(String? apiCode) {
    if (apiCode == null) return defaultLanguage;
    return all.firstWhere(
      (lang) => lang.apiCode == apiCode,
      orElse: () => defaultLanguage,
    );
  }
}
