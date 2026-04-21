import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<LoginResult> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
