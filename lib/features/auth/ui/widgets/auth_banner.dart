import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';

class AuthBanner extends StatelessWidget {
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

  final String texto;
  final String leftAsset;
  final String rightAsset;
  final double ornamentSize;
  final double leftX;
  final double leftY;
  final double rightX;
  final double rightY;
  final double ornamentOpacity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
              color: ColoresApp.dorado,
              borderRadius: BorderRadius.circular(AuthUiTokens.cardRadius),
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
              style: textTheme.titleMedium?.copyWith(
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
