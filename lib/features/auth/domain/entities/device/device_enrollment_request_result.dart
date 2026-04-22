class DeviceEnrollmentRequestResult {
  const DeviceEnrollmentRequestResult({
    required this.code,
    required this.message,
    this.enrollmentId,
  });

  final String code;
  final String message;
  final String? enrollmentId;
}
