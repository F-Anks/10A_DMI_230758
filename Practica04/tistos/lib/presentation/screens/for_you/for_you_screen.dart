import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/providers/discover_provider.dart';
import 'package:tistos/presentation/widgets/shared/video_scrollable_view.dart';

class ForYouScreen extends StatelessWidget {
  /// true cuando esta sección es la que se está mostrando
  final bool isActive;

  const ForYouScreen({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();

    return VideoScrollableView(
      videos: discoverProvider.forYouVideos,
      isActive: isActive,
    );
  }
}
