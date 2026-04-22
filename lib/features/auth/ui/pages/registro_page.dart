import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/core/ui/notificaciones/app_notifications.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/ui/auth_copy.dart';
import 'package:portal_servicios_usuario/features/auth/ui/forms/registro_form.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_feedback_listener.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_inline_link.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_shell.dart';

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
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

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

    AppNotifications.show(
      context,
      AppNotifications.authSuccess(AuthCopy.registerSuccess),
    );
    context.go('/login');
  }

  Widget _buildFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: 4),
        AuthInlineLink(
          prefixText: 'Ya tienes cuenta? ',
          actionText: 'Inicia sesion',
          onTap: () => context.go('/login'),
        ),
        const SizedBox(height: 6),
        Text(
          'Al continuar aceptas el Aviso de Privacidad.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: ColoresApp.textoSuave),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      handleAuthErrorFeedback(
        context: context,
        ref: ref,
        previous: previous,
        next: next,
      );
    });

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
      footer: _buildFooter(context),
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
