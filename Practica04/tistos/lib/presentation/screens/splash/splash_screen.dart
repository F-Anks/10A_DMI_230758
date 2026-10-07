import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tistos/config/helpers/logo_helper.dart';
import 'package:tistos/presentation/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Tema de la temporada actual (logo + colores) según la fecha
  late final SeasonTheme _theme = LogoHelper.getCurrentSeasonTheme();

  // Reproductor del sonido de la temporada
  final AudioPlayer _player = AudioPlayer();

  // Controla el movimiento continuo del gradiente
  late final AnimationController _bgController;

  // Controla la animación de entrada del logo y del texto
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
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

  /// Reproduce el sonido correspondiente a la temporada actual
  Future<void> _playSplashSound() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource(_theme.soundPath), volume: 1.0);
    } catch (e) {
      debugPrint('No se pudo reproducir el sonido del splash: $e');
    }
  }

  /// Baja el volumen gradualmente y detiene el sonido
  Future<void> _fadeOutSound() async {
    try {
      for (double v = 1.0; v > 0; v -= 0.1) {
        await _player.setVolume(v);
        await Future.delayed(const Duration(milliseconds: 40));
      }
      await _player.stop();
    } catch (_) {}
  }

  void _navigateToHome() async {
    // Esperar 3 segundos para el splash screen
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Apagar el sonido suavemente para que no se encime con los videos
    await _fadeOutSound();
    if (!mounted) return;

    // Navegar a la pantalla principal y eliminar el splash del historial
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _bgController.dispose();
    _introController.dispose();
    super.dispose();
  }

  /// Desplaza los colores de la paleta de forma continua para que "fluyan"
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
                // ===== Gradiente lineal que gira y cambia de color =====
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(math.cos(angle), math.sin(angle)),
                      end: Alignment(-math.cos(angle), -math.sin(angle)),
                      colors: _shiftedColors(colors, t),
                    ),
                  ),
                ),

                // ===== Manchas de luz que se mueven (efecto aurora) =====
                for (int i = 0; i < 3; i++)
                  _GlowBlob(
                    color: colors[(i + 1) % colors.length],
                    alignment: Alignment(
                      math.sin(angle + i * 2.1) * 0.9,
                      math.cos(angle * (i.isEven ? 1 : -1) + i * 1.3) * 0.8,
                    ),
                  ),

                // Velo oscuro sutil para dar profundidad y legibilidad
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
                // ===== Logo dinámico basado en la fecha =====
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _AnimatedLogo(
                      theme: _theme,
                      pulse: _bgController,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ===== Texto con la tipografía estilo Apple =====
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Text(
                      'TisTos',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x66000000),
                            blurRadius: 18,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
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

/// Logo recortado (sin el cuadro blanco del .jpg) con brillo pulsante
class _AnimatedLogo extends StatelessWidget {
  final SeasonTheme theme;
  final Animation<double> pulse;

  const _AnimatedLogo({required this.theme, required this.pulse});

  static const double _size = 160;
  static const double _radius = 38;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        // Brillo que "respira" suavemente
        final glow = (math.sin(pulse.value * 2 * math.pi) + 1) / 2;
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: theme.glowColor.withAlpha((90 + 80 * glow).round()),
                blurRadius: 30 + 25 * glow,
                spreadRadius: 2 + 6 * glow,
              ),
            ],
          ),
          child: child,
        );
      },
      // ClipRRect + escala: corta el margen blanco de las imágenes .jpg
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Transform.scale(
          scale: theme.cropScale,
          child: Image.asset(
            theme.logoPath,
            width: _size,
            height: _size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/// Círculo de luz difuminado que se desplaza por el fondo
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
            colors: [color.withAlpha(150), color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}
