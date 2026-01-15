import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/auth_shell.dart';
import 'widgets/otp_dots.dart';

class TokenPage extends StatefulWidget {
  const TokenPage({super.key});

  @override
  State<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  int _active = 0;

  void _continuar() {
    // TODO: validar token
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      titulo: 'Código de verificación\nenviado',
      subtitulo: 'Te enviamos un código de verificación al correo.\nIngresa el código para continuar con tu registro.',
      primaryText: 'Ingresa',
      onPrimary: _continuar,
      onBack: () => context.pop(),
      child: Column(
        children: [
          OtpDots(active: _active),
          const SizedBox(height: 16),

          // 👇 aquí luego metemos tu input real (4 dígitos). Por ahora placeholder.
          SizedBox(
            width: 220,
            child: TextField(
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(counterText: ''),
              onChanged: (v) => setState(() => _active = (v.length - 1).clamp(0, 3)),
            ),
          ),
        ],
      ),
    );
  }
}
