import '../../entities/session/auth_user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.getCurrentUser();
}
