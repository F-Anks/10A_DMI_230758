import 'package:flutter/material.dart';

/// Temporadas disponibles para CinePedia según la fecha del dispositivo
enum Season {
  normal,
  christmas,
  cinemaWorldDay,
  anniversary,
  halloween,
  valentine,
  cinemaValentine,
}

/// Configuración visual y sonora de cada temporada del splash
class SeasonTheme {
  final Season season;
  final String logoPath;
  final String? secondaryLogoPath;
  final String soundPath;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color secondaryGlowColor;
  final double cropScale;
  final double secondaryCropScale;

  const SeasonTheme({
    required this.season,
    required this.logoPath,
    this.secondaryLogoPath,
    required this.soundPath,
    required this.gradientColors,
    required this.glowColor,
    required this.secondaryGlowColor,
    this.cropScale = 1.38,
    this.secondaryCropScale = 1.38,
  });

  bool get isDualLogo => secondaryLogoPath != null;
}

class LogoHelper {
  /// 1. Resto de las fechas: logo.jpg - sound2
  static const SeasonTheme _normal = SeasonTheme(
    season: Season.normal,
    logoPath: 'assets/images/logo.jpg',
    soundPath: 'sounds/sound2.mp3',
    gradientColors: [
      Color(0xFF050B1E),
      Color(0xFF0D47A1),
      Color(0xFF00A8FF),
      Color(0xFF7B2CBF),
      Color(0xFFFFC300),
    ],
    glowColor: Color(0xFF00A8FF),
    secondaryGlowColor: Color(0xFFFFC300),
    cropScale: 1.38,
  );

  /// 2. Navidad (15 Diciembre - 06 Enero): christmas_logo.jpg - sound5
  static const SeasonTheme _christmas = SeasonTheme(
    season: Season.christmas,
    logoPath: 'assets/images/christmas_logo.jpg',
    soundPath: 'sounds/sound5.mp3',
    gradientColors: [
      Color(0xFF07132B),
      Color(0xFFC1121F),
      Color(0xFF1B7A43),
      Color(0xFFFFB703),
      Color(0xFF38BDF8),
    ],
    glowColor: Color(0xFFC1121F),
    secondaryGlowColor: Color(0xFFFFB703),
    cropScale: 1.38,
  );

  /// 3. Día Mundial del Cine (Segundo sábado de Febrero): cinema_world_day_logo.jpg - sound1
  static const SeasonTheme _cinemaWorldDay = SeasonTheme(
    season: Season.cinemaWorldDay,
    logoPath: 'assets/images/cinema_world_day_logo.jpg',
    soundPath: 'sounds/sound1.mp3',
    gradientColors: [
      Color(0xFF080D24),
      Color(0xFFD97706),
      Color(0xFFFFD166),
      Color(0xFF0096C7),
      Color(0xFF9D4EDD),
    ],
    glowColor: Color(0xFFFFD166),
    secondaryGlowColor: Color(0xFF00B4D8),
    cropScale: 1.34,
  );

  /// 4. Aniversario (05 Noviembre - 13 Noviembre): aniversary_logo.jpg - sound4
  static const SeasonTheme _anniversary = SeasonTheme(
    season: Season.anniversary,
    logoPath: 'assets/images/aniversary_logo.jpg',
    soundPath: 'sounds/sound4.mp3',
    gradientColors: [
      Color(0xFF100B30),
      Color(0xFF7209B7),
      Color(0xFFF72585),
      Color(0xFFFFBE0B),
      Color(0xFF00BBF9),
    ],
    glowColor: Color(0xFFF72585),
    secondaryGlowColor: Color(0xFFFFBE0B),
    cropScale: 1.38,
  );

