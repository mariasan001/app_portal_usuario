import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../data/mis_recibos_repository_mock.dart';
import '../domain/mis_recibos_models.dart';
import '../widgets/mis_recibos_ui.dart';
import '../widgets/recibo_card.dart';
import '../widgets/recibo_report_sheet.dart';
import 'recibo_detalle_page.dart';

class MisRecibosPage extends StatefulWidget {
  const MisRecibosPage({super.key});

  @override
  State<MisRecibosPage> createState() => _MisRecibosPageState();
}

class _MisRecibosPageState extends State<MisRecibosPage> {
  final repo = MisRecibosRepositoryMock.instance;

  bool _batchMode = false;
  final Set<String> _selected = <String>{};

  late Future<_VM> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_VM> _load() async {
    final p = await repo.proximaNomina();

    // Pedimos más para filtrar bien "anteriores a la próxima"
    final raw = await repo.ultimas(limit: 24);

    final proxKey = periodoKey(p.anio, p.quincena);

    final anteriores = raw
        .where((r) => periodoKey(r.anio, r.quincena) < proxKey)
        .toList()
      ..sort((a, b) => comparePeriodoDesc(a.anio, a.quincena, b.anio, b.quincena));

    final ult5 = anteriores.take(5).toList();

    return _VM(proxima: p, ultimas: ult5);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
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
  centerTitle: false,
  titleSpacing: 16,
  title: Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: ColoresApp.cafe,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        'Recibos de nómina',
        style: t.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: ColoresApp.texto,
          fontSize: 17,
          letterSpacing: -0.1,
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      tooltip: _batchMode ? 'Salir de lote' : 'Modo lote',
      onPressed: () {
        setState(() {
          _batchMode = !_batchMode;
          _selected.clear();
        });
      },
      icon: Icon(
        _batchMode ? PhosphorIconsRegular.x : PhosphorIconsRegular.stack,
        color: ColoresApp.texto,
      ),
    ),
  ],
),

      body: FutureBuilder<_VM>(
        future: _future,
        builder: (ctx, snap) {
          // ✅ sin circular progress
          if (snap.connectionState != ConnectionState.done) {
            return _MisRecibosSkeleton(accent: accent);
          }

          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snap.error}'),
            );
          }

          final vm = snap.data!;
          final proxima = vm.proxima;

          return RefreshIndicator(
            onRefresh: _reload,
            color: accent,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              children: [
                // ------------------ Próxima nómina (SIEMPRE) ------------------
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
                          color: ColoresApp.dorado.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColoresApp.dorado.withOpacity(0.22)),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.calendarCheck,
                          color: ColoresApp.dorado,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Próxima nómina',
                              style: t.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ColoresApp.texto,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // ✅ Mes + año + qna (compacto)
                              periodoLabel(proxima.anio, proxima.quincena, mesCorto: true),
                              style: t.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ColoresApp.textoSuave,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UiPill(
                        text: proxima.countdownLabel,
                        fg: proxima.disponible ? accent : ColoresApp.textoSuave,
                        bg: proxima.disponible ? accent.withOpacity(0.10) : ColoresApp.inputBg,
                        bd: proxima.disponible ? accent.withOpacity(0.22) : ColoresApp.bordeSuave,
                        icon: proxima.disponible ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.clock,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ------------------ Últimas 5 (SIEMPRE y ANTERIORES) ------------------
                UiSectionCard(
                  title: 'Últimas 5 nóminas',
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anteriores a la próxima nómina',
                        style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (vm.ultimas.isEmpty)
                        Text(
                          'Aún no hay nóminas anteriores registradas.',
                          style: t.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.textoSuave,
                          ),
                        )
                      else
                        for (final r in vm.ultimas) ...[
                          ReciboCard(
                            item: r,
                            accent: accent,
                            batchMode: _batchMode,
                            selected: _selected.contains(r.id),
                            onToggleSelect: () => _toggleSelect(r.id),
                            onOpen: () => _open(r.id),
                            onDownload: () => _descargar(r.id),
                            onReport: () => _reportar(r.id),
                          ),
                          const SizedBox(height: 12),
                        ],
                      if (_batchMode && _selected.isNotEmpty)
                        UiPrimaryButton(
                          text: 'Descargar lote (${_selected.length})',
                          accent: accent,
                          onTap: _descargarLote,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _open(String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReciboDetallePage(reciboId: id)),
    );
  }

  Future<void> _descargar(String id) async {
    try {
      final file = await repo.descargar(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descargado: $file (mock).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No disponible: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _descargarLote() async {
    try {
      final ids = _selected.toList();
      final files = await repo.descargarLote(ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lote descargado: ${files.length} archivos (mock).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _selected.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo descargar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reportar(String reciboId) async {
    final res = await ReciboReportSheet.open(context);
    if (res == null) return;

    try {
      await repo.reportar(
        ReporteNominaPayload(
          reciboId: reciboId,
          motivo: res.motivo,
          detalle: res.detalle,
        ),
      );
      if (!mounted) return;
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte enviado (mock).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _VM {
  const _VM({
    required this.proxima,
    required this.ultimas,
  });

  final ProximaNominaInfo proxima;
  final List<ReciboResumen> ultimas;
}

/// Skeleton simple (sin animación y sin círculos)
class _MisRecibosSkeleton extends StatelessWidget {
  const _MisRecibosSkeleton({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget bar({double w = 140, double h = 10}) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: ColoresApp.inputBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
      );
    }

    Widget cardRow() {
      return Container(
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
                border: Border.all(color: accent.withOpacity(0.18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(w: 160, h: 12),
                  const SizedBox(height: 8),
                  bar(w: 110, h: 10),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 96,
              height: 28,
              decoration: BoxDecoration(
                color: ColoresApp.inputBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ColoresApp.bordeSuave),
              ),
            ),
          ],
        ),
      );
    }

    Widget reciboPlaceholder() {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: ColoresApp.blanco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColoresApp.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColoresApp.bordeSuave),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(w: 180, h: 12),
                  const SizedBox(height: 8),
                  bar(w: 120, h: 10),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 26,
              decoration: BoxDecoration(
                color: ColoresApp.inputBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ColoresApp.bordeSuave),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        cardRow(),
        const SizedBox(height: 12),
        UiSectionCard(
          title: 'Últimas 5 nóminas',
          icon: PhosphorIconsRegular.clockCounterClockwise,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cargando…',
                style: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.textoSuave,
                ),
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < 5; i++) ...[
                reciboPlaceholder(),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
