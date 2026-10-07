

class VideoPost {

  final String caption;
  final String videoUrl;
  final int likes;
  final int views;

  /// Imagen de portada (opcional). Se muestra mientras carga el video.
  final String? coverUrl;

  VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.coverUrl,
  });

}
