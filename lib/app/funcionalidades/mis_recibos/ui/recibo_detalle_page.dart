import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../data/mis_recibos_repository_mock.dart';
import '../domain/mis_recibos_models.dart';
import '../widgets/mis_recibos_ui.dart';
import '../widgets/recibo_report_sheet.dart';

class ReciboDetallePage extends StatefulWidget {
  const ReciboDetallePage({super.key, required this.reciboId});

  final String reciboId;

  @override
  State<ReciboDetallePage> createState() => _ReciboDetallePageState();
}

class _ReciboDetallePageState extends State<ReciboDetallePage> {
  final repo = MisRecibosRepositoryMock.instance;
  late Future<ReciboDetalle> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.obtenerDetalle(widget.reciboId);
  }

  Future<void> _reload() async {
    setState(() => _future = repo.obtenerDetalle(widget.reciboId));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = ColoresApp.cafe;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        title: Text(
          'Detalle de recibo',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
        ),
      ),
      body: FutureBuilder<ReciboDetalle>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snap.error}'),
            );
          }

          final d = snap.data!;
          final r = d.resumen;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            children: [
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
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withOpacity(0.22)),
                      ),
                      child: Icon(PhosphorIconsRegular.filePdf, color: accent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.periodoLabel,
                            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              UiPill(
                                text: r.estado.label,
                                fg: r.disponible ? accent : ColoresApp.textoSuave,
                                bg: r.disponible ? accent.withOpacity(0.10) : ColoresApp.inputBg,
                                bd: r.disponible ? accent.withOpacity(0.22) : ColoresApp.bordeSuave,
                                icon: r.disponible ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.clock,
                              ),
                              UiPill(
                                text: 'Neto ${money(r.neto)}',
                                fg: ColoresApp.texto,
                                bg: ColoresApp.inputBg,
                                bd: ColoresApp.bordeSuave,
                                icon: PhosphorIconsRegular.money,
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

              UiSectionCard(
                title: 'Resumen',
                icon: PhosphorIconsRegular.info,
                child: Column(
                  children: [
                    UiKVRow(k: 'Año', v: r.anio.toString()),
                    UiKVRow(k: 'Quincena', v: fmt2(r.quincena)),
                    UiKVRow(k: 'Disponible', v: MaterialLocalizations.of(context).formatFullDate(r.disponibleAt)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              UiSectionCard(
                title: 'Percepciones',
                icon: PhosphorIconsRegular.plusCircle,
                child: Column(
                  children: [
                    for (final e in d.percepciones.entries) UiKVRow(k: e.key, v: money(e.value)),
                    UiKVRow(k: 'Total', v: money(d.totalPercepciones)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              UiSectionCard(
                title: 'Deducciones',
                icon: PhosphorIconsRegular.minusCircle,
                child: Column(
                  children: [
                    for (final e in d.deducciones.entries) UiKVRow(k: e.key, v: money(e.value)),
                    UiKVRow(k: 'Total', v: money(d.totalDeducciones)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: UiSecondaryButton(
                      text: 'Reportar',
                      onTap: () => _reportar(r.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UiPrimaryButton(
                      text: 'Descargar',
                      accent: accent,
                      enabled: r.disponible,
                      onTap: () => _descargar(r.id),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _descargar(String id) async {
    try {
      final file = await repo.descargar(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargado: $file (mock).'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No disponible: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _reportar(String id) async {
    final res = await ReciboReportSheet.open(context);
    if (res == null) return;

    try {
      await repo.reportar(ReporteNominaPayload(reciboId: id, motivo: res.motivo, detalle: res.detalle));
      if (!mounted) return;
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado (mock).'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
