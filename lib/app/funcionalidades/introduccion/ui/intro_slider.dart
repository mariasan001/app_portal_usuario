import 'package:flutter/material.dart';
import '../../../tema/colores.dart';
import '../modelos/slide_intro.dart';

class IntroSlider extends StatelessWidget {
  final SlideIntro slide;
  final int index; // index global del pageview (1..3)
  final int totalIntros; // 3
  final bool esUltimo;

  final VoidCallback onSaltar;
  final VoidCallback onAtras;
  final VoidCallback onSiguiente;

  const IntroSlider({
    super.key,
    required this.slide,
    required this.index,
    required this.totalIntros,
    required this.esUltimo,
    required this.onSaltar,
    required this.onAtras,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    // indexIntro: 0..2 (para dots)
    final indexIntro = index - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSaltar,
              style: TextButton.styleFrom(
                backgroundColor: ColoresApp.vino,
                foregroundColor: ColoresApp.blanco,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Saltar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),

          Expanded(
            child: Center(
              child: Image.asset(
                slide.imagen,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: ColoresApp.blanco,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 16,
                  offset: Offset(0, 8),
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  slide.titulo,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ColoresApp.texto,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  slide.descripcion,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ColoresApp.textoSuave,
                      ),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BotonCirculo(
                      onTap: onAtras,
                      enabled: index > 1,
                      icon: Icons.arrow_back,
                    ),
                    _IndicadorDots(actual: indexIntro, total: totalIntros),
                    _BotonCirculo(
                      onTap: onSiguiente,
                      enabled: true,
                      icon: esUltimo ? Icons.check : Icons.arrow_forward,
                      outlined: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonCirculo extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final IconData icon;
  final bool outlined;

  const _BotonCirculo({
    required this.onTap,
    required this.enabled,
    required this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.transparent : ColoresApp.vino;
    final fg = outlined ? ColoresApp.vino : ColoresApp.blanco;

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: outlined ? Border.all(color: ColoresApp.vino, width: 2) : null,
          ),
          child: Icon(icon, color: fg, size: 20),
        ),
      ),
    );
  }
}

class _IndicadorDots extends StatelessWidget {
  final int actual;
  final int total;

  const _IndicadorDots({required this.actual, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == actual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? ColoresApp.vino : const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
