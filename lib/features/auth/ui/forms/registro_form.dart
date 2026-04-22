import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_text_field.dart';

class RegistroForm extends StatelessWidget {
  const RegistroForm({
    super.key,
    required this.formKey,
    required this.claveSpCtrl,
    required this.plazaCtrl,
    required this.puestoCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.phoneCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController claveSpCtrl;
  final TextEditingController plazaCtrl;
  final TextEditingController puestoCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController phoneCtrl;
  final VoidCallback onSubmit;

  bool _isEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  String _onlyDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            label: 'Clave SP',
            hint: 'Ej. 210048332',
            icon: Icons.badge_outlined,
            controller: claveSpCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu clave de servidor publico';
              if (_onlyDigits(raw).length < 6) return 'Clave SP incompleta';
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Plaza',
            hint: 'Ej. 234000000002125',
            icon: Icons.account_tree_outlined,
            controller: plazaCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu plaza';
              if (_onlyDigits(raw).length < 6) return 'Plaza incompleta';
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Puesto',
            hint: 'Ej. ANALISTA ESPECIALIZADO B',
            icon: Icons.work_outline,
            controller: puestoCtrl,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu puesto';
              if (raw.length < 4) return 'Puesto demasiado corto';
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Correo',
            hint: 'Ej. nombre@correo.com',
            icon: Icons.email_outlined,
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu correo';
              if (!_isEmail(raw)) return 'Ese correo no se ve valido';
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Telefono',
            hint: 'Ej. 7221234567',
            icon: Icons.phone_outlined,
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe tu telefono';
              if (_onlyDigits(raw).length < 10) return 'Telefono incompleto';
              return null;
            },
          ),
          const SizedBox(height: AuthUiTokens.defaultFieldGap),
          AuthTextField(
            label: 'Contrasena',
            hint: 'Crea una contrasena segura',
            icon: Icons.lock_outline,
            controller: passwordCtrl,
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Escribe una contrasena';
              if (raw.length < 8) return 'Usa al menos 8 caracteres';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
