part of introduccion_intro_slider;

class _BottomCard extends StatelessWidget {
  final Widget child;
  const _BottomCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 10),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: child,
    );
  }
}
