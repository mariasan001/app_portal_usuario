import 'package:flutter/material.dart';

import '../../../../tema/colores.dart';

class AuthTextField extends StatefulWidget {
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

  final String? label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  void _toggleObscure() {
    if (!widget.obscure) return;
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          Text(
            widget.label!,
            style: t.bodySmall?.copyWith(
              color: ColoresApp.texto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
        ],
        SizedBox(
          height: 62,
          child: FormField<String>(
            initialValue: widget.controller.text,
            validator: (widget.validator == null)
                ? null
                : (_) => widget.validator!(widget.controller.text),
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
                        color: hasError
                            ? ColoresApp.vino.withValues(alpha: 0.55)
                            : const Color(0x11000000),
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
                          child: Icon(
                            widget.icon,
                            color: ColoresApp.blanco,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            obscureText: _obscureText,
                            keyboardType: widget.keyboardType,
                            textInputAction: widget.textInputAction,
                            onSubmitted: widget.onSubmitted,
                            onChanged: (_) =>
                                state.didChange(widget.controller.text),
                            decoration: InputDecoration(
                              hintText: widget.hint,
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
                        if (widget.obscure) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _toggleObscure,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: ColoresApp.textoSuave,
                              ),
                            ),
                          ),
                        ],
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
                              color: ColoresApp.vino.withValues(alpha: 0.85),
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
