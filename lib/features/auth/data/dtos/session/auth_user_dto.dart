import '../../../domain/entities/session/auth_user.dart';

class AuthUserDto {
  const AuthUserDto({
    required this.userId,
    required this.username,
    required this.email,
    required this.spId,
    required this.status,
    required this.roles,
  });

  final int userId;
  final String username;
  final String email;
  final String spId;
  final String status;
  final List<String> roles;

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];

    return AuthUserDto(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
      spId: (json['spId'] as String? ?? '').trim(),
      status: (json['status'] as String? ?? '').trim(),
      roles: rawRoles is List
          ? rawRoles.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
    );
  }

  AuthUser toDomain() {
    return AuthUser(
      userId: userId,
      username: username,
      email: email,
      spId: spId,
      status: status,
      roles: roles,
    );
  }
}
