import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../data/documentos_mock.dart';
import '../../domain/documento_item.dart';

class DocumentosPage extends StatefulWidget {
  const DocumentosPage({super.key});

  @override
  State<DocumentosPage> createState() => _DocumentosPageState();
}

class _DocumentosPageState extends State<DocumentosPage> {
  DocumentoCategoria _cat = DocumentoCategoria.constancias;

  List<DocumentoItem> get _filtered {
    final list = documentosMock.where((d) => d.categoria == _cat).toList();
    // ✅ Más reciente primero
    list.sort(
      (a, b) => (b.actualizado ?? DateTime(0)).compareTo(a.actualizado ?? DateTime(0)),
    );
    return list;
  }

  Color _estadoColor(DocumentoEstado e) {
    switch (e) {
      case DocumentoEstado.vigente:
        return ColoresApp.dorado;
      case DocumentoEstado.pendiente:
        return ColoresApp.cafe; // ✅ sutil, solo acento
      case DocumentoEstado.vencido:
        return ColoresApp.vino;
    }
  }

  String _formatFecha(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final mes = meses[dt.month - 1];
    return '${dt.day} $mes · ${two(dt.hour)}:${two(dt.minute)}';
  }

  void _openDocumento(DocumentoItem d) {
    // ✅ Documentos NO navegan a /servicios
    // 👁️ / tap de tarjeta: abre detalle del documento
    context.go('/documentos/${d.id}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = _filtered;

    return Container(
      color: ColoresApp.blanco,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Título con línea delgada café oscuro (SIN ícono)
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 22,
                    decoration: BoxDecoration(
                      color: ColoresApp.cafe.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mis documentos',
                      style: t.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ✅ Tabs (Segmented / Pills) – sin botoncitos negros
              _CategoriaTabs(
                value: _cat,
                onChanged: (c) => setState(() => _cat = c),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Sin documentos aquí… por ahora 😄',
                          style: t.bodyMedium?.copyWith(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w700,
                            color: ColoresApp.textoSuave,
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final d = items[i];
                          final accent = _estadoColor(d.estado);

                          return _DocumentoCard(
                            item: d,
                            accent: accent,
                            estadoLabel: d.estado.label,
                            estadoIcon: d.estado.icon,
                            fechaLabel: d.actualizado == null ? null : _formatFecha(d.actualizado!),

                            // ✅ Tap en tarjeta abre detalle
                            onOpen: () => _openDocumento(d),

                            // ✅ Acciones demo (luego conectamos)
                            onDownload: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Descargando "${d.titulo}" (demo)')),
                            ),
                            onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Compartir "${d.titulo}" (demo)')),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =========================
  TABS (Segmented)
========================= */

class _CategoriaTabs extends StatelessWidget {
  final DocumentoCategoria value;
  final ValueChanged<DocumentoCategoria> onChanged;

  const _CategoriaTabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cats = DocumentoCategoria.values;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColoresApp.inputBg.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: cats.map((c) {
          final selected = c == value;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? ColoresApp.blanco : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  c.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    fontSize: 11.4,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.15,
                    color: selected ? ColoresApp.texto : ColoresApp.textoSuave,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* =========================
  CARD
========================= */

class _DocumentoCard extends StatelessWidget {
  final DocumentoItem item;
  final Color accent;
  final String estadoLabel;
  final IconData estadoIcon;
  final String? fechaLabel;

  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  const _DocumentoCard({
    required this.item,
    required this.accent,
    required this.estadoLabel,
    required this.estadoIcon,
    required this.fechaLabel,
    required this.onOpen,
    required this.onDownload,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final desc = (item.descripcion ?? '').trim();

    return Material(
      color: ColoresApp.blanco,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: ColoresApp.bordeSuave),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
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
                    child: Icon(item.icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium?.copyWith(
                            fontSize: 13.2,
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall?.copyWith(
                              fontSize: 11.2,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              color: ColoresApp.textoSuave,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _Pill(
                    text: estadoLabel,
                    icon: estadoIcon,
                    accent: accent,
                  ),
                ],
              ),

              if (fechaLabel != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      PhosphorIcons.clock(PhosphorIconsStyle.light),
                      size: 14,
                      color: ColoresApp.textoSuave.withOpacity(0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Actualizado: $fechaLabel',
                      style: t.bodySmall?.copyWith(
                        fontSize: 10.8,
                        fontWeight: FontWeight.w700,
                        color: ColoresApp.textoSuave,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              Row(
                children: [
                  _ActionIcon(
                    icon: PhosphorIcons.eye(PhosphorIconsStyle.light),
                    onTap: onOpen, // ✅ abre detalle documento
                  ),
                  const SizedBox(width: 8),
                  _ActionIcon(
                    icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.light),
                    onTap: onDownload,
                  ),
                  const SizedBox(width: 8),
                  _ActionIcon(
                    icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.light),
                    onTap: onShare,
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                    size: 18,
                    color: ColoresApp.textoSuave.withOpacity(0.65),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color accent;

  const _Pill({required this.text, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.labelSmall?.copyWith(
              fontSize: 10.2,
              fontWeight: FontWeight.w900,
              color: accent,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.inputBg.withOpacity(0.75),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: ColoresApp.texto),
        ),
      ),
    );
  }
}
