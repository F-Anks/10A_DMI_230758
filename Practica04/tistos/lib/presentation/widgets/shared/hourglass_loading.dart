import 'dart:math' as math;
import 'package:flutter/material.dart';

class HourglassLoading extends StatefulWidget {
  const HourglassLoading({super.key});

  @override
  State<HourglassLoading> createState() => _HourglassLoadingState();
}

class _HourglassLoadingState extends State<HourglassLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 2.5 seconds total cycle: spin 180 deg, pause, spin 180 deg, pause
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Creates a spin-and-pause effect
        final t = _controller.value;
        double turns;
        if (t < 0.4) {
          // Spin first half
          turns = Curves.easeInOutCubic.transform(t / 0.4) * 0.5;
        } else if (t < 0.5) {
          // Pause
          turns = 0.5;
        } else if (t < 0.9) {
          // Spin second half
          turns = 0.5 + Curves.easeInOutCubic.transform((t - 0.5) / 0.4) * 0.5;
        } else {
          // Pause
          turns = 1.0;
        }
        
        return Transform.rotate(
          angle: turns * math.pi * 2,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.hourglass_bottom_rounded,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
