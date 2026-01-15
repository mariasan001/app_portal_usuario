import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    // TODO: aquí conectas API real (service)
    // await authService.login(user, pass);

    debugPrint('LOGIN -> user: $user, pass: $pass');

    // TODO: si todo OK:
    // context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AuthShell(
      // ✅ FONDO
      backgroundAsset: 'assets/img/fondo.png',

      titulo: 'Bienvenido a tu espacio\ndigital',
      subtitulo:
          'Inicia sesión para acceder a tus recibos, movimientos\ny normativas vigentes.',
      primaryText: 'Entrar a mi perfil',
      onPrimary: _login,

      child: LoginForm(
        formKey: _formKey,
        userCtrl: _userCtrl,
        passCtrl: _passCtrl,
        onLogin: _login,
      ),

      footer: Column(
        children: [
          TextButton(
            onPressed: () => context.go('/registro'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'No tengo cuenta quiero ',
                    style: t.bodySmall?.copyWith(
                      color: ColoresApp.texto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: 'registrarme',
                    style: t.bodySmall?.copyWith(
                      color: ColoresApp.vino,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Aviso de Privacidad',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: ColoresApp.textoSuave),
          ),
        ],
      ),
    );
  }
}
