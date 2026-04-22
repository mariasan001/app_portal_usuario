import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/notificaciones/app_notifications.dart';
import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../../features/auth/application/auth_state.dart';
import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/registro_form.dart';

class RegistroPage extends ConsumerStatefulWidget {
  const RegistroPage({super.key});

  @override
  ConsumerState<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends ConsumerState<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _claveSpCtrl = TextEditingController();
  final _plazaCtrl = TextEditingController();
  final _puestoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _claveSpCtrl.dispose();
    _plazaCtrl.dispose();
    _puestoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .register(
          claveSp: _claveSpCtrl.text.trim(),
          plaza: _plazaCtrl.text.trim(),
          puesto: _puestoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
        );

    if (result == null || !mounted) return;

    final message = result.message.trim().isEmpty
        ? 'Registro completado. Ahora puedes iniciar sesion.'
        : result.message.trim();

    AppNotifications.show(context, AppNotifications.authSuccess(message));
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;

      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        AppNotifications.show(context, AppNotifications.authError(nextError));
        ref.read(authControllerProvider.notifier).clearFeedback();
      }
    });

    final t = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,
      showBack: true,
      onBack: () => context.go('/login'),
      fallbackBackRoute: '/login',
      titulo: 'Activa tu perfil',
      subtitulo:
          'Completa tu informacion laboral y de contacto para validar tu registro en la plataforma.',
      primaryText: 'Crear cuenta',
      onPrimary: _registrar,
      primaryLoading: authState.isLoading,
      footer: Column(
        children: [
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Ya tienes cuenta? ',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        'Inicia sesion',
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
      child: RegistroForm(
        formKey: _formKey,
        claveSpCtrl: _claveSpCtrl,
        plazaCtrl: _plazaCtrl,
        puestoCtrl: _puestoCtrl,
        emailCtrl: _emailCtrl,
        passwordCtrl: _passwordCtrl,
        phoneCtrl: _phoneCtrl,
        onSubmit: _registrar,
      ),
    );
  }
}
