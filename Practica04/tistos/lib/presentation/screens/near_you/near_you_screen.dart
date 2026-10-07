import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/providers/feed_provider.dart';
import 'package:tistos/presentation/widgets/shared/video_scrollable_view.dart';

class NearYouScreen extends StatelessWidget {
  /// true cuando esta sección es la que se está mostrando
  final bool isActive;

  const NearYouScreen({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedProvider>().feed(FeedSection.nearYou);

    return VideoScrollableView(
      // Al refrescar cambia la key y se reconstruye todo desde el video 1
      key: ValueKey('near_you_${feedState.version}'),
      videos: feedState.videos,
      isActive: isActive,
    );
  }
}

