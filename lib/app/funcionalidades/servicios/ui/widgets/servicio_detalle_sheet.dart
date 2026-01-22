// servicio_detalle_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/servicios/data/servicios_detalle_mock.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../domain/servicio_detalle.dart';
import '../../domain/servicio_item.dart';

/// =======================================================
/// CTA inteligente + navegación segura al flujo de PROCESO
/// =======================================================

bool _hasAnyContactInfo(ServicioDetalle d) {
  final nombre = (d.ubicacionNombre ?? '').trim();
  final dir = (d.ubicacionDireccion ?? '').trim();

  return d.telefonos.isNotEmpty ||
      d.correos.isNotEmpty ||
      nombre.isNotEmpty ||
      dir.isNotEmpty;
}

/// ✅ Ruta del “proceso”
/// - Si `item.route` viene, se usa.
/// - Si no viene, se construye un fallback.
///   AJUSTA si tu GoRouter usa otra forma (ej: '/servicios/proceso/${id}')
String? _resolveProcessRoute(ServicioItem item) {
  final r = (item.route ?? '').trim();
  if (r.isNotEmpty) return r;

  // ✅ Fallback recomendado (REST style)
  final id = Uri.encodeComponent(item.id);
  return '/servicios/$id/proceso';
}

String _resolvePrimaryText({
  required ServicioItem item,
  required ServicioDetalle d,
  required bool hasProcessRoute,
}) {
  final isTramite = item.tipo == ServicioTipo.tramite;
  final isDigital = d.canal == ServicioCanal.digital;

  // Si existe flujo de proceso, CTA exacto
  if (hasProcessRoute) {
    if (isTramite && isDigital) return 'Iniciar trámite';
    if (isTramite && !isDigital) return 'Agendar cita';
    if (!isTramite && isDigital) return 'Abrir consulta';
    return 'Continuar';
  }

  // Sin flujo:
  if (!isDigital) {
    return _hasAnyContactInfo(d) ? 'Contactar' : 'Entendido';
  }

  return 'Próximamente';
}

bool _resolvePrimaryEnabled({
  required ServicioDetalle d,
  required bool hasProcessRoute,
}) {
  final isDigital = d.canal == ServicioCanal.digital;

  if (hasProcessRoute) return true;

  if (!isDigital) return true; // “Contactar” o “Entendido”
  return false; // “Próximamente”
}