  /// 5. Halloween (20 Octubre - 02 Noviembre): halloween_logo.jpg - sound3
  static const SeasonTheme _halloween = SeasonTheme(
    season: Season.halloween,
    logoPath: 'assets/images/halloween_logo.jpg',
    soundPath: 'sounds/sound3.mp3',
    gradientColors: [
      Color(0xFF0F051D),
      Color(0xFF5A189A),
      Color(0xFFFF6D00),
      Color(0xFF9D4EDD),
      Color(0xFF00B4D8),
    ],
    glowColor: Color(0xFFFF6D00),
    secondaryGlowColor: Color(0xFF9D4EDD),
    cropScale: 1.38,
  );

  /// 6. San Valentín (14 Febrero - 16 Febrero): valentine_logo.jpg - sound6
  static const SeasonTheme _valentine = SeasonTheme(
    season: Season.valentine,
    logoPath: 'assets/images/valentine_logo.jpg',
    soundPath: 'sounds/sound6.mp3',
    gradientColors: [
      Color(0xFF1F0826),
      Color(0xFF9B1B5A),
      Color(0xFFFF2A85),
      Color(0xFFFFB703),
      Color(0xFF3A86FF),
    ],
    glowColor: Color(0xFFFF2A85),
    secondaryGlowColor: Color(0xFFFFB703),
    cropScale: 1.38,
  );

  /// 7. Coincidencia 14 de Febrero + Segundo Sábado de Febrero (Ambos logos)
  static const SeasonTheme _cinemaValentine = SeasonTheme(
    season: Season.cinemaValentine,
    logoPath: 'assets/images/cinema_world_day_logo.jpg',
    secondaryLogoPath: 'assets/images/valentine_logo.jpg',
    soundPath: 'sounds/sound_dual.mp3',
    gradientColors: [
      Color(0xFF120924),
      Color(0xFFFFD166),
      Color(0xFFFF2A85),
      Color(0xFF0096C7),
      Color(0xFF9D4EDD),
    ],
    glowColor: Color(0xFFFFD166),
    secondaryGlowColor: Color(0xFFFF2A85),
    cropScale: 1.34,
    secondaryCropScale: 1.38,
  );

  /// Calcula el día exacto en que cae el segundo sábado de febrero del año indicado.
  static int getSecondSaturdayOfFebruaryDay(int year) {
    final firstDayOfFeb = DateTime(year, 2, 1);
    final daysUntilFirstSaturday =
        (DateTime.saturday - firstDayOfFeb.weekday + 7) % 7;
    final firstSaturdayDay = 1 + daysUntilFirstSaturday;
    return firstSaturdayDay + 7;
  }

  /// Verifica si una fecha corresponde exactamente al segundo sábado de febrero.
  static bool isSecondSaturdayOfFebruary(DateTime date) {
    return date.month == 2 &&
        date.day == getSecondSaturdayOfFebruaryDay(date.year);
  }

  /// Devuelve el tema correspondiente según la fecha del dispositivo.
  static SeasonTheme getCurrentSeasonTheme([DateTime? date]) {
    final now = date ?? DateTime.now();
    final month = now.month;
    final day = now.day;

    final isCinemaDay = isSecondSaturdayOfFebruary(now);
    final isValentine = month == 2 && day >= 14 && day <= 16;

    // Si el segundo sábado de febrero cae el 14 de febrero, mostrar los dos logos
    if (isCinemaDay && isValentine) {
      return _cinemaValentine;
    }

    // Segundo sábado de febrero (cualquier otro día fuera del 14)
    if (isCinemaDay) {
      return _cinemaWorldDay;
    }

    // 14 al 16 de febrero
    if (isValentine) {
      return _valentine;
    }

    // 15 de diciembre al 06 de enero
    if ((month == 12 && day >= 15) || (month == 1 && day <= 6)) {
      return _christmas;
    }

    // 20 de octubre al 02 de noviembre
    if ((month == 10 && day >= 20) || (month == 11 && day <= 2)) {
      return _halloween;
    }

    // 05 de noviembre al 13 de noviembre
    if (month == 11 && day >= 5 && day <= 13) {
      return _anniversary;
    }

    // Resto de las fechas
    return _normal;
  }
}

