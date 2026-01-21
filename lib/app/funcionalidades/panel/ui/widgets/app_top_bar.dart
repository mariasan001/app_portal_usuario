import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppTopBar extends StatelessWidget {
  final String nombre;
  final String hintSearch;

  final VoidCallback? onTapPerfil;
  final VoidCallback? onTapNotificaciones;
  final VoidCallback? onTapBuscar;

  const AppTopBar({
    super.key,
    required this.nombre,
    required this.hintSearch,
    this.onTapPerfil,
    this.onTapNotificaciones,
    this.onTapBuscar,
  });

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
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: ColoresApp.bordeSuave),
                    ),
                    child: Icon(
                      PhosphorIcons.user(PhosphorIconsStyle.light),
                      size: 18,
                      color: ColoresApp.texto,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    nombre, // ✅ solo nombre, grande
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleLarge?.copyWith(
                      fontSize: 18, // 🔥 más grande
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
                  child: Container(
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
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ===== Search pill (sin QR) =====
            _SearchPill(
              hint: hintSearch,
              onTap: onTapBuscar,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;

  const _SearchPill({
    required this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.inputBg, // ✅ gris súper clarito
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

              // detalle visual minimal (flecha) para que “se entienda” que abre búsqueda
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
