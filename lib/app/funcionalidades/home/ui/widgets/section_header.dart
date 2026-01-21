// lib/app/funcionalidades/home/ui/widget/section_header_chip.dart
import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class SectionHeaderChip extends StatelessWidget {
  final String title;
  final String chipText;

  /// Acento visual (no siempre vino). Default: café.
  final Color accent;

  /// Icono opcional dentro del chip (ej: Icons.today_rounded)
  final IconData? chipIcon;

  /// Acción opcional (ej: abrir filtros) - aparece como botoncito mini
  final VoidCallback? onAction;
  final IconData actionIcon;

  /// Línea inferior suave para separar sección (opcional)
  final bool showDivider;

  const SectionHeaderChip({
    super.key,
    required this.title,
    this.chipText = 'Hoy',
    this.accent = ColoresApp.cafe,
    this.chipIcon,
    this.onAction,
    this.actionIcon = Icons.tune_rounded,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // ✅ “Ancla” visual (mini, elegante)
              Container(
                width: 2.5, // 👈 súper fina
                height: 18,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: t.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                    color: ColoresApp.texto,
                  ),
                ),
              ),

              // ✅ Acción discreta (si la mandas)
              if (onAction != null) ...[
                _MiniActionButton(onTap: onAction!, icon: actionIcon),
                const SizedBox(width: 8),
              ],

              // ✅ Chip “real” (con icon opcional)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ColoresApp.inputBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ColoresApp.bordeSuave),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chipIcon != null) ...[
                      Icon(chipIcon, size: 14, color: ColoresApp.textoSuave),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      chipText,
                      style: t.labelMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.textoSuave,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (showDivider) ...[
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: ColoresApp.bordeSuave.withOpacity(0.7),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _MiniActionButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ColoresApp.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Icon(icon, size: 18, color: ColoresApp.texto),
        ),
      ),
    );
  }
}
