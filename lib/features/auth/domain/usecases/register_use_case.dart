import '../entities/register_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<RegisterResult> call({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  }) {
    return _repository.register(
      claveSp: claveSp,
      plaza: plaza,
      puesto: puesto,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
