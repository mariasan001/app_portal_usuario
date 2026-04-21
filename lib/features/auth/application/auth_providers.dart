import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers/network_providers.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/clear_session_use_case.dart';
import '../domain/usecases/get_current_user_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/ping_auth_api_use_case.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(iamApiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final pingAuthApiUseCaseProvider = Provider<PingAuthApiUseCase>((ref) {
  return PingAuthApiUseCase(ref.watch(authRepositoryProvider));
});

final clearSessionUseCaseProvider = Provider<ClearSessionUseCase>((ref) {
  return ClearSessionUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
