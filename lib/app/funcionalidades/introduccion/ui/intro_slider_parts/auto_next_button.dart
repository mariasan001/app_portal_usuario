part of introduccion_intro_slider;

class _AutoNextButton extends StatelessWidget {
  final AnimationController progress;
  final bool showProgress;
  final IconData icon;
  final VoidCallback onTap;

  const _AutoNextButton({
    required this.progress,
    required this.showProgress,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (showProgress)
              SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  value: progress.value.clamp(0.0, 1.0),
                  strokeWidth: 3,
                  backgroundColor: const Color(0x12B00020),
                  valueColor: AlwaysStoppedAnimation<Color>(ColoresApp.vino),
                ),
              ),
            _CircleAction(
              onTap: onTap,
              enabled: true,
              icon: icon,
              variant: _CircleVariant.outlined,
            ),
          ],
        );
      },
    );
  }
}
