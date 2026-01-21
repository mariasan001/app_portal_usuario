import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0..3
  final ValueChanged<int> onTap; // 0..4 (4 = Más)

  final Color activeColor;

  /// ✅ Estilo de íconos: light = balance, thin = más delgado
  final PhosphorIconsStyle iconStyle;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeColor = ColoresApp.cafe,
    this.iconStyle = PhosphorIconsStyle.light, // cambia a thin si quieres
  });

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).padding.bottom; // double
    final w = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.textScaleFactorOf(context);

    final navHeight = w < 360 ? 64.0 : 72.0;
    final bottomPad = 10.0 + (safe > 0 ? safe * 0.20 : 0.0);
    final compact = navHeight <= 66 || textScale > 1.10;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
        child: PhysicalShape(
          clipper: _NotchedPillClipper(radius: 26, notchRadius: 9),
          elevation: 14,
          color: ColoresApp.blanco.withOpacity(0.98),
          shadowColor: Colors.black.withOpacity(0.16),
          child: SizedBox(
            height: navHeight,
            child: Row(
              children: [
                _NavItem(
                  icon: PhosphorIcons.house(iconStyle),
                  label: 'Inicio',
                  active: currentIndex == 0,
                  activeColor: activeColor,
                  onTap: () => onTap(0),
                  compact: compact,
                ),
                _NavItem(
                  icon: PhosphorIcons.squaresFour(iconStyle),
                  label: 'Servicios',
                  active: currentIndex == 1,
                  activeColor: activeColor,
                  onTap: () => onTap(1),
                  compact: compact,
                ),
                _NavItem(
                  icon: PhosphorIcons.fileText(iconStyle),
                  label: 'Mis trámites',
                  active: currentIndex == 2,
                  activeColor: activeColor,
                  onTap: () => onTap(2),
                  compact: compact,
                ),
                _NavItem(
                  icon: PhosphorIcons.receipt(iconStyle),
                  label: 'Recibos',
                  active: currentIndex == 3,
                  activeColor: activeColor,
                  onTap: () => onTap(3),
                  compact: compact,
                ),
                _MoreItem(
                  icon: PhosphorIcons.dotsThree(iconStyle),
                  onTap: () => onTap(4),
                  compact: compact,
                ),
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
  final Color activeColor;
  final VoidCallback onTap;
  final bool compact;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final iconColor = active ? ColoresApp.texto : ColoresApp.textoSuave;
    final labelColor = active ? ColoresApp.texto : ColoresApp.textoSuave;

    final iconSize = compact ? 22.0 : 24.0;

    // ✅ letra más chica
    final labelSize = compact ? 9.0 : 10.0;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.03),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: iconColor),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: t.labelSmall?.copyWith(
                    fontSize: labelSize,
                    height: 1.0,
                    letterSpacing: 0.2, // ✅ se ve más limpio
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: active ? 16 : 0,
                height: active ? 3 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _MoreItem({
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final iconSize = compact ? 22.0 : 24.0;
    final labelSize = compact ? 9.0 : 10.0;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.black.withOpacity(0.05),
        highlightColor: Colors.black.withOpacity(0.03),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: ColoresApp.texto),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Más',
                  style: t.labelSmall?.copyWith(
                    fontSize: labelSize,
                    height: 1.0,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.textoSuave,
                  ),
                ),
              ),
              const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotchedPillClipper extends CustomClipper<Path> {
  final double radius;
  final double notchRadius;

  _NotchedPillClipper({
    required this.radius,
    required this.notchRadius,
  });

  @override
  Path getClip(Size size) {
    final outer = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final notch = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, 0),
          radius: notchRadius,
        ),
      );

    return Path.combine(PathOperation.difference, outer, notch);
  }

  @override
  bool shouldReclip(covariant _NotchedPillClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.notchRadius != notchRadius;
  }
}
