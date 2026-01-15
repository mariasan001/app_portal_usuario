import 'package:flutter/material.dart';
import '../../../../tema/colores.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  /// ✅ controla el ancho (ej: 240, 260, 280)
  final double maxWidth;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.maxWidth = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.cafe,
              foregroundColor: ColoresApp.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ColoresApp.blanco,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
