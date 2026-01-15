import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_shell.dart';
import 'widgets/recuperar_password_form.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _mailCtrl = TextEditingController();

  @override
  void dispose() {
    _mailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final email = _mailCtrl.text.trim();
    debugPrint('RECUPERAR -> email: $email');

    // TODO: API real -> enviar token al correo
    // await authService.forgotPassword(email);

    // ✅ aquí usamos tu MISMA TokenPage (la de círculos)
    context.go('/token', extra: {
      'flow': 'reset',
      'email': email,
      'backRoute': '/recuperar',
      'nextRoute': '/nueva-contrasena',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,

      showBack: true,
      onBack: () => context.go('/login'),
      fallbackBackRoute: '/login',

      titulo: 'Recupera tu acceso',
      subtitulo:
          'Escribe el correo con el que te registraste\npara enviarte un código de verificación.',

      primaryText: 'Enviar código',
      onPrimary: _enviarCodigo,

  child: RecuperarPasswordForm(
  formKey: _formKey,
  mailCtrl: _mailCtrl,
  onSubmit: () => _enviarCodigo(),
),

      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: Text(
          'Volver a iniciar sesión',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
