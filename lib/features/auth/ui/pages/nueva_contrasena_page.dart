import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/core/ui/notificaciones/app_notifications.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/ui/auth_copy.dart';
import 'package:portal_servicios_usuario/features/auth/ui/forms/nueva_contrasena_form.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_feedback_listener.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_shell.dart';

class NuevaContrasenaPage extends ConsumerStatefulWidget {
  const NuevaContrasenaPage({
    super.key,
    required this.email,
    required this.token,
    this.backRoute = '/token',
  });

  final String email;
  final String token;
  final String backRoute;

  @override
  ConsumerState<NuevaContrasenaPage> createState() =>
      _NuevaContrasenaPageState();
}

class _NuevaContrasenaPageState extends ConsumerState<NuevaContrasenaPage> {
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
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: widget.email.trim(),
          otp: widget.token.trim(),
          newPassword: _passCtrl.text.trim(),
        );

    if (result == null || !mounted) return;

    AppNotifications.show(
      context,
      AppNotifications.authSuccess(AuthCopy.passwordResetSuccess),
    );
    context.go('/login');
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
      onBack: () => context.go(widget.backRoute),
      fallbackBackRoute: widget.backRoute,
      titulo: 'Crea tu nueva contrasena',
      subtitulo:
          'Escribe una contrasena nueva y confirmala\npara recuperar tu acceso.',
      primaryText: 'Cambiar contrasena',
      onPrimary: _cambiar,
      primaryLoading: authState.isLoading,
      footer: Text(
        'Al finalizar volveras al inicio de sesion.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      child: NuevaContrasenaForm(
        formKey: _formKey,
        passCtrl: _passCtrl,
        pass2Ctrl: _pass2Ctrl,
        onSubmit: _cambiar,
      ),
    );
  }
}
