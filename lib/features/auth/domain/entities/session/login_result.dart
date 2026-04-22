class LoginResult {
  const LoginResult({
    required this.username,
    required this.userId,
    required this.message,
  });

  final String username;
  final int userId;
  final String message;
}
