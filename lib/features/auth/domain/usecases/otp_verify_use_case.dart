import '../entities/auth_action_result.dart';
import '../repositories/auth_repository.dart';

/// Valida un OTP para un proposito concreto, por ejemplo PASSWORD_RESET.
class OtpVerifyUseCase {
  const OtpVerifyUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthActionResult> call({
    required String usernameOrEmail,
    required String purpose,
    required String otp,
  }) {
    return _repository.verifyOtp(
      usernameOrEmail: usernameOrEmail,
      purpose: purpose,
      otp: otp,
    );
  }
}
