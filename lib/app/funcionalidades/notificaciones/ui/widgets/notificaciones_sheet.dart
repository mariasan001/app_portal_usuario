import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../tema/colores.dart';

/* =======================================================================
  MODELO
======================================================================= */

enum NotiTipo { tramite, cita, recibo, sistema }
enum NotiEstado { accion, enProceso, proxima, listo, info } // (se queda por backend, pero NO se muestra)

class NotificacionItem {
  final String id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final NotiTipo tipo;
  final NotiEstado estado;
  final bool leida;
  final String? route;
  final Color? accent;

  const NotificacionItem({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.tipo,
    required this.estado,
    this.leida = false,
    this.route,
    this.accent,
  });
}

/* =======================================================================
  SHEET (SIN FILTROS)
======================================================================= */

class NotificacionesSheet extends StatelessWidget {
  final List<NotificacionItem> items;
  final VoidCallback? onMarkAllRead;
  final void Function(NotificacionItem item)? onOpen;

  const NotificacionesSheet({
    super.key,
    required this.items,
    this.onMarkAllRead,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final unread = items.where((e) => !e.leida).length;

    return Container(
      decoration: const BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Header =====
              Row(
                children: [
                  Text(
                    'Notificaciones',
                    style: t.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (unread > 0) _CountPill(count: unread),
                  const Spacer(),
                  TextButton(
                    onPressed: unread == 0 ? null : onMarkAllRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Marcar todo',
                      style: t.bodySmall?.copyWith(
                        color: unread == 0 ? ColoresApp.textoSuave : ColoresApp.vino,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== Lista =====
              Flexible(
                child: items.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => NotificacionCard(
                          item: items[i],
                          onTap: () => onOpen?.call(items[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =======================================================================
  CARD (SIN ESTADO / SIN “PROCESO/PRÓXIMO/LISTO”)
======================================================================= */

class NotificacionCard extends StatelessWidget {
  final NotificacionItem item;
  final VoidCallback? onTap;

  const NotificacionCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final accent = item.accent ?? _accentForTipo(item.tipo);
    final icon = _iconFor(item.tipo);

    return Material(
      color: ColoresApp.blanco,
      surfaceTintColor: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ColoresApp.bordeSuave),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent rail (se estira solo)
                Container(
                  width: 4,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(item.leida ? 0.35 : 0.85),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                // Icon bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.22)),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),

                const SizedBox(width: 10),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodyMedium?.copyWith(
                                fontWeight: item.leida ? FontWeight.w800 : FontWeight.w900,
                                color: ColoresApp.texto,
                                letterSpacing: 0.1,
                                height: 1.15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(item.fecha),
                            style: t.bodySmall?.copyWith(
                              color: ColoresApp.textoSuave,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        item.mensaje,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                          color: ColoresApp.textoSuave,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          // ✅ Solo “no leído” (sin estado)
                          if (!item.leida)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: accent.withOpacity(0.22)),
                              ),
                              child: Text(
                                'Nuevo',
                                style: t.labelSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),

                          const Spacer(),

                          // dot sutil + chevron
                          if (!item.leida)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                              ),
                            ),

                          Icon(
                            PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                            size: 18,
                            color: ColoresApp.textoSuave.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
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

/* =======================================================================
  Pieces
======================================================================= */

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final label = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColoresApp.vino.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColoresApp.vino.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: t.labelSmall?.copyWith(
          color: ColoresApp.vino,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ColoresApp.inputBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: Icon(
              PhosphorIcons.bell(PhosphorIconsStyle.light),
              color: ColoresApp.textoSuave,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Todo al día 👌',
            style: t.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: ColoresApp.texto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí te avisamos cuando haya movimientos,\ntrámites o recibos nuevos.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
              color: ColoresApp.textoSuave,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/* =======================================================================
  Helpers
======================================================================= */

IconData _iconFor(NotiTipo tipo) {
  switch (tipo) {
    case NotiTipo.tramite:
      return PhosphorIcons.clipboardText(PhosphorIconsStyle.light);
    case NotiTipo.cita:
      return PhosphorIcons.calendarCheck(PhosphorIconsStyle.light);
    case NotiTipo.recibo:
      return PhosphorIcons.fileText(PhosphorIconsStyle.light);
    case NotiTipo.sistema:
      return PhosphorIcons.shieldCheck(PhosphorIconsStyle.light);
  }
}

Color _accentForTipo(NotiTipo tipo) {
  // ✅ colores “honestos” con tu marca (sin azules random)
  switch (tipo) {
    case NotiTipo.tramite:
      return ColoresApp.vino;
    case NotiTipo.cita:
      return ColoresApp.dorado;
    case NotiTipo.recibo:
      return ColoresApp.cafe;
    case NotiTipo.sistema:
      return ColoresApp.textoSuave;
  }
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
  if (diff.inHours < 24) return 'hace ${diff.inHours}h';

  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final d0 = DateTime(dt.year, dt.month, dt.day);
  final d1 = DateTime(yesterday.year, yesterday.month, yesterday.day);

  if (d0 == DateTime(now.year, now.month, now.day)) return 'hoy';
  if (d0 == d1) return 'ayer';

  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}
