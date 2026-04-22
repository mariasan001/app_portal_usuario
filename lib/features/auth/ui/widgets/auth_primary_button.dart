import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.maxWidth = 260,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onTap;
  final double maxWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: isLoading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.cafe,
              foregroundColor: ColoresApp.blanco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AuthUiTokens.cardRadius),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
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
