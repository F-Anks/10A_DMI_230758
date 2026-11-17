import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/series/series_providers.dart';
import 'package:cinemapedia/presentation/providers/settings/catalog_type_provider.dart';
import 'movies_providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  final isSeries = ref.watch(catalogTypeProvider) == CatalogType.series;

  if (isSeries) {
    final step1 = ref.watch(onTheAirSeriesProvider).isEmpty;
    final step2 = ref.watch(airingTodaySeriesProvider).isEmpty;
    final step3 = ref.watch(popularSeriesProvider).isEmpty;
    final step4 = ref.watch(topRatedSeriesProvider).isEmpty;
    return step1 || step2 || step3 || step4;
  }

  final step1 = ref.watch(nowPlayingMoviesProvider).isEmpty;
  final step2 = ref.watch(popularMoviesProvider).isEmpty;
  final step3 = ref.watch(topRatedMoviesProvider).isEmpty;
  final step4 = ref.watch(upcomingMoviesProvider).isEmpty;

  return step1 || step2 || step3 || step4;
});
