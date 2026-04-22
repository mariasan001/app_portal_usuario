class RegisterRequestDto {
  const RegisterRequestDto({
    required this.claveSp,
    required this.plaza,
    required this.puesto,
    required this.email,
    required this.password,
    required this.phone,
  });

  final String claveSp;
  final String plaza;
  final String puesto;
  final String email;
  final String password;
  final String phone;

  Map<String, dynamic> toJson() {
    return {
      'claveSp': claveSp,
      'plaza': plaza,
      'puesto': puesto,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }
}
