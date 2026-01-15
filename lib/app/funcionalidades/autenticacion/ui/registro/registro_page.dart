import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/auth_shell.dart';
import 'widgets/registro_form.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _mailCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _mailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarToken() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final user = _userCtrl.text.trim();
    final email = _mailCtrl.text.trim();

    // TODO: aquí conectas API real (service)
    // await authService.enviarTokenRegistro(user, email);

    debugPrint('REGISTRO -> user: $user, email: $email');

    context.go('/token');
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',

      titulo: 'Regístrate en el sistema',
      subtitulo:
          'Activa tu perfil con tu número de servidor público y\nobtén acceso a tus recibos y trámites.',
      primaryText: 'Ingresar',
      onPrimary: _enviarToken,
      onBack: () => context.pop(),
      child: RegistroForm(
        formKey: _formKey,
        userCtrl: _userCtrl,
        mailCtrl: _mailCtrl,
        onSubmit: _enviarToken,
      ),
    );
  }
}
