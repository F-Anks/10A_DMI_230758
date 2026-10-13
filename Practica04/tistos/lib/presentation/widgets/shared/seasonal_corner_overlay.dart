import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tistos/config/helpers/logo_helper.dart';

/// Widget superpuesto en pantalla que dibuja detalles decorativos estacionales
/// sutiles en las esquinas superiores de la app (telarañas en Halloween, nieve en Navidad,
/// corazones en San Valentín y serpentinas/confeti festivo en Aniversario).
/// 
/// Características clave:
/// - Totalmente transparente a toques ([IgnorePointer]) para no interferir con la UI o videos.
/// - Se desactiva y oculta automáticamente al cambiar a vista horizontal (landscape).
/// - Estilo sutil, elegante y con micro-animaciones continuas no intrusivas.
class SeasonalCornerOverlay extends StatefulWidget {
  const SeasonalCornerOverlay({
    super.key,
    this.overrideSeason,
  });

  /// Permite forzar una temporada específica para pruebas o previsualización.
  final Season? overrideSeason;

  @override
  State<SeasonalCornerOverlay> createState() => _SeasonalCornerOverlayState();
}

class _SeasonalCornerOverlayState extends State<SeasonalCornerOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Ocultar inmediatamente si la pantalla está en orientación horizontal
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape) {
      return const SizedBox.shrink();
    }

    final season = widget.overrideSeason ?? LogoHelper.getCurrentSeasonTheme().season;

    if (season == Season.normal) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final t = _animController.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Esquina Superior Izquierda
              Positioned(
                top: 0,
                left: 0,
                child: _buildCorner(season, isRight: false, animationProgress: t),
              ),

              // Esquina Superior Derecha
              Positioned(
                top: 0,
                right: 0,
                child: _buildCorner(season, isRight: true, animationProgress: t),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCorner(Season season, {required bool isRight, required double animationProgress}) {
    const size = 110.0;

    switch (season) {
      case Season.halloween:
        return CustomPaint(
          size: const Size(size, size),
          painter: _SpiderWebCornerPainter(
            isRight: isRight,
            animationProgress: animationProgress,
          ),
        );

      case Season.christmas:
        return CustomPaint(
          size: const Size(size, size),
          painter: _SnowFrostCornerPainter(
            isRight: isRight,
            animationProgress: animationProgress,
          ),
        );

      case Season.valentine:
        return CustomPaint(
          size: const Size(size, size),
          painter: _ValentineHeartsCornerPainter(
            isRight: isRight,
            animationProgress: animationProgress,
          ),
        );

      case Season.anniversary:
        return CustomPaint(
          size: const Size(size, size),
          painter: _AnniversaryCornerPainter(
            isRight: isRight,
            animationProgress: animationProgress,
          ),
        );

      case Season.normal:
        return const SizedBox.shrink();
    }
  }
}

// ============================================================================
// 1. TELARAÑAS EN MODO HALLOWEEN (SUTIL Y ELEGANTE CON ARAÑITA COLGANTE)
// ============================================================================
class _SpiderWebCornerPainter extends CustomPainter {
  final bool isRight;
  final double animationProgress;

