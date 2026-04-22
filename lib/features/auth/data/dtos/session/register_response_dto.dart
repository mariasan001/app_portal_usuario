import '../../../domain/entities/session/register_result.dart';

class RegisterResponseDto {
  const RegisterResponseDto({
    required this.userId,
    required this.username,
    required this.status,
    required this.message,
  });

  final int userId;
  final String username;
  final String status;
  final String message;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? '').trim(),
      message: (json['message'] as String? ?? '').trim(),
    );
  }

  RegisterResult toDomain() {
    return RegisterResult(
      userId: userId,
      username: username,
      status: status,
      message: message,
    );
  }
}
