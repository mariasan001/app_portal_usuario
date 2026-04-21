import '../repositories/auth_repository.dart';

class PingAuthApiUseCase {
  const PingAuthApiUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call() => _repository.ping();
}
