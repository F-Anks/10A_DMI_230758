import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/infrastructure/datasources/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/language_provider.dart';

final actorsRepositoryProvider = Provider((ref) {
  final language = ref.watch(languageProvider);
  return ActorRepositoryImpl(
    ActorMovieDbDatasource(language: language.apiCode),
  );
});
