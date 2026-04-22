import '../../domain/entities/auth_action_result.dart';

class AuthActionResponseDto {
  const AuthActionResponseDto({required this.ok, required this.message});

  final bool ok;
  final String message;

  factory AuthActionResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthActionResponseDto(
      ok: json['ok'] as bool? ?? false,
      message: (json['message'] as String? ?? '').trim(),
    );
  }

  AuthActionResult toDomain() {
    return AuthActionResult(ok: ok, message: message);
  }
}
