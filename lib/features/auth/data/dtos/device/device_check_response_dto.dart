import '../../../domain/entities/device/device_check_result.dart';

/// Respuesta cruda del endpoint de validacion de dispositivo.
class DeviceCheckResponseDto {
  const DeviceCheckResponseDto({
    required this.code,
    required this.message,
    this.deviceIdHash,
  });

  final String code;
  final String message;
  final String? deviceIdHash;

  factory DeviceCheckResponseDto.fromJson(Map<String, dynamic> json) {
    return DeviceCheckResponseDto(
      code: (json['code'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
      deviceIdHash: (json['deviceIdHash'] as String?)?.trim(),
    );
  }

  DeviceCheckResult toDomain() {
    return DeviceCheckResult(
      code: DeviceCheckResult.parseCode(code),
      rawCode: code,
      message: message,
      deviceIdHash: deviceIdHash,
    );
  }
}
