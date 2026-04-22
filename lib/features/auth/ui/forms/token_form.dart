import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class TokenForm extends StatefulWidget {
  const TokenForm({
    super.key,
    required this.formKey,
    required this.codeCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController codeCtrl;
  final Future<void> Function() onSubmit;

  @override
  State<TokenForm> createState() => _TokenFormState();
}

class _TokenFormState extends State<TokenForm> {
  static const _length = 6;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
    widget.codeCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.codeCtrl.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String get _value => widget.codeCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          GestureDetector(
            onTap: _focusNode.requestFocus,
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                SizedBox(
                  height: 62,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_length, (index) {
                      final filled = index < _value.length;
                      final active =
                          index == _value.length && _value.length < _length;
                      final character = filled ? _value[index] : '';

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.only(
                          right: index == _length - 1 ? 0 : 10,
                        ),
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: filled
                              ? ColoresApp.vino.withValues(alpha: 0.08)
                              : const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: active
                                ? ColoresApp.vino
                                : filled
                                ? ColoresApp.vino.withValues(alpha: 0.35)
                                : const Color(0x14000000),
                            width: active ? 2.0 : 1.2,
                          ),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 160),
                          style: textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                            letterSpacing: 1,
                            fontSize: 18,
                          ),
                          child: Text(character.isEmpty ? '.' : character),
                        ),
                      );
                    }),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: widget.codeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_length),
                      ],
                      validator: (value) {
                        final raw = (value ?? '').trim();
                        if (raw.isEmpty) {
                          return 'Escribe el codigo de verificacion';
                        }
                        if (raw.length != _length) {
                          return 'El codigo debe tener $_length digitos';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.trim().length == _length) {
                          widget.onSubmit();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Toca los cuadros para escribir tu codigo de verificacion.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: ColoresApp.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
