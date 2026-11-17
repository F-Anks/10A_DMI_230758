import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemapedia/config/helpers/age_rating.dart';
import 'package:cinemapedia/config/helpers/logo_helper.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/widgets/movies/movies_slideshow.dart';

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

  group('MediaId helpers', () {
    test('codifica y decodifica IDs de series sin colisionar con películas', () {
      const tmdbId = 1396;
      final seriesId = MediaId.fromSeries(tmdbId);

      expect(MediaId.isSeries(tmdbId), isFalse);
      expect(MediaId.isSeries(seriesId), isTrue);
      expect(MediaId.tmdbId(tmdbId), tmdbId);
      expect(MediaId.tmdbId(seriesId), tmdbId);
      expect(MediaId.kind(tmdbId), 'movie');
      expect(MediaId.kind(seriesId), 'tv');
    });
  });

  group('AgeRatings rules', () {
    test('resuelve certificación directa para MX, US y DE', () {
      const sample = {'MX': 'b15', 'US': 'PG-13', 'DE': '12'};
      expect(
        AgeRatings.resolveForCountry(countryCode: 'MX', byCountry: sample),
        'B15',
      );
      expect(
        AgeRatings.resolveForCountry(countryCode: 'US', byCountry: sample),
        'PG-13',
      );
      expect(
        AgeRatings.resolveForCountry(countryCode: 'DE', byCountry: sample),
        'FSK 12',
      );
      expect(
        AgeRatings.resolveForCountry(
          countryCode: 'DE',
          byCountry: const {'DE': 'FSK 16'},
        ),
        'FSK 16',
      );
    });

    test('CN devuelve NR cuando no existe certificación local', () {
      expect(
        AgeRatings.resolveForCountry(
          countryCode: 'CN',
          byCountry: const {'US': 'R'},
        ),
        'NR',
      );
    });

    test('EG aproxima desde US si no existe certificación egipcia directa', () {
      expect(
        AgeRatings.resolveForCountry(
          countryCode: 'EG',
          byCountry: const {'US': 'R'},
        ),
        '+16',
      );
      expect(
        AgeRatings.resolveForCountry(
          countryCode: 'EG',
          byCountry: const {'US': 'TV-MA'},
        ),
        '+18',
      );
      expect(
        AgeRatings.resolveForCountry(
          countryCode: 'EG',
          byCountry: const {'EG': '+12', 'US': 'R'},
        ),
        '+12',
      );
    });

    test('clasifica niveles correctamente', () {
      expect(AgeRatings.classify('G'), AgeRatingLevel.allAges);
      expect(AgeRatings.classify('PG-13'), AgeRatingLevel.teen);
      expect(AgeRatings.classify('FSK 12'), AgeRatingLevel.teen);
      expect(AgeRatings.classify('B15'), AgeRatingLevel.mature);
      expect(AgeRatings.classify('FSK 16'), AgeRatingLevel.mature);
      expect(AgeRatings.classify('TV-MA'), AgeRatingLevel.adult);
      expect(AgeRatings.classify('FSK 18'), AgeRatingLevel.adult);
      expect(AgeRatings.classify('NR'), AgeRatingLevel.unrated);
    });
  });

  group('i18n languages & strings', () {
    test('expone los 5 idiomas y cadenas no vacías', () {
      expect(AppLanguages.all.length, 5);
      expect(
        AppLanguages.all.map((l) => l.apiCode),
        ['es-MX', 'en-US', 'de-DE', 'zh-CN', 'ar-EG'],
      );
      expect(AppLanguages.fromApiCode('unknown'), AppLanguages.mexico);

      for (final lang in AppLanguages.all) {
        final s = AppStrings.byCode(lang.code);
        expect(s.home, isNotEmpty);
        expect(s.movies, isNotEmpty);
        expect(s.series, isNotEmpty);
        expect(s.ageRating, isNotEmpty);
        expect(s.settings, isNotEmpty);
        expect(s.loaderMessagesMovies, isNotEmpty);
        expect(s.loaderMessagesSeries, isNotEmpty);
        expect(s.themeSection, isNotEmpty);
        expect(s.seasonThemeNames.length, seasonThemeColors.length);
      }
    });
  });

  group('AppTheme configuration', () {
    test('permite alternar entre modo oscuro/claro y colores de temporada', () {
      const darkDefault = AppTheme();
      expect(darkDefault.getTheme().brightness, Brightness.dark);

      final lightHalloween =
          darkDefault.copyWith(isDarkmode: false, selectedColor: 4);
      expect(lightHalloween.getTheme().brightness, Brightness.light);
      expect(lightHalloween.selectedColor, 4);
    });
  });

  group('MoviesSlideshow widget', () {
    Movie buildSampleMovie(int id, String title, String overview) => Movie(
          adult: false,
          backdropPath: 'https://example.com/$id.jpg',
          genreIds: const ['Acción'],
          id: id,
          originalLanguage: 'es',
          originalTitle: title,
          overview: overview,
          popularity: 100,
          posterPath: 'https://example.com/p$id.jpg',
          releaseDate: DateTime(2026, 11, 16),
          title: title,
          video: false,
          voteAverage: 8.5,
          voteCount: 500,
        );

    testWidgets('muestra titulo, sinopsis y flechas laterales con navegacion circular',
        (tester) async {
      final movies = [
        buildSampleMovie(1, 'Película Uno', 'Sinopsis corta uno'),
        buildSampleMovie(2, 'Película Dos', 'Sinopsis corta dos'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoviesSlideshow(movies: movies),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Película Uno'), findsOneWidget);
      expect(find.text('Sinopsis corta uno'), findsOneWidget);
      expect(find.text('8.5'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.star_rounded), findsAtLeastNWidgets(4));
      expect(find.byIcon(Icons.star_half_rounded), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Película Dos'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Película Uno'), findsOneWidget);
    });
  });
}
