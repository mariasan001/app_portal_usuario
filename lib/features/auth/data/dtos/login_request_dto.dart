import '../../../../core/config/app_environment.dart';

class LoginRequestDto {
  const LoginRequestDto({
    required this.username,
    required this.password,
    required this.appCode,
  });

  final String username;
  final String password;
  final String appCode;

  factory LoginRequestDto.fromCredentials({
    required String username,
    required String password,
  }) {
    return LoginRequestDto(
      username: username,
      password: password,
      appCode: AppEnvironment.iamAppCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password, 'appCode': appCode};
  }
}
