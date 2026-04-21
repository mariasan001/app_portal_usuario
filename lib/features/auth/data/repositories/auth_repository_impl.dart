import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    return response.toDomain();
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    final response = await _remoteDataSource.getCurrentUser();
    return response.toDomain();
  }

  @override
  Future<String> ping() => _remoteDataSource.ping();

  @override
  Future<void> clearSession() => _remoteDataSource.clearSession();
}
