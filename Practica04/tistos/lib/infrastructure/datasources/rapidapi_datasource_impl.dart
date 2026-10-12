import 'dart:math';

import 'package:dio/dio.dart';
import 'package:tistos/config/constants/environment.dart';
import 'package:tistos/config/helpers/video_deduplicator.dart';
import 'package:tistos/domain/datasources/video_posts_datasource.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/infrastructure/services/local_storage_service.dart';

/// Datasource que obtiene videos de RapidAPI / Pixabay / TikWM.
///
/// - For You  -> TikTok (feed US) / Failover Pixabay
/// - Discover -> Pixabay Videos (vertical sports/lifestyle)
/// - Near You -> TikTok (feed MX) / Failover Pixabay Regional
class RapidApiDatasource implements VideoPostDatasource {
  static const int minVideos = 10;
  static int _globalVideoCounter = 0;

  final Dio dio;
  final Random _random = Random();

  RapidApiDatasource()
    : dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'x-rapidapi-key': Environment.rapidApiKey},
        ),
      );

  // ---------------------------------------------------------------------------
  // For You (Tab 1) - TikWM US Feed
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getTikTokVideos() async {
    return await _fetchPixabayFeed();
  }

  // ---------------------------------------------------------------------------
  // Discover (Tab 2) - Pixabay Sports / Lifestyle
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getYouTubeShorts() async {
    return await _fetchRedditFeed();
  }

  // ---------------------------------------------------------------------------
  // Near You (Tab 3) - TikWM Regional MX
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getInstagramReels() async {
    return await _fetchNasaFeed();
  }

  // ---------------------------------------------------------------------------
  // API 1: TikTok Feed (US) - "For You"
  // ---------------------------------------------------------------------------
  Future<List<VideoPost>> _fetchPixabayFeed() async {
    try {
      final res = await dio.get(
        'https://tikwm.com/api/feed/list',
        queryParameters: {'region': 'US', 'count': '15'},
      );

      final List<VideoPost> rawList = [];
      if (res.data != null && res.data['data'] != null) {
        final list = res.data['data'] as List;
        for (final item in list) {
          if (item['play'] != null) {
            rawList.add(
              VideoPost(
                id: item['video_id']?.toString() ?? DateTime.now().toString(),
                caption: item['title'] ?? 'Trending Video · For You',
                videoUrl: item['play'],
                coverUrl: item['cover'] ?? '',
                username: '@${item['author']?['unique_id'] ?? 'tiktok_creator'}',
              ),
            );
          }
        }
      }

      // Regla estricta de validación y deduplicación
      final cleanVideos = VideoDeduplicator.deduplicate(rawList);
      if (cleanVideos.isNotEmpty) {
        cleanVideos.shuffle(_random);
        return cleanVideos.map((v) => _applyStats(v)).toList();
      }
    } catch (_) {}

    // Failover si TikWM falla en For You: se obtienen videos de Pixabay
    return await _fetchRedditFeed();
  }

  // ---------------------------------------------------------------------------
  // API 2: Pixabay Videos API - "Discover"
  // ---------------------------------------------------------------------------
  Future<List<VideoPost>> _fetchRedditFeed() async {
    try {
      final res = await dio.get(
        'https://pixabay.com/api/videos/',
        queryParameters: {
          'key': '57929024-d9d2e5539159a28206fcf347f',
          'q': 'vertical sports',
          'per_page': 15,
          'page': _random.nextInt(10) + 1,
        },
      );

      final List<VideoPost> rawList = [];
      if (res.data != null && res.data['hits'] != null) {
        final list = res.data['hits'] as List;
        for (final item in list) {
          final videosData = item['videos'];
          if (videosData != null && videosData['tiny'] != null) {
            rawList.add(
              VideoPost(
                id: 'disc_${item['id'] ?? DateTime.now().millisecondsSinceEpoch}',
                caption: item['tags'] ?? 'Action & Sports · Discover',
                videoUrl: videosData['tiny']['url'],
                coverUrl: item['picture_id'] != null 
                    ? 'https://i.vimeocdn.com/video/${item['picture_id']}_640x360.jpg' 
                    : '',
                username: '@${item['user'] ?? 'athlete_pro'}',
              ),
            );
          }
        }
      }

      // Regla estricta de validación y deduplicación
      final cleanVideos = VideoDeduplicator.deduplicate(rawList);
      if (cleanVideos.isNotEmpty) {
        cleanVideos.shuffle(_random);
        return cleanVideos.map((v) => _applyStats(v)).toList();
      }
    } catch (_) {}

    // Fallbacks exclusivos y garantizados para Discover (sin colisión con Near You)
    final fallbacks = [
      VideoPost(
        id: 'disc_fb_1',
        caption: 'Extreme mountain downhill skateboard session #Discover',
        videoUrl: 'https://cdn.pixabay.com/video/2022/10/25/136421-764426574_tiny.mp4',
        coverUrl: 'https://i.vimeocdn.com/video/1534062123-5e9fa07e15d86221469e38e65839ce6b2545d9e5db4d1df0059c1c4e979cf318-d_640x360.jpg',
        username: '@downhill_sports',
      ),
      VideoPost(
        id: 'disc_fb_2',
        caption: 'Sunset surfing barrel wave #Discover',
        videoUrl: 'https://cdn.pixabay.com/video/2020/05/25/40149-424754593_tiny.mp4',
        coverUrl: 'https://i.vimeocdn.com/video/897587843-982c7a02292f75d2786968ce61d7b00366ebae77d346ff85227bf791f4ae8b74-d_640x360.jpg',
        username: '@ocean_vibes',
      ),
      VideoPost(
        id: 'disc_fb_3',
        caption: 'Ruta escénica en senderismo de montaña #Discover',
        videoUrl: 'https://cdn.pixabay.com/video/2026/09/24/378498_tiny.mp4',
        coverUrl: 'https://cdn.pixabay.com/video/2026/09/24/378498_tiny.jpg',
        username: '@nature_explorer',
      ),
      VideoPost(
        id: 'disc_fb_4',
        caption: 'Aventura en bicicleta de montaña por el bosque #Discover',
        videoUrl: 'https://cdn.pixabay.com/video/2026/09/24/378487_tiny.mp4',
        coverUrl: 'https://cdn.pixabay.com/video/2026/09/24/378487_tiny.jpg',
        username: '@trail_riders',
      ),
    ];
    return VideoDeduplicator.deduplicate(fallbacks).map((v) => _applyStats(v)).toList();
  }

  // ---------------------------------------------------------------------------
  // API 3: Social Scraper API - "Near You" (Regional MX Feed con Failover)
  // ---------------------------------------------------------------------------
  Future<List<VideoPost>> _fetchNasaFeed() async {
    // Intento 1: TikWM regional MX
    try {
      final res = await dio.get(
        'https://tikwm.com/api/feed/list',
        queryParameters: {
          'region': 'MX', 
          'count': '15',
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
          },
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final List<VideoPost> rawList = [];
      if (res.data != null && res.data['data'] != null) {
        final list = res.data['data'] as List;
        for (final item in list) {
          if (item['play'] != null) {
            rawList.add(
              VideoPost(
                id: item['video_id']?.toString() ?? DateTime.now().toString(),
                caption: item['title'] ?? 'Regional Video · Near You',
                videoUrl: item['play'],
                coverUrl: item['cover'] ?? '',
                username: '@${item['author']?['unique_id'] ?? 'near_you_user'}',
              ),
            );
          }
        }
      }

      // Regla estricta de validación y deduplicación
      final cleanVideos = VideoDeduplicator.deduplicate(rawList);
      if (cleanVideos.isNotEmpty) {
        cleanVideos.shuffle(_random);
        return cleanVideos.map((v) => _applyStats(v)).toList();
      }
    } catch (_) {
      // Si TikWM falla o rate-limita, continuamos al Failover Regional
    }

    // Intento 2 (Failover Regional): Pixabay Videos temáticos México / Regional
    try {
      final res = await dio.get(
        'https://pixabay.com/api/videos/',
        queryParameters: {
          'key': '57929024-d9d2e5539159a28206fcf347f',
          'q': 'mexico city',
          'per_page': 15,
          'page': _random.nextInt(3) + 1,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      final List<VideoPost> rawList = [];
      if (res.data != null && res.data['hits'] != null) {
        final list = res.data['hits'] as List;
        for (final item in list) {
          final videosData = item['videos'];
          if (videosData != null && videosData['tiny'] != null) {
            rawList.add(
              VideoPost(
                id: 'near_${item['id'] ?? DateTime.now().millisecondsSinceEpoch}',
                caption: item['tags'] ?? 'Regional Video · Near You',
                videoUrl: videosData['tiny']['url'],
                coverUrl: item['picture_id'] != null 
                    ? 'https://i.vimeocdn.com/video/${item['picture_id']}_640x360.jpg' 
                    : '',
                username: '@${item['user'] ?? 'local_creator'}',
              ),
            );
          }
        }
      }

      // Regla estricta de validación y deduplicación
      final cleanVideos = VideoDeduplicator.deduplicate(rawList);
      if (cleanVideos.isNotEmpty) {
        cleanVideos.shuffle(_random);
        return cleanVideos.map((v) => _applyStats(v)).toList();
      }
    } catch (_) {
      // Continuamos al Fallback garantizado
    }

    // Intento 3: Videos de respaldo garantizados (completamente distintos de Discover)
    final fallbacks = [
      VideoPost(
        id: 'near_fb_1',
        caption: 'Explorando las calles y cultura de la ciudad 🇲🇽 #NearYou',
        videoUrl: 'https://cdn.pixabay.com/video/2023/01/28/148311-793718132_tiny.mp4',
        coverUrl: 'https://i.vimeocdn.com/video/1601053070-7b560868f0c5a2c286ad91176b6d5f756044fa906e537c3da46aa79d2b8ceea4-d_640x360.jpg',
        username: '@mexico_urbano',
      ),
      VideoPost(
        id: 'near_fb_2',
        caption: 'Freestyle y talento callejero local #NearYou',
        videoUrl: 'https://cdn.pixabay.com/video/2023/10/22/186064-877284714_tiny.mp4',
        coverUrl: 'https://i.vimeocdn.com/video/1743603411-cf199be3a105ae3e35a146ebcfd76eb73b06385d564fa7e85c138b3aa1e4a191-d_640x360.jpg',
        username: '@talento_local',
      ),
      VideoPost(
        id: 'near_fb_3',
        caption: 'Atardecer en la plaza central y arquitectura colonial #NearYou',
        videoUrl: 'https://cdn.pixabay.com/video/2026/09/24/378500_tiny.mp4',
        coverUrl: 'https://cdn.pixabay.com/video/2026/09/24/378500_tiny.jpg',
        username: '@rutas_mexico',
      ),
      VideoPost(
        id: 'near_fb_4',
        caption: 'Festival de música y ambiente de noche #NearYou',
        videoUrl: 'https://cdn.pixabay.com/video/2026/09/24/378492_tiny.mp4',
        coverUrl: 'https://cdn.pixabay.com/video/2026/09/24/378492_tiny.jpg',
        username: '@noches_de_ciudad',
      ),
    ];
    return VideoDeduplicator.deduplicate(fallbacks).map((v) => _applyStats(v)).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  VideoPost _applyStats(VideoPost post) {
    // Si ya existe en LocalStorage, sobreescribe los valores random/ceros
    final localData = LocalStorageService.getVideoData(post.id);
    if (localData != null) {
      post.updateFromJson(localData);
      RapidApiDatasource._globalVideoCounter++;
      return post;
    }

    // Los primeros videos siempre en 0 vistas, 0 likes
    if (RapidApiDatasource._globalVideoCounter < 2) {
      post.likes = 0;
      post.views = 0;
      post.comments = 0;
    } else {
      // Aleatorios inferiores a 1500
      post.views = _random.nextInt(1500) + 100; // mínimo 100 views
      post.likes = _random.nextInt(1500);
      post.comments = _random.nextInt(500);
    }

    RapidApiDatasource._globalVideoCounter++;
    return post;
  }
}
