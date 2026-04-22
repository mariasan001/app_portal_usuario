enum DeviceCheckCode {
  ok,
  deviceNotEnrolled,
  deviceMismatch,
  deviceBlocked,
  unknown,
}

class DeviceCheckResult {
  const DeviceCheckResult({
    required this.code,
    required this.rawCode,
    required this.message,
    this.deviceIdHash,
  });

  final DeviceCheckCode code;
  final String rawCode;
  final String message;
  final String? deviceIdHash;

  bool get isAuthorized => code == DeviceCheckCode.ok;

  bool get requiresEnrollment =>
      code == DeviceCheckCode.deviceNotEnrolled ||
      code == DeviceCheckCode.deviceMismatch;

  static DeviceCheckCode parseCode(String rawCode) {
    switch (rawCode.trim().toUpperCase()) {
      case 'OK':
        return DeviceCheckCode.ok;
      case 'DEVICE_NOT_ENROLLED':
        return DeviceCheckCode.deviceNotEnrolled;
      case 'DEVICE_MISMATCH':
        return DeviceCheckCode.deviceMismatch;
      case 'DEVICE_BLOCKED':
        return DeviceCheckCode.deviceBlocked;
      default:
        return DeviceCheckCode.unknown;
    }
  }
}
