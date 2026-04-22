import '../domain/entities/device/device_check_result.dart';

abstract final class AuthCopy {
  static const loginWelcomeSubtitle =
      'Inicia sesion para consultar tu informacion y continuar con tus servicios.';
  static const loginUnexpectedError =
      'No pudimos iniciar sesion. Intenta nuevamente.';
  static const registerSuccess =
      'Tu cuenta fue creada. Ya puedes iniciar sesion.';
  static const registerFailed = 'No pudimos completar tu registro.';
  static const recoveryCodeSent =
      'Te enviamos un codigo de verificacion a tu correo.';
  static const recoveryCodeResent =
      'Te enviamos un nuevo codigo de verificacion.';
  static const recoveryStartFailed =
      'No pudimos enviar el codigo de verificacion.';
  static const missingRecoveryEmail =
      'Escribe tu correo para reenviar el codigo.';
  static const passwordResetSuccess =
      'Tu contrasena fue actualizada. Inicia sesion nuevamente.';
  static const passwordResetFailed = 'No pudimos actualizar tu contrasena.';
  static const identitySetupMissing =
      'No pudimos preparar la verificacion de identidad. Intenta nuevamente.';
  static const identityDataMissing =
      'Necesitamos confirmar tu identidad antes de continuar.';
  static const identityVerificationStarted =
      'Verificaremos tu identidad para proteger tu cuenta.';
  static const identityVerificationStartFailed =
      'No pudimos iniciar la verificacion de identidad.';
  static const identityCodeResent =
      'Te enviamos un nuevo codigo para verificar tu identidad.';
  static const identityVerificationSuccess =
      'Identidad verificada. Ya puedes iniciar sesion.';
  static const identityVerificationFailed =
      'No pudimos completar la verificacion de identidad.';
  static const deviceVerificationTitle = 'Verifica tu identidad';
  static const deviceVerificationSubtitle =
      'Para proteger tu cuenta, confirma tu identidad con el codigo que te enviamos.';
  static const recoveryVerificationTitle = 'Confirma tu codigo';
  static String recoveryVerificationSubtitle(String email) {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return 'Te enviamos un codigo de verificacion. Escribelo para continuar.';
    }

    return 'Te enviamos un codigo de verificacion a:\n$normalizedEmail';
  }

  static const continueWithCode = 'Continuar';
  static const confirmIdentityAction = 'Verificar identidad';
  static const resendCode = 'Reenviar codigo';
  static String resendCodeIn(int seconds) => 'Reenviar en $seconds s';
  static const backToLogin = 'Volver a iniciar sesion';

  static String deviceCheckMessage(DeviceCheckResult result) {
    switch (result.code) {
      case DeviceCheckCode.ok:
        return 'Identidad verificada.';
      case DeviceCheckCode.deviceNotEnrolled:
        return 'Para proteger tu cuenta, primero verificaremos tu identidad en este dispositivo.';
      case DeviceCheckCode.deviceMismatch:
        return 'Detectamos un dispositivo distinto al registrado. Verificaremos tu identidad para continuar.';
      case DeviceCheckCode.deviceBlocked:
        return 'Por seguridad, este dispositivo no puede continuar con el acceso.';
      case DeviceCheckCode.unknown:
        return 'No pudimos confirmar tu identidad en este dispositivo.';
    }
  }
}
