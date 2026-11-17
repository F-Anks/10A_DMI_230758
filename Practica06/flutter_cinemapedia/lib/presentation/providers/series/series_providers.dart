import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

final onTheAirSeriesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreSeries = ref.watch(movieRepositoryProvider).getOnTheAirSeries;
  return MoviesNotifier(fetchMoreMovies: fetchMoreSeries);
});

final airingTodaySeriesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreSeries =
      ref.watch(movieRepositoryProvider).getAiringTodaySeries;
  return MoviesNotifier(fetchMoreMovies: fetchMoreSeries);
});

final popularSeriesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreSeries = ref.watch(movieRepositoryProvider).getPopularSeries;
  return MoviesNotifier(fetchMoreMovies: fetchMoreSeries);
});

final topRatedSeriesProvider =
    StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreSeries = ref.watch(movieRepositoryProvider).getTopRatedSeries;
  return MoviesNotifier(fetchMoreMovies: fetchMoreSeries);
});

final seriesSlideshowProvider = Provider<List<Movie>>((ref) {
  final onTheAirSeries = ref.watch(onTheAirSeriesProvider);
  if (onTheAirSeries.isEmpty) return [];
  return onTheAirSeries.sublist(0, math.min(6, onTheAirSeries.length));
});
