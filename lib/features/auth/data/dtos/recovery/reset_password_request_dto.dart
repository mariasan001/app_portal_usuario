class ResetPasswordRequestDto {
  const ResetPasswordRequestDto({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  final String email;
  final String otp;
  final String newPassword;

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'newPassword': newPassword};
  }
}
