part of introduccion_intro_slider;

class _SwipeHint extends StatelessWidget {
  final AnimationController ctrl;
  const _SwipeHint({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final dy = (ctrl.value - 0.5) * 6;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColoresApp.blanco.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x14000000)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swipe, size: 16, color: ColoresApp.vino),
                const SizedBox(width: 8),
                Text(
                  'Desliza para continuar',
                  style: t.bodySmall?.copyWith(
                    color: ColoresApp.textoSuave,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
