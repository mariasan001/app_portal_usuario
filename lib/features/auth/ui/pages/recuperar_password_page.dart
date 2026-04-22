import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/core/ui/notificaciones/app_notifications.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/ui/auth_copy.dart';
import 'package:portal_servicios_usuario/features/auth/ui/forms/recuperar_password_form.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_feedback_listener.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_navigation_helper.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_shell.dart';

class RecuperarPasswordPage extends ConsumerStatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  ConsumerState<RecuperarPasswordPage> createState() =>
      _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends ConsumerState<RecuperarPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _mailCtrl = TextEditingController();

  @override
  void dispose() {
    _mailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _mailCtrl.text.trim();
    final result = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(email: email);

    if (result == null || !mounted) return;

    AppNotifications.show(
      context,
      AppNotifications.authSuccess(AuthCopy.recoveryCodeSent),
    );
    context.go('/token', extra: buildPasswordResetTokenRouteData(email: email));
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
      titulo: 'Recupera tu acceso',
      subtitulo:
          'Escribe el correo con el que te registraste\npara enviarte un codigo de verificacion.',
      primaryText: 'Enviar codigo',
      onPrimary: _enviarCodigo,
      primaryLoading: authState.isLoading,
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: Text(
          AuthCopy.backToLogin,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      child: RecuperarPasswordForm(
        formKey: _formKey,
        mailCtrl: _mailCtrl,
        onSubmit: _enviarCodigo,
      ),
    );
  }
}
