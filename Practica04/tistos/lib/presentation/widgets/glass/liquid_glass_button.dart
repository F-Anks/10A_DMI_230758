import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:tistos/presentation/widgets/glass/liquid_glass.dart';

/// Botón circular de vidrio líquido.
///
/// Al presionarlo crece y se ilumina con física de resorte; al soltarlo
/// rebota a su tamaño original, igual que los botones de iOS 26.
class LiquidGlassButton extends StatefulWidget {
  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 52,
    this.tint,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;

  /// Color opcional del vidrio (ej. rosa cuando el like está activo).
  final Color? tint;

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  /// 0 = reposo, 1 = presionado. Sin límites para permitir el rebote.
  late final AnimationController _press = AnimationController.unbounded(vsync: this);

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _springTo(double target, {double velocity = 0}) {
    _press.animateWith(
      SpringSimulation(kLiquidSpring, _press.value, target, velocity),
    );
  }

  void _onPressDown() => _springTo(1, velocity: _press.velocity);

  /// En un tap rápido el botón casi no alcanza a crecer; se le da un
  /// impulso para que siempre se vea el "pop" líquido.
  void _onPressUp() => _springTo(0, velocity: math.max(_press.velocity, 10));

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.size / 2);

    return GestureDetector(
      onTapDown: (_) => _onPressDown(),
      onTapUp: (_) => _onPressUp(),
      onTapCancel: () => _springTo(0),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _press,
        child: SizedBox.square(
          dimension: widget.size,
          child: Center(child: widget.child),
        ),
        builder: (context, child) {
          final value = _press.value;
          return Transform.scale(
            scale: 1 + 0.15 * value,
            child: LiquidGlass(
              borderRadius: radius,
              highlight: value.clamp(0.0, 1.5),
              tintColor: widget.tint ?? Colors.white,
              tintOpacity: widget.tint == null ? 0.12 : 0.22,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
