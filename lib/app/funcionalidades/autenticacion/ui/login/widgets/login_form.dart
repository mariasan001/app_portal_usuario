import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../tema/colores.dart';
import '../../widgets/auth_text_field.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.userCtrl,
    required this.passCtrl,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Número de Servidor Público',
            hint: 'Ingresa tu número de servidor público',
            icon: Icons.person,
            controller: userCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Ingresa tu número de servidor público';
              if (value.length < 3) return 'Número inválido';
              return null;
            },
          ),
          const SizedBox(height: 12),
          AuthTextField(
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            icon: Icons.lock,
            obscure: true,
            controller: passCtrl,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onLogin(),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Ingresa tu contraseña';
              if (value.length < 4) return 'Contraseña muy corta';
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
                      text: 'Olvidé mi ',
                      style: t.bodySmall?.copyWith(
                        color: ColoresApp.texto,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: 'contraseña',
                      style: t.bodySmall?.copyWith(
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
