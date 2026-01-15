import 'package:flutter/material.dart';
import '../../widgets/auth_text_field.dart';

class RecuperarPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController mailCtrl;
  final VoidCallback onSubmit;

  const RecuperarPasswordForm({
    super.key,
    required this.formKey,
    required this.mailCtrl,
    required this.onSubmit,
  });

  bool _isEmail(String v) {
    final s = v.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
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
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Escribe tu correo';
              if (!_isEmail(value)) return 'Ese correo no se ve válido';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
