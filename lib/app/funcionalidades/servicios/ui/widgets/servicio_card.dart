import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../domain/servicio_item.dart';

class ServicioCard extends StatelessWidget {
  final ServicioItem item;
  final VoidCallback onTap;

  const ServicioCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = item.accent;

    final tipoText = item.tipo == ServicioTipo.tramite ? 'Trámite' : 'Consulta';

    const radius = 18.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias, // ✅ CLAVE: respeta el redondeo en Stack/halo/barra
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.03),
        child: Ink(
          decoration: BoxDecoration(
            color: ColoresApp.blanco,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: ColoresApp.bordeSuave),
            boxShadow: [
              // ✅ menos “cartón”, más suave
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✅ barra lateral con radios (ya no se ve cortada)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(radius),
                    bottomLeft: Radius.circular(radius),
                  ),
                  child: Container(
                    width: 4,
                    color: accent.withOpacity(0.85),
                  ),
                ),
              ),

              // ✅ halo más discreto (y ya queda clipeado por el Material)
              Positioned(
                right: -44,
                top: -44,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.06),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent.withOpacity(0.18)),
                      ),
                      child: Icon(item.icon, size: 20, color: accent),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // título + badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.bodyMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.texto,
                                    height: 1.10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // ✅ badge alineado + menos “gordito”
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: accent.withOpacity(0.18)),
                                ),
                                child: Text(
                                  tipoText,
                                  style: t.labelSmall?.copyWith(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w900,
                                    color: accent.withOpacity(0.95),
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if ((item.subtitle ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              item.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall?.copyWith(
                                fontSize: 11.2,
                                height: 1.20,
                                fontWeight: FontWeight.w700, // ✅ un poquito más firme
                                color: ColoresApp.textoSuave,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ✅ botón flecha más “limpio” y centrado
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: accent.withOpacity(0.16)),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: accent.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
