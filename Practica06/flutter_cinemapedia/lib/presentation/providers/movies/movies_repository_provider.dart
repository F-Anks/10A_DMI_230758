import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/infrastructure/datasources/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/language_provider.dart';

final movieRepositoryProvider = Provider((ref) {
  final language = ref.watch(languageProvider);
  return MovieRepositoryImpl(
    MoviedbDatasource(language: language.apiCode),
  );
});
