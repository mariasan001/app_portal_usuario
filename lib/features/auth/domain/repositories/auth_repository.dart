import '../entities/auth_user.dart';
import '../entities/login_result.dart';

abstract interface class AuthRepository {
  Future<LoginResult> login({
    required String username,
    required String password,
  });

  Future<AuthUser> getCurrentUser();

  Future<String> ping();

  Future<void> clearSession();
}
