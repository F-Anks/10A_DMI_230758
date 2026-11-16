/// Las películas y las series de The Movie DB pueden tener el mismo ID numérico.
/// Como comparten pantalla de detalle, rutas y almacenamiento local, las series
/// se representan internamente con ID negativo (-id de TMDB).
class MediaId {
  static bool isSeries(int id) => id < 0;

  /// ID interno para series dentro de la aplicación.
  static int fromSeries(int tmdbId) => -tmdbId.abs();

  /// ID real de The Movie DB (siempre positivo).
  static int tmdbId(int id) => id.abs();

  /// Segmento de ruta en la API de TMDB ('tv' o 'movie').
  static String kind(int id) => isSeries(id) ? 'tv' : 'movie';
}
