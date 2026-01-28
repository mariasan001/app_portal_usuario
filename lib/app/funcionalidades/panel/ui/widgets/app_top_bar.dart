import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppTopBar extends StatelessWidget {
  final String nombre;
  final String hintSearch;

  final VoidCallback? onTapPerfil;
  final VoidCallback? onTapNotificaciones;
  final VoidCallback? onTapBuscar;

  /// ✅ Por si algún día necesitas ocultar el buscador en una pantalla específica.
  final bool showSearch;

  /// ✅ Personaliza el trailing del SearchPill (por ejemplo, filtros en Servicios).
  /// Si no lo mandas, usa el caretRight.
  final Widget? searchTrailing;

  /// ✅ Imagen del perfil (asset o network).
  /// Si es null o falla, se muestra el ícono.
  final ImageProvider? avatarImage;

  /// ✅ Notificaciones: si es null -> no badge.
  /// Si es 0 -> no badge (por defecto), pero puedes forzarlo si quieres.
  /// Si es > 0 -> muestra número (hasta 99+).
  final int? notificacionesPendientes;

  /// ✅ Si quieres que se vea el puntito aunque sean 0 (por ejemplo “hay algo que revisar” sin contador).
  final bool showNotificationDotWhenZero;

  const AppTopBar({
    super.key,
    required this.nombre,
    required this.hintSearch,
    this.onTapPerfil,
    this.onTapNotificaciones,
    this.onTapBuscar,
    this.showSearch = true,
    this.searchTrailing,
    this.avatarImage,
    this.notificacionesPendientes,
    this.showNotificationDotWhenZero = false,
  });

  bool get _showBadge {
    if (notificacionesPendientes == null) return false;
    if (notificacionesPendientes! > 0) return true;
    return showNotificationDotWhenZero;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.blanco,
      surfaceTintColor: Colors.transparent, // ✅ evita tintes M3
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          children: [
            // ===== Header =====
            Row(
              children: [
                InkWell(
                  onTap: onTapPerfil,
                  borderRadius: BorderRadius.circular(999),
                  child: _Avatar(
                    image: avatarImage,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                      letterSpacing: 0.2,
                      height: 1.0,
                    ),
                  ),
                ),

                InkWell(
                  onTap: onTapNotificaciones,
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ColoresApp.bordeSuave),
                        ),
                        child: Icon(
                          PhosphorIcons.bell(PhosphorIconsStyle.light),
                          size: 19,
                          color: ColoresApp.texto,
                        ),
                      ),

                      // ✅ Badge / bolita
                      if (_showBadge)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: _NotifBadge(count: notificacionesPendientes),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (showSearch) ...[
              const SizedBox(height: 10),

              // ===== Search pill =====
              _SearchPill(
                hint: hintSearch,
                onTap: onTapBuscar,
                trailing: searchTrailing,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ----------------------- Avatar con imagen ----------------------- */

class _Avatar extends StatelessWidget {
  final ImageProvider? image;
  final double size;

  const _Avatar({
    required this.image,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: image == null
            ? Icon(
                PhosphorIcons.user(PhosphorIconsStyle.light),
                size: 18,
                color: ColoresApp.texto,
              )
            : Image(
                image: image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  PhosphorIcons.user(PhosphorIconsStyle.light),
                  size: 18,
                  color: ColoresApp.texto,
                ),
              ),
      ),
    );
  }
}

/* ----------------------- Badge notificaciones ----------------------- */

class _NotifBadge extends StatelessWidget {
  /// null => puntito, >0 => número, 0 => oculto
  final int? count;

  /// Micro-ajuste visual (por defecto ya queda bien)
  final Offset offset;

  const _NotifBadge({
    this.count,
    this.offset = const Offset(0, 0),
  });

  @override
  Widget build(BuildContext context) {
    final int? c = count;
    final bool showDot = c == null;
    final bool showNumber = (c ?? 0) > 0;

    if (!showDot && !showNumber) return const SizedBox.shrink();

    // ✅ Estilo institucional: borde vino fuerte + fondo vino claro
    final Color border = ColoresApp.vino.withOpacity(0.55);
    final Color bg = ColoresApp.vino.withOpacity(0.12);
    final Color fg = ColoresApp.vino;

    // Tamaños consistentes
    final double h = showNumber ? 18 : 10;
    final double minW = showNumber ? 18 : 10;

    final String text = (c ?? 0) > 99 ? '99+' : '${c ?? ''}';

    return Transform.translate(
      offset: offset,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minW,
          minHeight: h,
        ),
        padding: showNumber ? const EdgeInsets.symmetric(horizontal: 6) : EdgeInsets.zero,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // ✅ Dot sólido para que sí se vea (sin bordes blancos)
          color: showDot ? ColoresApp.vino : bg,
          borderRadius: BorderRadius.circular(999),
          border: showDot
              ? null
              : Border.all(
                  color: border,
                  width: 1.0, // delgadito como manejan ustedes
                ),
          boxShadow: [
            // ✅ halo sutil vino (no negro) para separarlo del icono
            BoxShadow(
              color: ColoresApp.vino.withOpacity(showDot ? 0.20 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: showNumber
            ? Text(
                text,
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: fg, // ✅ mismo color del borde
                      fontWeight: FontWeight.w900,
                      fontSize: 9.6,
                      height: 1.0,
                      letterSpacing: 0.1,
                    ),
                strutStyle: const StrutStyle(
                  fontSize: 9.6,
                  height: 1.0,
                  forceStrutHeight: true,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}


/* -------------------------- Search pill -------------------------- */

class _SearchPill extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SearchPill({
    required this.hint,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.inputBg,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.light),
                size: 18,
                color: ColoresApp.textoSuave,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ColoresApp.textoSuave,
                    letterSpacing: 0.1,
                    height: 1.0,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                    size: 18,
                    color: ColoresApp.textoSuave.withOpacity(0.6),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
