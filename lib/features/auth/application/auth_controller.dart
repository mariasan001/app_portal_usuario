import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

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
      final result = await ref
          .read(loginUseCaseProvider)
          .call(username: username, password: password);

      final user = await ref.read(getCurrentUserUseCaseProvider).call();

      state = AuthState.authenticated(
        user,
        infoMessage: result.message.isEmpty ? null : result.message,
      );
      return true;
    } on ApiException catch (error) {
      await ref.read(clearSessionUseCaseProvider).call();
      state = AuthState.unauthenticated(errorMessage: error.message);
      return false;
    } catch (_) {
      await ref.read(clearSessionUseCaseProvider).call();
      state = const AuthState.unauthenticated(
        errorMessage: 'No se pudo iniciar sesión. Intenta nuevamente.',
      );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String> ping() => ref.read(pingAuthApiUseCaseProvider).call();

  Future<void> signOutLocally() async {
    await ref.read(clearSessionUseCaseProvider).call();
    state = const AuthState.unauthenticated();
  }

  void clearFeedback() {
    state = state.copyWith(clearErrorMessage: true, clearInfoMessage: true);
  }
}
