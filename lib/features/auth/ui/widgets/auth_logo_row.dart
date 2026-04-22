import 'package:flutter/material.dart';

class AuthLogoRow extends StatelessWidget {
  const AuthLogoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _LogoBox(
              asset: 'assets/img/escudo_2.png',
              height: 94,
              maxWidth: 140,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _LogoBox(
              asset: 'assets/img/escudo.png',
              height: 54,
              maxWidth: 210,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.asset, this.height = 54, this.maxWidth = 210});

  final String asset;
  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
