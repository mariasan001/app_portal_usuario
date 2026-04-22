import '../../domain/entities/device_enrollment_confirm_result.dart';

class DeviceEnrollmentConfirmResponseDto {
  const DeviceEnrollmentConfirmResponseDto({
    required this.code,
    required this.message,
    this.deviceIdHash,
  });

  final String code;
  final String message;
  final String? deviceIdHash;

  factory DeviceEnrollmentConfirmResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return DeviceEnrollmentConfirmResponseDto(
      code: (json['code'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      deviceIdHash: (json['deviceIdHash'] as String?)?.trim(),
    );
  }

  DeviceEnrollmentConfirmResult toDomain() {
    return DeviceEnrollmentConfirmResult(
      code: code,
      message: message,
      deviceIdHash: deviceIdHash,
    );
  }
}
