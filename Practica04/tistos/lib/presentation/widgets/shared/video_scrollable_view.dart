import 'package:flutter/material.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<VideoPost> videos;

  /// Indica si la sección que contiene esta lista está visible.
  /// Si es false, ningún video de la lista se reproduce.
  final bool isActive;
  final Future<void> Function()? onRefresh;

  const VideoScrollableView({
    super.key,
    required this.videos,
    this.isActive = true,
    this.onRefresh,
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

    Widget pageView = PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final VideoPost videoPost = widget.videos[index];

        if (!widget.isActive) {
          return VideoPlaceholder(coverUrl: videoPost.coverUrl);
        }

        return SizedBox.expand(
          child: FullScreenPlayer(
            key: ValueKey('$index-${videoPost.videoUrl}'),
            videoPost: videoPost,
            isActive: index == _currentIndex,
          ),
        );
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        strokeWidth: 3,
        color: Colors.white,
        backgroundColor: Colors.black87,
        child: pageView,
      );
    }
    
    return pageView;
  }
}
