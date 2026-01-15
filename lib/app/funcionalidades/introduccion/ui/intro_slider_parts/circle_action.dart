part of introduccion_intro_slider;

enum _CircleVariant { filled, outlined }

class _CircleAction extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final IconData icon;
  final _CircleVariant variant;

  const _CircleAction({
    required this.onTap,
    required this.enabled,
    required this.icon,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final filled = variant == _CircleVariant.filled;

    final bg = filled ? ColoresApp.vino : Colors.transparent;
    final fg = filled ? ColoresApp.blanco : ColoresApp.vino;

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: filled ? null : Border.all(color: ColoresApp.vino, width: 2),
            ),
            child: Icon(icon, color: fg, size: 20),
          ),
        ),
      ),
    );
  }
}
