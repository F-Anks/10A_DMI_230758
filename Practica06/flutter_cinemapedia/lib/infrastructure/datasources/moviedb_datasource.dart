import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/entities.dart';
import 'package:cinemapedia/infrastructure/mappers/mappers.dart';
import 'package:cinemapedia/infrastructure/models/models.dart';

class MoviedbDatasource extends MoviesDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': 'es-MX',
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

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get('/movie/now_playing', queryParameters: {
      'page': page,
    });

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await dio.get('/movie/popular', queryParameters: {
      'page': page,
    });

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response = await dio.get('/movie/top_rated', queryParameters: {
      'page': page,
    });

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await dio.get('/movie/upcoming', queryParameters: {
      'page': page,
    });

    return _jsonToMovies(response.data);
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

    final movieDetails = MovieDetails.fromJson(response.data);
    return MovieMapper.movieDetailsToEntity(movieDetails);
  }

  Future<Movie> _getSeriesById(int tmdbId) async {
    final response = await dio.get('/tv/$tmdbId');
    if (response.statusCode != 200) {
      throw Exception('Series with id: $tmdbId not found');
    }

    final seriesDetails = SeriesDetails.fromJson(response.data);
    return SeriesMapper.seriesDetailsToEntity(seriesDetails);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await dio.get('/search/movie', queryParameters: {
      'query': query,
    });

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    if (MediaId.isSeries(movieId)) {
      final response = await dio.get('/tv/${MediaId.tmdbId(movieId)}/similar');
      return _jsonToSeries(response.data);
    }

    final response = await dio.get('/movie/$movieId/similar');
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get(
      '/${MediaId.kind(movieId)}/${MediaId.tmdbId(movieId)}/videos',
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
    final response = await dio.get('/tv/on_the_air', queryParameters: {
      'page': page,
    });

    return _jsonToSeries(response.data);
  }

  @override
  Future<List<Movie>> getAiringTodaySeries({int page = 1}) async {
    final response = await dio.get('/tv/airing_today', queryParameters: {
      'page': page,
    });

    return _jsonToSeries(response.data);
  }

  @override
  Future<List<Movie>> getPopularSeries({int page = 1}) async {
    final response = await dio.get('/tv/popular', queryParameters: {
      'page': page,
    });

    return _jsonToSeries(response.data);
  }

  @override
  Future<List<Movie>> getTopRatedSeries({int page = 1}) async {
    final response = await dio.get('/tv/top_rated', queryParameters: {
      'page': page,
    });

    return _jsonToSeries(response.data);
  }

  @override
  Future<List<Movie>> searchSeries(String query) async {
    if (query.trim().isEmpty) return [];

    final response = await dio.get('/search/tv', queryParameters: {
      'query': query,
    });

    return _jsonToSeries(response.data);
  }
}
