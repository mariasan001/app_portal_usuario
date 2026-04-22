class DeviceEnrollmentConfirmResult {
  const DeviceEnrollmentConfirmResult({
    required this.code,
    required this.message,
    this.deviceIdHash,
  });

  final String code;
  final String message;
  final String? deviceIdHash;
}
