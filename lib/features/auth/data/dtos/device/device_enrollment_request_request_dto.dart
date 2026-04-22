import '../../../../../core/config/app_environment.dart';
import '../../../../../core/device/models/app_device_info.dart';
import 'device_payload_dto.dart';

class DeviceEnrollmentRequestRequestDto {
  const DeviceEnrollmentRequestRequestDto({
    required this.username,
    required this.appCode,
    required this.device,
  });

  final String username;
  final String appCode;
  final DevicePayloadDto device;

  factory DeviceEnrollmentRequestRequestDto.fromDomain({
    required String username,
    required AppDeviceInfo device,
  }) {
    return DeviceEnrollmentRequestRequestDto(
      username: username,
      appCode: AppEnvironment.iamAppCode,
      device: DevicePayloadDto.fromDomain(device),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'appCode': appCode,
      'device': device.toJson(),
    };
  }
}