  _SpiderWebCornerPainter({
    required this.isRight,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(isRight ? size.width : 0, 0);

    final linePaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.50 + 0.12 * animationProgress)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final subtleGlowPaint = Paint()
      ..color = const Color(0xFF9333EA).withValues(alpha: 0.22)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    // Ángulos de los rayos radiales desde el vértice de la esquina
    final startAngle = isRight ? math.pi / 2 : 0.0;
    final endAngle = isRight ? math.pi : math.pi / 2;
    const rayCount = 5;
    final rays = <Offset>[];

    final maxRadius = size.width * 0.92;

    for (int i = 0; i < rayCount; i++) {
      final angle = startAngle + (endAngle - startAngle) * (i / (rayCount - 1));
      final p = Offset(
        origin.dx + math.cos(angle) * maxRadius * (isRight ? -1 : 1),
        origin.dy + math.sin(angle) * maxRadius,
      );
      rays.add(p);
      canvas.drawLine(origin, p, subtleGlowPaint);
      canvas.drawLine(origin, p, linePaint);
    }

    // Arcos concéntricos entre los rayos
    final arcTiers = [0.26, 0.50, 0.74, 0.94];
    for (final tier in arcTiers) {
      final path = Path();
      for (int i = 0; i < rayCount; i++) {
        final angle = startAngle + (endAngle - startAngle) * (i / (rayCount - 1));
        final r = maxRadius * tier;
        final x = origin.dx + math.cos(angle) * r * (isRight ? -1 : 1);
        final y = origin.dy + math.sin(angle) * r;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevAngle = startAngle + (endAngle - startAngle) * ((i - 1) / (rayCount - 1));
          final midAngle = (prevAngle + angle) / 2;
          final sagR = r * 0.90; // comba natural de telaraña
          final cx = origin.dx + math.cos(midAngle) * sagR * (isRight ? -1 : 1);
          final cy = origin.dy + math.sin(midAngle) * sagR;
          path.quadraticBezierTo(cx, cy, x, y);
        }
      }
      canvas.drawPath(path, linePaint);
    }

    // Pequeña araña sutil colgando de un hilo en la esquina derecha
    if (isRight) {
      final dropLength = 48.0 + 8.0 * math.sin(animationProgress * math.pi);
      final spiderX = size.width - 26;
      final spiderY = dropLength;

      // Hilo de seda
      final silkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(spiderX, 0), Offset(spiderX, spiderY), silkPaint);

      // Cuerpo de la arañita
      final spiderPaint = Paint()
        ..color = const Color(0xFF1E1B4B).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(spiderX, spiderY), 3.2, spiderPaint);
      canvas.drawCircle(Offset(spiderX, spiderY + 3.8), 2.2, spiderPaint);

      // Ojos naranja neón diminutos
      final eyePaint = Paint()
        ..color = const Color(0xFFFF6A00).withValues(alpha: 0.95);
      canvas.drawCircle(Offset(spiderX - 0.9, spiderY + 4.2), 0.6, eyePaint);
      canvas.drawCircle(Offset(spiderX + 0.9, spiderY + 4.2), 0.6, eyePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpiderWebCornerPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}

// ============================================================================
// 2. NIEVE Y ESCARCHA EN MODO NAVIDAD (CRISHMAS)
// ============================================================================
class _SnowFrostCornerPainter extends CustomPainter {
  final bool isRight;
  final double animationProgress;

