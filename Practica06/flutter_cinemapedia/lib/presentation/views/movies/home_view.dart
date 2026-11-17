import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    _loadFirstPages();
  }

  void _loadFirstPages() {
    final isSeries = ref.read(catalogTypeProvider) == CatalogType.series;
    final providers = isSeries
        ? [
            onTheAirSeriesProvider,
            airingTodaySeriesProvider,
            popularSeriesProvider,
            topRatedSeriesProvider,
          ]
        : [
            nowPlayingMoviesProvider,
            upcomingMoviesProvider,
            popularMoviesProvider,
            topRatedMoviesProvider,
          ];

    for (final provider in providers) {
      if (ref.read(provider).isEmpty) {
        ref.read(provider.notifier).loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(languageProvider, (previous, next) {
      if (previous == next) return;
      Future.microtask(() {
        if (mounted) _loadFirstPages();
      });
    });

    ref.listen(catalogTypeProvider, (previous, next) {
      if (previous == next) return;
      Future.microtask(() {
        if (mounted) _loadFirstPages();
      });
    });

    final t = AppStrings.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isSeries = ref.watch(catalogTypeProvider) == CatalogType.series;

    final initialLoading = ref.watch(initialLoadingProvider);
    if (initialLoading) return const FullScreenLoader();

    final firstProvider =
        isSeries ? onTheAirSeriesProvider : nowPlayingMoviesProvider;
    final secondProvider =
        isSeries ? airingTodaySeriesProvider : upcomingMoviesProvider;
    final thirdProvider =
        isSeries ? topRatedSeriesProvider : topRatedMoviesProvider;

    final slideShowMovies = ref.watch(
      isSeries ? seriesSlideshowProvider : moviesSlideshowProvider,
    );
    final firstMovies = ref.watch(firstProvider);
    final secondMovies = ref.watch(secondProvider);
    final thirdMovies = ref.watch(thirdProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: CustomAppbar(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Column(
                children: [
                  MoviesSlideshow(
                    key: ValueKey('slideshow-$isSeries'),
                    movies: slideShowMovies,
                  ),
                  MovieHorizontalListview(
                    key: ValueKey('first-$isSeries'),
                    movies: firstMovies,
                    title: isSeries ? t.seriesOnAir : t.nowPlaying,
                    subTitle: HumanFormats.today(languageCode),
                    loadNextPage: () =>
                        ref.read(firstProvider.notifier).loadNextPage(),
                  ),
                  MovieHorizontalListview(
                    key: ValueKey('second-$isSeries'),
                    movies: secondMovies,
                    title: isSeries ? t.airingToday : t.upcoming,
                    subTitle: isSeries ? t.airingTodaySub : t.upcomingSub,
                    loadNextPage: () =>
                        ref.read(secondProvider.notifier).loadNextPage(),
                  ),
                  MovieHorizontalListview(
                    key: ValueKey('third-$isSeries'),
                    movies: thirdMovies,
                    title: t.topRated,
                    subTitle: t.topRatedSub,
                    loadNextPage: () =>
                        ref.read(thirdProvider.notifier).loadNextPage(),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
