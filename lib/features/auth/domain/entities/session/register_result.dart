class RegisterResult {
  const RegisterResult({
    required this.userId,
    required this.username,
    required this.status,
    required this.message,
  });

  final int userId;
  final String username;
  final String status;
  final String message;
}
