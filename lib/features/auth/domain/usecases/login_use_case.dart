import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase = una accion puntual del negocio.
///
/// Este caso de uso deja claro que "iniciar sesion" es una operacion del
/// dominio y no algo que deba vivir dentro de la UI.
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
