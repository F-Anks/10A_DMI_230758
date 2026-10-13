import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/providers/feed_provider.dart';
import 'package:tistos/presentation/widgets/shared/video_scrollable_view.dart';

class FavoritesScreen extends StatelessWidget {
  final bool isActive;

  const FavoritesScreen({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedProvider>().feed(FeedSection.favorites);

    if (feedState.videos.isEmpty && !feedState.isRefreshing) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Aún no tienes videos favoritos',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return VideoScrollableView(
      key: ValueKey('favorites_${feedState.version}'),
      videos: feedState.videos,
      isActive: isActive,
      onRefresh: () => context.read<FeedProvider>().refresh(FeedSection.favorites),
    );
  }
}
