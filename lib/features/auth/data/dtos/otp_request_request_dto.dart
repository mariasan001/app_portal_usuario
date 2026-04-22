class OtpRequestRequestDto {
  const OtpRequestRequestDto({
    required this.usernameOrEmail,
    required this.purpose,
  });

  final String usernameOrEmail;
  final String purpose;

  Map<String, dynamic> toJson() {
    return {'usernameOrEmail': usernameOrEmail, 'purpose': purpose};
  }
}
