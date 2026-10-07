import 'package:flutter/foundation.dart';
import 'package:tistos/domain/entities/video_post.dart';

/// Estado inmutable de una sección del feed.
///
/// Al ser inmutable, cada cambio crea una instancia nueva y los widgets que
/// usan `context.select` solo se reconstruyen si SU sección cambió.
@immutable
class FeedState {
  const FeedState({
    this.videos = const [],
    this.version = 0,
    this.isRefreshing = false,
  });

  final List<VideoPost> videos;

  /// Aumenta en cada refresh. Se usa como Key para reconstruir la lista
  /// completa (incluido el video que se estaba reproduciendo).
  final int version;

  final bool isRefreshing;

  FeedState copyWith({
    List<VideoPost>? videos,
    int? version,
    bool? isRefreshing,
  }) {
    return FeedState(
      videos: videos ?? this.videos,
      version: version ?? this.version,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
