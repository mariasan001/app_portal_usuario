import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../tema/colores.dart';

class SplashLogo extends StatefulWidget {
  final String imagen;
  final bool mostrarLoader;

  const SplashLogo({
    super.key,
    required this.imagen,
    this.mostrarLoader = true,
  });

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColoresApp.fondoCrema,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow radial sutil
              Opacity(
                opacity: 0.14 * _glow.value,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ColoresApp.vino,
                        ColoresApp.vino.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.75],
                    ),
                  ),
                ),
              ),

              // Logo con fade + scale
              Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _fade.value,
                  child: Image.asset(
                    widget.imagen,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Loader minimal abajo (opcional)
              if (widget.mostrarLoader)
                Positioned(
                  bottom: 48,
                  child: _MiniLoader(opacity: _fade.value),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  final double opacity;
  const _MiniLoader({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: math.min(1, opacity),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Dot(delay: 0),
          SizedBox(width: 8),
          _Dot(delay: 140),
          SizedBox(width: 8),
          _Dot(delay: 280),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOut.transform(_c.value);
        final size = 7 + (t * 5); // 7..12
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: ColoresApp.vino.withOpacity(0.75),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
