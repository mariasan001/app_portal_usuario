import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../tema/colores.dart';
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

    debugPrint('REGISTRO -> user: $user, email: $email');

    context.go('/token');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10, // mantiene el fondo con contraste como login

      // ✅ Back arriba (tu AuthShell lo dibuja)
      showBack: true,
      onBack: () => context.go('/login'),
      fallbackBackRoute: '/login',

      // ✅ Copy más “cool”
      titulo: 'Activa tu perfil',
      subtitulo:
          'Usa tu número de servidor público y tu correo para recibir\nun código de verificación y continuar.',

      // ✅ CTA con sentido (no “Ingresar”)
      primaryText: 'Enviar código',
      onPrimary: _enviarToken,

      child: RegistroForm(
        formKey: _formKey,
        userCtrl: _userCtrl,
        mailCtrl: _mailCtrl,
        onSubmit: _enviarToken,
      ),

      // ✅ Acción abajo: volver a login
      footer: Column(
        children: [
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '¿Ya tienes cuenta? ',
                  style: t.bodySmall?.copyWith(
                    color: ColoresApp.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () => context.go('/login'),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Inicia sesión',
                        style: t.bodySmall?.copyWith(
                          color: ColoresApp.vino,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Al continuar aceptas el Aviso de Privacidad.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: ColoresApp.textoSuave),
          ),
        ],
      ),
    );
  }
}
