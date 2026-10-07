import 'dart:math';

import 'package:dio/dio.dart';
import 'package:tistos/config/constants/environment.dart';
import 'package:tistos/domain/datasources/video_posts_datasource.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/shared/data/local_video_post.dart';

/// Datasource que obtiene videos de RapidAPI.
///
/// - For You  -> TikTok (feed US)
/// - Near You -> Instagram Reels; si no hay suscripción, TikTok (feed MX)
/// - Discover -> YouTube Shorts; si no hay suscripción, TikTok (búsqueda)
///
/// Cada sección SIEMPRE devuelve al menos [minVideos] videos. Si la API falla,
/// se completa con los videos locales de Drive.
class RapidApiDatasource implements VideoPostDatasource {
  static const int minVideos = 10;

  static const String _tiktokHost = 'tiktok-video-no-watermark2.p.rapidapi.com';
  static const String _youtubeHost = 'yt-api.p.rapidapi.com';
  static const String _instagramHost = 'instagram-scraper-api2.p.rapidapi.com';

  static const List<String> _discoverKeywords = [
    'funny', 'viral', 'satisfying', 'dance', 'cooking', 'travel',
    'cats', 'dogs', 'football', 'gaming', 'tech', 'art', 'music', 'comedy',
  ];

  final Dio dio;
  final Random _random = Random();

