import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../tema/colores.dart';
import '../widgets/auth_shell.dart';
import 'widgets/token_form.dart';

class TokenPage extends ConsumerStatefulWidget {
  const TokenPage({
    super.key,
    required this.backRoute,
    required this.nextRoute,
    required this.flow,
    this.email,
    this.username = '',
    this.enrollmentId = '',
  });

  final String backRoute;
  final String nextRoute;
  final String? email;
  final String flow;
  final String username;
  final String enrollmentId;

  @override
  ConsumerState<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends ConsumerState<TokenPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  Timer? _timer;
  int _seconds = 40;
  late String _enrollmentId;

  bool get _isDeviceEnrollmentFlow => widget.flow == 'device-enroll';

  @override
  void initState() {
    super.initState();
    _enrollmentId = widget.enrollmentId;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 40);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds <= 1) {
        timer.cancel();
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

    if (_isDeviceEnrollmentFlow) {
      if (_enrollmentId.trim().isEmpty || widget.username.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falta informacion para confirmar el dispositivo.'),
          ),
        );
        return;
      }

      try {
        final result = await ref
            .read(authControllerProvider.notifier)
            .confirmDeviceEnrollment(
              enrollmentId: _enrollmentId,
              otp: code,
              username: widget.username,
            );

        if (!mounted) return;
        final message = result.message.trim().isEmpty
            ? 'Dispositivo enrolado correctamente. Ahora inicia sesion.'
            : result.message.trim();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        context.go('/login');
      } catch (_) {
        if (!mounted) return;
        final message =
            ref.read(authControllerProvider).errorMessage ??
            'No se pudo confirmar el enrolamiento del dispositivo.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    context.go(
      widget.nextRoute,
      extra: {
        'email': widget.email ?? '',
        'token': code,
        'backRoute': '/token',
      },
    );
  }

  Future<void> _reenviar() async {
    if (_seconds > 0) return;

    if (_isDeviceEnrollmentFlow) {
      try {
        final result = await ref
            .read(authControllerProvider.notifier)
            .requestDeviceEnrollment(username: widget.username);

        if (!mounted) return;
        final enrollmentId = (result.enrollmentId ?? '').trim();
        if (enrollmentId.isNotEmpty) {
          setState(() => _enrollmentId = enrollmentId);
        }

        final message = result.message.trim().isEmpty
            ? 'Se envio un nuevo codigo para enrolar tu dispositivo.'
            : result.message.trim();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } catch (_) {
        if (!mounted) return;
        final message =
            ref.read(authControllerProvider).errorMessage ??
            'No se pudo reenviar el codigo del enrolamiento.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }

    if (!_isDeviceEnrollmentFlow) {
      final email = (widget.email ?? '').trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falta el correo para reenviar el codigo.'),
          ),
        );
        return;
      }

      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(email: email);

      if (!mounted) return;
      if (result == null) {
        final message =
            ref.read(authControllerProvider).errorMessage ??
            'No se pudo reenviar el codigo de recuperacion.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      final message = result.message.trim().isEmpty
          ? 'Te enviamos un nuevo codigo de recuperacion.'
          : result.message.trim();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final email = (widget.email ?? '').trim();

    final subtitle = _isDeviceEnrollmentFlow
        ? 'Tu cuenta requiere validar este dispositivo.\nIngresa el codigo OTP para continuar.'
        : (email.isNotEmpty
              ? 'Enviamos un codigo de recuperacion a:\n$email'
              : 'Enviamos un codigo de recuperacion.\nEscribelo para continuar.');

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,
      primaryLoading: authState.isLoading,
      showBack: true,
      onBack: () => context.go(widget.backRoute),
      fallbackBackRoute: widget.backRoute,
      titulo: _isDeviceEnrollmentFlow
          ? 'Autoriza este dispositivo'
          : 'Verifica tu codigo',
      subtitulo: subtitle,
      primaryText: _isDeviceEnrollmentFlow
          ? 'Confirmar dispositivo'
          : 'Continuar',
      onPrimary: _verificar,
      footer: Column(
        children: [
          const SizedBox(height: 6),
          TextButton(
            onPressed: _seconds == 0 ? _reenviar : null,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _seconds == 0 ? 'Reenviar codigo' : 'Reenviar en $_seconds s',
              style: t.bodySmall?.copyWith(
                color: _seconds == 0 ? ColoresApp.vino : ColoresApp.textoSuave,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Volver a iniciar sesion',
              style: t.bodySmall?.copyWith(
                color: ColoresApp.texto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      child: TokenForm(
        formKey: _formKey,
        codeCtrl: _codeCtrl,
        onSubmit: _verificar,
      ),
    );
  }
}
