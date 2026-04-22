import '../domain/entities/auth_user.dart';
import '../domain/entities/device_check_result.dart';

/// Estado observable del modulo de autenticacion.
///
/// La UI mira este objeto para saber:
/// - si hay sesion
/// - si hay loading
/// - si hubo error
/// - si quedo algo pendiente, como enrolamiento de dispositivo
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
    this.pendingUsername,
    this.pendingEnrollmentId,
    this.deviceCheckResult,
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
  final String? pendingUsername;
  final String? pendingEnrollmentId;
  final DeviceCheckResult? deviceCheckResult;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
    String? pendingUsername,
    String? pendingEnrollmentId,
    DeviceCheckResult? deviceCheckResult,
    bool clearUser = false,
    bool clearErrorMessage = false,
    bool clearInfoMessage = false,
    bool clearPendingUsername = false,
    bool clearPendingEnrollmentId = false,
    bool clearDeviceCheckResult = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      pendingUsername: clearPendingUsername
          ? null
          : (pendingUsername ?? this.pendingUsername),
      pendingEnrollmentId: clearPendingEnrollmentId
          ? null
          : (pendingEnrollmentId ?? this.pendingEnrollmentId),
      deviceCheckResult: clearDeviceCheckResult
          ? null
          : (deviceCheckResult ?? this.deviceCheckResult),
    );
  }
}
