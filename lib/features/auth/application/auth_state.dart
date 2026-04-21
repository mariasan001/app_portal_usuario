import '../domain/entities/auth_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.authenticated(AuthUser user, {String? infoMessage})
    : this(
        status: AuthStatus.authenticated,
        user: user,
        infoMessage: infoMessage,
      );

  const AuthState.unauthenticated({String? errorMessage, String? infoMessage})
    : this(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
        infoMessage: infoMessage,
      );

  final AuthStatus status;
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    bool clearUser = false,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
