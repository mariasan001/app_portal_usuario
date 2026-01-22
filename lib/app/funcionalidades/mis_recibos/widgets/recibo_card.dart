import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../domain/mis_recibos_models.dart';
import 'mis_recibos_ui.dart';

class ReciboCard extends StatelessWidget {
  const ReciboCard({
    super.key,
    required this.item,
    required this.accent,
    required this.onOpen,
    required this.onDownload,
    required this.onReport,
    this.batchMode = false,
    this.selected = false,
    this.onToggleSelect,
  });

  final ReciboResumen item;
  final Color accent; // en tu page viene ColoresApp.cafe

  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onReport;

  final bool batchMode;
  final bool selected;
  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // 🎨 roles de color (más variedad, menos “todo café”)
    final primary = accent; // Café (acción principal)
    final doc = ColoresApp.dorado; // Documento / highlight
    final danger = ColoresApp.vino; // Reporte / alerta
    final softBg = ColoresApp.fondoCrema.withOpacity(0.35);

    // Estado (solo una vez)
    final estadoPill = item.disponible
        ? UiPill(
            text: 'Disponible',
            fg: doc,
            bg: doc.withOpacity(0.10),
            bd: doc.withOpacity(0.22),
            icon: PhosphorIconsRegular.checkCircle,
          )
        : UiPill(
            text: 'Pendiente',
            fg: ColoresApp.textoSuave,
            bg: ColoresApp.inputBg,
            bd: ColoresApp.bordeSuave,
            icon: PhosphorIconsRegular.clock,
          );

    final reportePill = item.tieneReporte
        ? UiPill(
            text: 'Reporte enviado',
            fg: danger,
            bg: danger.withOpacity(0.10),
            bd: danger.withOpacity(0.22),
            icon: PhosphorIconsRegular.warningCircle,
          )
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: batchMode ? onToggleSelect : onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          color: ColoresApp.blanco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Header ----------
            Row(
              children: [
                // Icono documento (dorado)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: doc.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: doc.withOpacity(0.22)),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.filePdf,
                    color: doc,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // Título (un pelín más chico)
                Expanded(
                  child: Text(
                    item.periodoLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Batch check OR estado
                if (batchMode)
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onToggleSelect,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? primary : ColoresApp.blanco,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? primary : ColoresApp.bordeSuave,
                        ),
                      ),
                      child: selected
                          ? Icon(
                              PhosphorIconsFill.check,
                              size: 14,
                              color: ColoresApp.blanco,
                            )
                          : null,
                    ),
                  )
                else
                  estadoPill,
              ],
            ),

            // Reporte pill (si aplica)
            if (!batchMode && reportePill != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [reportePill],
              ),
            ],

            const SizedBox(height: 12),

            // ---------- Neto (card suave con crema) ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColoresApp.bordeSuave),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.money,
                    size: 18,
                    color: ColoresApp.textoSuave,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Neto',
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.textoSuave,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Text(
                    money(item.neto),
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                      fontSize: 14.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Actions (compactas) ----------
            if (!batchMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReport,
                      icon: Icon(
                        PhosphorIconsRegular.flag,
                        size: 18,
                        color: danger,
                      ),
                      label: Text(
                        'Reportar',
                        style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: danger,
                          fontSize: 12.8,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: danger.withOpacity(0.28)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        backgroundColor: ColoresApp.blanco,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: item.disponible ? onDownload : null,
                      icon: Icon(
                        PhosphorIconsRegular.downloadSimple,
                        size: 18,
                        color: ColoresApp.blanco,
                      ),
                      label: Text(
                        'Descargar',
                        style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.blanco,
                          fontSize: 12.8,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: item.disponible ? primary : ColoresApp.bordeSuave,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
