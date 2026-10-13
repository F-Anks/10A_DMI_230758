import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/providers/feed_provider.dart';
import 'package:tistos/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  /// true cuando esta sección es la que se está mostrando
  final bool isActive;

  const DiscoverScreen({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedProvider>().feed(FeedSection.discover);

    return VideoScrollableView(
      // Al refrescar cambia la key y se reconstruye todo desde el video 1
      key: ValueKey('discover_${feedState.version}'),
      videos: feedState.videos,
      isActive: isActive,
      onRefresh: () => context.read<FeedProvider>().refresh(FeedSection.discover),
    );
  }
}

