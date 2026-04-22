import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_text_field.dart';

class NuevaContrasenaForm extends StatelessWidget {
  const NuevaContrasenaForm({
    super.key,
    required this.formKey,
    required this.passCtrl,
    required this.pass2Ctrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passCtrl;
  final TextEditingController pass2Ctrl;
  final Future<void> Function() onSubmit;

  String? _validatePassword(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Escribe tu contrasena nueva';
    if (raw.length < 8) return 'Minimo 8 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Confirma tu contrasena';
    if (raw != passCtrl.text.trim()) return 'Las contrasenas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Nueva contrasena',
            hint: 'Escribe tu nueva contrasena',
            icon: Icons.lock_outline,
            controller: passCtrl,
            obscure: true,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Confirmar contrasena',
            hint: 'Vuelve a escribir tu contrasena',
            icon: Icons.verified_user_outlined,
            controller: pass2Ctrl,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: _validateConfirmPassword,
          ),
        ],
      ),
    );
  }
}
