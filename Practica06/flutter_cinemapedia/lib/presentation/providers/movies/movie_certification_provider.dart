import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:cinemapedia/presentation/providers/settings/language_provider.dart';

final movieCertificationProvider =
    FutureProvider.family.autoDispose<String, int>((ref, movieId) {
  ref.watch(languageProvider);
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getCertification(movieId);
});
