import 'package:flutter/foundation.dart';
import 'package:tistos/config/helpers/video_deduplicator.dart';
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

  /// Carga inicial rápida: Carga 'For You' de inmediato para desbloquear la UI,
  /// y carga las demás secciones en segundo plano para que nunca haya bucle infinito.
  Future<void> loadAll() async {
    try {
      // 1. Cargamos primero For You (la pestaña activa) para que el usuario entre de inmediato
      final forYouVideos = await _fetch(FeedSection.forYou);
      _feeds[FeedSection.forYou] = FeedState(videos: forYouVideos);
    } catch (e) {
      debugPrint('FeedProvider: Error cargando For You inicial: $e');
    } finally {
      // Desbloquea la UI de HomeScreen al instante (termina initialLoading)
      _initialLoading = false;
      notifyListeners();
    }

    // 2. Cargamos las demás pestañas en segundo plano sin bloquear al usuario
    for (final section in [FeedSection.nearYou, FeedSection.discover, FeedSection.favorites]) {
      try {
        final videos = await _fetch(section);
        _feeds[section] = FeedState(videos: videos);
        notifyListeners();
      } catch (e) {
        debugPrint('FeedProvider: Error cargando $section en segundo plano: $e');
      }
    }
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
    List<VideoPost> rawList;
    switch (section) {
      case FeedSection.forYou:
        rawList = await _repository.getTikTokVideos();
        break;
      case FeedSection.nearYou:
        rawList = await _repository.getInstagramReels();
        break;
      case FeedSection.discover:
        rawList = await _repository.getYouTubeShorts();
        break;
      case FeedSection.favorites:
        final favIds = LocalStorageService.getFavorites();
        final List<VideoPost> favs = [];
        for (final id in favIds) {
          final data = LocalStorageService.getVideoData(id);
          if (data != null) {
            favs.add(VideoPost.fromJson(data));
          }
        }
        rawList = favs;
        break;
    }

    // Validación y deduplicación estricta a nivel Provider
    return VideoDeduplicator.deduplicate(rawList);
  }

  void _update(FeedSection section, FeedState state) {
    _feeds[section] = state;
    notifyListeners();
  }
}
