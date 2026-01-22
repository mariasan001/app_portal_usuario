import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../data/servicios_mock.dart';
import '../../domain/servicio_item.dart';
import 'servicio_card.dart';

class ServiciosSearchSheet extends StatefulWidget {
  const ServiciosSearchSheet({
    super.key,
    required this.onOpen,
    this.initialTipo = ServicioTipo.tramite,
  });

  final void Function(ServicioItem item) onOpen;
  final ServicioTipo initialTipo;

  @override
  State<ServiciosSearchSheet> createState() => _ServiciosSearchSheetState();
}

class _ServiciosSearchSheetState extends State<ServiciosSearchSheet> {
  final _ctrl = TextEditingController();

  late ServicioTipo _tipo = widget.initialTipo;
  ServicioCategoria _categoria = ServicioCategoria.todas;

  String get _q => _ctrl.text.trim().toLowerCase();
  bool get _isSearching => _q.isNotEmpty;

  List<ServicioItem> get _all => serviciosMock;

  List<ServicioCategoria> get _categoriasTramites => const <ServicioCategoria>[
        ServicioCategoria.todas,
        ServicioCategoria.controlPagos,
        ServicioCategoria.prestacionesSocioeconomicas,
        ServicioCategoria.remuneraciones,
      ];

  String get _categoriaLabel => _categoria == ServicioCategoria.todas ? 'Todas' : _categoria.texto;

  List<ServicioItem> get _filtered {
    return _all.where((it) {
      if (it.tipo != _tipo) return false;

      if (_tipo == ServicioTipo.tramite && _categoria != ServicioCategoria.todas) {
        if (it.categoria != _categoria) return false;
      }

      if (_q.isNotEmpty) {
        final hay = it.titulo.toLowerCase().contains(_q) ||
            (it.subtitle ?? '').toLowerCase().contains(_q) ||
            it.categoria.texto.toLowerCase().contains(_q);
        if (!hay) return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setTipo(ServicioTipo v) {
    if (_tipo == v) return;
    setState(() {
      _tipo = v;
      _categoria = ServicioCategoria.todas;
      _ctrl.clear();
    });
  }

  void _clearSearch() {
    setState(() => _ctrl.clear());
  }

  Future<void> _openCategoriaSheet() async {
    if (_tipo != ServicioTipo.tramite) return;

    final selected = await showModalBottomSheet<ServicioCategoria>(
      context: context,
      backgroundColor: ColoresApp.blanco,
      barrierColor: Colors.black.withOpacity(0.40),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ColoresApp.bordeSuave,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Filtrar categoría',
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, ServicioCategoria.todas),
                      child: Text(
                        'Quitar filtro',
                        style: t.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.cafe,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._categoriasTramites.map((c) {
                  final isSel = c == _categoria;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(ctx, c),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel ? ColoresApp.cafe.withOpacity(0.08) : ColoresApp.inputBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? ColoresApp.cafe.withOpacity(0.25) : ColoresApp.bordeSuave,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.check_circle_rounded : Icons.circle_outlined,
                                size: 18,
                                color: isSel ? ColoresApp.cafe : ColoresApp.textoSuave,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  c.texto,
                                  style: t.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.texto,
                                  ),
                                ),
                              ),
                              if (isSel)
                                Text(
                                  'Activo',
                                  style: t.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.cafe,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _categoria) {
      setState(() => _categoria = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: ColoresApp.blanco,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ColoresApp.bordeSuave,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Buscar en Servicios',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: ColoresApp.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ColoresApp.bordeSuave),
                            ),
                            child: Icon(Icons.close_rounded, color: ColoresApp.texto),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Toggle (compacto)
                  _TipoToggle(value: _tipo, onChanged: _setTipo),

                  const SizedBox(height: 10),

                  // Search + filtro (solo trámites)
                  Row(
                    children: [
                      Expanded(
                        child: _SearchInput(
                          controller: _ctrl,
                          hintText: _tipo == ServicioTipo.tramite
                              ? 'Buscar trámites (ej. no adeudo, quinquenio)…'
                              : 'Buscar consultas (ej. FUMP, asistencia)…',
                          onChanged: (_) => setState(() {}),
                          onClear: _clearSearch,
                        ),
                      ),
                      if (_tipo == ServicioTipo.tramite) ...[
                        const SizedBox(width: 10),
                        _FilterButton(
                          label: _categoriaLabel,
                          onTap: _openCategoriaSheet,
                        ),
                      ],
                    ],
                  ),

                  // Badge “filtro activo”
                  if (_tipo == ServicioTipo.tramite && _categoria != ServicioCategoria.todas) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: ColoresApp.cafe.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _categoria = ServicioCategoria.todas),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: ColoresApp.cafe.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune_rounded, size: 16, color: ColoresApp.cafe),
                                const SizedBox(width: 8),
                                Text(
                                  'Filtro: $_categoriaLabel',
                                  style: t.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.cafe,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.close_rounded, size: 16, color: ColoresApp.cafe),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Resultados header + contador
                  Row(
                    children: [
                      Text(
                        _isSearching ? 'Resultados' : 'Todos',
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
                          '${_filtered.length} ${_filtered.length == 1 ? "resultado" : "resultados"}',
                          style: t.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.textoSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: _filtered.isEmpty
                        ? const _Empty(text: 'No se encontraron resultados.')
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final it = _filtered[i];
                              return ServicioCard(
                                item: it,
                                onTap: () => widget.onOpen(it),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TipoToggle extends StatelessWidget {
  final ServicioTipo value;
  final ValueChanged<ServicioTipo> onChanged;

  const _TipoToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget pill(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
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
                style: t.labelMedium?.copyWith(
                  fontSize: 11.8,
                  fontWeight: FontWeight.w900,
                  color: selected ? ColoresApp.texto : ColoresApp.textoSuave,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.inputBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: [
          pill('Consultas', value == ServicioTipo.consulta, () => onChanged(ServicioTipo.consulta)),
          pill('Trámites', value == ServicioTipo.tramite, () => onChanged(ServicioTipo.tramite)),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 18, color: ColoresApp.textoSuave),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColoresApp.texto,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.expand_more_rounded, size: 18, color: ColoresApp.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchInput({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ColoresApp.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: ColoresApp.textoSuave),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              onChanged: onChanged,
              style: t.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: ColoresApp.texto,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColoresApp.textoSuave,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.trim().isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onClear,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, size: 18, color: ColoresApp.textoSuave),
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

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
                fontWeight: FontWeight.w700,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
