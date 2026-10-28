import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_widgets_app/config/theme/app_theme.dart';
import 'package:flutter_widgets_app/presentation/providers/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const String name = 'splash_screen';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  // Paletas personalizadas para cada uno de los 8 temas y sus respectivos logos
  static const List<List<Color>> _themePalettes = [
    // 0: Azul
    [
      Color(0xFF060B26),
      Colors.blue,
      Color(0xFF5E35B1),
      Color(0xFF00E5FF),
      Color(0xFFAB47BC),
    ],
    // 1: Teal
    [
      Color(0xFF021B1F),
      Colors.teal,
      Color(0xFF00897B),
      Color(0xFF1DE9B6),
      Color(0xFF00B0FF),
    ],
    // 2: Verde
    [
      Color(0xFF081C0B),
      Colors.green,
      Color(0xFF2E7D32),
      Color(0xFF00E676),
      Color(0xFFC6FF00),
    ],
    // 3: Púrpura
    [
      Color(0xFF180726),
      Colors.purple,
      Color(0xFF7B1FA2),
      Color(0xFFE040FB),
      Color(0xFF7C4DFF),
    ],
    // 4: Púrpura profundo
    [
      Color(0xFF120324),
      Colors.deepPurple,
      Color(0xFF512DA8),
      Color(0xFF7C4DFF),
      Color(0xFFB388FF),
    ],
    // 5: Naranja
    [
      Color(0xFF241002),
      Colors.orange,
      Color(0xFFE65100),
      Color(0xFFFF9100),
      Color(0xFFFFD600),
    ],
    // 6: Rosa
    [
      Color(0xFF240715),
      Colors.pink,
      Color(0xFFC2185B),
      Color(0xFFFF4081),
      Color(0xFFFF80AB),
    ],
    // 7: Rosa Accent
    [
      Color(0xFF260215),
      Colors.pinkAccent,
      Color(0xFF880E4F),
      Color(0xFFFF1744),
      Color(0xFFFF4081),
    ],
  ];

  static const List<Color> _secondaryGlows = [
    Color(0xFF00E5FF),
    Color(0xFF1DE9B6),
    Color(0xFF00E676),
    Color(0xFFE040FB),
    Color(0xFFB388FF),
    Color(0xFFFF9100),
    Color(0xFFFF4081),
    Color(0xFFFF1744),
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
    await Future.delayed(const Duration(milliseconds: 3800));
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
    final appTheme = ref.watch(themeNotifierProvider);
    final selectedColor = (appTheme.selectedColor >= 0 &&
            appTheme.selectedColor < colorList.length)
        ? appTheme.selectedColor
        : 0;

    final paletteColors = _themePalettes[selectedColor];
    final glowColor = colorList[selectedColor];
    final secondaryGlow = _secondaryGlows[selectedColor];
    final logoPath = getLogoPath(selectedColor);
    final themeName = themeNames[selectedColor];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: paletteColors.first,
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            final t = _bgController.value;
            final angle = t * 2 * math.pi;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Fondo con degradado animado dinámico según el tema activo
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(math.cos(angle), math.sin(angle)),
                      end: Alignment(-math.cos(angle), -math.sin(angle)),
                      colors: _shiftedColors(paletteColors, t),
                    ),
                  ),
                ),

                // Manchas de luz difuminadas (efecto aurora con la paleta del tema)
                for (int i = 0; i < 3; i++)
                  _GlowBlob(
                    color: paletteColors[(i + 1) % paletteColors.length],
                    alignment: Alignment(
                      math.sin(angle + i * 2.1) * 0.9,
                      math.cos(angle * (i.isEven ? 1 : -1) + i * 1.3) * 0.8,
                    ),
                  ),

                // Velo radial sutil para resaltar el logo y texto
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
                      glowColor: glowColor,
                      secondaryGlow: secondaryGlow,
                      logoPath: logoPath,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        const Text(
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
                        const SizedBox(height: 8),
                        Text(
                          'Flutter • Material 3 • Riverpod',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Colors.white.withAlpha(210),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: glowColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: glowColor.withAlpha(140),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            themeName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _textFade,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        secondaryGlow,
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

class _AnimatedLogo extends StatelessWidget {
  final Animation<double> pulse;
  final Color glowColor;
  final Color secondaryGlow;
  final String logoPath;

  const _AnimatedLogo({
    required this.pulse,
    required this.glowColor,
    required this.secondaryGlow,
    required this.logoPath,
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
                color: secondaryGlow.withAlpha((70 + 60 * glow).round()),
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
            logoPath,
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
