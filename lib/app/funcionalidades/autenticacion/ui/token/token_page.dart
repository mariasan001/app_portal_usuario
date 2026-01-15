import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/token_form.dart';

class TokenPage extends StatefulWidget {
  final String backRoute; // ej: /registro o /recuperar
  final String nextRoute; // ej: /crear-password o /nueva-contrasena
  final String? email;    // opcional (para mostrar/reenviar)

  const TokenPage({
    super.key,
    required this.backRoute,
    required this.nextRoute,
    this.email,
  });

  @override
  State<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  Timer? _timer;
  int _seconds = 40;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 40);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verificar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final code = _codeCtrl.text.trim();
    debugPrint('TOKEN -> code: $code, email: ${widget.email ?? ''}');

    // TODO: aquí conectas API real (registro o reset)
    // await authService.verificarToken(code);

    // ✅ Avanza a la ruta que toque (registro o reset)
    context.go(widget.nextRoute, extra: {
      'email': widget.email ?? '',
      'token': code,
    });
  }

  Future<void> _reenviar() async {
    if (_seconds > 0) return;

    debugPrint('REENVIAR TOKEN -> email: ${widget.email ?? ''}');
    // TODO: llamar API reenviar token (si aplica)
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final correo = (widget.email ?? '').trim();

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,

      showBack: true,
      onBack: () => context.go(widget.backRoute),
      fallbackBackRoute: widget.backRoute,

      titulo: 'Verifica tu código',
      subtitulo: correo.isNotEmpty
          ? 'Enviamos un código de 6 dígitos a:\n$correo'
          : 'Enviamos un código a tu correo.\nEscríbelo para continuar.',

      primaryText: 'Verificar código',
      onPrimary: _verificar,

      child: TokenForm(
        formKey: _formKey,
        codeCtrl: _codeCtrl,
        onSubmit: _verificar,
      ),

      footer: Column(
        children: [
          const SizedBox(height: 6),

          // Reenviar
          TextButton(
            onPressed: _seconds == 0 ? _reenviar : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _seconds == 0 ? 'Reenviar código' : 'Reenviar en $_seconds s',
              style: t.bodySmall?.copyWith(
                color: _seconds == 0 ? ColoresApp.vino : ColoresApp.textoSuave,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // Volver a login
          TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Volver a iniciar sesión',
              style: t.bodySmall?.copyWith(
                color: ColoresApp.texto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
