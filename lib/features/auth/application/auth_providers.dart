import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/device/device_metadata_collector.dart';
import '../../../core/device/providers/device_providers.dart';
import '../../../core/network/providers/network_providers.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/check_device_use_case.dart';
import '../domain/usecases/clear_session_use_case.dart';
import '../domain/usecases/confirm_device_enrollment_use_case.dart';
import '../domain/usecases/forgot_password_use_case.dart';
import '../domain/usecases/get_current_user_use_case.dart';
import '../domain/usecases/login_use_case.dart';
import '../domain/usecases/register_use_case.dart';
import '../domain/usecases/reset_password_use_case.dart';
import '../domain/usecases/request_device_enrollment_use_case.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

/// Providers = fabrica de dependencias.
///
/// Aqui Riverpod conecta todas las piezas:
/// ApiClient -> DataSource -> Repository -> UseCase -> Controller.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(iamApiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final clearSessionUseCaseProvider = Provider<ClearSessionUseCase>((ref) {
  return ClearSessionUseCase(ref.watch(authRepositoryProvider));
});

final checkDeviceUseCaseProvider = Provider<CheckDeviceUseCase>((ref) {
  return CheckDeviceUseCase(ref.watch(authRepositoryProvider));
});

final requestDeviceEnrollmentUseCaseProvider =
    Provider<RequestDeviceEnrollmentUseCase>((ref) {
      return RequestDeviceEnrollmentUseCase(ref.watch(authRepositoryProvider));
    });

final confirmDeviceEnrollmentUseCaseProvider =
    Provider<ConfirmDeviceEnrollmentUseCase>((ref) {
      return ConfirmDeviceEnrollmentUseCase(ref.watch(authRepositoryProvider));
    });

final deviceMetadataCollectorServiceProvider =
    Provider<DeviceMetadataCollector>((ref) {
      return ref.watch(deviceMetadataCollectorProvider);
    });

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
