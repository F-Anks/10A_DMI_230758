enum AgeRatingLevel {
  allAges,
  teen,
  mature,
  adult,
  unrated,
}

/// Reglas y utilidades para resolver la clasificación de edad según el país
/// activo (`MX`, `US`, `DE`, `CN`, `EG`), tanto para películas como para series.
class AgeRatings {
  AgeRatings._();

  /// TMDB raramente incluye certificaciones egipcias directas; se aproxima a
  /// partir de la clasificación de Estados Unidos cuando no hay entrada `EG`.
  static const Map<String, String> egyptFromUs = {
    'G': 'All',
    'PG': 'PG',
    'PG-13': '+12',
    'R': '+16',
    'NC-17': '+18',
    'TV-Y': 'All',
    'TV-Y7': 'All',
    'TV-Y7-FV': 'All',
    'TV-G': 'All',
    'TV-PG': '+12',
    'TV-14': '+16',
    'TV-MA': '+18',
  };

  /// Formatea el código de clasificación para mostrarlo de forma consistente.
  static String normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'NR';
    return trimmed.toUpperCase();
  }

  /// Formatea el código de clasificación para mostrarlo de forma consistente,
  /// agregando el prefijo `FSK` a clasificaciones numéricas alemanas (`DE`).
  static String normalizeForCountry(String country, String raw) {
    final code = normalize(raw);
    if (code == 'NR') return 'NR';

    if (country.toUpperCase() == 'DE' &&
        const {'0', '6', '12', '16', '18'}.contains(code)) {
      return 'FSK $code';
    }
    return code;
  }

  /// Resuelve la clasificación efectiva dado un mapa `{iso_3166_1: certification}`.
  static String resolveForCountry({
    required String countryCode,
    required Map<String, String> byCountry,
  }) {
    final country = countryCode.toUpperCase();
    final direct = byCountry[country]?.trim() ?? '';

    if (country == 'EG') {
      if (direct.isNotEmpty) return normalize(direct);
      final us = byCountry['US']?.trim().toUpperCase() ?? '';
      return egyptFromUs[us] ?? (us.isEmpty ? 'NR' : normalize(us));
    }

    if (direct.isNotEmpty) return normalizeForCountry(country, direct);
    return 'NR';
  }

  /// Clasifica el nivel de restricción para estilizar la insignia sin perder
  /// coherencia visual entre países (MX, US, DE, CN, EG).
  static AgeRatingLevel classify(String certification) {
    var code = certification.trim().toUpperCase();
    if (code.startsWith('FSK ')) {
      code = code.substring(4).trim();
    } else if (code.startsWith('FSK-')) {
      code = code.substring(4).trim();
    }

    if (code.isEmpty || code == 'NR' || code == 'S/C') {
      return AgeRatingLevel.unrated;
    }

    if (const {
      'AA',
      'A',
      'G',
      '0',
      '6',
      'ALL',
      'TV-Y',
      'TV-Y7',
      'TV-Y7-FV',
      'TV-G',
      'TP',
      'U',
    }.contains(code)) {
      return AgeRatingLevel.allAges;
    }

    if (const {
      'PG',
      'B',
      '12',
      '+12',
      '12+',
      'PG-13',
      'TV-PG',
    }.contains(code)) {
      return AgeRatingLevel.teen;
    }

    if (const {
      'B15',
      'B-15',
      '14',
      '15',
      '16',
      '+16',
      '16+',
      'R',
      'TV-14',
    }.contains(code)) {
      return AgeRatingLevel.mature;
    }

    if (const {
      'C',
      'D',
      '18',
      '+18',
      '18+',
      'NC-17',
      'TV-MA',
    }.contains(code)) {
      return AgeRatingLevel.adult;
    }

    return AgeRatingLevel.unrated;
  }
}
