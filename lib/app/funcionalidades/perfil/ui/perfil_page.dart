import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();

  // ✅ Demo (después vendrá del backend)
  final String _nombre = 'María';
  final String _numeroServidor = '123456';
  final String _curp = 'XXXX000000XXXXXX00';
  final String _dependencia = 'Dirección General';
  final String _puesto = 'Servidor(a) Público(a)';

  late final TextEditingController _correoCtrl;
  late final TextEditingController _telCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _correoCtrl = TextEditingController(text: 'maria@email.com');
    _telCtrl = TextEditingController(text: '722 000 0000');
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    HapticFeedback.selectionClick();
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados (demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ColoredBox(
      color: ColoresApp.blanco,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header =====
            _SectionCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: ColoresApp.inputBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: ColoresApp.bordeSuave),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: ColoresApp.textoSuave,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleMedium?.copyWith(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w900,
                              color: ColoresApp.texto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Núm. servidor: $_numeroServidor',
                            style: t.bodySmall?.copyWith(
                              fontSize: 11.4,
                              fontWeight: FontWeight.w700,
                              color: ColoresApp.textoSuave,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _Pill(
                      text: 'Verificado',
                      icon: PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
                      fg: ColoresApp.cafe,
                      bg: ColoresApp.cafe.withOpacity(0.10),
                      bd: ColoresApp.cafe.withOpacity(0.18),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== Datos NO editables =====
            Text(
              'Datos del servidor',
              style: t.titleMedium?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
              ),
            ),
            const SizedBox(height: 8),

            _SectionCard(
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Número de servidor',
                    value: _numeroServidor,
                    locked: true,
                    icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.light),
                  ),
                  const _DividerSoft(),
                  _InfoRow(
                    label: 'CURP',
                    value: _curp,
                    locked: true,
                    icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.light),
                  ),
                  const _DividerSoft(),
                  _InfoRow(
                    label: 'Dependencia',
                    value: _dependencia,
                    locked: true,
                    icon: PhosphorIcons.buildings(PhosphorIconsStyle.light),
                  ),
                  const _DividerSoft(),
                  _InfoRow(
                    label: 'Puesto',
                    value: _puesto,
                    locked: true,
                    icon: PhosphorIcons.briefcase(PhosphorIconsStyle.light),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== Datos editables =====
            Text(
              'Contacto',
              style: t.titleMedium?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
              ),
            ),
            const SizedBox(height: 8),

            _SectionCard(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    children: [
                      _Input(
                        label: 'Correo',
                        controller: _correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: PhosphorIcons.envelopeSimple(PhosphorIconsStyle.light),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Ingresa tu correo';
                          if (!s.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _Input(
                        label: 'Teléfono',
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: PhosphorIcons.phone(PhosphorIconsStyle.light),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return 'Ingresa tu teléfono';
                          if (s.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                            return 'Teléfono incompleto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.vino,
                            foregroundColor: ColoresApp.blanco,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Guardar cambios',
                                  style: t.labelLarge?.copyWith(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Algunos datos no se pueden editar por seguridad.',
                        style: t.bodySmall?.copyWith(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w600,
                          color: ColoresApp.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================================
  UI Pieces
============================================================================ */

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DividerSoft extends StatelessWidget {
  const _DividerSoft();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: ColoresApp.bordeSuave.withOpacity(0.70),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color fg;
  final Color bg;
  final Color bd;

  const _Pill({
    required this.text,
    required this.icon,
    required this.fg,
    required this.bg,
    required this.bd,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: t.labelMedium?.copyWith(
              fontSize: 11.0,
              fontWeight: FontWeight.w900,
              color: fg,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool locked;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.locked,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ColoresApp.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColoresApp.bordeSuave),
            ),
            child: Icon(icon, size: 18, color: ColoresApp.textoSuave),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.bodySmall?.copyWith(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: ColoresApp.textoSuave,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                  ),
                ),
              ],
            ),
          ),

          if (locked) ...[
            const SizedBox(width: 10),
            Icon(
              PhosphorIcons.lock(PhosphorIconsStyle.light),
              size: 18,
              color: ColoresApp.textoSuave.withOpacity(0.75),
            ),
          ],
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const _Input({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: ColoresApp.bordeSuave),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.bodySmall?.copyWith(
            fontSize: 11.0,
            fontWeight: FontWeight.w800,
            color: ColoresApp.texto,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: t.bodyMedium?.copyWith(
            fontSize: 12.6,
            fontWeight: FontWeight.w800,
            color: ColoresApp.texto,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColoresApp.inputBg,
            prefixIcon: Icon(prefixIcon, size: 18, color: ColoresApp.textoSuave),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: ColoresApp.vino.withOpacity(0.45)),
            ),
            errorBorder: border.copyWith(
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: border.copyWith(
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
