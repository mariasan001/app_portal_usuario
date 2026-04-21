import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/login_form.dart';
// ...imports
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

    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,

      // ✅ Logos ahora van “hasta arriba” por el AuthShell
      childTop: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _LogoBox(
                asset: 'assets/img/escudo_2.png',
                height: 94,
                maxWidth: 140,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _LogoBox(
                asset: 'assets/img/escudo.png',
                height: 54,
                maxWidth: 210,
              ),
            ),
          ),
        ],
      ),

      titulo: 'Bienvenido a tu espacio\ndigital',
      subtitulo: 'Inicia sesión para acceder a tus recibos, movimientos\ny normativas vigentes.',
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
          // ...tu footer igual (registro, recuperar, aviso, leyenda)
          Text(
            'Aviso de Privacidad',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: ColoresApp.textoSuave),
          ),
          const SizedBox(height: 8),
          Text(
            'Desarrollado por Oficialía Mayor . Dirección General del Personal',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
              fontSize: 10.6,
              height: 1.25,
              color: ColoresApp.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  final String asset;
  final double height;
  final double maxWidth;

  const _LogoBox({
    required this.asset,
    this.height = 54,
    this.maxWidth = 210,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

    
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
