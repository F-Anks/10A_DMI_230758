import 'package:flutter_test/flutter_test.dart';
import 'package:cinemapedia/config/helpers/logo_helper.dart';

void main() {
  group('LogoHelper seasonal date rules', () {
    test('Navidad: 15 de diciembre al 06 de enero', () {
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2026, 12, 15)).season,
        Season.christmas,
      );
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2027, 1, 6)).season,
        Season.christmas,
      );
    });

    test('Día Mundial del Cine: segundo sábado de febrero (sin choque)', () {
      // En 2025 el 1 de febrero fue sábado -> 2do sábado fue 8 de febrero
      expect(LogoHelper.isSecondSaturdayOfFebruary(DateTime(2025, 2, 8)), isTrue);
      expect(LogoHelper.isSecondSaturdayOfFebruary(DateTime(2025, 2, 9)), isFalse);
      final theme = LogoHelper.getCurrentSeasonTheme(DateTime(2025, 2, 8));
      expect(theme.season, Season.cinemaWorldDay);
      expect(theme.logoPath, 'assets/images/cinema_world_day_logo.jpg');
      expect(theme.soundPath, 'sounds/sound1.mp3');
      expect(theme.isDualLogo, isFalse);
    });

    test('Coincidencia 14 de febrero y segundo sábado de febrero (ambos logos)', () {
      // En 2026 el 1 de febrero es domingo -> 1er sábado = 7 feb, 2do sábado = 14 feb
      expect(LogoHelper.isSecondSaturdayOfFebruary(DateTime(2026, 2, 14)), isTrue);
      final theme = LogoHelper.getCurrentSeasonTheme(DateTime(2026, 2, 14));
      expect(theme.season, Season.cinemaValentine);
      expect(theme.isDualLogo, isTrue);
      expect(theme.logoPath, 'assets/images/cinema_world_day_logo.jpg');
      expect(theme.secondaryLogoPath, 'assets/images/valentine_logo.jpg');
    });

    test('San Valentín: 14 al 16 de febrero (cuando no es segundo sábado)', () {
      final theme = LogoHelper.getCurrentSeasonTheme(DateTime(2026, 2, 15));
      expect(theme.season, Season.valentine);
      expect(theme.logoPath, 'assets/images/valentine_logo.jpg');
      expect(theme.soundPath, 'sounds/sound6.mp3');
    });

    test('Halloween: 20 de octubre al 02 de noviembre', () {
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2026, 10, 20)).season,
        Season.halloween,
      );
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2026, 11, 2)).season,
        Season.halloween,
      );
    });

    test('Aniversario: 05 de noviembre al 13 de noviembre', () {
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2026, 11, 5)).season,
        Season.anniversary,
      );
      expect(
        LogoHelper.getCurrentSeasonTheme(DateTime(2026, 11, 13)).season,
        Season.anniversary,
      );
    });

    test('Normal: resto de las fechas', () {
      final theme = LogoHelper.getCurrentSeasonTheme(DateTime(2026, 11, 3));
      expect(theme.season, Season.normal);
      expect(theme.logoPath, 'assets/images/logo.jpg');
      expect(theme.soundPath, 'sounds/sound2.mp3');
    });
  });
}
