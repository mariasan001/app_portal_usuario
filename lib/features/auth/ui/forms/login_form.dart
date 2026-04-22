import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Numero de servidor publico',
            hint: 'Ingresa tu numero de servidor publico',
            icon: Icons.person,
            controller: userCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) {
                return 'Ingresa tu numero de servidor publico';
              }
              if (raw.length < 3) {
                return 'Numero invalido';
              }
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Contrasena',
            hint: 'Ingresa tu contrasena',
            icon: Icons.lock,
            obscure: true,
            controller: passCtrl,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) {
                return 'Ingresa tu contrasena';
              }
              if (raw.length < 4) {
                return 'Contrasena muy corta';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/recuperar'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Olvide mi ',
                      style: textTheme.bodySmall?.copyWith(
                        color: ColoresApp.texto,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: 'contrasena',
                      style: textTheme.bodySmall?.copyWith(
                        color: ColoresApp.vino,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
