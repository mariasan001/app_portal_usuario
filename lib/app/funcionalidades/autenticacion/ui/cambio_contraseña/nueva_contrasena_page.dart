import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../../features/auth/application/auth_state.dart';
import '../widgets/auth_shell.dart';
import 'widgets/nueva_contrasena_form.dart';

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
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: widget.email.trim(),
          otp: widget.token.trim(),
          newPassword: _passCtrl.text.trim(),
        );

    if (result == null || !mounted) {
      return;
    }

    final message = result.message.trim().isEmpty
        ? 'Contrasena actualizada correctamente. Inicia sesion de nuevo.'
        : result.message.trim();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;

      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
        ref.read(authControllerProvider.notifier).clearFeedback();
      }
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
