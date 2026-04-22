import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/notificaciones/app_notifications.dart';
import '../../../../../features/auth/application/auth_providers.dart';
import '../../../../../features/auth/ui/auth_copy.dart';
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
        AppNotifications.show(
          context,
          AppNotifications.missingDeviceEnrollmentData(),
        );
        return;
      }

      try {
        await ref
            .read(authControllerProvider.notifier)
            .confirmDeviceEnrollment(
              enrollmentId: _enrollmentId,
              otp: code,
              username: widget.username,
            );

        if (!mounted) return;
        AppNotifications.show(
          context,
          AppNotifications.authSuccess(AuthCopy.identityVerificationSuccess),
        );
        context.go('/login');
      } catch (_) {
        if (!mounted) return;
        final message =
            ref.read(authControllerProvider).errorMessage ??
            AuthCopy.identityVerificationFailed;
        AppNotifications.show(context, AppNotifications.authError(message));
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

        AppNotifications.show(
          context,
          AppNotifications.info(AuthCopy.identityCodeResent),
        );
      } catch (_) {
        if (!mounted) return;
        final message =
            ref.read(authControllerProvider).errorMessage ??
            AuthCopy.identityVerificationStartFailed;
        AppNotifications.show(context, AppNotifications.authError(message));
      }
    }

    if (!_isDeviceEnrollmentFlow) {
      final email = (widget.email ?? '').trim();
      if (email.isEmpty) {
        AppNotifications.show(context, AppNotifications.missingRecoveryEmail());
        return;
      }

      final result = await ref
          .read(authControllerProvider.notifier)
          .forgotPassword(email: email);

      if (!mounted) return;
      if (result == null) {
        final message =
            ref.read(authControllerProvider).errorMessage ??
            AuthCopy.recoveryStartFailed;
        AppNotifications.show(context, AppNotifications.authError(message));
        return;
      }

      AppNotifications.show(
        context,
        AppNotifications.info(AuthCopy.recoveryCodeResent),
      );
    }

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider);
    final email = (widget.email ?? '').trim();

    final subtitle = _isDeviceEnrollmentFlow
        ? AuthCopy.deviceVerificationSubtitle
        : AuthCopy.recoveryVerificationSubtitle(email);

    return AuthShell(
      backgroundAsset: 'assets/img/fondo.png',
      overlayOpacity: 0.10,
      primaryLoading: authState.isLoading,
      showBack: true,
      onBack: () => context.go(widget.backRoute),
      fallbackBackRoute: widget.backRoute,
      titulo: _isDeviceEnrollmentFlow
          ? AuthCopy.deviceVerificationTitle
          : AuthCopy.recoveryVerificationTitle,
      subtitulo: subtitle,
      primaryText: _isDeviceEnrollmentFlow
          ? AuthCopy.confirmIdentityAction
          : AuthCopy.continueWithCode,
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
              _seconds == 0
                  ? AuthCopy.resendCode
                  : AuthCopy.resendCodeIn(_seconds),
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
              AuthCopy.backToLogin,
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
