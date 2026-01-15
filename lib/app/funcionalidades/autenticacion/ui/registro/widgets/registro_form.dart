import 'package:flutter/material.dart';
import '../../widgets/auth_text_field.dart';

class RegistroForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userCtrl;
  final TextEditingController mailCtrl;
  final VoidCallback onSubmit;

  const RegistroForm({
    super.key,
    required this.formKey,
    required this.userCtrl,
    required this.mailCtrl,
    required this.onSubmit,
  });

  bool _isEmail(String v) {
    final s = v.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
  }

  String _onlyDigits(String v) => v.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Número de Servidor Público',
            hint: 'Ej. 123456',
            icon: Icons.person,
            controller: userCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) {
              final raw = (v ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu número de servidor público';
              final digits = _onlyDigits(raw);
              if (digits.length < 3) return 'Revisa el número, parece incompleto';
              return null;
            },
          ),
          const SizedBox(height: 12),
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
