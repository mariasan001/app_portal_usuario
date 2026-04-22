import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device/models/app_device_info.dart';
import '../../../../core/network/api_exception.dart';
import '../domain/entities/device/device_check_result.dart';
import '../domain/entities/device/device_enrollment_confirm_result.dart';
import '../domain/entities/device/device_enrollment_request_result.dart';
import '../domain/entities/recovery/auth_action_result.dart';
import '../domain/entities/session/register_result.dart';
import '../ui/auth_copy.dart';
import 'auth_device_messages.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Controller = orquestador del flujo.
///
/// La UI le pide acciones como login, registro o reset de password.
/// El controller llama use cases, actualiza el estado y decide mensajes
/// o pasos intermedios como el chequeo de dispositivo.
class AuthController extends Notifier<AuthState> {
  bool _didBootstrap = false;

  @override
  AuthState build() {
    Future<void>.microtask(bootstrap);
    return const AuthState.unknown();
  }

  Future<void> bootstrap() async {
    if (_didBootstrap) {
      return;
    }
    _didBootstrap = true;

    try {
      final user = await ref.read(getCurrentUserUseCaseProvider).call();
      state = AuthState.authenticated(user);
    } on ApiException {
      state = const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      await ref
          .read(loginUseCaseProvider)
          .call(username: username, password: password);

      final device = await _collectCurrentDevice();
      final deviceCheck = await ref
          .read(checkDeviceUseCaseProvider)
          .call(username: username, device: device);

      if (!deviceCheck.isAuthorized) {
        await ref.read(clearSessionUseCaseProvider).call();
        state = AuthState(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          errorMessage: defaultDeviceMessage(deviceCheck),
          pendingUsername: username,
          deviceCheckResult: deviceCheck,
        );
        return false;
      }

      final user = await ref.read(getCurrentUserUseCaseProvider).call();

      state = AuthState.authenticated(
        user,
        infoMessage: defaultDeviceMessage(deviceCheck),
      );
      return true;
    } on ApiException catch (error) {
      await ref.read(clearSessionUseCaseProvider).call();
      state = AuthState.unauthenticated(errorMessage: error.message);
      return false;
    } catch (_) {
      await ref.read(clearSessionUseCaseProvider).call();
      state = const AuthState.unauthenticated(
        errorMessage: AuthCopy.loginUnexpectedError,
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<RegisterResult?> register({
    required String claveSp,
    required String plaza,
    required String puesto,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final result = await ref
          .read(registerUseCaseProvider)
          .call(
            claveSp: claveSp,
            plaza: plaza,
            puesto: puesto,
            email: email,
            password: password,
            phone: phone,
          );

      state = state.copyWith(
        isLoading: false,
        infoMessage: AuthCopy.registerSuccess,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthCopy.registerFailed,
      );
      return null;
    }
  }

  Future<AuthActionResult?> forgotPassword({required String email}) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final result = await ref
          .read(forgotPasswordUseCaseProvider)
          .call(email: email);

      state = state.copyWith(
        isLoading: false,
        infoMessage: AuthCopy.recoveryCodeSent,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthCopy.recoveryStartFailed,
      );
      return null;
    }
  }

  Future<AuthActionResult?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final result = await ref
          .read(resetPasswordUseCaseProvider)
          .call(email: email, otp: otp, newPassword: newPassword);

      state = state.copyWith(
        isLoading: false,
        infoMessage: AuthCopy.passwordResetSuccess,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthCopy.passwordResetFailed,
      );
      return null;
    }
  }

  Future<DeviceCheckResult> checkCurrentDevice({
    required String username,
  }) async {
    final device = await _collectCurrentDevice();
    final result = await ref
        .read(checkDeviceUseCaseProvider)
        .call(username: username, device: device);

    state = state.copyWith(
      pendingUsername: username,
      deviceCheckResult: result,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    return result;
  }

  Future<DeviceEnrollmentRequestResult> requestDeviceEnrollment({
    required String username,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final device = await _collectCurrentDevice();
      final result = await ref
          .read(requestDeviceEnrollmentUseCaseProvider)
          .call(username: username, device: device);

      state = state.copyWith(
        isLoading: false,
        pendingUsername: username,
        pendingEnrollmentId: result.enrollmentId,
        infoMessage: AuthCopy.identityVerificationStarted,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthCopy.identityVerificationStartFailed,
      );
      rethrow;
    }
  }

  Future<DeviceEnrollmentConfirmResult> confirmDeviceEnrollment({
    required String enrollmentId,
    required String otp,
    required String username,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearInfoMessage: true,
    );

    try {
      final result = await ref
          .read(confirmDeviceEnrollmentUseCaseProvider)
          .call(enrollmentId: enrollmentId, otp: otp, username: username);

      state = state.copyWith(
        isLoading: false,
        infoMessage: AuthCopy.identityVerificationSuccess,
        clearPendingEnrollmentId: true,
        clearDeviceCheckResult: true,
      );
      return result;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthCopy.identityVerificationFailed,
      );
      rethrow;
    }
  }

  Future<void> signOutLocally() async {
    await ref.read(clearSessionUseCaseProvider).call();
    state = const AuthState.unauthenticated();
  }

  void clearFeedback() {
    state = state.copyWith(clearErrorMessage: true, clearInfoMessage: true);
  }

  Future<AppDeviceInfo> _collectCurrentDevice() {
    return ref.read(deviceMetadataCollectorServiceProvider).collect();
  }
}
