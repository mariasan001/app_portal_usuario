import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/widgets/section_header.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/data/servicios_mock.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/domain/servicio_item.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/ui/widgets/servicio_card.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class ServiciosTab extends StatefulWidget {
  const ServiciosTab({super.key});

  @override
  State<ServiciosTab> createState() => _ServiciosTabState();
}

class _ServiciosTabState extends State<ServiciosTab> {
  ServicioTipo _tipo = ServicioTipo.tramite;

  List<ServicioItem> get _all => serviciosMock;

  List<ServicioItem> get _itemsTipo => _all.where((x) => x.tipo == _tipo).toList();

  Map<ServicioCategoria, List<ServicioItem>> get _groupedByCategoria {
    final map = <ServicioCategoria, List<ServicioItem>>{};
    for (final it in _itemsTipo) {
      map.putIfAbsent(it.categoria, () => <ServicioItem>[]).add(it);
    }
    return map;
  }

  void _open(ServicioItem item) {
    final r = (item.route ?? '').trim();
    if (r.isNotEmpty) {
      context.go(r);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir: ${item.titulo}')),
    );
  }

  void _setTipo(ServicioTipo tipo) {
    if (_tipo == tipo) return;
    setState(() => _tipo = tipo);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    const orderTramites = <ServicioCategoria>[
      ServicioCategoria.controlPagos,
      ServicioCategoria.prestacionesSocioeconomicas,
      ServicioCategoria.remuneraciones,
    ];

    final grouped = _groupedByCategoria;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),

        SectionHeaderChip(
          title: 'Servicios',
          chipText: _tipo == ServicioTipo.tramite ? 'Trámites' : 'Consultas',
        ),

        // Toggle (consultas / trámites)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: _SegmentedTipo(
            leftText: 'Consultas',
            rightText: 'Trámites',
            isRightSelected: _tipo == ServicioTipo.tramite,
            onChanged: (rightSelected) => _setTipo(
              rightSelected ? ServicioTipo.tramite : ServicioTipo.consulta,
            ),
          ),
        ),

        // Header catálogo + contador
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Text(
                _tipo == ServicioTipo.tramite ? 'Catálogo por categoría' : 'Consultas disponibles',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColoresApp.inputBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ColoresApp.bordeSuave),
                ),
                child: Text(
                  '${_itemsTipo.length} ${_itemsTipo.length == 1 ? "opción" : "opciones"}',
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.textoSuave,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Catálogo
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _itemsTipo.isEmpty
              ? _EmptyState(text: 'Aún no hay servicios en este apartado.')
              : (_tipo == ServicioTipo.consulta
                  ? Column(
                      children: _itemsTipo.map((it) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ServicioCard(
                            item: it,
                            onTap: () => _open(it),
                          ),
                        );
                      }).toList(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final c in orderTramites)
                          if ((grouped[c]?.isNotEmpty ?? false)) ...[
                            _CategoryHeader(
                              title: c.texto,
                              count: grouped[c]!.length,
                            ),
                            const SizedBox(height: 10),
                            for (final it in grouped[c]!)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ServicioCard(
                                  item: it,
                                  onTap: () => _open(it),
                                ),
                              ),
                            const SizedBox(height: 2),
                          ],
                      ],
                    )),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final int count;

  const _CategoryHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColoresApp.inputBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: Text(
              '$count',
              style: t.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.inputBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: ColoresApp.textoSuave),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTipo extends StatelessWidget {
  final String leftText;
  final String rightText;
  final bool isRightSelected;
  final ValueChanged<bool> onChanged;

  const _SegmentedTipo({
    required this.leftText,
    required this.rightText,
    required this.isRightSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.inputBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegItem(
              text: leftText,
              selected: !isRightSelected,
              onTap: () => onChanged(false),
              textTheme: t,
            ),
          ),
          Expanded(
            child: _SegItem(
              text: rightText,
              selected: isRightSelected,
              onTap: () => onChanged(true),
              textTheme: t,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegItem extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final TextTheme textTheme;

  const _SegItem({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ColoresApp.blanco : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: selected ? Border.all(color: ColoresApp.cafe.withOpacity(0.25)) : null,
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              fontSize: 11.8,
              fontWeight: FontWeight.w900,
              color: selected ? ColoresApp.texto : ColoresApp.textoSuave,
            ),
          ),
        ),
      ),
    );
  }
}
