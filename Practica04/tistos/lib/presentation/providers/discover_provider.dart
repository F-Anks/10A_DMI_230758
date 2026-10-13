import 'package:flutter/material.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/domain/repositories/video_posts_repository.dart';
import 'package:tistos/infrastructure/datasources/rapidapi_datasource_impl.dart';
import 'package:tistos/infrastructure/repositories/video_posts_repository_impl.dart';

class DiscoverProvider extends ChangeNotifier {
  final VideoPostRepository videosRepository;

  bool initialLoading = true;
  List<VideoPost> forYouVideos = [];
  List<VideoPost> nearYouVideos = [];
  List<VideoPost> discoverVideos = [];

  /// Versión de cada sección. Cambia en cada refresh y se usa como Key para
  /// reconstruir la lista completa (incluido el video que se está reproduciendo).
  final List<int> sectionVersion = [0, 0, 0];

  /// Indica si una sección se está refrescando.
  final List<bool> sectionRefreshing = [false, false, false];

  DiscoverProvider({VideoPostRepository? videosRepository})
      : videosRepository = videosRepository ??
            VideoPostsRepositoryImpl(videosDatasource: RapidApiDatasource());

  Future<void> loadNextPage() async {
    // Pedimos las 3 secciones en paralelo
    final results = await Future.wait([
      videosRepository.getTikTokVideos(),     // For You
      videosRepository.getInstagramReels(),   // Near You
      videosRepository.getYouTubeShorts(),    // Discover
    ]);

    forYouVideos = results[0];
    nearYouVideos = results[1];
    discoverVideos = results[2];

    initialLoading = false;
    notifyListeners();
  }

  Future<void> refreshSection(int index) async {
    if (sectionRefreshing[index]) return; // evita refrescos dobles
    sectionRefreshing[index] = true;
    notifyListeners();

    try {
      if (index == 0) {
        forYouVideos = await videosRepository.getTikTokVideos();
      } else if (index == 1) {
        nearYouVideos = await videosRepository.getInstagramReels();
      } else {
        discoverVideos = await videosRepository.getYouTubeShorts();
      }
      // Nueva versión -> la sección se reconstruye desde el primer video
      sectionVersion[index]++;
    } finally {
      sectionRefreshing[index] = false;
      notifyListeners();
    }
  }
}
