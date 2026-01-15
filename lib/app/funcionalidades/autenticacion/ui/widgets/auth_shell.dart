import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../tema/colores.dart';
import 'auth_banner.dart';
import 'auth_primary_button.dart';

class AuthShell extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget child;

  final String primaryText;
  final VoidCallback onPrimary;

  final Widget? footer;

  // ✅ si quieres mostrar back
  final bool showBack;
  final VoidCallback? onBack;
  final String fallbackBackRoute; // por si no hay stack

  // ✅ Fondo opcional
  final String? backgroundAsset; // ej: 'assets/img/fondo.png'
  final BoxFit backgroundFit;
  final Alignment backgroundAlignment;

  // ✅ Overlay para legibilidad
  final double overlayOpacity;

  const AuthShell({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.child,
    required this.primaryText,
    required this.onPrimary,
    this.footer,

    // ✅ Back
    this.showBack = false,
    this.onBack,
    this.fallbackBackRoute = '/login',

    // ✅ Fondo
    this.backgroundAsset,
    this.backgroundFit = BoxFit.cover,
    this.backgroundAlignment = Alignment.center,
    this.overlayOpacity = 0.18,
  });

  void _handleBack(BuildContext context) {
    // 1) si el caller quiere ejecutar algo extra
    onBack?.call();

    // 2) back real (si hay historial)
    if (context.canPop()) {
      context.pop();
      return;
    }

    // 3) si NO hay historial (porque viniste con go)
    context.go(fallbackBackRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: Stack(
        children: [
          // ✅ Fondo
          if (backgroundAsset != null)
            Positioned.fill(
              child: Image.asset(
                backgroundAsset!,
                fit: backgroundFit,
                alignment: backgroundAlignment,
              ),
            ),

          // ✅ Overlay suave
          if (backgroundAsset != null && overlayOpacity > 0)
            Positioned.fill(
              child: Container(
                color: ColoresApp.blanco.withOpacity(overlayOpacity),
              ),
            ),

          SafeArea(
            child: Stack(
              children: [
                // ✅ Contenido centrado
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 26), // deja aire para el back flotante

                          AuthBanner(
                            texto: titulo,
                            leftAsset: 'assets/ornamentos/flor_d.png',
                            rightAsset: 'assets/ornamentos/flor_i.png',
                          ),

                          const SizedBox(height: 14),

                          Text(
                            subtitulo,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ColoresApp.textoSuave,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                          ),

                          const SizedBox(height: 20),
                          child,
                          const SizedBox(height: 18),

                          AuthPrimaryButton(text: primaryText, onTap: onPrimary),

                          if (footer != null) ...[
                            const SizedBox(height: 10),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ✅ Back flotante PRO (más arriba)
                if (showBack)
                  Positioned(
                    left: 14,
                    top: 6,
                    child: _FloatingBackButton(
                      onTap: () => _handleBack(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ColoresApp.blanco.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x14000000)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 7),
                color: Color(0x1A000000),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: ColoresApp.vino,
            size: 22,
          ),
        ),
      ),
    );
  }
}
