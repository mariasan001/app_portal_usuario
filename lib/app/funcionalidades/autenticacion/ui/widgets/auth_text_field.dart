import 'package:flutter/material.dart';
import '../../../../tema/colores.dart';

class AuthTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.trim().isNotEmpty) ...[
          Text(
            label!,
            style: t.bodySmall?.copyWith(
              color: ColoresApp.texto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
        ],

        SizedBox(
          height: 62, // ✅ reserva espacio para error sin “brinco”
          child: FormField<String>(
            initialValue: controller.text,
            validator: (validator == null) ? null : (_) => validator!(controller.text),
            builder: (state) {
              final hasError = state.hasError;
              final errorText = state.errorText;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hasError ? ColoresApp.vino.withOpacity(0.55) : const Color(0x11000000),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: ColoresApp.vino,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(icon, color: ColoresApp.blanco, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            obscureText: obscure,
                            keyboardType: keyboardType,
                            textInputAction: textInputAction,
                            onSubmitted: onSubmitted,
                            onChanged: (_) => state.didChange(controller.text),
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: t.bodySmall?.copyWith(
                                color: ColoresApp.textoSuave,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(bottom: 2),
                            ),
                            style: t.bodyMedium?.copyWith(
                              color: ColoresApp.texto,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  AnimatedOpacity(
                    opacity: hasError ? 1 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: hasError
                        ? Text(
                            errorText ?? '',
                            style: t.bodySmall?.copyWith(
                              color: ColoresApp.vino.withOpacity(0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          )
                        : const SizedBox(height: 14),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
