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
  final Color accent;

  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onReport;

  final bool batchMode;
  final bool selected;
  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final estadoPill = item.disponible
        ? UiPill(
            text: 'Disponible',
            fg: accent,
            bg: accent.withOpacity(0.10),
            bd: accent.withOpacity(0.22),
            icon: PhosphorIconsRegular.checkCircle,
          )
        : UiPill(
            text: 'Pendiente',
            fg: ColoresApp.textoSuave,
            bg: ColoresApp.inputBg,
            bd: ColoresApp.bordeSuave,
            icon: PhosphorIconsRegular.clock,
          );

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: batchMode ? onToggleSelect : onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: ColoresApp.blanco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.22)),
                  ),
                  child: Icon(PhosphorIconsRegular.filePdf, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.periodoLabel,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (batchMode)
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onToggleSelect,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: selected ? accent : ColoresApp.blanco,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: selected ? accent : ColoresApp.bordeSuave),
                      ),
                      child: selected
                          ? Icon(PhosphorIconsFill.check, size: 14, color: ColoresApp.blanco)
                          : null,
                    ),
                  )
                else
                  estadoPill,
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(PhosphorIconsRegular.money, size: 18, color: ColoresApp.textoSuave),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Neto: ${money(item.neto)}',
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                    ),
                  ),
                ),
                if (!batchMode) estadoPill,
              ],
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                UiPill(
                  text: 'Año ${item.anio}',
                  fg: ColoresApp.textoSuave,
                  bg: ColoresApp.inputBg,
                  bd: ColoresApp.bordeSuave,
                  icon: PhosphorIconsRegular.calendar,
                ),
                UiPill(
                  text: 'Qna ${fmt2(item.quincena)}',
                  fg: ColoresApp.textoSuave,
                  bg: ColoresApp.inputBg,
                  bd: ColoresApp.bordeSuave,
                  icon: PhosphorIconsRegular.numberCircleOne,
                ),
                if (item.tieneReporte)
                  UiPill(
                    text: 'Reporte enviado',
                    fg: ColoresApp.vino,
                    bg: ColoresApp.vino.withOpacity(0.10),
                    bd: ColoresApp.vino.withOpacity(0.22),
                    icon: PhosphorIconsRegular.warningCircle,
                  ),
              ],
            ),

            if (!batchMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReport,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColoresApp.bordeSuave),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Reportar',
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.texto,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: item.disponible ? onDownload : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: item.disponible ? accent : ColoresApp.bordeSuave,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Descargar',
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.blanco,
                        ),
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
