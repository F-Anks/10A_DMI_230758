import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Resorte compartido por todas las animaciones "líquidas" (rebote suave,
/// como los controles de iOS 26).
const SpringDescription kLiquidSpring = SpringDescription(
  mass: 1,
  stiffness: 380,
  damping: 16,
);

/// Superficie "Liquid Glass" estilo Apple.
///
/// Capas (de abajo hacia arriba):
/// 1. Fondo desenfocado y con más saturación (BackdropFilter).
/// 2. Tinte translúcido con degradado vertical.
/// 3. Contenido ([child]).
/// 4. Reflejo especular superior + canto interior + borde de luz que simula
///    la refracción en la orilla del vidrio.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blur = 14,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.12,
    this.highlight = 0,
    this.padding,
    this.showShadow = true,
  });

  final Widget? child;
  final BorderRadius borderRadius;

  /// Desenfoque del fondo. Con 0 no se usa BackdropFilter (mucho más barato);
  /// útil cuando el vidrio ya está encima de otro vidrio o de un fondo borroso.
  final double blur;

  final Color tintColor;
  final double tintOpacity;

  /// Brillo extra (0 = reposo, 1 = presionado).
  final double highlight;

  final EdgeInsetsGeometry? padding;
  final bool showShadow;

  /// Matriz que aumenta la saturación ~1.7x y aclara un poco el fondo,
  /// igual que el material de Apple (los colores "brillan" a través del vidrio).
  static const List<double> _saturationMatrix = [
    1.5512, -0.5006, -0.0505, 0, 6, //
    -0.1488, 1.1994, -0.0505, 0, 6, //
    -0.1488, -0.5006, 1.6495, 0, 6, //
    0, 0, 0, 1, 0,
  ];

  /// Se reutiliza el mismo filtro por valor de blur para no recrear capas.
  static final Map<double, ui.ImageFilter> _filterCache = {};

  static ui.ImageFilter _filterFor(double sigma) {
    return _filterCache.putIfAbsent(
      sigma,
      () => ui.ImageFilter.compose(
        outer: const ui.ColorFilter.matrix(_saturationMatrix),
        inner: ui.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: ui.TileMode.mirror,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: _GlassFillPainter(
        borderRadius: borderRadius,
        color: tintColor,
        opacity: tintOpacity,
        highlight: highlight,
      ),
      foregroundPainter: _GlassRimPainter(
        borderRadius: borderRadius,
        highlight: highlight,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (blur > 0) {
      // grouped: todos los vidrios dentro de un BackdropGroup comparten una
      // sola lectura del fondo (mejor rendimiento sobre el video)
      content = BackdropFilter.grouped(filter: _filterFor(blur), child: content);
    }

    content = ClipRRect(borderRadius: borderRadius, child: content);

    if (!showShadow) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }
}

Color _white(double alpha) =>
    Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0));

/// Tinte del vidrio: más claro arriba y más transparente abajo.
class _GlassFillPainter extends CustomPainter {
  const _GlassFillPainter({
    required this.borderRadius,
    required this.color,
    required this.opacity,
    required this.highlight,
  });

  final BorderRadius borderRadius;
  final Color color;
  final double opacity;
  final double highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: (opacity * 1.6 + 0.1 * highlight).clamp(0.0, 1.0)),
          color.withValues(alpha: (opacity * 0.6 + 0.05 * highlight).clamp(0.0, 1.0)),
        ],
      ).createShader(rect);

    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  }

  @override
  bool shouldRepaint(_GlassFillPainter old) =>
      old.color != color ||
      old.opacity != opacity ||
      old.highlight != highlight ||
      old.borderRadius != borderRadius;
}

/// Reflejo especular, grosor del vidrio y borde de luz.
class _GlassRimPainter extends CustomPainter {
  const _GlassRimPainter({required this.borderRadius, required this.highlight});

  final BorderRadius borderRadius;
  final double highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final boost = 1 + highlight;

    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Reflejo especular: luz suave en la mitad superior
    final specular = Rect.fromLTWH(
      -size.width * 0.1,
      -size.height * 0.45,
      size.width * 1.2,
      size.height,
    );
    canvas.drawOval(
      specular,
      Paint()
        ..shader = RadialGradient(
          colors: [_white(0.18 * boost), _white(0)],
        ).createShader(specular),
    );

    // 2. Canto interior difuso: da la sensación de grosor del vidrio
    canvas.drawRRect(
      rrect.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_white(0.30 * boost), _white(0), _white(0.14 * boost)],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    canvas.restore();

    // 3. Borde de luz: brilla arriba-izquierda y abajo-derecha (refracción)
    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _white(0.80 * boost),
            _white(0.12),
            _white(0.05),
            _white(0.45 * boost),
          ],
          stops: const [0, 0.4, 0.6, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GlassRimPainter old) =>
      old.highlight != highlight || old.borderRadius != borderRadius;
}
