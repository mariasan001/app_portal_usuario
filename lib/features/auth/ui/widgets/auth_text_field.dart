import 'package:flutter/material.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';
import 'package:portal_servicios_usuario/features/auth/ui/styles/auth_ui_tokens.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.trim().isNotEmpty) ...[
          Text(
            widget.label!,
            style: textTheme.bodySmall?.copyWith(
              color: ColoresApp.texto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
        ],
        FormField<String>(
          initialValue: widget.controller.text,
          validator: widget.validator == null
              ? null
              : (_) => widget.validator!(widget.controller.text),
          builder: (state) {
            final hasError = state.hasError;
            final errorText = state.errorText;

            return AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(
                        AuthUiTokens.compactRadius,
                      ),
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
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: ColoresApp.textoSuave,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(bottom: 2),
                            ),
                            style: textTheme.bodyMedium?.copyWith(
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: hasError
                        ? Padding(
                            key: const ValueKey('auth-field-error'),
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ColoresApp.vino.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AuthUiTokens.compactRadius,
                                ),
                                border: Border.all(
                                  color: ColoresApp.vino.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 15,
                                    color: ColoresApp.vino.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      errorText ?? '',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: ColoresApp.vino.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.6,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('auth-field-no-error'),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
