import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0..3
  final ValueChanged<int> onTap; // 0..4 (4 = Más)

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding.bottom;
    final w = MediaQuery.of(context).size.width;

    // ✅ alturas responsivas (más margen en pantallas normales)
    final navHeight = w < 360 ? 58.0 : 64.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + (safe > 0 ? safe * 0.20 : 0)),
        child: SizedBox(
          height: navHeight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: ColoresApp.blanco.withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x12000000)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Color(0x12000000),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  active: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Servicios',
                  active: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.event_rounded,
                  label: 'Citas',
                  active: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Recibos',
                  active: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _MoreItem(onTap: () => onTap(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final iconBg = active ? ColoresApp.vino : Colors.transparent;
    final iconColor = active ? ColoresApp.blanco : ColoresApp.textoSuave;
    final labelColor = active ? ColoresApp.vino : ColoresApp.textoSuave;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, c) {
          // ✅ modo compacto si la altura está justa (o si el sistema trae texto grande)
          final textScale = MediaQuery.textScaleFactorOf(context);
          final compact = c.maxHeight <= 58 || textScale > 1.10;

          final iconBox = compact ? 30.0 : 34.0;
          final iconSize = compact ? 18.0 : 20.0;
          final gap1 = compact ? 1.0 : 3.0;
          final gap2 = compact ? 1.0 : 2.0;

          // ✅ indicador se apaga en compacto (es el que suele “matar” 2–4px)
          final showIndicator = !compact;

          // ✅ tip: en pantallas mini, el label es el culpable #1
          final showLabel = c.maxHeight >= 56;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ no estirar
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: iconBox,
                      height: iconBox,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                        border: active ? null : Border.all(color: const Color(0x12000000)),
                        boxShadow: active
                            ? const [
                                BoxShadow(
                                  blurRadius: 12,
                                  offset: Offset(0, 7),
                                  color: Color(0x1A000000),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(icon, size: iconSize, color: iconColor),
                    ),

                    SizedBox(height: gap1),

                    if (showLabel)
                      // ✅ scaleDown evita overflow con “letra grande”
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                            color: labelColor,
                            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                            fontSize: compact ? 9.5 : 10.5,
                            height: 1,
                          ),
                        ),
                      ),

                    SizedBox(height: gap2),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      width: (active && showIndicator) ? 12 : 0,
                      height: (active && showIndicator) ? 3 : 0,
                      decoration: BoxDecoration(
                        color: ColoresApp.vino,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, c) {
          final textScale = MediaQuery.textScaleFactorOf(context);
          final compact = c.maxHeight <= 58 || textScale > 1.10;

          final iconBox = compact ? 30.0 : 34.0;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: iconBox,
                      height: iconBox,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x12000000)),
                      ),
                      child: Icon(
                        Icons.more_horiz_rounded,
                        size: compact ? 21 : 22,
                        color: ColoresApp.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Más',
                        style: t.bodySmall?.copyWith(
                          color: ColoresApp.textoSuave,
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 9.5 : 10.5,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
