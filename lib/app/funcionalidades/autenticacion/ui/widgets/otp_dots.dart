import 'package:flutter/material.dart';
import '../../../../tema/colores.dart';

class OtpDots extends StatelessWidget {
  final int total;
  final int active; // 0..total-1

  const OtpDots({super.key, this.total = 4, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == active;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.transparent : const Color(0xFFEFEFEF),
            border: Border.all(
              color: isActive ? ColoresApp.vino : const Color(0xFFE5E5E5),
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
