import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/notificaciones/app_notifications.dart';
import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../../features/auth/application/auth_state.dart';
import '../../../../../features/auth/ui/auth_copy.dart';
import '../widgets/auth_shell.dart';
import 'widgets/recuperar_password_form.dart';

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
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final email = _mailCtrl.text.trim();
    final result = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(email: email);

    if (result == null || !mounted) {
      return;
    }

    AppNotifications.show(
      context,
      AppNotifications.authSuccess(AuthCopy.recoveryCodeSent),
    );

    context.go(
      '/token',
      extra: {
        'flow': 'password-reset',
        'email': email,
        'backRoute': '/recuperar',
        'nextRoute': '/nueva-contrasena',
      },
    );
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