  RapidApiDatasource()
      : dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'x-rapidapi-key': Environment.rapidApiKey},
        ));

  bool get _hasKey => Environment.rapidApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // For You
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getTikTokVideos() async {
    final videos = await _fetchTikTokFeed(region: 'US');
    return _ensureMinimum(videos);
  }

  // ---------------------------------------------------------------------------
  // Discover
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getYouTubeShorts() async {
    final videos = await _tryYouTube();
    if (videos.length < minVideos) {
      videos.addAll(await _fetchTikTokSearch());
    }
    return _ensureMinimum(videos);
  }

  // ---------------------------------------------------------------------------
  // Near You
  // ---------------------------------------------------------------------------
  @override
  Future<List<VideoPost>> getInstagramReels() async {
    final videos = await _tryInstagram();
    if (videos.length < minVideos) {
      videos.addAll(await _fetchTikTokFeed(region: 'MX'));
    }
    return _ensureMinimum(videos);
  }

  // ---------------------------------------------------------------------------
  // TikTok
  // ---------------------------------------------------------------------------
  Future<List<VideoPost>> _fetchTikTokFeed({required String region}) async {
    if (!_hasKey) return [];
    final Map<String, VideoPost> result = {};

    // El feed es aleatorio: se repite hasta juntar suficientes videos válidos
    for (int attempt = 0; attempt < 3 && result.length < minVideos; attempt++) {
      final data = await _tiktokGet('/feed/list', {'region': region, 'count': 20});
      final list = data?['data'];
      if (list is List) _parseTikTokItems(list, result);
    }
    return result.values.toList();
  }

  Future<List<VideoPost>> _fetchTikTokSearch() async {
    if (!_hasKey) return [];
    final Map<String, VideoPost> result = {};
    final keywords = [..._discoverKeywords]..shuffle(_random);

    for (final keyword in keywords.take(3)) {
      if (result.length >= minVideos) break;
      final data = await _tiktokGet('/feed/search', {
        'keywords': keyword,
        'count': 20,
        'cursor': _random.nextInt(3) * 20, // página aleatoria = videos distintos
        'region': 'US',
      });
      final inner = data?['data'];
      final list = inner is Map ? inner['videos'] : null;
      if (list is List) _parseTikTokItems(list, result);
    }
    return result.values.toList();
  }

  /// GET a la API de TikTok. Nunca lanza excepción; reintenta si hay 429.
  Future<Map<String, dynamic>?> _tiktokGet(
      String path, Map<String, dynamic> params) async {
    for (int retry = 0; retry < 3; retry++) {
      try {
        final response = await dio.get(
          'https://$_tiktokHost$path',
          queryParameters: params,
          options: Options(headers: {'x-rapidapi-host': _tiktokHost}),
        );
        final body = response.data;
        if (body is Map<String, dynamic> && body['code'] == 0) return body;
        return null;
      } on DioException catch (e) {
        if (e.response?.statusCode == 429) {
          await Future.delayed(Duration(milliseconds: 1200 * (retry + 1)));
          continue;
        }
        return null;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Convierte la respuesta de TikTok en [VideoPost], descartando lo que NO es
  /// video: los posts de fotos (slideshow) traen en `play` un MP3 de música,
  /// por eso antes había "videos" que solo reproducían audio.
  void _parseTikTokItems(List items, Map<String, VideoPost> into) {
    for (final item in items) {
      if (item is! Map) continue;

      final images = item['images'];
      if (images is List && images.isNotEmpty) continue; // slideshow
      if (item['is_ad'] == true) continue;

      final play = item['play'];
      if (play is! String || play.isEmpty) continue;
      if (play.contains('music') || play.contains('.mp3')) continue;

      final duration = item['duration'];
      if (duration is num && duration <= 0) continue;

      final id = (item['video_id'] ?? item['aweme_id'] ?? play).toString();
      final cover = item['cover'] ?? item['origin_cover'];

      into.putIfAbsent(
        id,
        () => VideoPost(
          caption: _cleanCaption(item['title']),
          videoUrl: play,
          coverUrl: cover is String && cover.isNotEmpty ? cover : null,
          likes: _toInt(item['digg_count']),
          views: _toInt(item['play_count']),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // YouTube / Instagram (solo funcionan si estás suscrito en RapidAPI)
  // ---------------------------------------------------------------------------
  Future<List<VideoPost>> _tryYouTube() async {
    if (!_hasKey) return [];
    try {
      final response = await dio.get(
        'https://$_youtubeHost/search',
        options: Options(headers: {'x-rapidapi-host': _youtubeHost}),
        queryParameters: {'query': 'shorts', 'type': 'shorts'},
      );
      final List<VideoPost> videos = [];
      final dataList = response.data is Map ? response.data['data'] : null;
      if (dataList is List) {
        for (final item in dataList) {
          if (item is Map && item['videoUrl'] is String) {
            videos.add(VideoPost(
              caption: item['title']?.toString() ?? 'YouTube Short',
              videoUrl: item['videoUrl'],
              likes: 250,
              views: _toInt(item['viewCount']),
            ));
          }
        }
      }
      return videos;
    } catch (_) {
      return [];
    }
  }

  Future<List<VideoPost>> _tryInstagram() async {
    if (!_hasKey) return [];
    try {
      final response = await dio.get(
        'https://$_instagramHost/v1/reels',
        options: Options(headers: {'x-rapidapi-host': _instagramHost}),
        queryParameters: {'username_or_id_or_url': 'natgeo'},
      );
      final List<VideoPost> videos = [];
      final data = response.data is Map ? response.data['data'] : null;
      final items = data is Map ? data['items'] : null;
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          final versions = item['video_versions'];
          if (versions is List && versions.isNotEmpty && versions[0]['url'] is String) {
            videos.add(VideoPost(
              caption: item['caption']?['text']?.toString() ?? 'Reel',
              videoUrl: versions[0]['url'],
              likes: _toInt(item['like_count']),
              views: _toInt(item['play_count']),
            ));
          }
        }
      }
      return videos;
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Garantiza al menos [minVideos] videos completando con los de Drive.
  List<VideoPost> _ensureMinimum(List<VideoPost> videos) {
    if (videos.length >= minVideos) return videos;

    final backup = videoPosts
        .map((v) => VideoPost(
              caption: v['name'] as String,
              videoUrl: v['videoUrl'] as String,
              likes: v['likes'] as int,
              views: v['views'] as int,
            ))
        .toList()
      ..shuffle(_random);

    final result = [...videos];
    int i = 0;
    while (result.length < minVideos) {
      result.add(backup[i % backup.length]);
      i++;
    }
    return result;
  }

  String _cleanCaption(dynamic title) {
    final text = title?.toString().trim() ?? '';
    return text.isEmpty ? 'TikTok' : text;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
