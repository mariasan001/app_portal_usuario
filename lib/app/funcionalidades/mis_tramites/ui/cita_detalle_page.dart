import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/mis_citas_repository_mock.dart';
import '../domain/mis_citas_models.dart';
import '../widgets/cita_selector_sheet.dart';
import '../widgets/cita_timeline.dart';
import '../widgets/mis_citas_ui.dart';

class CitaDetallePage extends StatefulWidget {
  const CitaDetallePage({super.key, required this.citaId});

  final String citaId;

  @override
  State<CitaDetallePage> createState() => _CitaDetallePageState();
}

class _CitaDetallePageState extends State<CitaDetallePage> {
  final repo = MisCitasRepositoryMock.instance;

  late Future<CitaDetalle> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.obtenerDetalle(widget.citaId);
  }

  Future<void> _reload() async {
    setState(() => _future = repo.obtenerDetalle(widget.citaId));
  }

  // ─────────────────────────────
  // 🎨 Acento institucional
  // ─────────────────────────────
  bool _isAccentOficial(Color c) {
    return c.value == ColoresApp.vino.value ||
        c.value == ColoresApp.dorado.value ||
        c.value == ColoresApp.cafe.value;
  }

  Color _accentOf(CitaDetalle d) {
    final c = d.accent;
    if (c != null && _isAccentOficial(c)) return c;

    // Fallback por estado (solo identidad)
    switch (d.estado) {
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

  // ─────────────────────────────
  // 🧩 Íconos Phosphor
  // ─────────────────────────────
  IconData _canalIcon(CitaCanal canal) {
    switch (canal) {
      case CitaCanal.digital:
        return PhosphorIconsRegular.globeHemisphereWest;
      case CitaCanal.presencial:
        return PhosphorIconsRegular.mapPin;
    }
  }

  IconData _estadoIcon(CitaEstado estado) {
    switch (estado) {
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

  IconData _tipoIcon(CitaTipo tipo) {
    return tipo == CitaTipo.tramite ? PhosphorIconsRegular.fileText : PhosphorIconsRegular.magnifyingGlass;
  }

  // ─────────────────────────────
  // 🟣 Píldora de estado (consistente)
  // ─────────────────────────────
  UiPill _pillEstado(CitaDetalle d, Color a) {
    switch (d.estado) {
      case CitaEstado.proxima:
        return UiPill(
          text: d.estado.label,
          fg: a,
          bg: a.withOpacity(0.10),
          bd: a.withOpacity(0.22),
          icon: _estadoIcon(d.estado),
        );

      case CitaEstado.enProceso:
        return UiPill(
          text: d.estado.label,
          fg: ColoresApp.texto,
          bg: ColoresApp.inputBg,
          bd: ColoresApp.bordeSuave,
          icon: _estadoIcon(d.estado),
        );

      case CitaEstado.finalizada:
        return UiPill(
          text: d.estado.label,
          fg: ColoresApp.texto,
          bg: ColoresApp.inputBg,
          bd: ColoresApp.bordeSuave,
          icon: _estadoIcon(d.estado),
        );

      case CitaEstado.cancelada:
        return UiPill(
          text: d.estado.label,
          fg: Colors.red.shade700,
          bg: Colors.red.shade50,
          bd: Colors.red.shade200,
          icon: _estadoIcon(d.estado),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        title: Text(
          'Detalle de cita',
          style: t.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: ColoresApp.texto,
          ),
        ),
      ),
      body: FutureBuilder<CitaDetalle>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: ColoresApp.cafe),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snap.error}'),
            );
          }

          final d = snap.data!;
          final a = _accentOf(d);
          final ml = MaterialLocalizations.of(context);

          final citaLabel = d.citaAt == null
              ? (d.canal == CitaCanal.digital ? 'En línea' : '—')
              : '${ml.formatFullDate(d.citaAt!)} • ${ml.formatTimeOfDay(
                  TimeOfDay.fromDateTime(d.citaAt!),
                  alwaysUse24HourFormat: true,
                )}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            children: [
              // ─────────────────────────────
              // Header / Hero
              // ─────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: ColoresApp.blanco,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ColoresApp.bordeSuave),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: a.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: a.withOpacity(0.22)),
                      ),
                      child: Icon(_canalIcon(d.canal), color: a, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.titulo,
                            style: t.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ColoresApp.texto,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pillEstado(d, a),
                              UiPill(
                                text: d.canal.label,
                                fg: a,
                                bg: a.withOpacity(0.10),
                                bd: a.withOpacity(0.22),
                                icon: _canalIcon(d.canal),
                              ),
                              UiPill(
                                text: d.tipo == CitaTipo.tramite ? 'Trámite' : 'Consulta',
                                fg: ColoresApp.textoSuave,
                                bg: ColoresApp.inputBg,
                                bd: ColoresApp.bordeSuave,
                                icon: _tipoIcon(d.tipo),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─────────────────────────────
              // Resumen
              // ─────────────────────────────
              UiSectionCard(
                title: 'Resumen',
                icon: PhosphorIconsRegular.info,
                child: Column(
                  children: [
                    UiKVRow(k: 'Folio', v: d.folio),
                    UiKVRow(k: 'Canal', v: d.canal.label),
                    UiKVRow(k: 'Fecha/hora', v: citaLabel),
                    if ((d.ubicacionNombre ?? '').trim().isNotEmpty)
                      UiKVRow(k: 'Lugar', v: d.ubicacionNombre!.trim()),
                    if ((d.direccion ?? '').trim().isNotEmpty)
                      UiKVRow(k: 'Dirección', v: d.direccion!.trim()),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─────────────────────────────
              // Historial
              // ─────────────────────────────
              UiSectionCard(
                title: 'Historial del proceso',
                icon: PhosphorIconsRegular.path,
                child: CitaTimeline(pasos: d.pasos, accent: a),
              ),

              // ─────────────────────────────
              // Recomendaciones
              // ─────────────────────────────
              if (d.recomendaciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                UiSectionCard(
                  title: 'Recomendaciones',
                  icon: PhosphorIconsRegular.listChecks,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final x in d.recomendaciones)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                PhosphorIconsRegular.info,
                                size: 18,
                                color: ColoresApp.textoSuave,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  x,
                                  style: t.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: ColoresApp.textoSuave,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // ─────────────────────────────
              // Constancia
              // ─────────────────────────────
              if (d.constancia != null) ...[
                const SizedBox(height: 12),
                UiSectionCard(
                  title: 'Constancia',
                  icon: PhosphorIconsRegular.fileText,
                  child: Column(
                    children: [
                      UiKVRow(k: 'Emitida', v: ml.formatFullDate(d.constancia!.emitidaAt)),
                      UiKVRow(k: 'Vence', v: ml.formatFullDate(d.constancia!.venceAt)),
                      UiKVRow(k: 'Vigencia', v: '6 meses (mock)'),
                      const SizedBox(height: 10),
                      if (d.puedeDescargarConstancia)
                        UiPrimaryButton(
                          text: 'Descargar constancia',
                          accent: a,
                          onTap: () => _descargar(d),
                        )
                      else if (d.constanciaVencida)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: ColoresApp.inputBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ColoresApp.bordeSuave),
                          ),
                          child: Text(
                            'La constancia ya venció. Puedes generar una nueva realizando la consulta/trámite nuevamente (mock).',
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ColoresApp.textoSuave,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ─────────────────────────────
              // Acciones
              // ─────────────────────────────
              if (d.puedeReagendar || d.puedeCancelar) ...[
                Row(
                  children: [
                    if (d.puedeCancelar) ...[
                      Expanded(
                        child: UiSecondaryButton(
                          text: 'Cancelar',
                          onTap: () => _cancelar(d),
                        ),
                      ),
                    ],
                    if (d.puedeCancelar && d.puedeReagendar) const SizedBox(width: 12),
                    if (d.puedeReagendar) ...[
                      Expanded(
                        child: UiPrimaryButton(
                          text: 'Cambiar fecha',
                          accent: a,
                          onTap: () => _reagendar(d),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancelar(CitaDetalle d) async {
    try {
      await repo.cancelar(d.id);
      if (!mounted) return;
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada (mock).'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cancelar: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _reagendar(CitaDetalle d) async {
    final initial = d.citaAt ?? DateTime.now().add(const Duration(days: 2));
    final res = await CitaSelectorSheet.open(
      context,
      accent: _accentOf(d), // ✅ siempre oficial
      initial: initial,
      daysWindow: 21,
    );
    if (res == null) return;

    try {
      await repo.reagendar(id: d.id, nuevaFechaHora: res.fechaHora);
      if (!mounted) return;
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita reagendada (mock).'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo reagendar: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _descargar(CitaDetalle d) async {
    try {
      final file = await repo.descargarConstancia(d.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargada: $file (mock).'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No disponible: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
