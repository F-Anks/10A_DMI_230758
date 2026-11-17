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
  late final SwiperController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = SwiperController();
  }

  @override
  void didUpdateWidget(covariant MoviesSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movies.isNotEmpty && _currentIndex >= widget.movies.length) {
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goPrevious() {
    if (widget.movies.length <= 1) return;
    if (_currentIndex <= 0) {
      _controller.move(widget.movies.length - 1);
    } else {
      _controller.previous();
    }
  }

  void _goNext() {
    if (widget.movies.length <= 1) return;
    if (_currentIndex >= widget.movies.length - 1) {
      _controller.move(0);
    } else {
      _controller.next();
    }
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
            Swiper(
              controller: _controller,
              loop: false,
              viewportFraction: 0.8,
              scale: 0.9,
              autoplay: hasMultiple,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: DecoratedBox(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => context.push('/home/0/movie/${movie.id}'),
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: const AssetImage('assets/loaders/bottle-loader.gif'),
              image: NetworkImage(movie.backdropPath),
            ),
          ),
        ),
      ),
    );
  }
}
