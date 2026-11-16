import 'movie_details.dart';

class SeriesDetails {
  SeriesDetails({
    required this.adult,
    required this.backdropPath,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.firstAirDate,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
  });

  final bool adult;
  final String backdropPath;
  final List<Genre> genres;
  final String homepage;
  final int id;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime firstAirDate;
  final String name;
  final double voteAverage;
  final int voteCount;

  factory SeriesDetails.fromJson(Map<String, dynamic> json) => SeriesDetails(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"] ?? '',
        genres: List<Genre>.from(
          (json["genres"] ?? []).map((x) => Genre.fromJson(x)),
        ),
        homepage: json["homepage"] ?? '',
        id: json["id"],
        originalLanguage: json["original_language"] ?? '',
        originalName: json["original_name"] ?? '',
        overview: json["overview"] ?? '',
        popularity: json["popularity"]?.toDouble() ?? 0,
        posterPath: json["poster_path"] ?? '',
        firstAirDate: json["first_air_date"] != null &&
                json["first_air_date"].toString().isNotEmpty
            ? (DateTime.tryParse(json["first_air_date"]) ?? DateTime.now())
            : DateTime.now(),
        name: json["name"] ?? 'No Title',
        voteAverage: json["vote_average"]?.toDouble() ?? 0,
        voteCount: json["vote_count"] ?? 0,
      );
}
