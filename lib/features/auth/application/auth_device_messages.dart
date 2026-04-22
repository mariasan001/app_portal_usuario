import '../domain/entities/device_check_result.dart';

String defaultDeviceMessage(DeviceCheckResult result) {
  if (result.message.trim().isNotEmpty) {
    return result.message.trim();
  }

  switch (result.code) {
    case DeviceCheckCode.ok:
      return 'Dispositivo reconocido.';
    case DeviceCheckCode.deviceNotEnrolled:
      return 'Este dispositivo no está enrolado para tu cuenta.';
    case DeviceCheckCode.deviceMismatch:
      return 'Este dispositivo no coincide con el equipo autorizado.';
    case DeviceCheckCode.deviceBlocked:
      return 'El dispositivo registrado se encuentra bloqueado.';
    case DeviceCheckCode.unknown:
      return 'No se pudo validar el dispositivo actual.';
  }
}
