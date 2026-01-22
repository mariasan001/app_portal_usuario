import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../domain/mis_citas_models.dart';

class CitaTimeline extends StatelessWidget {
  const CitaTimeline({
    super.key,
    required this.pasos,
    this.accent,
  });

  final List<CitaPaso> pasos;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = accent ?? ColoresApp.cafe;

    Color dotColor(PasoEstado s) {
      switch (s) {
        case PasoEstado.completo:
          return a;
        case PasoEstado.actual:
          return ColoresApp.texto;
        case PasoEstado.pendiente:
          return ColoresApp.bordeSuave;
      }
    }

    IconData dotIcon(PasoEstado s) {
      switch (s) {
        case PasoEstado.completo:
          return Icons.check_rounded;
        case PasoEstado.actual:
          return Icons.more_horiz_rounded;
        case PasoEstado.pendiente:
          return Icons.circle_outlined;
      }
    }

    return Column(
      children: [
        for (int i = 0; i < pasos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left timeline rail
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: dotColor(pasos[i].estado).withOpacity(pasos[i].estado == PasoEstado.pendiente ? 0.15 : 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: dotColor(pasos[i].estado).withOpacity(pasos[i].estado == PasoEstado.pendiente ? 0.9 : 0.35),
                        ),
                      ),
                      child: Icon(dotIcon(pasos[i].estado), size: 18, color: dotColor(pasos[i].estado)),
                    ),
                    if (i != pasos.length - 1)
                      Container(
                        width: 2,
                        height: 34,
                        color: ColoresApp.bordeSuave,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    decoration: BoxDecoration(
                      color: ColoresApp.inputBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ColoresApp.bordeSuave),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pasos[i].titulo,
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                          ),
                        ),
                        if ((pasos[i].descripcion ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            pasos[i].descripcion!.trim(),
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: ColoresApp.textoSuave,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
