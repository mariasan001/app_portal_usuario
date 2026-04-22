import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_text_field.dart';

class RecuperarPasswordForm extends StatelessWidget {
  const RecuperarPasswordForm({
    super.key,
    required this.formKey,
    required this.mailCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController mailCtrl;
  final VoidCallback onSubmit;

  bool _isEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Correo',
            hint: 'Ej. nombre@correo.com',
            icon: Icons.email,
            controller: mailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu correo';
              if (!_isEmail(raw)) return 'Ese correo no se ve valido';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
