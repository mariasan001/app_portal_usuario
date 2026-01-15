import 'package:flutter/material.dart';
import '../../../../tema/colores.dart';

class AuthBanner extends StatelessWidget {
  final String texto;

  // Assets
  final String leftAsset;  // ej: assets/img/flor_d.png (la que va a la izquierda)
  final String rightAsset; // ej: assets/img/flor_i.png (la que va a la derecha)

  // Ajustes
  final double ornamentSize;
  final double leftX;
  final double leftY;
  final double rightX;
  final double rightY;
  final double ornamentOpacity;

  const AuthBanner({
    super.key,
    required this.texto,
    required this.leftAsset,
    required this.rightAsset,
    this.ornamentSize = 62,
    this.leftX = -32,
    this.leftY = -10,
    this.rightX = -32,
    this.rightY = -10,
    this.ornamentOpacity = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ✅ ORNAMENTO IZQUIERDA (detrás)
          Positioned(
            left: leftX,
            top: leftY,
            child: IgnorePointer(
              child: Opacity(
                opacity: ornamentOpacity,
                child: Image.asset(
                  leftAsset,
                  height: ornamentSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ✅ ORNAMENTO DERECHA (detrás)
          Positioned(
            right: rightX,
            top: rightY,
            child: IgnorePointer(
              child: Opacity(
                opacity: ornamentOpacity,
                child: Image.asset(
                  rightAsset,
                  height: ornamentSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ✅ BANNER DORADO (encima)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
              color: ColoresApp.dorado,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 6),
                  color: Color(0x14000000),
                ),
              ],
            ),
            child: Text(
              texto,
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(
                color: ColoresApp.blanco,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
