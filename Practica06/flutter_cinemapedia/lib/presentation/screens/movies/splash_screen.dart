import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/helpers/dynamic_icon_helper.dart';
import 'package:cinemapedia/config/helpers/logo_helper.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SeasonTheme _theme = LogoHelper.getCurrentSeasonTheme();
  final AudioPlayer _player = AudioPlayer();

  late final AnimationController _bgController;
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    DynamicIconHelper.syncWithCurrentSeason();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _playSplashSound();
    _navigateToHome();
  }

  Future<void> _playSplashSound() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource(_theme.soundPath), volume: 1.0);
    } catch (e) {
      debugPrint('No se pudo reproducir el sonido del splash: $e');
    }
  }

  Future<void> _fadeOutSound() async {
    try {
      for (double v = 0.8; v >= 0; v -= 0.2) {
        if (!mounted) break;
        await _player.setVolume(v.clamp(0.0, 1.0));
        await Future.delayed(const Duration(milliseconds: 35));
      }
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _navigateToHome() async {
    // Duración exacta de 5 segundos para el splash
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    await _fadeOutSound();
    if (!mounted) return;

    context.go('/home/0');
  }

  @override
  void dispose() {
    _player.dispose();
    _bgController.dispose();
    _introController.dispose();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.first,
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            final t = _bgController.value;
            final angle = t * 2 * math.pi;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Gradiente animado con los colores del icono de la temporada
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(math.cos(angle), math.sin(angle)),
                      end: Alignment(-math.cos(angle), -math.sin(angle)),
                      colors: _shiftedColors(colors, t),
                    ),
                  ),
                ),

                // Efecto aurora con manchas de luz en movimiento
                for (int i = 0; i < 3; i++)
                  _GlowBlob(
                    color: colors[(i + 1) % colors.length],
                    alignment: Alignment(
                      math.sin(angle + i * 2.1) * 0.9,
                      math.cos(angle * (i.isEven ? 1 : -1) + i * 1.3) * 0.8,
                    ),
                  ),

                // Viñeta radial sutil para dar profundidad al logo
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.2,
                      colors: [Color(0x00000000), Color(0x8C000000)],
                    ),
                  ),
                ),

                child!,
              ],
            );
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _theme.isDualLogo
                        ? _DualAnimatedLogos(
                            theme: _theme,
                            pulse: _bgController,
                          )
                        : _AnimatedLogo(
                            logoPath: _theme.logoPath,
                            cropScale: _theme.cropScale,
                            glowColor: _theme.glowColor,
                            secondaryGlowColor: _theme.secondaryGlowColor,
                            pulse: _bgController,
                            size: 175,
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: AnimatedBuilder(
                      animation: _bgController,
                      builder: (context, child) {
                        final glow =
                            (math.sin(_bgController.value * 2 * math.pi) + 1) /
                                2;
                        return Text(
                          'CinePedia',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: _theme.glowColor
                                    .withAlpha((100 + 80 * glow).round()),
                                blurRadius: 16 + 10 * glow,
                              ),
                              const Shadow(
                                color: Color(0x88000000),
                                blurRadius: 18,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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

/// Logo individual recortado con animación de flotación y resplandor pulsante
class _AnimatedLogo extends StatelessWidget {
  final String logoPath;
  final double cropScale;
  final Color glowColor;
  final Color secondaryGlowColor;
  final Animation<double> pulse;
  final double size;
  final double phaseOffset;

  const _AnimatedLogo({
    required this.logoPath,
    required this.cropScale,
    required this.glowColor,
    required this.secondaryGlowColor,
    required this.pulse,
    this.size = 175,
    this.phaseOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.22;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final angle = (pulse.value + phaseOffset) * 2 * math.pi;
        final glow = (math.sin(angle) + 1) / 2;
        final floatY = math.sin(angle) * 6.0;
        final tilt = math.cos(angle) * 0.025;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.rotate(
            angle: tilt,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withAlpha((110 + 90 * glow).round()),
                    blurRadius: 28 + 24 * glow,
                    spreadRadius: 2 + 6 * glow,
                  ),
                  BoxShadow(
                    color: secondaryGlowColor
                        .withAlpha((70 + 70 * (1 - glow)).round()),
                    blurRadius: 18 + 16 * (1 - glow),
                    spreadRadius: 1 + 3 * (1 - glow),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Transform.scale(
          scale: cropScale,
          child: Image.asset(
            logoPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Muestra ambos logos (Día Mundial del Cine + San Valentín) cuando coinciden el 14 de febrero
class _DualAnimatedLogos extends StatelessWidget {
  final SeasonTheme theme;
  final Animation<double> pulse;

  const _DualAnimatedLogos({
    required this.theme,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedLogo(
          logoPath: theme.logoPath,
          cropScale: theme.cropScale,
          glowColor: theme.glowColor,
          secondaryGlowColor: theme.secondaryGlowColor,
          pulse: pulse,
          size: 145,
          phaseOffset: 0.0,
        ),
        const SizedBox(width: 20),
        _AnimatedLogo(
          logoPath: theme.secondaryLogoPath!,
          cropScale: theme.secondaryCropScale,
          glowColor: theme.secondaryGlowColor,
          secondaryGlowColor: theme.glowColor,
          pulse: pulse,
          size: 145,
          phaseOffset: 0.5,
        ),
      ],
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
            colors: [color.withAlpha(155), color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}

