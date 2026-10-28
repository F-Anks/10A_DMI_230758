import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_widgets_app/config/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  static const String name = 'splash_screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Paleta de colores del icono (assets/images/logo.jpg) combinada con
  // el color por defecto de la aplicación (colorList[0] = Colors.blue).
  static final List<Color> _paletteColors = [
    const Color(0xFF060B26), // Azul medianoche profundo del icono
    colorList.first,         // Color por defecto de la app (Colors.blue)
    const Color(0xFF5E35B1), // Violeta/índigo del cabello y circuitos
    const Color(0xFF00E5FF), // Cian eléctrico del logo Flutter y Riverpod
    const Color(0xFFAB47BC), // Magenta/púrpura neón de los nodos y destellos
  ];

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

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _paletteColors.first,
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            final t = _bgController.value;
            final angle = t * 2 * math.pi;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Fondo con degradado dinámico usando la paleta del icono y el color default
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(math.cos(angle), math.sin(angle)),
                      end: Alignment(-math.cos(angle), -math.sin(angle)),
                      colors: _shiftedColors(_paletteColors, t),
                    ),
                  ),
                ),

                // Manchas de luz difuminadas (efecto aurora con colores del icono y default)
                for (int i = 0; i < 3; i++)
                  _GlowBlob(
                    color: _paletteColors[(i + 1) % _paletteColors.length],
                    alignment: Alignment(
                      math.sin(angle + i * 2.1) * 0.9,
                      math.cos(angle * (i.isEven ? 1 : -1) + i * 1.3) * 0.8,
                    ),
                  ),

                // Velo radial sutil para resaltar el icono y título
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.2,
                      colors: [Color(0x11000000), Color(0x8804071A)],
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
                    child: _AnimatedLogo(
                      pulse: _bgController,
                      glowColor: colorList.first,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Column(
                      children: [
                        Text(
                          'Ridgets App',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x80000000),
                                blurRadius: 18,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Flutter • Material 3 • Riverpod',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Color(0xCCBBDEFB),
                          ),
                        ),
                      ],
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

class _AnimatedLogo extends StatelessWidget {
  final Animation<double> pulse;
  final Color glowColor;

  const _AnimatedLogo({
    required this.pulse,
    required this.glowColor,
  });

  static const double _size = 168;
  static const double _radius = 38;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = (math.sin(pulse.value * 2 * math.pi) + 1) / 2;
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: glowColor.withAlpha((100 + 85 * glow).round()),
                blurRadius: 28 + 22 * glow,
                spreadRadius: 2 + 6 * glow,
              ),
              BoxShadow(
                color: const Color(0xFF00E5FF).withAlpha((70 + 60 * glow).round()),
                blurRadius: 18 + 16 * glow,
                spreadRadius: 1 + 3 * glow,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Transform.scale(
          scale: 1.03,
          child: Image.asset(
            'assets/images/logo.jpg',
            width: _size,
            height: _size,
            fit: BoxFit.cover,
          ),
        ),
      ),
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

