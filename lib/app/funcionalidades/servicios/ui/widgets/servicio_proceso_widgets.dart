import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/domain/servicio_proceso_models.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class HeroClean extends StatelessWidget {
  const HeroClean({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<ChipData> chips;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.18)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: chips.map((c) => _Chip(data: c)).toList(),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.textoSuave,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepChips extends StatelessWidget {
  const StepChips({
    super.key,
    required this.accent,
    required this.steps,
    required this.currentIndex,
  });

  final Color accent;
  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < steps.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: i <= currentIndex ? accent.withOpacity(0.10) : ColoresApp.inputBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: i <= currentIndex ? accent.withOpacity(0.22) : ColoresApp.bordeSuave,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  i < currentIndex ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 16,
                  color: i <= currentIndex ? accent : ColoresApp.textoSuave,
                ),
                const SizedBox(width: 6),
                Text(
                  steps[i],
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: i <= currentIndex ? accent : ColoresApp.textoSuave,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.accent,
    required this.icon,
    required this.child,
  });

  final String title;
  final Color accent;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.18)),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class KVRow extends StatelessWidget {
  const KVRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.textoSuave,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: ColoresApp.texto,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PickRow extends StatelessWidget {
  const PickRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.inputBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: t.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: ColoresApp.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletItem extends StatelessWidget {
  const BulletItem({super.key, required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.22)),
            ),
            child: Icon(Icons.check_rounded, size: 14, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: ColoresApp.texto,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HintBox extends StatelessWidget {
  const HintBox({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.inputBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: ColoresApp.textoSuave),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: ColoresApp.textoSuave,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocTile extends StatelessWidget {
  const DocTile({
    super.key,
    required this.doc,
    required this.accent,
    required this.onTap,
  });

  final DocReq doc;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ok = doc.attachedName != null;

    return Material(
      color: ColoresApp.inputBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ok ? accent.withOpacity(0.10) : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ok ? accent.withOpacity(0.18) : ColoresApp.bordeSuave),
                ),
                child: Icon(
                  ok ? Icons.task_alt_rounded : Icons.insert_drive_file_outlined,
                  color: ok ? accent : ColoresApp.textoSuave,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.label,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ok ? doc.attachedName! : (doc.hint ?? 'Adjunta un archivo'),
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColoresApp.textoSuave,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ok ? accent.withOpacity(0.10) : ColoresApp.blanco,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ok ? accent.withOpacity(0.22) : ColoresApp.bordeSuave),
                ),
                child: Text(
                  ok ? 'Adjunto' : 'Subir',
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ok ? accent : ColoresApp.textoSuave,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BtnPrimary extends StatelessWidget {
  const BtnPrimary({
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

    return Material(
      color: enabled ? accent : ColoresApp.bordeSuave,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: enabled ? Colors.white : ColoresApp.textoSuave,
            ),
          ),
        ),
      ),
    );
  }
}

class BtnSecondary extends StatelessWidget {
  const BtnSecondary({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Text(
            text,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: ColoresApp.texto,
            ),
          ),
        ),
      ),
    );
  }
}

class SheetOption extends StatelessWidget {
  const SheetOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: ColoresApp.inputBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColoresApp.bordeSuave),
          ),
          child: Row(
            children: [
              Icon(icon, color: danger ? Colors.redAccent : ColoresApp.textoSuave),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: danger ? Colors.redAccent : ColoresApp.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColoresApp.textoSuave,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: ColoresApp.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.data});
  final ChipData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: data.bd),
      ),
      child: Text(
        data.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: data.fg,
        ),
      ),
    );
  }
}
