class SeriesDbResponse {
  SeriesDbResponse({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  final int page;
  final List<SeriesMovieDB> results;
  final int totalPages;
  final int totalResults;

  factory SeriesDbResponse.fromJson(Map<String, dynamic> json) =>
      SeriesDbResponse(
        page: json["page"] ?? 1,
        results: List<SeriesMovieDB>.from(
          (json["results"] ?? []).map((x) => SeriesMovieDB.fromJson(x)),
        ),
        totalPages: json["total_pages"] ?? 1,
        totalResults: json["total_results"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class SeriesMovieDB {
  SeriesMovieDB({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
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
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String posterPath;
  final DateTime? firstAirDate;
  final String name;
  final double voteAverage;
  final int voteCount;

  factory SeriesMovieDB.fromJson(Map<String, dynamic> json) => SeriesMovieDB(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"] ?? '',
        genreIds: List<int>.from((json["genre_ids"] ?? []).map((x) => x)),
        id: json["id"],
        originalLanguage: json["original_language"] ?? '',
        originalName: json["original_name"] ?? '',
        overview: json["overview"] ?? '',
        popularity: json["popularity"]?.toDouble() ?? 0,
        posterPath: json["poster_path"] ?? '',
        firstAirDate: json["first_air_date"] != null &&
                json["first_air_date"].toString().isNotEmpty
            ? DateTime.tryParse(json["first_air_date"])
            : null,
        name: json["name"] ?? 'No Title',
        voteAverage: json["vote_average"]?.toDouble() ?? 0,
        voteCount: json["vote_count"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "original_language": originalLanguage,
        "original_name": originalName,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "first_air_date": firstAirDate != null
            ? "${firstAirDate!.year.toString().padLeft(4, '0')}-${firstAirDate!.month.toString().padLeft(2, '0')}-${firstAirDate!.day.toString().padLeft(2, '0')}"
            : null,
        "name": name,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}
