import 'package:flutter/foundation.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/domain/repositories/video_posts_repository.dart';
import 'package:tistos/infrastructure/datasources/rapidapi_datasource_impl.dart';
import 'package:tistos/infrastructure/repositories/video_posts_repository_impl.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/models/feed_state.dart';

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

  /// Carga inicial de las 3 secciones en paralelo.
  Future<void> loadAll() async {
    final results = await Future.wait(FeedSection.values.map(_fetch));

    for (final section in FeedSection.values) {
      _feeds[section] = FeedState(videos: results[section.index]);
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

  Future<List<VideoPost>> _fetch(FeedSection section) => switch (section) {
        FeedSection.forYou => _repository.getTikTokVideos(),
        FeedSection.nearYou => _repository.getInstagramReels(),
        FeedSection.discover => _repository.getYouTubeShorts(),
      };

  void _update(FeedSection section, FeedState state) {
    _feeds[section] = state;
    notifyListeners();
  }
}
