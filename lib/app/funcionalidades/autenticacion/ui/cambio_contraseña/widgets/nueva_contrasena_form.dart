import 'package:flutter/material.dart';

class NuevaContrasenaForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passCtrl;
  final TextEditingController pass2Ctrl;
  final Future<void> Function() onSubmit;

  const NuevaContrasenaForm({
    super.key,
    required this.formKey,
    required this.passCtrl,
    required this.pass2Ctrl,
    required this.onSubmit,
  });

  @override
  State<NuevaContrasenaForm> createState() => _NuevaContrasenaFormState();
}

class _NuevaContrasenaFormState extends State<NuevaContrasenaForm> {
  bool _show1 = false;
  bool _show2 = false;

  String? _v1(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Escribe tu contraseña nueva';
    if (s.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _v2(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Confirma tu contraseña';
    if (s != widget.passCtrl.text.trim()) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: widget.passCtrl,
            obscureText: !_show1,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _show1 = !_show1),
                icon: Icon(_show1 ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            validator: _v1,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: widget.pass2Ctrl,
            obscureText: !_show2,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit(),
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _show2 = !_show2),
                icon: Icon(_show2 ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            validator: _v2,
          ),
        ],
      ),
    );
  }
}
