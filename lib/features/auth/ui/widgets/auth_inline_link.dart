import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';

class AuthInlineLink extends StatelessWidget {
  const AuthInlineLink({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.onTap,
  });

  final String prefixText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: prefixText,
            style: textTheme.bodySmall?.copyWith(
              color: ColoresApp.texto,
              fontWeight: FontWeight.w600,
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: AuthUiTokens.inlineLinkPadding,
                child: Text(
                  actionText,
                  style: textTheme.bodySmall?.copyWith(
                    color: ColoresApp.vino,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
