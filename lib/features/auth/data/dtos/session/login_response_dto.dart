import '../../../domain/entities/session/login_result.dart';

/// DTO de response = lectura cruda de la respuesta del backend.
///
/// Despues se transforma a LoginResult, que es el objeto que usa la app.
class LoginResponseDto {
  const LoginResponseDto({
    required this.username,
    required this.userId,
    required this.message,
  });

  final String username;
  final int userId;
  final String message;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      username: (json['username'] as String? ?? '').trim(),
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      message: (json['message'] as String? ?? '').trim(),
    );
  }

  LoginResult toDomain() {
    return LoginResult(username: username, userId: userId, message: message);
  }
}
