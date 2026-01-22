import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../data/mis_citas_repository_mock.dart';
import '../domain/mis_citas_models.dart';
import '../widgets/cita_card.dart';
import 'cita_detalle_page.dart';

class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  final repo = MisCitasRepositoryMock.instance;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // ✅ Instantáneo: siempre pintamos con el cache
    final data = repo.cache;

    final proximas = data.where((x) => x.estado == CitaEstado.proxima).toList();
    final proceso = data
        .where((x) => x.estado == CitaEstado.enProceso)
        .toList();
    final finalizadas = data
        .where((x) => x.estado == CitaEstado.finalizada)
        .toList();

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
              width: 2,
              height: 18,
              decoration: BoxDecoration(
                color: ColoresApp.cafe,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Mis citas',
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
                fontSize: 18, // 👈 leve boost, no exagerado
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        top: false,
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: ColoresApp.texto,
                unselectedLabelColor: ColoresApp.textoSuave,
                indicatorColor: ColoresApp.cafe,
                labelStyle: t.bodySmall?.copyWith(fontWeight: FontWeight.w900),
                tabs: [
                  Tab(text: 'Próximas (${proximas.length})'),
                  Tab(text: 'En proceso (${proceso.length})'),
                  Tab(text: 'Finalizadas (${finalizadas.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _ListTab(
                      items: proximas,
                      emptyText: 'No tienes citas próximas por ahora.',
                      onOpen: _open,
                      onCancelar: _cancelar,
                      onReagendar: _reagendar,
                    ),
                    _ListTab(
                      items: proceso,
                      emptyText:
                          'Nada en proceso. Respira: el sistema también 😄',
                      onOpen: _open,
                      onCancelar: _cancelar,
                      onReagendar: _reagendar,
                    ),
                    _ListTab(
                      items: finalizadas,
                      emptyText: 'Aún no hay citas finalizadas.',
                      onOpen: _open,
                      onCancelar: _cancelar,
                      onReagendar: _reagendar,
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

  void _open(CitaResumen c) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => CitaDetallePage(citaId: c.id)));
  }

  Future<void> _cancelar(CitaResumen c) async {
    if (!c.puedeCancelar) return;

    try {
      await repo.cancelar(c.id);
      if (!mounted) return;

      // ✅ refresca inmediato (sin loaders)
      setState(() {});

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita cancelada (mock).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cancelar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reagendar(CitaResumen c) async {
    if (!c.puedeReagendar) return;
    _open(c);
  }
}

class _ListTab extends StatelessWidget {
  const _ListTab({
    required this.items,
    required this.emptyText,
    required this.onOpen,
    required this.onCancelar,
    required this.onReagendar,
  });

  final List<CitaResumen> items;
  final String emptyText;

  final void Function(CitaResumen c) onOpen;
  final Future<void> Function(CitaResumen c) onCancelar;
  final Future<void> Function(CitaResumen c) onReagendar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          emptyText,
          style: t.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: ColoresApp.textoSuave,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final c = items[i];
        return CitaCard(
          item: c,
          onOpen: () => onOpen(c),
          onCancelar: c.puedeCancelar ? () => onCancelar(c) : null,
          onReagendar: c.puedeReagendar ? () => onReagendar(c) : null,
        );
      },
    );
  }
}
