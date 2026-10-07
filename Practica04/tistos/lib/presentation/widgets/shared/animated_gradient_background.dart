import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tistos/config/helpers/logo_helper.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final SeasonTheme _theme = LogoHelper.getCurrentSeasonTheme();
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  List<Color> _shiftedColors(List<Color> colors, double t) {
    final n = colors.length;
    final pos = t * n;
    final idx = pos.floor();
    final frac = pos - idx;
    return List.generate(
      n,
      (i) => Color.lerp(
        colors[(i + idx) % n],
        colors[(i + idx + 1) % n],
        frac,
      )!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _theme.gradientColors;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;
        final angle = t * 2 * math.pi;

        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.first,
                gradient: LinearGradient(
                  begin: Alignment(math.cos(angle), math.sin(angle)),
                  end: Alignment(-math.cos(angle), -math.sin(angle)),
                  colors: _shiftedColors(colors, t),
                ),
              ),
            ),
            for (int i = 0; i < 3; i++)
              _GlowBlob(
                color: colors[(i + 1) % colors.length],
                alignment: Alignment(
                  math.sin(angle + i * 2.1) * 0.9,
                  math.cos(angle * (i.isEven ? 1 : -1) + i * 1.3) * 0.8,
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [Color(0x8C000000), Color(0xCC000000)], // Un poco más oscuro para que no oculte el reloj de arena
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final Alignment alignment;

  const _GlowBlob({required this.color, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 360,
        height: 360,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
