import 'package:flutter/material.dart';

/// Temporadas disponibles para la app
enum Season { normal, anniversary, halloween, christmas, valentine }

/// Configuración visual de cada temporada (logo + colores + sonido del splash)
class SeasonTheme {
  final Season season;
  final String logoPath;

  /// Sonido del splash (ruta relativa a la carpeta assets/)
  final String soundPath;

  /// Colores del gradiente animado del splash (tomados del logo)
  final List<Color> gradientColors;

  /// Color del brillo (glow) alrededor del logo
  final Color glowColor;

  /// Escala para recortar el margen blanco de los .jpg
  /// (1.0 = sin recorte, el Logo.png ya no tiene margen)
  final double cropScale;

  const SeasonTheme({
    required this.season,
    required this.logoPath,
    required this.soundPath,
    required this.gradientColors,
    required this.glowColor,
    this.cropScale = 1.0,
  });
}

class LogoHelper {

  // ==================== 5 SPLASH SCREENS ====================

  /// 1. Logo original (neón: azul noche, morado, rosa y cian)
  static const SeasonTheme _normal = SeasonTheme(
    season: Season.normal,
    logoPath: 'assets/images/Logo.png',
    soundPath: 'sounds/logo_sound.mp3',
    gradientColors: [
      Color(0xFF0B0B2B),
      Color(0xFF3A1C71),
      Color(0xFFD946EF),
      Color(0xFF22D3EE),
    ],
    glowColor: Color(0xFFD946EF),
  );

  /// 2. Aniversario (fiesta: morado, rosa, dorado y turquesa)
  static const SeasonTheme _anniversary = SeasonTheme(
    season: Season.anniversary,
    logoPath: 'assets/images/aniversary_logo.jpg',
    soundPath: 'sounds/aniversary_sound.mp3',
    gradientColors: [
      Color(0xFF1A1446),
      Color(0xFF7B2FF7),
      Color(0xFFF72585),
      Color(0xFFFFB703),
      Color(0xFF4CC9F0),
    ],
    glowColor: Color(0xFFF72585),
    cropScale: 1.32,
  );

  /// 3. Halloween (morado oscuro, naranja calabaza y verde neón)
  static const SeasonTheme _halloween = SeasonTheme(
    season: Season.halloween,
    logoPath: 'assets/images/halloween_logo.jpg',
    soundPath: 'sounds/halloween_sound.mp3',
    gradientColors: [
      Color(0xFF120621),
      Color(0xFF5B1A8C),
      Color(0xFFFF6A00),
      Color(0xFF9B30FF),
      Color(0xFF39FF14),
    ],
    glowColor: Color(0xFFFF6A00),
    cropScale: 1.32,
  );

  /// 4. Navidad (azul noche, rojo y verde pino)
  static const SeasonTheme _christmas = SeasonTheme(
    season: Season.christmas,
    logoPath: 'assets/images/chrismas_logo.jpg',
    soundPath: 'sounds/chrismas_sound.mp3',
    gradientColors: [
      Color(0xFF0A1931),
      Color(0xFFB3001B),
      Color(0xFF0B6E4F),
      Color(0xFF1E3A8A),
      Color(0xFF22C55E),
    ],
    glowColor: Color(0xFF22C55E),
    cropScale: 1.32,
  );

  /// 5. San Valentín (vino, magenta, rosa)
  static const SeasonTheme _valentine = SeasonTheme(
    season: Season.valentine,
    logoPath: 'assets/images/valentine´s_logo.jpg',
    soundPath: 'sounds/valentine´s_sound.mp3',
    gradientColors: [
      Color(0xFF2B0A3D),
      Color(0xFF8E1B5E),
      Color(0xFFFF2E63),
      Color(0xFFFF8FAB),
      Color(0xFF6A0572),
    ],
    glowColor: Color(0xFFFF2E63),
    cropScale: 1.32,
  );

  /// Devuelve el tema completo (logo + colores) según la fecha actual
  static SeasonTheme getCurrentSeasonTheme([DateTime? date]) {
    final now = date ?? DateTime.now();
    final month = now.month;
    final day = now.day;

    // 1. Del 01 de Octubre al 10 de Octubre el logo de aniversary_logo.jpg
    if (month == 10 && day >= 1 && day <= 10) {
      return _anniversary;
    }

    // 2. Del 20 de Octubre al 20 de Noviembre el logo halloween_logo.jpg
    if ((month == 10 && day >= 20) || (month == 11 && day <= 20)) {
      return _halloween;
    }

    // 3. Del 10 de Diciembre al 10 de Enero el logo crishmas_logo.jpg
    if ((month == 12 && day >= 10) || (month == 1 && day <= 10)) {
      return _christmas;
    }

    // 4. Del 02 de Febrero al 22 de Febrero el logo valentine´s_logo.jpg
    if (month == 2 && day >= 2 && day <= 22) {
      return _valentine;
    }

    // Por defecto, si no es ninguna de esas fechas, devuelve el logo original
    return _normal;
  }

  /// Devuelve la ruta de la imagen del logotipo dependiendo de la fecha actual
  static String getCurrentLogoPath() => getCurrentSeasonTheme().logoPath;

}
