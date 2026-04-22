import '../../../../../core/config/app_environment.dart';

/// DTO de request = formato exacto que la API espera al hacer login.
///
/// Se separa del dominio para que cambios del backend no contaminen toda la app.
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
