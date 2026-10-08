import 'package:flutter/foundation.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/domain/repositories/video_posts_repository.dart';
import 'package:tistos/infrastructure/datasources/rapidapi_datasource_impl.dart';
import 'package:tistos/infrastructure/repositories/video_posts_repository_impl.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/models/feed_state.dart';
import 'package:tistos/infrastructure/services/local_storage_service.dart';

/// Maneja los videos de las 3 secciones del feed.
class FeedProvider extends ChangeNotifier {
  FeedProvider({VideoPostRepository? repository})
      : _repository = repository ??
            VideoPostsRepositoryImpl(videosDatasource: RapidApiDatasource());

  /// Tiempo mínimo que se muestra el reloj de arena al refrescar, para que la
  /// animación no aparezca como un parpadeo, pero tampoco sea lenta.
  static const Duration _minRefreshDuration = Duration(milliseconds: 500);

  final VideoPostRepository _repository;

  final Map<FeedSection, FeedState> _feeds = {
    for (final section in FeedSection.values) section: const FeedState(),
  };

  bool _initialLoading = true;
  bool get initialLoading => _initialLoading;

  FeedState feed(FeedSection section) => _feeds[section]!;

  /// Carga inicial de las 3 secciones (secuencial para evitar rate limits de la API)
  Future<void> loadAll() async {
    for (final section in FeedSection.values) {
      final videos = await _fetch(section);
      _feeds[section] = FeedState(videos: videos);
      // Notificamos para que la UI vaya mostrando las que ya cargaron
      notifyListeners();
    }
    _initialLoading = false;
    notifyListeners();
  }

  /// Pide videos nuevos para una sección y la reinicia desde el primer video.
  Future<void> refresh(FeedSection section) async {
    final current = feed(section);
    if (current.isRefreshing) return; // evita refrescos dobles

    _update(section, current.copyWith(isRefreshing: true));

    final (videos, _) = await (
      _fetch(section),
      Future<void>.delayed(_minRefreshDuration),
    ).wait;

    _update(section, FeedState(videos: videos, version: current.version + 1));
  }

  Future<List<VideoPost>> _fetch(FeedSection section) async {
    switch (section) {
      case FeedSection.forYou:
        return _repository.getTikTokVideos();
      case FeedSection.nearYou:
        return _repository.getInstagramReels();
      case FeedSection.discover:
        return _repository.getYouTubeShorts();
      case FeedSection.favorites:
        final favIds = LocalStorageService.getFavorites();
        final List<VideoPost> favs = [];
        for (final id in favIds) {
          final data = LocalStorageService.getVideoData(id);
          if (data != null) {
            favs.add(VideoPost.fromJson(data));
          }
        }
        return favs;
    }
  }

  void _update(FeedSection section, FeedState state) {
    _feeds[section] = state;
    notifyListeners();
  }
}
