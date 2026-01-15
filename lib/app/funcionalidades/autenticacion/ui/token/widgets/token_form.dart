import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../tema/colores.dart';

class TokenForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController codeCtrl;
  final Future<void> Function() onSubmit;

  const TokenForm({
    super.key,
    required this.formKey,
    required this.codeCtrl,
    required this.onSubmit,
  });

  @override
  State<TokenForm> createState() => _TokenFormState();
}

class _TokenFormState extends State<TokenForm> {
  final _focus = FocusNode();

  static const int _len = 6;

  @override
  void initState() {
    super.initState();
    // Auto focus suave
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });

    widget.codeCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.codeCtrl.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  String get _value => widget.codeCtrl.text.trim();

  void _tapFocus() => _focus.requestFocus();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // ✅ Input invisible (captura teclado) + UI de círculos
          GestureDetector(
            onTap: _tapFocus,
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                SizedBox(
                  height: 62,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_len, (i) {
                      final filled = i < _value.length;
                      final active = i == _value.length && _value.length < _len;
                      final ch = filled ? _value[i] : '';

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        margin: EdgeInsets.only(right: i == _len - 1 ? 0 : 10),
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: filled
                              ? ColoresApp.vino.withOpacity(0.08)
                              : const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: active
                                ? ColoresApp.vino
                                : filled
                                    ? ColoresApp.vino.withOpacity(0.35)
                                    : const Color(0x14000000),
                            width: active ? 2.0 : 1.2,
                          ),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 160),
                          style: t.titleMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                            letterSpacing: 1.0,
                            fontSize: 18,
                          ),
                          child: Text(ch.isEmpty ? '•' : ch),
                        ),
                      );
                    }),
                  ),
                ),

                // Campo real (invisible) para manejar teclado/validación
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextFormField(
                      focusNode: _focus,
                      controller: widget.codeCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters:  [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_len),
                      ],
                      validator: (v) {
                        final s = (v ?? '').trim();
                        if (s.isEmpty) return 'Ingresa el código';
                        if (s.length != _len) return 'Debe tener $_len dígitos';
                        return null;
                      },
                      onChanged: (v) {
                        final s = v.trim();
                        if (s.length == _len) {
                          widget.onSubmit(); // auto-submit cuando completa
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
            'Toca los cuadros para escribir el código.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
              color: ColoresApp.textoSuave,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
