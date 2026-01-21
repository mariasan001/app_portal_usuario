// lib/app/funcionalidades/home/ui/widget/enlaces_institucionales_section.dart

import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/home/ui/widgets/section_header.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

import '../../domain/enlace_institucional.dart';

class EnlacesInstitucionalesSection extends StatelessWidget {
  final List<EnlaceInstitucional> items;
  final ValueChanged<EnlaceInstitucional> onTap;

  const EnlacesInstitucionalesSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final ts = MediaQuery.textScaleFactorOf(context);

    // ✅ un poco más alto para permitir subtitle SIEMPRE
    final base = w < 360 ? 176.0 : 168.0;
    final extra = ((ts - 1.0) * 70.0).clamp(0.0, 70.0);
    final listHeight = base + extra;

    return Column(
      children: [
        const SectionHeaderChip(
          title: 'Enlaces institucionales',
          chipText: 'Accesos',
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final it = items[i];
              return _EnlaceCard(
                item: it,
                onTap: () => onTap(it),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnlaceCard extends StatelessWidget {
  final EnlaceInstitucional item;
  final VoidCallback onTap;

  const _EnlaceCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = item.accent;

    final w = MediaQuery.of(context).size.width;
    final ts = MediaQuery.textScaleFactorOf(context);

    final compact = w < 360 || ts > 1.05;
    final cardW = compact ? 192.0 : 198.0;

    return SizedBox(
      width: cardW,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.black.withOpacity(0.05),
          highlightColor: Colors.black.withOpacity(0.03),
          child: Ink(
            decoration: BoxDecoration(
              color: ColoresApp.blanco,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColoresApp.bordeSuave),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // barra institucional
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      color: accent.withOpacity(0.85),
                    ),
                  ),

                  // halo suave
                  Positioned(
                    right: -42,
                    top: -42,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.08),
                      ),
                    ),
                  ),

                  LayoutBuilder(
                    builder: (context, c) {
                      final h = c.maxHeight;

                      // si está apretado, reducimos cosas pero SIN ocultar subtitle
                      final tight = h < 170;
                      final veryTight = h < 156;

                      final pad = veryTight ? 10.0 : (compact ? 11.0 : 12.0);
                      final iconBox = veryTight ? 38.0 : (compact ? 40.0 : 42.0);
                      final chevronBox = veryTight ? 26.0 : (compact ? 28.0 : 30.0);

                      final titleMaxLines = tight ? 1 : 2;
                      final subtitleMaxLines = veryTight ? 1 : (tight ? 1 : 2);

                      final titleSize = veryTight ? 12.4 : (compact ? 12.7 : 13.0);
                      final subtitleSize = veryTight ? 10.6 : (compact ? 10.9 : 11.2);

                      final hasSubtitle = (item.subtitle ?? '').trim().isNotEmpty;

                      return Padding(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: icon + chevron
                            Row(
                              children: [
                                Container(
                                  width: iconBox,
                                  height: iconBox,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: accent.withOpacity(0.18)),
                                  ),
                                  child: Icon(item.icon, size: 20, color: accent),
                                ),
                                const Spacer(),

                                // ✅ flechita con color del accent
                                Container(
                                  width: chevronBox,
                                  height: chevronBox,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: accent.withOpacity(0.18)),
                                  ),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: veryTight ? 16 : 18,
                                    color: accent.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: veryTight ? 8 : 10),

                            Text(
                              item.titulo,
                              maxLines: titleMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodyMedium?.copyWith(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w900,
                                color: ColoresApp.texto,
                                height: 1.05,
                              ),
                            ),

                            // ✅ Subtitle SIEMPRE (si existe)
                            if (hasSubtitle) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle!,
                                maxLines: subtitleMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: t.bodySmall?.copyWith(
                                  fontSize: subtitleSize,
                                  height: 1.15,
                                  fontWeight: FontWeight.w600,
                                  color: ColoresApp.textoSuave,
                                ),
                              ),
                            ],

                            // espacio flexible (sin overflow)
                            Flexible(child: Container()),

                            // CTA
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: veryTight ? 9 : 11,
                                  vertical: veryTight ? 6 : 7,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: accent.withOpacity(0.18)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ir al sitio',
                                      style: t.labelSmall?.copyWith(
                                        fontSize: veryTight ? 10.4 : 10.8,
                                        fontWeight: FontWeight.w900,
                                        color: accent.withOpacity(0.95),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: veryTight ? 13 : 14,
                                      color: accent.withOpacity(0.95),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
