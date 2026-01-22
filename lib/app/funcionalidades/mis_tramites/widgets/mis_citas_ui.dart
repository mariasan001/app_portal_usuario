import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class UiPill extends StatelessWidget {
  const UiPill({
    super.key,
    required this.text,
    required this.fg,
    required this.bg,
    this.bd,
    this.icon,
  });

  final String text;
  final Color fg;
  final Color bg;
  final Color? bd;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd ?? Colors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: t.bodySmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class UiSectionCard extends StatelessWidget {
  const UiSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: ColoresApp.inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColoresApp.bordeSuave),
                  ),
                  child: Icon(icon, color: ColoresApp.textoSuave),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class UiPrimaryButton extends StatelessWidget {
  const UiPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
    this.accent,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = accent ?? ColoresApp.cafe;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: a,
          disabledBackgroundColor: ColoresApp.bordeSuave,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: ColoresApp.blanco,
          ),
        ),
      ),
    );
  }
}

class UiSecondaryButton extends StatelessWidget {
  const UiSecondaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: ColoresApp.bordeSuave),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: ColoresApp.texto,
          ),
        ),
      ),
    );
  }
}

class UiKVRow extends StatelessWidget {
  const UiKVRow({super.key, required this.k, required this.v});

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: t.bodySmall?.copyWith(
                color: ColoresApp.textoSuave,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              v,
              style: t.bodySmall?.copyWith(
                color: ColoresApp.texto,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String fmtDiaCorto(int weekday) {
  // 1..7 (Lun..Dom)
  switch (weekday) {
    case DateTime.monday:
      return 'Lun';
    case DateTime.tuesday:
      return 'Mar';
    case DateTime.wednesday:
      return 'Mié';
    case DateTime.thursday:
      return 'Jue';
    case DateTime.friday:
      return 'Vie';
    case DateTime.saturday:
      return 'Sáb';
    case DateTime.sunday:
      return 'Dom';
    default:
      return '';
  }
}

String fmt2(int n) => n.toString().padLeft(2, '0');
