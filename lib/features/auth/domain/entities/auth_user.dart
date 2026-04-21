class AuthUser {
  const AuthUser({
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
}
