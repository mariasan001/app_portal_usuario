import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/core/ui/notificaciones/app_notifications.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';
import 'package:portal_servicios_usuario/features/auth/ui/auth_copy.dart';
import 'package:portal_servicios_usuario/features/auth/ui/forms/login_form.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_feedback_listener.dart';
import 'package:portal_servicios_usuario/features/auth/ui/helpers/auth_navigation_helper.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_inline_link.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_logo_row.dart';
import 'package:portal_servicios_usuario/features/auth/ui/widgets/auth_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _startingEnrollment = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await ref
        .read(authControllerProvider.notifier)
        .login(
          username: _userCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
  }

  Future<void> _startDeviceEnrollment(String username) async {
    if (_startingEnrollment) return;

    setState(() => _startingEnrollment = true);

    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestDeviceEnrollment(username: username);

      if (!mounted) return;

      final enrollmentId = (result.enrollmentId ?? '').trim();
      if (enrollmentId.isEmpty) {
        AppNotifications.show(context, AppNotifications.missingEnrollmentId());
        return;
      }

      context.go(
        '/token',
        extra: buildDeviceEnrollmentRouteData(
          username: username,
          enrollmentId: enrollmentId,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final message =
          ref.read(authControllerProvider).errorMessage ??
          AuthCopy.identityVerificationStartFailed;
      AppNotifications.show(context, AppNotifications.authError(message));
    } finally {
      if (mounted) {
        setState(() => _startingEnrollment = false);
      } else {
        _startingEnrollment = false;
      }
    }
  }

  Widget _buildFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AuthInlineLink(
          prefixText: 'Aun no tienes cuenta? ',
          actionText: 'Registrarme',
          onTap: () => context.go('/registro'),
        ),
        const SizedBox(height: 10),
        Text(
          'Aviso de Privacidad',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: ColoresApp.textoSuave),
        ),
        const SizedBox(height: 8),
        Text(
          'Desarrollado por Oficialia Mayor . Direccion General del Personal',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 10.6,
            height: 1.25,
            color: ColoresApp.textoSuave,
            fontWeight: FontWeight.w600,
          ),
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

      final previousDeviceCode = previous?.deviceCheckResult?.rawCode;
      final nextDeviceResult = next.deviceCheckResult;
      if (nextDeviceResult != null &&
          nextDeviceResult.requiresEnrollment &&
          nextDeviceResult.rawCode != previousDeviceCode) {
        final username = (next.pendingUsername ?? '').trim();
        if (username.isNotEmpty) {
          _startDeviceEnrollment(username);
        }
      }

      handleAuthenticatedNavigation(
        context: context,
        previous: previous,
        next: next,
      );
    });

    final authState = ref.watch(authControllerProvider);

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,
      primaryLoading: authState.isLoading || _startingEnrollment,
      childTop: const AuthLogoRow(),
      titulo: 'Bienvenido a tu espacio\ndigital',
      subtitulo: AuthCopy.loginWelcomeSubtitle,
      primaryText: 'Entrar a mi perfil',
      onPrimary: _login,
      footer: _buildFooter(context),
      child: LoginForm(
        formKey: _formKey,
        userCtrl: _userCtrl,
        passCtrl: _passCtrl,
        onLogin: _login,
      ),
    );
  }
}