Future<void> _copyToClipboard(BuildContext context, String text, {String? toast}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(toast ?? 'Copiado al portapapeles'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<void> _showContactOptionsSheet({
  required BuildContext context,
  required ServicioDetalle detalle,
  required Color accent,
}) async {
  final nombre = (detalle.ubicacionNombre ?? '').trim();
  final dir = (detalle.ubicacionDireccion ?? '').trim();
  final horario = (detalle.horario ?? '').trim();

  final hasNombre = nombre.isNotEmpty;
  final hasDir = dir.isNotEmpty;
  final hasHorario = horario.isNotEmpty;

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    barrierColor: Colors.black.withOpacity(0.40),
    backgroundColor: ColoresApp.blanco,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withOpacity(0.18)),
                  ),
                  child: Icon(Icons.support_agent_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Opciones de contacto',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (hasHorario)
              _ContactTile(
                icon: Icons.schedule_rounded,
                title: 'Horario',
                subtitle: horario,
                onTap: () => _copyToClipboard(context, horario, toast: 'Horario copiado'),
              ),

            if (hasNombre || hasDir)
              _ContactTile(
                icon: Icons.location_on_outlined,
                title: hasNombre ? nombre : 'Ubicación',
                subtitle: hasDir ? dir : '—',
                onTap: () {
                  final text = [
                    if (hasNombre) nombre,
                    if (hasDir) dir,
                  ].join('\n');
                  _copyToClipboard(context, text, toast: 'Ubicación copiada');
                },
              ),

            if (detalle.telefonos.isNotEmpty)
              for (final tel in detalle.telefonos)
                _ContactTile(
                  icon: Icons.phone_outlined,
                  title: 'Teléfono',
                  subtitle: tel,
                  onTap: () => _copyToClipboard(context, tel, toast: 'Teléfono copiado'),
                ),

            if (detalle.correos.isNotEmpty)
              for (final mail in detalle.correos)
                _ContactTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Correo',
                  subtitle: mail,
                  onTap: () => _copyToClipboard(context, mail, toast: 'Correo copiado'),
                ),

            if (!hasHorario &&
                !hasNombre &&
                !hasDir &&
                detalle.telefonos.isEmpty &&
                detalle.correos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: _EmptyInfo(),
              ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _SecondaryButton(
                text: 'Cerrar',
                onTap: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showServicioDetalleSheet({
  required BuildContext context,
  required ServicioItem item,
}) async {
  final base = Theme.of(context);

  final sheetTheme = base.copyWith(
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ColoresApp.blanco,
      modalBackgroundColor: ColoresApp.blanco,
      surfaceTintColor: Colors.transparent,
    ),
    colorScheme: base.colorScheme.copyWith(
      surface: ColoresApp.blanco,
      surfaceTint: Colors.transparent,
    ),
    dividerColor: Colors.transparent,
  );

  // ✅ Guardamos el contexto “de afuera” para navegar seguro después del pop del sheet
  final outerContext = context;

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    barrierColor: Colors.black.withOpacity(0.40),
    backgroundColor: ColoresApp.blanco,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Theme(
      data: sheetTheme,
      child: _ServicioDetalleSheet(
        item: item,
        outerContext: outerContext,
      ),
    ),
  );
}

class _ServicioDetalleSheet extends StatelessWidget {
  final ServicioItem item;
  final BuildContext outerContext;

  const _ServicioDetalleSheet({
    required this.item,
    required this.outerContext,
  });

  ServicioDetalle _detalleFor(ServicioItem it) {
    return serviciosDetallesMock[it.id] ??
        ServicioDetalle(
          canal: ServicioCanal.digital,
          descripcion: 'Información detallada disponible próximamente.',
          requisitos: const ['—'],
          pasos: const ['—'],
        );
  }

  @override
  Widget build(BuildContext context) {
    final accent = item.accent;
    final detalle = _detalleFor(item);

    final tipoLabel = item.tipo == ServicioTipo.tramite ? 'Trámite' : 'Consulta';
    final categoriaLabel = item.categoria.texto;

    final processRoute = _resolveProcessRoute(item);
    final hasProcessRoute = (processRoute ?? '').trim().isNotEmpty;

    final String primaryText = _resolvePrimaryText(
      item: item,
      d: detalle,
      hasProcessRoute: hasProcessRoute,
    );

    final bool primaryEnabled = _resolvePrimaryEnabled(
      d: detalle,
      hasProcessRoute: hasProcessRoute,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            _HeroHeader(
              item: item,
              accent: accent,
              tipoLabel: tipoLabel,
              categoriaLabel: categoriaLabel,
              onClose: () => Navigator.pop(context),
            ),

            Expanded(
              child: CustomScrollView(
                controller: scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: _QuickFactsCarousel(
                        accent: accent,
                        canal: detalle.canal,
                        requisitos: detalle.requisitos.length,
                        pasos: detalle.pasos.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _DescriptionCard(
                        accent: accent,
                        title: 'Descripción',
                        text: detalle.descripcion,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AccordionSection(
                        accent: accent,
                        detalle: detalle,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: ColoresApp.blanco,
                  border: Border(
                    top: BorderSide(color: ColoresApp.bordeSuave.withOpacity(0.9)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        text: 'Cerrar',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrimaryButton(
                        text: primaryText,
                        accent: accent,
                        enabled: primaryEnabled,
                        onTap: () async {
                          // 1) Si existe flujo de proceso => push (para evitar pantalla negra al volver)
                          if (hasProcessRoute) {
                            Navigator.pop(context); // cierra sheet

                            // ✅ Navega con el contexto externo y en microtask
                            Future.microtask(() => outerContext.push(processRoute!));
                            return;
                          }

                          // 2) Sin flujo: si es presencial con datos => sheet de contacto
                          if (detalle.canal == ServicioCanal.presencial && _hasAnyContactInfo(detalle)) {
                            Navigator.pop(context);
                            await _showContactOptionsSheet(
                              context: outerContext,
                              detalle: detalle,
                              accent: accent,
                            );
                            return;
                          }

                          // 3) Entendido / Próximamente
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// =====================
/// HERO HEADER
/// =====================
class _HeroHeader extends StatelessWidget {
  final ServicioItem item;
  final Color accent;
  final String tipoLabel;
  final String categoriaLabel;
  final VoidCallback onClose;

  const _HeroHeader({
    required this.item,
    required this.accent,
    required this.tipoLabel,
    required this.categoriaLabel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final subtitle = (item.subtitle ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        border: Border(bottom: BorderSide(color: ColoresApp.bordeSuave.withOpacity(0.9))),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 35,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.08),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColoresApp.blanco,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withOpacity(0.18)),
                ),
                child: Icon(item.icon, size: 22, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                        height: 1.06,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          text: tipoLabel,
                          bg: ColoresApp.blanco.withOpacity(0.90),
                          bd: accent.withOpacity(0.20),
                          fg: accent.withOpacity(0.95),
                        ),
                        _Chip(
                          text: categoriaLabel,
                          bg: ColoresApp.blanco.withOpacity(0.70),
                          bd: ColoresApp.bordeSuave,
                          fg: ColoresApp.textoSuave,
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColoresApp.textoSuave,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =====================
/// QUICK FACTS
/// =====================
class _QuickFactsCarousel extends StatelessWidget {
  final Color accent;
  final ServicioCanal canal;
  final int requisitos;
  final int pasos;

  const _QuickFactsCarousel({
    required this.accent,
    required this.canal,
    required this.requisitos,
    required this.pasos,
  });

  @override
  Widget build(BuildContext context) {
    final canalText = canal == ServicioCanal.digital ? 'Digital' : 'Presencial';

    return SizedBox(
      height: 74,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            width: 170,
            child: _MiniFact(
              accent: accent,
              icon: canal == ServicioCanal.digital ? Icons.public_rounded : Icons.location_on_outlined,
              title: 'Canal',
              value: canalText,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: _MiniFact(
              accent: accent,
              icon: Icons.checklist_rounded,
              title: 'Requisitos',
              value: '$requisitos',
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 170,
            child: _MiniFact(
              accent: accent,
              icon: Icons.alt_route_rounded,
              title: 'Pasos',
              value: '$pasos',
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String title;
  final String value;

  const _MiniFact({
    required this.accent,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.18)),
            ),
            child: Center(child: Icon(icon, size: 20, color: accent)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.textoSuave,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
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

/// =====================
/// DESCRIPTION CARD
/// =====================
class _DescriptionCard extends StatelessWidget {
  final Color accent;
  final String title;
  final String text;

  const _DescriptionCard({
    required this.accent,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.90),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: t.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: ColoresApp.texto,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================
/// ACCORDION SECTION
/// =====================
class _AccordionSection extends StatefulWidget {
  final Color accent;
  final ServicioDetalle detalle;

  const _AccordionSection({
    required this.accent,
    required this.detalle,
  });

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  bool openReq = true;
  bool openPasos = true;
  bool openAtencion = true;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final detalle = widget.detalle;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Column(
        children: [
          _ExpCard(
            title: 'Requisitos',
            icon: Icons.checklist_rounded,
            accent: accent,
            expanded: openReq,
            onChanged: (v) => setState(() => openReq = v),
            child: Column(
              children: detalle.requisitos.map((x) => _CheckRow(text: x, accent: accent)).toList(),
            ),
          ),
          const SizedBox(height: 10),
          _ExpCard(
            title: 'Pasos',
            icon: Icons.alt_route_rounded,
            accent: accent,
            expanded: openPasos,
            onChanged: (v) => setState(() => openPasos = v),
            child: _TimelineSteps(pasos: detalle.pasos, accent: accent),
          ),
          const SizedBox(height: 10),
          _ExpCard(
            title: detalle.canal == ServicioCanal.digital ? 'Canal digital' : 'Atención presencial',
            icon: detalle.canal == ServicioCanal.digital ? Icons.public_rounded : Icons.location_on_outlined,
            accent: accent,
            expanded: openAtencion,
            onChanged: (v) => setState(() => openAtencion = v),
            child: detalle.canal == ServicioCanal.digital ? const _DigitalInfo() : _PresencialInfo(detalle: detalle),
          ),
        ],
      ),
    );
  }
}

class _ExpCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final bool expanded;
  final ValueChanged<bool> onChanged;
  final Widget child;

  const _ExpCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.expanded,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: expanded,
        onExpansionChanged: onChanged,
        tilePadding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: ColoresApp.textoSuave,
        collapsedIconColor: ColoresApp.textoSuave,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.18)),
              ),
              child: Center(child: Icon(icon, size: 20, color: accent)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
            ),
          ],
        ),
        children: [child],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  final Color accent;

  const _CheckRow({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Icon(Icons.check_rounded, size: 14, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: ColoresApp.texto,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSteps extends StatelessWidget {
  final List<String> pasos;
  final Color accent;

  const _TimelineSteps({
    required this.pasos,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        for (int i = 0; i < pasos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent.withOpacity(0.22)),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: t.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: accent.withOpacity(0.95),
                            ),
                          ),
                        ),
                      ),
                      if (i != pasos.length - 1)
                        Container(
                          width: 2,
                          height: 26,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pasos[i],
                    style: t.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.texto,
                      height: 1.35,
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

class _DigitalInfo extends StatelessWidget {
  const _DigitalInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.verified_user_outlined,
          title: 'Proceso en línea',
          subtitle: 'Puedes iniciarlo desde el portal.',
        ),
        SizedBox(height: 10),
        _InfoRow(
          icon: Icons.lock_outline_rounded,
          title: 'Recomendación',
          subtitle: 'Ten tus datos a la mano para completar el trámite sin pausas.',
        ),
      ],
    );
  }
}

class _PresencialInfo extends StatelessWidget {
  final ServicioDetalle detalle;
  const _PresencialInfo({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];

    void add(Widget w) {
      if (blocks.isNotEmpty) blocks.add(const SizedBox(height: 10));
      blocks.add(w);
    }

    final horario = (detalle.horario ?? '').trim();
    final nombre = (detalle.ubicacionNombre ?? '').trim();
    final dir = (detalle.ubicacionDireccion ?? '').trim();

    if (horario.isNotEmpty) add(_InfoRow(icon: Icons.schedule_rounded, title: 'Horario', subtitle: horario));
    if (nombre.isNotEmpty || dir.isNotEmpty) {
      add(_InfoRow(
        icon: Icons.location_on_outlined,
        title: nombre.isNotEmpty ? nombre : 'Ubicación',
        subtitle: dir.isNotEmpty ? dir : '—',
      ));
    }
    if (detalle.telefonos.isNotEmpty) {
      add(_InfoRow(icon: Icons.phone_outlined, title: 'Teléfono', subtitle: detalle.telefonos.join(' • ')));
    }
    if (detalle.correos.isNotEmpty) {
      add(_InfoRow(icon: Icons.mail_outline_rounded, title: 'Correo', subtitle: detalle.correos.join(' • ')));
    }

    if (blocks.isEmpty) return const _EmptyInfo();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }
}

class _EmptyInfo extends StatelessWidget {
  const _EmptyInfo();

  @override
  Widget build(BuildContext context) {
    return const _InfoRow(
      icon: Icons.info_outline_rounded,
      title: 'Información',
      subtitle: 'Disponible próximamente.',
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColoresApp.textoSuave),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.textoSuave,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color bd;
  final Color fg;

  const _Chip({
    required this.text,
    required this.bg,
    required this.bd,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: enabled ? accent : ColoresApp.bordeSuave,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: enabled ? Colors.white : ColoresApp.textoSuave,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.inputBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: ColoresApp.texto,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: ColoresApp.textoSuave),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.copy_rounded, size: 18),
      ),
    );
  }
}
