class OtpVerifyRequestDto {
  const OtpVerifyRequestDto({
    required this.usernameOrEmail,
    required this.purpose,
    required this.otp,
  });

  final String usernameOrEmail;
  final String purpose;
  final String otp;

  Map<String, dynamic> toJson() {
    return {'usernameOrEmail': usernameOrEmail, 'purpose': purpose, 'otp': otp};
  }
}
