import '../../domain/entities/device_enrollment_request_result.dart';

class DeviceEnrollmentRequestResponseDto {
  const DeviceEnrollmentRequestResponseDto({
    required this.code,
    required this.message,
    this.enrollmentId,
  });

  final String code;
  final String message;
  final String? enrollmentId;

  factory DeviceEnrollmentRequestResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawEnrollmentId =
        json['enrollmentId'] ?? json['enrolmentId'] ?? json['requestId'];

    return DeviceEnrollmentRequestResponseDto(
      code: (json['code'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      enrollmentId: (rawEnrollmentId as String?)?.trim(),
    );
  }

  DeviceEnrollmentRequestResult toDomain() {
    return DeviceEnrollmentRequestResult(
      code: code,
      message: message,
      enrollmentId: enrollmentId,
    );
  }
}
