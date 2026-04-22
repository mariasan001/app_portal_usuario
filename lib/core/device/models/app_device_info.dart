class AppDeviceInfo {
  const AppDeviceInfo({
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
