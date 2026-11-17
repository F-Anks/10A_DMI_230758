import 'package:cinemapedia/config/helpers/media_id.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/series_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/series_moviedb.dart';

class SeriesMapper {
  static Movie seriesDBToEntity(SeriesMovieDB series) => Movie(
        adult: series.adult,
        backdropPath: (series.backdropPath != '')
            ? 'https://image.tmdb.org/t/p/w500${series.backdropPath}'
            : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
        genreIds: series.genreIds.map((e) => e.toString()).toList(),
        id: MediaId.fromSeries(series.id),
        originalLanguage: series.originalLanguage,
        originalTitle: series.originalName,
        overview: series.overview,
        popularity: series.popularity,
        posterPath: (series.posterPath != '')
            ? 'https://image.tmdb.org/t/p/w500${series.posterPath}'
            : 'https://www.movienewz.com/img/films/poster-holder.jpg',
        releaseDate: series.firstAirDate ?? DateTime.now(),
        title: series.name,
        video: false,
        voteAverage: series.voteAverage,
        voteCount: series.voteCount,
      );

  static Movie seriesDetailsToEntity(SeriesDetails series) => Movie(
        adult: series.adult,
        backdropPath: (series.backdropPath != '')
            ? 'https://image.tmdb.org/t/p/w500${series.backdropPath}'
            : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
        genreIds: series.genres.map((e) => e.name).toList(),
        id: MediaId.fromSeries(series.id),
        originalLanguage: series.originalLanguage,
        originalTitle: series.originalName,
        overview: series.overview,
        popularity: series.popularity,
        posterPath: (series.posterPath != '')
            ? 'https://image.tmdb.org/t/p/w500${series.posterPath}'
            : 'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg',
        releaseDate: series.firstAirDate,
        title: series.name,
        video: false,
        voteAverage: series.voteAverage,
        voteCount: series.voteCount,
      );
}
