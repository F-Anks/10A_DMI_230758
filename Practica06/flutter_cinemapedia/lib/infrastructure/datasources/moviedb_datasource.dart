import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/infrastructure/mappers/mappers.dart';
import 'package:cinemapedia/infrastructure/models/models.dart';

class MoviedbDatasource extends MoviesDatasource {
  /// Código de idioma para TMDB (ej. 'es-MX', 'en-US', 'de-DE', 'zh-CN', 'ar-EG').
  final String language;

  MoviedbDatasource({this.language = 'es-MX'});

  late final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': language,
    },
  ));

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final movieDBResponse = MovieDbResponse.fromJson(json);

    return movieDBResponse.results
        .where((moviedb) => moviedb.posterPath != 'no-poster')
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();
  }

  List<Movie> _jsonToSeries(Map<String, dynamic> json) {
    final seriesResponse = SeriesDbResponse.fromJson(json);

    return seriesResponse.results
        .where((series) => series.posterPath.isNotEmpty)
        .map((series) => SeriesMapper.seriesDBToEntity(series))
        .toList();
  }

  String get _languageCode => language.split('-').first;

  bool _needsTitleFallback(Movie item) =>
      item.title == item.originalTitle &&
      item.originalLanguage != _languageCode &&
      item.originalLanguage != 'en';

  bool _needsOverviewFallback(Movie item) => item.overview.trim().isEmpty;

  bool _needsFallback(Movie item) =>
      _needsTitleFallback(item) || _needsOverviewFallback(item);

  Movie _mergeEnglish(Movie item, Movie en) => Movie(
        adult: item.adult,
        backdropPath: item.backdropPath,
        genreIds: item.genreIds,
        id: item.id,
        originalLanguage: item.originalLanguage,
        originalTitle: item.originalTitle,
        overview: (_needsOverviewFallback(item) && en.overview.trim().isNotEmpty)
            ? en.overview
            : item.overview,
        popularity: item.popularity,
        posterPath: item.posterPath,
        releaseDate: item.releaseDate,
        title: (_needsTitleFallback(item) && en.title.trim().isNotEmpty)
            ? en.title
            : item.title,
        video: item.video,
        voteAverage: item.voteAverage,
        voteCount: item.voteCount,
      );

  /// Si un elemento no tiene traducción en el idioma seleccionado, se usa `en-US`
  /// como respaldo para título y sinopsis.
  Future<List<Movie>> _withEnglishFallback(
    List<Movie> items,
    String path, {
    Map<String, dynamic>? params,
    bool isSeries = false,
  }) async {
    if (language.startsWith('en') || !items.any(_needsFallback)) return items;

    try {
      final response = await dio.get(
        path,
        queryParameters: {
          ...?params,
          'language': 'en-US',
        },
      );

      final parsed =
          isSeries ? _jsonToSeries(response.data) : _jsonToMovies(response.data);
      final englishById = {for (final m in parsed) m.id: m};

      return items.map((item) {
        final en = englishById[item.id];
        if (en == null || !_needsFallback(item)) return item;
        return _mergeEnglish(item, en);
      }).toList();
    } catch (_) {
      return items;
    }
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    const path = '/movie/now_playing';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToMovies(response.data), path,
        params: params);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    const path = '/movie/popular';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToMovies(response.data), path,
        params: params);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    const path = '/movie/top_rated';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToMovies(response.data), path,
        params: params);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    const path = '/movie/upcoming';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToMovies(response.data), path,
        params: params);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final numericId = int.tryParse(id);
    if (numericId != null && MediaId.isSeries(numericId)) {
      return _getSeriesById(MediaId.tmdbId(numericId));
    }

    final response = await dio.get('/movie/$id');
    if (response.statusCode != 200) {
      throw Exception('Movie with id: $id not found');
    }

    final movie =
        MovieMapper.movieDetailsToEntity(MovieDetails.fromJson(response.data));

    if (!language.startsWith('en') && _needsFallback(movie)) {
      try {
        final enResponse =
            await dio.get('/movie/$id', queryParameters: {'language': 'en-US'});
        final english = MovieMapper.movieDetailsToEntity(
          MovieDetails.fromJson(enResponse.data),
        );
        return _mergeEnglish(movie, english);
      } catch (_) {
        return movie;
      }
    }

    return movie;
  }

  Future<Movie> _getSeriesById(int tmdbId) async {
    final response = await dio.get('/tv/$tmdbId');
    if (response.statusCode != 200) {
      throw Exception('Series with id: $tmdbId not found');
    }

    final series =
        SeriesMapper.seriesDetailsToEntity(SeriesDetails.fromJson(response.data));

    if (!language.startsWith('en') && _needsFallback(series)) {
      try {
        final enResponse = await dio
            .get('/tv/$tmdbId', queryParameters: {'language': 'en-US'});
        final english = SeriesMapper.seriesDetailsToEntity(
          SeriesDetails.fromJson(enResponse.data),
        );
        return _mergeEnglish(series, english);
      } catch (_) {
        return series;
      }
    }

    return series;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    const path = '/search/movie';
    final params = {'query': query};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToMovies(response.data), path,
        params: params);
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    if (MediaId.isSeries(movieId)) {
      final path = '/tv/${MediaId.tmdbId(movieId)}/similar';
      final response = await dio.get(path);
      return _withEnglishFallback(_jsonToSeries(response.data), path,
          isSeries: true);
    }

    final path = '/movie/$movieId/similar';
    final response = await dio.get(path);
    return _withEnglishFallback(_jsonToMovies(response.data), path);
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get(
      '/${MediaId.kind(movieId)}/${MediaId.tmdbId(movieId)}/videos',
      queryParameters: {
        'include_video_language': '$_languageCode,en,null',
      },
    );
    final moviedbVideosResponse =
        MoviedbVideosResponse.fromJson(response.data);
    final videos = <Video>[];

    for (final moviedbVideo in moviedbVideosResponse.results) {
      if (moviedbVideo.site == 'YouTube') {
        videos.add(VideoMapper.moviedbVideoToEntity(moviedbVideo));
      }
    }

    return videos;
  }

  @override
  Future<List<Movie>> getOnTheAirSeries({int page = 1}) async {
    const path = '/tv/on_the_air';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToSeries(response.data), path,
        params: params, isSeries: true);
  }

  @override
  Future<List<Movie>> getAiringTodaySeries({int page = 1}) async {
    const path = '/tv/airing_today';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToSeries(response.data), path,
        params: params, isSeries: true);
  }

  @override
  Future<List<Movie>> getPopularSeries({int page = 1}) async {
    const path = '/tv/popular';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToSeries(response.data), path,
        params: params, isSeries: true);
  }

  @override
  Future<List<Movie>> getTopRatedSeries({int page = 1}) async {
    const path = '/tv/top_rated';
    final params = {'page': page};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToSeries(response.data), path,
        params: params, isSeries: true);
  }

  @override
  Future<List<Movie>> searchSeries(String query) async {
    if (query.trim().isEmpty) return [];

    const path = '/search/tv';
    final params = {'query': query};
    final response = await dio.get(path, queryParameters: params);

    return _withEnglishFallback(_jsonToSeries(response.data), path,
        params: params, isSeries: true);
  }
}
