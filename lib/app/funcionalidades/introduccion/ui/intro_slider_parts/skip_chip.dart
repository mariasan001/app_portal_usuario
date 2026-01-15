part of introduccion_intro_slider;

class _SkipChip extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.blanco.withOpacity(0.70),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x1A000000)),
          ),
          child: Text(
            'Saltar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColoresApp.vino,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ),
    );
  }
}
