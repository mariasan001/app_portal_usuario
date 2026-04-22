import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/core/ui/notificaciones/app_notifications.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_providers.dart';
import 'package:portal_servicios_usuario/features/auth/application/auth_state.dart';

void handleAuthErrorFeedback({
  required BuildContext context,
  required WidgetRef ref,
  required AuthState? previous,
  required AuthState next,
}) {
  final previousError = previous?.errorMessage;
  final nextError = next.errorMessage;

  if (nextError == null || nextError == previousError) return;

  AppNotifications.show(context, AppNotifications.authError(nextError));
  ref.read(authControllerProvider.notifier).clearFeedback();
}

void handleAuthenticatedNavigation({
  required BuildContext context,
  required AuthState? previous,
  required AuthState next,
  String route = '/home',
}) {
  final wasAuthenticated = previous?.isAuthenticated ?? false;
  if (next.isAuthenticated && !wasAuthenticated) {
    context.go(route);
  }
}
