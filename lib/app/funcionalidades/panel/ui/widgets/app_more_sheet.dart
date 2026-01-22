import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppMoreSheet extends StatelessWidget {
  final VoidCallback onPerfil;
  final VoidCallback onConfig;
  final VoidCallback onAyuda;
  final VoidCallback onLogout;

  /// ✅ Si quieres tu handle (la barrita), ponlo en true.
  /// En AppShell lo estamos dejando en false para no duplicar.
  final bool showCustomHandle;

  const AppMoreSheet({
    super.key,
    required this.onPerfil,
    required this.onConfig,
    required this.onAyuda,
    required this.onLogout,
    this.showCustomHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ColoredBox(
      color: ColoresApp.blanco, // ✅ blanco real
      child: Material(
        type: MaterialType.transparency, // ✅ InkWell sin “pintar” fondo
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCustomHandle) ...[
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ColoresApp.bordeSuave,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // ✅ espacio para que no se vea pegado al handle del sistema
                  const SizedBox(height: 6),
                ],

                Row(
                  children: [
                    Text(
                      'Más opciones',
                      style: t.titleMedium?.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.texto,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColoresApp.fondoCrema.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ColoresApp.bordeSuave),
                      ),
                      child: Text(
                        'Portal',
                        style: t.labelMedium?.copyWith(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: ColoresApp.textoSuave,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _SectionCard(
                  children: [
                    _ModernTile(
                      icon: PhosphorIcons.user(PhosphorIconsStyle.light),
                      title: 'Editar perfil',
                      subtitle: 'Actualiza tu información',
                      accent: ColoresApp.dorado,
                      onTap: onPerfil,
                    ),
                    const _DividerSoft(),
                    _ModernTile(
                      icon: PhosphorIcons.gear(PhosphorIconsStyle.light),
                      title: 'Configuración',
                      subtitle: 'Preferencias, tema y seguridad',
                      accent: ColoresApp.cafe,
                      onTap: onConfig,
                    ),
                    const _DividerSoft(),
                    _ModernTile(
                      icon: PhosphorIcons.headset(PhosphorIconsStyle.light),
                      title: 'Ayuda y soporte',
                      subtitle: 'Resuelve dudas rápido',
                      accent: ColoresApp.vino,
                      onTap: onAyuda,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _SectionCard(
                  child: _ModernTile(
                    icon: PhosphorIcons.signOut(PhosphorIconsStyle.light),
                    title: 'Cerrar sesión',
                    subtitle: 'Salir de tu cuenta',
                    accent: Colors.redAccent,
                    danger: true,
                    onTap: onLogout,
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

class _SectionCard extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;

  const _SectionCard({this.child, this.children});

  @override
  Widget build(BuildContext context) {
    final content = child ?? Column(mainAxisSize: MainAxisSize.min, children: children ?? []);

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _ModernTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool danger;

  const _ModernTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.18)),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.bodyMedium?.copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.15,
                      color: danger ? Colors.redAccent : ColoresApp.texto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: t.bodySmall?.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: 0.10,
                      color: ColoresApp.textoSuave,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.light),
              color: ColoresApp.textoSuave.withOpacity(0.70),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerSoft extends StatelessWidget {
  const _DividerSoft();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: ColoresApp.bordeSuave.withOpacity(0.70),
    );
  }
}
