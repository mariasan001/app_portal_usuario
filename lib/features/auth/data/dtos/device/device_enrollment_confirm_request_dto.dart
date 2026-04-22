import '../../../../../core/config/app_environment.dart';

class DeviceEnrollmentConfirmRequestDto {
  const DeviceEnrollmentConfirmRequestDto({
    required this.enrollmentId,
    required this.otp,
    required this.username,
    required this.appCode,
  });

  final String enrollmentId;
  final String otp;
  final String username;
  final String appCode;

  factory DeviceEnrollmentConfirmRequestDto.fromDomain({
    required String enrollmentId,
    required String otp,
    required String username,
  }) {
    return DeviceEnrollmentConfirmRequestDto(
      enrollmentId: enrollmentId,
      otp: otp,
      username: username,
      appCode: AppEnvironment.iamAppCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'otp': otp,
      'username': username,
      'appCode': appCode,
    };
  }
}