  _SnowFrostCornerPainter({
    required this.isRight,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Manto de escarcha suave en la esquina
    final frostPath = Path();
    if (isRight) {
      frostPath.moveTo(size.width, 0);
      frostPath.lineTo(size.width - 65, 0);
      frostPath.quadraticBezierTo(size.width - 45, 20, size.width - 32, 38);
      frostPath.quadraticBezierTo(size.width - 15, 52, size.width, 62);
      frostPath.close();
    } else {
      frostPath.moveTo(0, 0);
      frostPath.lineTo(65, 0);
      frostPath.quadraticBezierTo(45, 20, 32, 38);
      frostPath.quadraticBezierTo(15, 52, 0, 62);
      frostPath.close();
    }

    final frostPaint = Paint()
      ..shader = RadialGradient(
        center: isRight ? Alignment.topRight : Alignment.topLeft,
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          const Color(0xFFBAE6FD).withValues(alpha: 0.28),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(frostPath, frostPaint);

    // 2. Copos de nieve flotantes con centelleo sutil
    final flakes = [
      {'x': isRight ? size.width - 32 : 32.0, 'y': 22.0, 'r': 4.5, 'phase': 0.0},
      {'x': isRight ? size.width - 56 : 56.0, 'y': 15.0, 'r': 3.2, 'phase': 0.3},
      {'x': isRight ? size.width - 18 : 18.0, 'y': 48.0, 'r': 3.6, 'phase': 0.6},
      {'x': isRight ? size.width - 42 : 42.0, 'y': 44.0, 'r': 2.4, 'phase': 0.8},
      {'x': isRight ? size.width - 70 : 70.0, 'y': 30.0, 'r': 2.0, 'phase': 0.4},
    ];

    for (final flake in flakes) {
      final x = flake['x'] as double;
      final y = flake['y'] as double;
      final r = flake['r'] as double;
      final phase = flake['phase'] as double;

      final shimmer = (math.sin((animationProgress + phase) * 2 * math.pi) + 1) / 2;
      final alpha = 0.40 + 0.45 * shimmer;

      _drawSnowflake(canvas, Offset(x, y), r, alpha);
    }
  }

  void _drawSnowflake(Canvas canvas, Offset center, double radius, double alpha) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Centro brillante
    canvas.drawCircle(center, radius * 0.28, Paint()..color = Colors.white.withValues(alpha: alpha));

    // 6 brazos estrellados
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(center, end, paint);

      // Pequeñas ramitas
      if (radius > 3.0) {
        final mid = Offset(
          center.dx + math.cos(angle) * (radius * 0.55),
          center.dy + math.sin(angle) * (radius * 0.55),
        );
        final branchAngle1 = angle + math.pi / 5;
        final branchAngle2 = angle - math.pi / 5;
        canvas.drawLine(
          mid,
          Offset(mid.dx + math.cos(branchAngle1) * (radius * 0.32), mid.dy + math.sin(branchAngle1) * (radius * 0.32)),
          paint,
        );
        canvas.drawLine(
          mid,
          Offset(mid.dx + math.cos(branchAngle2) * (radius * 0.32), mid.dy + math.sin(branchAngle2) * (radius * 0.32)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnowFrostCornerPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}

// ============================================================================
// 3. CORAZONES EN MODO SAN VALENTÍN (VALENTINE'S)
// ============================================================================
class _ValentineHeartsCornerPainter extends CustomPainter {
  final bool isRight;
  final double animationProgress;

  _ValentineHeartsCornerPainter({
    required this.isRight,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hearts = [
      {
        'x': isRight ? size.width - 34 : 34.0,
        'y': 24.0,
        'size': 14.0,
        'rot': isRight ? -0.25 : 0.25,
        'color': const Color(0xFFFF2E63),
        'phase': 0.0,
      },
      {
        'x': isRight ? size.width - 58 : 58.0,
        'y': 18.0,
        'size': 9.5,
        'rot': isRight ? 0.35 : -0.35,
        'color': const Color(0xFFFF8FAB),
        'phase': 0.35,
      },
      {
        'x': isRight ? size.width - 22 : 22.0,
        'y': 48.0,
        'size': 10.5,
        'rot': isRight ? -0.45 : 0.45,
        'color': const Color(0xFFE11D48),
        'phase': 0.70,
      },
      {
        'x': isRight ? size.width - 44 : 44.0,
        'y': 42.0,
        'size': 7.0,
        'rot': isRight ? 0.20 : -0.20,
        'color': const Color(0xFFFFB3C6),
        'phase': 0.50,
      },
    ];

    for (final h in hearts) {
      final x = h['x'] as double;
      final y = h['y'] as double;
      final hSize = h['size'] as double;
      final rot = h['rot'] as double;
      final color = h['color'] as Color;
      final phase = h['phase'] as double;

      // Latido suave
      final pulse = (math.sin((animationProgress + phase) * 2 * math.pi) + 1) / 2;
      final scale = 1.0 + 0.12 * pulse;
      final alpha = 0.55 + 0.30 * pulse;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.scale(scale);

      // Resplandor difuminado
      final glowPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      _drawHeartShape(canvas, hSize, glowPaint);

      // Corazón sólido
      final fillPaint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      _drawHeartShape(canvas, hSize, fillPaint);

      // Brillo interior superior
      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.55)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-hSize * 0.22, -hSize * 0.22), hSize * 0.14, shinePaint);

      canvas.restore();
    }
  }

  void _drawHeartShape(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final w = size;
    final h = size * 0.95;

    path.moveTo(0, h * 0.35);
    path.cubicTo(-w * 0.55, -h * 0.25, -w * 0.55, -h * 0.65, 0, -h * 0.18);
    path.cubicTo(w * 0.55, -h * 0.65, w * 0.55, -h * 0.25, 0, h * 0.35);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ValentineHeartsCornerPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}

// ============================================================================
// 4. CONFETI Y SERPENTINAS EN MODO ANIVERSARIO (CUMPLEAÑOS DE LA APP)
// ============================================================================
class _AnniversaryCornerPainter extends CustomPainter {
  final bool isRight;
  final double animationProgress;

  _AnniversaryCornerPainter({
    required this.isRight,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final originX = isRight ? size.width : 0.0;

    // Serpentina ondulada festiva desde la esquina
    final ribbonPath = Path();
    ribbonPath.moveTo(originX, 0);

    if (isRight) {
      ribbonPath.cubicTo(size.width - 25, 12, size.width - 45, 28, size.width - 28, 48);
      ribbonPath.cubicTo(size.width - 15, 62, size.width - 38, 74, size.width - 52, 85);
    } else {
      ribbonPath.cubicTo(25, 12, 45, 28, 28, 48);
      ribbonPath.cubicTo(15, 62, 38, 74, 52, 85);
    }

    final ribbonPaint = Paint()
      ..color = const Color(0xFFFFB703).withValues(alpha: 0.65)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(ribbonPath, ribbonPaint);

    // Segunda serpentina cian
    final ribbon2 = Path();
    ribbon2.moveTo(originX, 0);
    if (isRight) {
      ribbon2.cubicTo(size.width - 12, 25, size.width - 32, 40, size.width - 18, 65);
    } else {
      ribbon2.cubicTo(12, 25, 32, 40, 18, 65);
    }
    final ribbon2Paint = Paint()
      ..color = const Color(0xFF4CC9F0).withValues(alpha: 0.55)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(ribbon2, ribbon2Paint);

    // Confetis geométricos festivos (estrellas, rombos y círculos)
    final confetti = [
      {'x': isRight ? size.width - 42 : 42.0, 'y': 22.0, 'c': const Color(0xFFF72585), 'shape': 'star', 'size': 5.5, 'phase': 0.0},
      {'x': isRight ? size.width - 64 : 64.0, 'y': 16.0, 'c': const Color(0xFFFFB703), 'shape': 'dot',  'size': 3.2, 'phase': 0.3},
      {'x': isRight ? size.width - 24 : 24.0, 'y': 38.0, 'c': const Color(0xFF7209B7), 'shape': 'rect', 'size': 4.0, 'phase': 0.6},
      {'x': isRight ? size.width - 50 : 50.0, 'y': 48.0, 'c': const Color(0xFF4CC9F0), 'shape': 'star', 'size': 4.8, 'phase': 0.8},
      {'x': isRight ? size.width - 34 : 34.0, 'y': 62.0, 'c': const Color(0xFFFFB703), 'shape': 'dot',  'size': 2.6, 'phase': 0.2},
      {'x': isRight ? size.width - 68 : 68.0, 'y': 36.0, 'c': const Color(0xFFF72585), 'shape': 'rect', 'size': 3.4, 'phase': 0.5},
    ];

    for (final c in confetti) {
      final x = c['x'] as double;
      final y = c['y'] as double;
      final color = c['c'] as Color;
      final shape = c['shape'] as String;
      final s = c['size'] as double;
      final phase = c['phase'] as double;

      final shimmer = (math.sin((animationProgress + phase) * 2 * math.pi) + 1) / 2;
      final paint = Paint()
        ..color = color.withValues(alpha: 0.50 + 0.40 * shimmer)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((animationProgress + phase) * math.pi);

      if (shape == 'dot') {
        canvas.drawCircle(Offset.zero, s, paint);
      } else if (shape == 'rect') {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: s * 1.6, height: s * 0.9), const Radius.circular(1)),
          paint,
        );
      } else if (shape == 'star') {
        _drawMiniStar(canvas, s, paint);
      }
      canvas.restore();
    }
  }

  void _drawMiniStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x1 = math.cos(angle) * radius;
      final y1 = math.sin(angle) * radius;
      final x2 = math.cos(angle + math.pi / 4) * (radius * 0.35);
      final y2 = math.sin(angle + math.pi / 4) * (radius * 0.35);
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnniversaryCornerPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
