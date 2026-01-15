import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_shell.dart';
import 'widgets/nueva_contrasena_form.dart';

class NuevaContrasenaPage extends StatefulWidget {
  final String email;
  final String token;

  // por si quieres controlar el back según el flujo
  final String backRoute;

  const NuevaContrasenaPage({
    super.key,
    required this.email,
    required this.token,
    this.backRoute = '/token',
  });

  @override
  State<NuevaContrasenaPage> createState() => _NuevaContrasenaPageState();
}

class _NuevaContrasenaPageState extends State<NuevaContrasenaPage> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final pass = _passCtrl.text.trim();

    // ✅ datos ya vienen por constructor (mejor)
    final email = widget.email.trim();
    final token = widget.token.trim();

    debugPrint('NUEVA PASSWORD -> email: $email, token: $token, pass: $pass');

    // TODO: API real -> reset password
    // await authService.resetPassword(email: email, token: token, newPassword: pass);

    // ✅ al terminar, login
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,

      showBack: true,
      onBack: () => context.go(widget.backRoute),
      fallbackBackRoute: widget.backRoute,

      titulo: 'Crea tu nueva contraseña',
      subtitulo:
          'Escribe una contraseña nueva y confírmala\npara recuperar tu acceso.',

      primaryText: 'Cambiar contraseña',
      onPrimary: _cambiar,

      child: NuevaContrasenaForm(
        formKey: _formKey,
        passCtrl: _passCtrl,
        pass2Ctrl: _pass2Ctrl,
        onSubmit: _cambiar,
      ),

      footer: Text(
        'Al finalizar volverás al inicio de sesión.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
