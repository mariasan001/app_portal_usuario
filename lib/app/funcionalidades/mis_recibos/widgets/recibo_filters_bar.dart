import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class ReciboFilters {
  const ReciboFilters({required this.anio, this.quincena});

  final int anio;
  final int? quincena;

  ReciboFilters copyWith({int? anio, int? quincena, bool clearQuincena = false}) {
    return ReciboFilters(
      anio: anio ?? this.anio,
      quincena: clearQuincena ? null : (quincena ?? this.quincena),
    );
  }
}

class ReciboFiltersBar extends StatelessWidget {
  const ReciboFiltersBar({
    super.key,
    required this.filters,
    required this.years,
    required this.onChanged,
  });

  final ReciboFilters filters;
  final List<int> years;
  final void Function(ReciboFilters f) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 340;

          final yearBox = _CompactDropdown<int>(
            label: 'Año',
            icon: PhosphorIconsRegular.calendarBlank,
            value: filters.anio,
            items: years,
            itemLabel: (x) => x.toString(),
            onChanged: (v) => onChanged(filters.copyWith(anio: v, clearQuincena: true)),
          );

          final quincenaBox = _CompactDropdown<int?>(
            label: 'Quincena',
            icon: PhosphorIconsRegular.hash,
            value: filters.quincena,
            items: const [null, ..._quincenas],
            itemLabel: (x) => x == null ? 'Todas' : x.toString().padLeft(2, '0'),
            onChanged: (v) => onChanged(filters.copyWith(quincena: v)),
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: yearBox),
                const SizedBox(width: 10),
                Expanded(child: quincenaBox),
              ],
            );
          }

          return Column(
            children: [
              yearBox,
              const SizedBox(height: 10),
              quincenaBox,
            ],
          );
        },
      ),
    );
  }
}

const List<int> _quincenas = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
  13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
];

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T x) itemLabel;
  final void Function(T v) onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    String line(T x) => '$label · ${itemLabel(x)}';

    return SizedBox(
      height: 44, // ✅ campo delgado (esto NO afecta la altura del menú)
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: ColoresApp.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: ColoresApp.textoSuave),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  isDense: true, // ✅ compacta el botón
                  dropdownColor: ColoresApp.blanco,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColoresApp.textoSuave),
                  iconSize: 22,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                  ),

                  // ✅ NO pongas itemHeight < 48 (Flutter lo prohíbe)
                  // itemHeight: 48, // si quieres fijarlo, déjalo 48 o null

                  items: items
                      .map(
                        (x) => DropdownMenuItem<T>(
                          value: x,
                          child: Text(
                            line(x),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ColoresApp.texto,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  selectedItemBuilder: (context) {
                    return items.map((x) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          line(x),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (v) {
                    if (v == null) return;
                    onChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
