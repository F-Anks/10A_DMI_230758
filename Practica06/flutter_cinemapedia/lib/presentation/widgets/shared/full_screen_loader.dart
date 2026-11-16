import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class FullScreenLoader extends ConsumerWidget {
  const FullScreenLoader({super.key});

  Stream<String> getLoadingMessages(List<String> messages) {
    return Stream.periodic(const Duration(milliseconds: 1200), (step) {
      return messages[step];
    }).take(messages.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppStrings.of(context);
    final isSeries = ref.watch(catalogTypeProvider) == CatalogType.series;
    final messages =
        isSeries ? t.loaderMessagesSeries : t.loaderMessagesMovies;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.pleaseWait),
          const SizedBox(height: 10),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: getLoadingMessages(messages),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text(t.loading);

              return Text(snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}
