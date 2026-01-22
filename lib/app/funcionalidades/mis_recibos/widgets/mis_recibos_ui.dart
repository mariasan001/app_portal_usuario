import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

/// =====================
/// Helpers de formato
/// =====================

String money(double v) {
  final s = v.toStringAsFixed(2);
  // sin intl por ahora (mock simple)
  return '\$$s';
}

String fmt2(int n) => n.toString().padLeft(2, '0');

/// =====================
/// Helpers de periodo (Año + Quincena)
/// =====================

/// Convierte (anio, quincena) a una key comparable.
/// Ej: 2026 Qna 01 => 202601
int periodoKey(int anio, int quincena) => (anio * 100) + quincena;

/// true si (anio, quincena) es ANTES que (refAnio, refQuincena)
bool esPeriodoAntes(int anio, int quincena, int refAnio, int refQuincena) {
  return periodoKey(anio, quincena) < periodoKey(refAnio, refQuincena);
}

/// true si (anio, quincena) es DESPUÉS que (refAnio, refQuincena)
bool esPeriodoDespues(int anio, int quincena, int refAnio, int refQuincena) {
  return periodoKey(anio, quincena) > periodoKey(refAnio, refQuincena);
}

/// Comparador DESC (más nuevo primero).
/// Útil para sort(): list.sort((a,b)=>comparePeriodoDesc(...))
int comparePeriodoDesc(int aAnio, int aQuincena, int bAnio, int bQuincena) {
  return periodoKey(bAnio, bQuincena).compareTo(periodoKey(aAnio, aQuincena));
}

/// Quincena 1..24 => mes 1..12
int mesDeQuincena(int quincena) {
  final q = quincena.clamp(1, 24);
  return ((q - 1) ~/ 2) + 1;
}

const List<String> _mesesEs = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const List<String> _mesesEsCorto = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

String nombreMesEs(int mes, {bool corto = false}) {
  final m = mes.clamp(1, 12);
  return corto ? _mesesEsCorto[m - 1] : _mesesEs[m - 1];
}

/// Ej: "Enero 2026 · Qna 01"
String periodoLabel(int anio, int quincena, {bool mesCorto = false}) {
  final mes = mesDeQuincena(quincena);
  final mesTxt = nombreMesEs(mes, corto: mesCorto);
  return '$mesTxt $anio · Qna ${fmt2(quincena)}';
}

/// =====================
/// Widgets UI
/// =====================

class UiPill extends StatelessWidget {
  const UiPill({
    super.key,
    required this.text,
    required this.fg,
    required this.bg,
    required this.bd,
    this.icon,
  });

  final String text;
  final Color fg;
  final Color bg;
  final Color bd;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: fg),
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
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
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
              Icon(icon, size: 18, color: ColoresApp.texto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.textoSuave),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              v,
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w900, color: ColoresApp.texto),
            ),
          ),
        ],
      ),
    );
  }
}

class UiPrimaryButton extends StatelessWidget {
  const UiPrimaryButton({
    super.key,
    required this.text,
    required this.accent,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final Color accent;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: enabled ? accent : ColoresApp.bordeSuave,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: t.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: ColoresApp.blanco,
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
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: ColoresApp.bordeSuave),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: t.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: ColoresApp.texto,
        ),
      ),
    );
  }
}
