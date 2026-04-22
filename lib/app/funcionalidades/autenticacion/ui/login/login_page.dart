import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../../features/auth/application/auth_state.dart';
import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/login_form.dart';

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
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La API no devolvio enrollmentId para continuar el enrolamiento.',
            ),
          ),
        );
        return;
      }

      context.go(
        '/token',
        extra: {
          'flow': 'device-enroll',
          'username': username,
          'enrollmentId': enrollmentId,
          'backRoute': '/login',
          'nextRoute': '/login',
        },
      );
    } catch (_) {
      if (!mounted) return;
      final message =
          ref.read(authControllerProvider).errorMessage ??
          'No se pudo iniciar el enrolamiento del dispositivo.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _startingEnrollment = false);
      } else {
        _startingEnrollment = false;
      }
    }
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

      final wasAuthenticated = previous?.isAuthenticated ?? false;
      if (next.isAuthenticated && !wasAuthenticated) {
        context.go('/home');
      }
    });

    final t = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,
      primaryLoading: authState.isLoading || _startingEnrollment,
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
      subtitulo:
          'Inicia sesion para acceder a tus recibos, movimientos\ny normativas vigentes.',
      primaryText: 'Entrar a mi perfil',
      onPrimary: _login,
      footer: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Aun no tienes cuenta? ',
                  style: t.bodySmall?.copyWith(
                    color: ColoresApp.texto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () => context.go('/registro'),
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(
                        'Registrarme',
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
          const SizedBox(height: 10),
          Text(
            'Aviso de Privacidad',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: ColoresApp.textoSuave),
          ),
          const SizedBox(height: 8),
          Text(
            'Desarrollado por Oficialia Mayor . Direccion General del Personal',
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
      child: LoginForm(
        formKey: _formKey,
        userCtrl: _userCtrl,
        passCtrl: _passCtrl,
        onLogin: _login,
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({required this.asset, this.height = 54, this.maxWidth = 210});

  final String asset;
  final double height;
  final double maxWidth;

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
