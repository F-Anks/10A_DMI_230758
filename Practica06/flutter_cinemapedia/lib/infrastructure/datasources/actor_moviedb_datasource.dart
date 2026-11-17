import 'package:dio/dio.dart';

import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';

class ActorMovieDbDatasource extends ActorsDatasource {
  final String language;

  ActorMovieDbDatasource({this.language = 'es-MX'});

  late final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': Environment.theMovieDbKey,
      'language': language,
    },
  ));

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async {
    final numericId = int.tryParse(movieId);
    final path = (numericId != null && MediaId.isSeries(numericId))
        ? '/tv/${MediaId.tmdbId(numericId)}/credits'
        : '/movie/$movieId/credits';

    final response = await dio.get(path);
    final castResponse = CreditsResponse.fromJson(response.data);

    return castResponse.cast
        .map((cast) => ActorMapper.castToEntity(cast))
        .toList();
  }
}
