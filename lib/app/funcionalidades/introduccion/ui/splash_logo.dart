import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../tema/colores.dart';

class SplashLogo extends StatefulWidget {
  final String imagen;
  final bool mostrarLoader;
  final bool mostrarTexto;

  const SplashLogo({
    super.key,
    required this.imagen,
    this.mostrarLoader = true,
    this.mostrarTexto = true,
  });

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with TickerProviderStateMixin {
  late final AnimationController _enterC;
  late final AnimationController _loopC;

  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _halo;
  late final Animation<double> _floatY;

  @override
  void initState() {
    super.initState();

    _enterC = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _loopC = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _fade = CurvedAnimation(parent: _enterC, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _enterC, curve: Curves.easeOutBack),
    );
    _halo = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterC, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _floatY = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _loopC, curve: Curves.easeInOut),
    );

    _enterC.forward();
    _loopC.repeat(reverse: true);
  }

  @override
  void dispose() {
    _enterC.dispose();
    _loopC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fondo crema pero con profundidad
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColoresApp.fondoCrema,
            ColoresApp.fondoCrema.withOpacity(0.92),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_enterC, _loopC]),
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // ✅ “grain” / textura sutil para quitar lo plano
              const Positioned.fill(child: _SoftGrain(opacity: 0.06)),

              // ✅ Halo radial elegante (no círculo duro)
              Opacity(
                opacity: 0.18 * _halo.value,
                child: Transform.scale(
                  scale: 0.92 + (0.10 * _halo.value),
                  child: Container(
                    width: 520,
                    height: 520,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ColoresApp.vino.withOpacity(0.55),
                          ColoresApp.vino.withOpacity(0.14),
                          ColoresApp.vino.withOpacity(0.00),
                        ],
                        stops: const [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Logo + micro-float (vivo pero serio)
              Transform.translate(
                offset: Offset(0, _floatY.value),
                child: Transform.scale(
                  scale: _scale.value,
                  child: Opacity(
                    opacity: _fade.value,
                    child: Image.asset(
                      widget.imagen,
                      width: 320,
                      height: 320,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              if (widget.mostrarLoader)
                Positioned(
                  bottom: 54,
                  child: Opacity(
                    opacity: math.min(1, _fade.value),
                    child: Column(
                      children: [
                        // ✅ Loader premium (barra indeterminada)
                        const _SlimProgressBar(width: 160),
                        if (widget.mostrarTexto) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Cargando…',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ColoresApp.textoSuave,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/* -------------------------- Loader premium -------------------------- */

class _SlimProgressBar extends StatefulWidget {
  final double width;
  const _SlimProgressBar({required this.width});

  @override
  State<_SlimProgressBar> createState() => _SlimProgressBarState();
}

class _SlimProgressBarState extends State<_SlimProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: widget.width,
        height: 6,
        child: Stack(
          children: [
            // Track
            Positioned.fill(
              child: Container(color: ColoresApp.vino.withOpacity(0.10)),
            ),
            // Shimmer bar
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final t = _c.value; // 0..1
                final x = (t * (widget.width + 60)) - 60; // entra y sale
                return Positioned(
                  left: x,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColoresApp.vino.withOpacity(0.00),
                          ColoresApp.vino.withOpacity(0.55),
                          ColoresApp.vino.withOpacity(0.00),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------- Grain / textura -------------------------- */
/* No es ruido real (no assets), es una capa de puntitos generada con painter. */

class _SoftGrain extends StatelessWidget {
  final double opacity;
  const _SoftGrain({required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _GrainPainter(),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final _rnd = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.10);

    // Poquitos puntos para que sea barato
    final count = (size.width * size.height / 8000).clamp(180, 520).toInt();
    for (int i = 0; i < count; i++) {
      final dx = _rnd.nextDouble() * size.width;
      final dy = _rnd.nextDouble() * size.height;
      final r = 0.6 + _rnd.nextDouble() * 0.9;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
