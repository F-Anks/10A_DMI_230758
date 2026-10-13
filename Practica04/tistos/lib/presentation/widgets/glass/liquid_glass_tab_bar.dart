import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:tistos/presentation/widgets/glass/liquid_glass.dart';

/// Barra de secciones estilo iOS 26: una cápsula de vidrio con una "gota"
/// de vidrio que se desliza hasta la sección activa.
///
/// La gota sigue al [controller] en tiempo real, así que se mueve tanto al
/// hacer tap como al deslizar con el dedo, y se estira como líquido mientras
/// viaja entre secciones.
class LiquidGlassTabBar extends StatefulWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.labels,
    required this.controller,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> labels;
  final PageController controller;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  static const double _tabWidth = 96;
  static const double _height = 46;
  static const double _inset = 4;

  /// Pequeño "latido" de la gota al tocar una sección.
  late final AnimationController _pulse = AnimationController.unbounded(vsync: this);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Posición actual del PageView (con decimales mientras se desliza).
  double get _page {
    final controller = widget.controller;
    if (controller.hasClients && controller.position.hasContentDimensions) {
      return controller.page ?? widget.selectedIndex.toDouble();
    }
    return widget.selectedIndex.toDouble();
  }

  void _handleTap(int index) {
    _pulse.animateWith(SpringSimulation(kLiquidSpring, _pulse.value, 0, 12));
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      borderRadius: BorderRadius.circular(_height / 2),
      child: SizedBox(
        width: _tabWidth * widget.labels.length + _inset * 2,
        height: _height,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.controller, _pulse]),
          builder: (context, _) {
            final page = _page;
            return Stack(
              children: [
                _buildDroplet(page),
                Positioned.fill(
                  left: _inset,
                  right: _inset,
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.labels.length; i++)
                        _TabLabel(
                          label: widget.labels[i],
                          width: _tabWidth,
                          emphasis: (1 - (page - i).abs()).clamp(0.0, 1.0),
                          onTap: () => _handleTap(i),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Gota de vidrio que marca la sección activa.
  Widget _buildDroplet(double page) {
    // 0 en reposo, 1 a mitad del camino entre dos secciones
    final stretch = math.sin((page - page.floorToDouble()) * math.pi).abs();
    final pulse = _pulse.value;

    return Positioned(
      left: _inset + page * _tabWidth,
      top: _inset,
      width: _tabWidth,
      height: _height - _inset * 2,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          1 + 0.24 * stretch + 0.18 * pulse, // se alarga al viajar
          1 - 0.12 * stretch + 0.18 * pulse, // y se aplana un poco
          1,
        ),
        child: const LiquidGlass(
          blur: 0, // ya está encima de la cápsula borrosa
          showShadow: false,
          tintOpacity: 0.22,
          borderRadius: BorderRadius.all(Radius.circular(999)),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.width,
    required this.emphasis,
    required this.onTap,
  });

  final String label;
  final double width;

  /// 1 = sección activa, 0 = inactiva (con valores intermedios al deslizar).
  final double emphasis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6 + 0.4 * emphasis),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              shadows: const [Shadow(color: Color(0x55000000), blurRadius: 6)],
            ),
          ),
        ),
      ),
    );
  }
}
