import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/domain/entities/movie.dart';

class MoviesSlideshow extends StatefulWidget {
  final List<Movie> movies;

  const MoviesSlideshow({
    super.key,
    required this.movies,
  });

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  static const _autoplayInterval = Duration(seconds: 4);

  late final SwiperController _controller;
  Timer? _autoplayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = SwiperController();
    _restartAutoplay();
  }

  @override
  void didUpdateWidget(covariant MoviesSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movies.isNotEmpty && _currentIndex >= widget.movies.length) {
      _currentIndex = 0;
    }
    if (oldWidget.movies.length != widget.movies.length) {
      _restartAutoplay();
    }
  }

  @override
  void dispose() {
    _stopAutoplay();
    _controller.dispose();
    super.dispose();
  }

  void _stopAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
  }

  void _restartAutoplay() {
    _stopAutoplay();
    if (widget.movies.length <= 1) return;

    _autoplayTimer = Timer.periodic(_autoplayInterval, (_) {
      if (!mounted) return;
      _advanceNext();
    });
  }

  void _advanceNext() {
    if (widget.movies.length <= 1) return;
    if (_currentIndex >= widget.movies.length - 1) {
      _controller.move(0);
    } else {
      _controller.next();
    }
  }

  void _goPrevious() {
    if (widget.movies.length <= 1) return;
    if (_currentIndex <= 0) {
      _controller.move(widget.movies.length - 1);
    } else {
      _controller.previous();
    }
    _restartAutoplay();
  }

  void _goNext() {
    _advanceNext();
    _restartAutoplay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final hasMultiple = widget.movies.length > 1;

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification &&
                    notification.dragDetails != null) {
                  _stopAutoplay();
                } else if (notification is ScrollEndNotification) {
                  _restartAutoplay();
                }
                return false;
              },
              child: Swiper(
                controller: _controller,
                loop: false,
                viewportFraction: 0.8,
                scale: 0.9,
                autoplay: false,
                onIndexChanged: (index) => _currentIndex = index,
                pagination: SwiperPagination(
                  margin: const EdgeInsets.only(top: 0),
                  builder: DotSwiperPaginationBuilder(
                    activeColor: colors.primary,
                    color: colors.secondary,
                  ),
                ),
                itemCount: widget.movies.length,
                itemBuilder: (context, index) =>
                    _Slide(movie: widget.movies[index]),
              ),
            ),
            if (hasMultiple) ...[
              Positioned(
                left: 6,
                top: 0,
                bottom: 30,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _goPrevious,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 0,
                bottom: 30,
                child: Center(
                  child: _CarouselArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _goNext,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.72),
      shape: CircleBorder(
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 24,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final Movie movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black45,
          blurRadius: 10,
          offset: Offset(0, 10),
        ),
      ],
    );

    final overview = movie.overview.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => context.push('/home/0/movie/${movie.id}'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FadeInImage(
                  fit: BoxFit.cover,
                  placeholder:
                      const AssetImage('assets/loaders/bottle-loader.gif'),
                  image: NetworkImage(movie.backdropPath),
                  imageErrorBuilder: (context, _, __) => ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [
                        Colors.transparent,
                        Color(0xD9000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: _SlideRateBadge(voteAverage: movie.voteAverage),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                      ),
                      if (overview.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.2,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 3),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideRateBadge extends StatelessWidget {
  final double voteAverage;

  const _SlideRateBadge({required this.voteAverage});

  @override
  Widget build(BuildContext context) {
    final stars = (voteAverage / 2).clamp(0.0, 5.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              stars >= i + 0.75
                  ? Icons.star_rounded
                  : stars >= i + 0.25
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: 13.5,
              color: stars >= i + 0.25
                  ? Colors.amber.shade400
                  : Colors.white38,
            ),
          const SizedBox(width: 5),
          Text(
            voteAverage.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
