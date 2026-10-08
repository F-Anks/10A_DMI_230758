

class VideoPost {
  final String id;
  final String caption;
  final String videoUrl;
  int likes;
  int views;
  int comments;
  bool isLiked;
  final String username;
  final String? coverUrl;

  VideoPost({
    required this.id,
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.views = 0,
    this.comments = 0,
    this.isLiked = false,
    this.username = '@user',
    this.coverUrl,
  });

  // Método para convertir de/a JSON para el local storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'caption': caption,
    'videoUrl': videoUrl,
    'likes': likes,
    'views': views,
    'comments': comments,
    'isLiked': isLiked,
    'username': username,
    'coverUrl': coverUrl,
  };

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    return VideoPost(
      id: json['id'] ?? '',
      caption: json['caption'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      username: json['username'] ?? '@user',
      coverUrl: json['coverUrl'],
    );
  }

  void updateFromJson(Map<String, dynamic> json) {
    likes = json['likes'] ?? likes;
    views = json['views'] ?? views;
    comments = json['comments'] ?? comments;
    isLiked = json['isLiked'] ?? isLiked;
  }
}
