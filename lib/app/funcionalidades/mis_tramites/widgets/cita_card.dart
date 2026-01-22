import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../domain/mis_citas_models.dart';
import 'mis_citas_ui.dart';

class CitaCard extends StatelessWidget {
  const CitaCard({
    super.key,
    required this.item,
    required this.onOpen,
    this.onReagendar,
    this.onCancelar,
  });

  final CitaResumen item;
  final VoidCallback onOpen;
  final VoidCallback? onReagendar;
  final VoidCallback? onCancelar;

  String _tipoLabel() => item.tipo == CitaTipo.tramite ? 'Trámite' : 'Consulta';

  // ✅ Solo permitimos acentos oficiales; si viene un color raro del mock, se ignora.
  bool _isAccentOficial(Color c) {
    return c.value == ColoresApp.vino.value ||
        c.value == ColoresApp.dorado.value ||
        c.value == ColoresApp.cafe.value;
  }

  // ✅ Accent final institucional (por estado si el mock viene “loco”)
  Color _accent() {
    final c = item.accent;
    if (c != null && _isAccentOficial(c)) return c;

    switch (item.estado) {
      case CitaEstado.proxima:
        return ColoresApp.vino;
      case CitaEstado.enProceso:
        return ColoresApp.dorado;
      case CitaEstado.finalizada:
        return ColoresApp.cafe;
      case CitaEstado.cancelada:
        return ColoresApp.vino;
    }
  }

  IconData _canalIcon() {
    return item.esDigital
        ? PhosphorIconsRegular.globeHemisphereWest
        : PhosphorIconsRegular.mapPin;
  }

  IconData _estadoIcon() {
    switch (item.estado) {
      case CitaEstado.proxima:
        return PhosphorIconsRegular.calendarCheck;
      case CitaEstado.enProceso:
        return PhosphorIconsRegular.arrowsClockwise;
      case CitaEstado.finalizada:
        return PhosphorIconsRegular.sealCheck;
      case CitaEstado.cancelada:
        return PhosphorIconsRegular.xCircle;
    }
  }

  UiPill _pillEstado(Color a) {
    switch (item.estado) {
      case CitaEstado.proxima:
        return UiPill(
          text: 'Próxima',
          fg: a,
          bg: a.withOpacity(0.10),
          bd: a.withOpacity(0.22),
          icon: _estadoIcon(),
        );
      case CitaEstado.enProceso:
        return UiPill(
          text: 'En proceso',
          fg: ColoresApp.texto,
          bg: ColoresApp.inputBg,
          bd: ColoresApp.bordeSuave,
          icon: _estadoIcon(),
        );
      case CitaEstado.finalizada:
        return UiPill(
          text: 'Finalizada',
          fg: ColoresApp.texto,
          bg: ColoresApp.inputBg,
          bd: ColoresApp.bordeSuave,
          icon: _estadoIcon(),
        );
      case CitaEstado.cancelada:
        return UiPill(
          text: 'Cancelada',
          fg: Colors.red.shade700,
          bg: Colors.red.shade50,
          bd: Colors.red.shade200,
          icon: _estadoIcon(),
        );
    }
  }

  String _countdown() {
    if (item.citaAt == null) return '';
    final now = DateTime.now();
    final d0 = DateUtils.dateOnly(now);
    final d1 = DateUtils.dateOnly(item.citaAt!);
    final diff = d1.difference(d0).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Mañana';
    if (diff > 1) return 'En $diff días';
    return 'Pasó';
  }

  Future<void> _copyFolio(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: item.folio));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Folio copiado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = _accent();

    // 🔧 Radios “master” para alinear TODO (card + clip + franja)
    const double radius = 18;
    final r = BorderRadius.circular(radius);

    final ml = MaterialLocalizations.of(context);
    final citaLabel = item.citaAt == null
        ? (item.esDigital ? 'En línea' : '—')
        : '${ml.formatShortDate(item.citaAt!)} • ${ml.formatTimeOfDay(
            TimeOfDay.fromDateTime(item.citaAt!),
            alwaysUse24HourFormat: true,
          )}';

    final soft = a.withOpacity(0.08);
    final bd = a.withOpacity(0.16);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: r, // ✅ recorta perfecto las esquinas
        child: InkWell(
          onTap: onOpen,
          child: Ink(
            decoration: BoxDecoration(
              color: ColoresApp.blanco,
              borderRadius: r,
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge, // ✅ extra safety
              children: [
                // ✅ Franja ya NO pelea con el borde redondeado
                Positioned(
                  left: 1,   // 🔧 1px hacia dentro del borde
                  top: 1,
                  bottom: 1, // 🔧 evita “picos” en esquinas
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: a.withOpacity(0.75),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(radius - 1),
                        bottomLeft: Radius.circular(radius - 1),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: soft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: bd),
                            ),
                            child: Icon(_canalIcon(), color: a, size: 20),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.texto,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.hash,
                                      size: 16,
                                      color: ColoresApp.textoSuave,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: GestureDetector(
                                        onLongPress: () => _copyFolio(context),
                                        child: Text(
                                          item.folio,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: ColoresApp.texto,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.clock,
                                      size: 16,
                                      color: ColoresApp.textoSuave,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        citaLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: ColoresApp.textoSuave,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),
                          _pillEstado(a),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          UiPill(
                            text: _tipoLabel(),
                            fg: ColoresApp.textoSuave,
                            bg: ColoresApp.inputBg,
                            bd: ColoresApp.bordeSuave,
                            icon: item.tipo == CitaTipo.tramite
                                ? PhosphorIconsRegular.fileText
                                : PhosphorIconsRegular.magnifyingGlass,
                          ),
                          UiPill(
                            text: item.canal.label,
                            fg: a,
                            bg: a.withOpacity(0.10),
                            bd: a.withOpacity(0.22),
                            icon: item.esDigital
                                ? PhosphorIconsRegular.globeHemisphereWest
                                : PhosphorIconsRegular.mapPin,
                          ),
                          if (item.esPresencial &&
                              (item.ubicacionNombre ?? '').trim().isNotEmpty)
                            UiPill(
                              text: item.ubicacionNombre!.trim(),
                              fg: ColoresApp.textoSuave,
                              bg: ColoresApp.inputBg,
                              bd: ColoresApp.bordeSuave,
                              icon: PhosphorIconsRegular.buildings,
                            ),
                          if (item.estado == CitaEstado.proxima &&
                              item.esPresencial &&
                              item.citaAt != null)
                            UiPill(
                              text: _countdown(),
                              fg: a,
                              bg: a.withOpacity(0.10),
                              bd: a.withOpacity(0.22),
                              icon: PhosphorIconsRegular.timer,
                            ),
                        ],
                      ),

                      if (item.puedeReagendar || item.puedeCancelar) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (item.puedeCancelar) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: onCancelar,
                                  icon: Icon(
                                    PhosphorIconsRegular.x,
                                    color: Colors.red.shade700,
                                    size: 18,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red.shade200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  label: Text(
                                    'Cancelar',
                                    style: t.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (item.puedeCancelar && item.puedeReagendar)
                              const SizedBox(width: 10),
                            if (item.puedeReagendar) ...[
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: onReagendar,
                                  icon: Icon(
                                    PhosphorIconsRegular.pencilSimpleLine,
                                    color: ColoresApp.blanco,
                                    size: 18,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: a,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  label: Text(
                                    'Cambiar fecha',
                                    style: t.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: ColoresApp.blanco,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
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
