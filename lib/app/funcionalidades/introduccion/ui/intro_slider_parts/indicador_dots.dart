part of introduccion_intro_slider;

class _IndicadorDots extends StatelessWidget {
  final int actual;
  final int total;

  const _IndicadorDots({required this.actual, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == actual;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? ColoresApp.vino : const Color(0xFFE9E9E9),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
