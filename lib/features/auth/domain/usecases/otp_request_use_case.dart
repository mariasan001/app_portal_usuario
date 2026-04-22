import '../entities/auth_action_result.dart';
import '../repositories/auth_repository.dart';

class OtpRequestUseCase {
  const OtpRequestUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthActionResult> call({
    required String usernameOrEmail,
    required String purpose,
  }) {
    return _repository.requestOtp(
      usernameOrEmail: usernameOrEmail,
      purpose: purpose,
    );
  }
}
