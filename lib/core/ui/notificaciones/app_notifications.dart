import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

enum AppNotificationTone { success, error, info, warning }

class AppNotificationMessage {
  const AppNotificationMessage({required this.tone, required this.message});

  final AppNotificationTone tone;
  final String message;
}

/// Catalogo central de notificaciones visuales.
///
/// Aqui concentramos:
/// - el estilo visual
/// - los tipos de notificacion
/// - los mensajes frecuentes del flujo auth y shell
///
/// Asi la UI solo pide "que" mostrar y no "como" construirlo.
abstract final class AppNotifications {
  static void show(BuildContext context, AppNotificationMessage notification) {
    showTopSnackBar(
      Overlay.of(context, rootOverlay: true),
      _buildSnackBar(notification),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, authSuccess(message));
  }

  static void showError(BuildContext context, String message) {
    show(context, authError(message));
  }

  static void showInfo(BuildContext context, String message) {
    show(context, info(message));
  }

  static AppNotificationMessage authSuccess(String message) {
    return AppNotificationMessage(
      tone: AppNotificationTone.success,
      message: message,
    );
  }

  static AppNotificationMessage authError(String message) {
    return AppNotificationMessage(
      tone: AppNotificationTone.error,
      message: message,
    );
  }

  static AppNotificationMessage info(String message) {
    return AppNotificationMessage(
      tone: AppNotificationTone.info,
      message: message,
    );
  }

  static AppNotificationMessage warning(String message) {
    return AppNotificationMessage(
      tone: AppNotificationTone.warning,
      message: message,
    );
  }

  static AppNotificationMessage missingEnrollmentId() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.error,
      message:
          'La API no devolvio enrollmentId para continuar el enrolamiento.',
    );
  }

  static AppNotificationMessage missingDeviceEnrollmentData() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.error,
      message: 'Falta informacion para confirmar el dispositivo.',
    );
  }

  static AppNotificationMessage missingRecoveryEmail() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.error,
      message: 'Falta el correo para reenviar el codigo.',
    );
  }

  static AppNotificationMessage logoutSuccess() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.success,
      message: 'Sesion cerrada correctamente.',
    );
  }

  static AppNotificationMessage documentsSearchPending() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.info,
      message: 'Buscador de documentos (pendiente)',
    );
  }

  static AppNotificationMessage notificationsMarkedAsRead() {
    return const AppNotificationMessage(
      tone: AppNotificationTone.info,
      message: 'Marcadas como leidas (demo)',
    );
  }

  static AppNotificationMessage openItem(String title) {
    return AppNotificationMessage(
      tone: AppNotificationTone.info,
      message: 'Abrir: $title',
    );
  }

  static Widget _buildSnackBar(AppNotificationMessage notification) {
    final style = _styleFor(notification.tone);

    return _CompactNotificationCard(
      message: notification.message,
      backgroundColor: style.backgroundColor,
      textColor: style.textColor,
      icon: style.icon,
      iconColor: style.iconColor,
    );
  }

  static _NotificationStyle _styleFor(AppNotificationTone tone) {
    switch (tone) {
      case AppNotificationTone.success:
        return const _NotificationStyle(
          backgroundColor: Color(0xFF12C96A),
          textColor: Colors.white,
          icon: Icons.sentiment_very_satisfied,
          iconColor: Color(0x24000000),
        );
      case AppNotificationTone.error:
        return const _NotificationStyle(
          backgroundColor: Color(0xFFFF5B5B),
          textColor: Colors.white,
          icon: Icons.error_outline_rounded,
          iconColor: Color(0x24000000),
        );
      case AppNotificationTone.info:
        return const _NotificationStyle(
          backgroundColor: Color(0xFF2D9CFF),
          textColor: Colors.white,
          icon: Icons.sentiment_neutral_rounded,
          iconColor: Color(0x24000000),
        );
      case AppNotificationTone.warning:
        return const _NotificationStyle(
          backgroundColor: Color(0xFFFFB020),
          textColor: Colors.white,
          icon: Icons.warning_amber_rounded,
          iconColor: Color(0x24000000),
        );
    }
  }
}

class _CompactNotificationCard extends StatelessWidget {
  const _CompactNotificationCard({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -10,
                  child: Transform.rotate(
                    angle: 0.55,
                    child: IgnorePointer(
                      child: Icon(icon, size: 70, color: iconColor),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Center(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
}
