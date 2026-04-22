import '../../../../../core/device/models/app_device_info.dart';

class DevicePayloadDto {
  const DevicePayloadDto({
    required this.deviceIdFinal,
    required this.fingerprintId,
    required this.brand,
    required this.model,
    required this.platform,
    required this.osVersion,
    required this.arch,
    required this.appVersion,
  });

  final String deviceIdFinal;
  final String fingerprintId;
  final String brand;
  final String model;
  final String platform;
  final String osVersion;
  final String arch;
  final String appVersion;

  factory DevicePayloadDto.fromDomain(AppDeviceInfo device) {
    return DevicePayloadDto(
      deviceIdFinal: device.deviceIdFinal,
      fingerprintId: device.fingerprintId,
      brand: device.brand,
      model: device.model,
      platform: device.platform,
      osVersion: device.osVersion,
      arch: device.arch,
      appVersion: device.appVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceIdFinal': deviceIdFinal,
      'fingerprintId': fingerprintId,
      'brand': brand,
      'model': model,
      'platform': platform,
      'osVersion': osVersion,
      'arch': arch,
      'appVersion': appVersion,
    };
  }
}
