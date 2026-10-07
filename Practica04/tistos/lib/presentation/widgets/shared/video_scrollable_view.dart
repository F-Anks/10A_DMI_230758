import 'package:flutter/material.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  
  final List<VideoPost> videos;

  /// Indica si la sección que contiene esta lista está visible.
  /// Si es false, ningún video de la lista se reproduce.
  final bool isActive;
  
  const VideoScrollableView({
    super.key, 
    required this.videos,
    this.isActive = true,
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;

  // Mantiene viva la sección al deslizar entre pestañas
  // (conserva la posición en la que se quedó el usuario)
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final VideoPost videoPost = widget.videos[index];

        // Solo la sección visible crea reproductores. Los teléfonos tienen un
        // número limitado de decodificadores de video por hardware; si se
        // agotan, el video se queda en negro y solo se escucha el audio.
        if (!widget.isActive) {
          return VideoPlaceholder(coverUrl: videoPost.coverUrl);
        }

        return SizedBox.expand(
          child: FullScreenPlayer(
            // Key única: evita que un reproductor viejo se reutilice
            key: ValueKey('$index-${videoPost.videoUrl}'),
            videoPost: videoPost,
            // Solo se reproduce el video actual de la lista
            isActive: index == _currentIndex,
          ),
        );
      },
    );
  }
}