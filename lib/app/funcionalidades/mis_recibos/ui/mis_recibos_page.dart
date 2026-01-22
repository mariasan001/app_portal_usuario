import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../data/mis_recibos_repository_mock.dart';
import '../domain/mis_recibos_models.dart';
import '../widgets/mis_recibos_ui.dart';
import '../widgets/recibo_card.dart';
import '../widgets/recibo_filters_bar.dart';
import '../widgets/recibo_report_sheet.dart';
import 'recibo_detalle_page.dart';

class MisRecibosPage extends StatefulWidget {
  const MisRecibosPage({super.key});

  @override
  State<MisRecibosPage> createState() => _MisRecibosPageState();
}

class _MisRecibosPageState extends State<MisRecibosPage> {
  final repo = MisRecibosRepositoryMock.instance;

  late ReciboFilters _filters;
  bool _batchMode = false;
  final Set<String> _selected = <String>{};

  late Future<_VM> _future;

  // ✅ Para “brincar” directo a Resultados cuando cambias filtros
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _resultsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final y = DateTime.now().year;
    _filters = ReciboFilters(anio: y);
    _future = _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<_VM> _load() async {
    final p = await repo.proximaNomina();
    final ult = await repo.ultimas(limit: 5);
    final list = await repo.listar(anio: _filters.anio, quincena: _filters.quincena);
    return _VM(proxima: p, ultimas: ult, filtradas: list);
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
  }

  void _scrollToResults() {
    final ctx = _resultsKey.currentContext;
    if (ctx == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ asegura que Resultados se vea sin andar buscando con el dedo
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.06, // un poquito abajo del top
      );
    });
  }

  bool get _hasActiveFilters {
    final currentYear = DateTime.now().year;
    return _filters.anio != currentYear || _filters.quincena != null;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = ColoresApp.cafe;

    final years = List<int>.generate(6, (i) => DateTime.now().year - i);

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        title: Text(
          'Recibos de nómina',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
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
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snap.error}'),
            );
          }

          final vm = snap.data!;
          final proxima = vm.proxima;

          return ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            children: [
              // ------------------ Próxima nómina ------------------
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
                            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qna ${proxima.quincena.toString().padLeft(2, '0')} · ${proxima.anio}',
                            style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.textoSuave),
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

              // ------------------ Buscar (COMPACTO) ------------------
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ReciboFiltersBar(
                    filters: _filters,
                    years: years,
                    onChanged: (f) {
                      setState(() {
                        _filters = f;
                        _selected.clear();
                      });
                      _reload();
                      _scrollToResults(); // ✅ al filtrar, te manda a Resultados
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------ Resultados (CLAVE) ------------------
              KeyedSubtree(
                key: _resultsKey,
                child: UiSectionCard(
                  title: 'Resultados',
                  icon: PhosphorIconsRegular.magnifyingGlass,
                  child: Column(
                    children: [
                      if (vm.filtradas.isEmpty)
                        Text(
                          'No hay recibos con esos filtros.',
                          style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.textoSuave),
                        )
                      else
                        for (final r in vm.filtradas) ...[
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
                      if (_batchMode && _selected.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        UiPrimaryButton(
                          text: 'Descargar lote (${_selected.length})',
                          accent: accent,
                          onTap: _descargarLote,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------ Últimas 5 (NO ESTORBA) ------------------
              if (_hasActiveFilters)
                UiSectionCard(
                  title: 'Últimas 5 nóminas',
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: false, // ✅ colapsado cuando estás filtrando
                      title: Text(
                        'Ver últimas 5',
                        style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
                      ),
                      trailing: Icon(Icons.expand_more_rounded, color: ColoresApp.textoSuave),
                      children: [
                        const SizedBox(height: 10),
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
                      ],
                    ),
                  ),
                )
              else
                UiSectionCard(
                  title: 'Últimas 5 nóminas',
                  icon: PhosphorIconsRegular.clockCounterClockwise,
                  child: Column(
                    children: [
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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReciboDetallePage(reciboId: id)));
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

  Future<void> _descargarLote() async {
    try {
      final ids = _selected.toList();
      final files = await repo.descargarLote(ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lote descargado: ${files.length} archivos (mock).'), behavior: SnackBarBehavior.floating),
      );
      setState(() => _selected.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo descargar: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _reportar(String reciboId) async {
    final res = await ReciboReportSheet.open(context);
    if (res == null) return;

    try {
      await repo.reportar(ReporteNominaPayload(reciboId: reciboId, motivo: res.motivo, detalle: res.detalle));
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

class _VM {
  const _VM({
    required this.proxima,
    required this.ultimas,
    required this.filtradas,
  });

  final ProximaNominaInfo proxima;
  final List<ReciboResumen> ultimas;
  final List<ReciboResumen> filtradas;
}
