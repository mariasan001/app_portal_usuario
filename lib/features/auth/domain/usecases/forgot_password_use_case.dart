import '../entities/auth_action_result.dart';
import '../repositories/auth_repository.dart';

/// Inicia la recuperacion de password solicitando el envio del codigo.
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthActionResult> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}
