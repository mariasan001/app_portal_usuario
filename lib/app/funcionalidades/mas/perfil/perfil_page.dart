import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/mas/perfil/perfil_models.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/mas/perfil/perfil_repository.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/mas/perfil/perfil_repository_mock.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';


// ✅ UI helpers (si ya tienes UiSectionCard/UiKVRow, puedes reemplazar por los tuyos)
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: ColoresApp.texto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ColoresApp.texto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.k, required this.v});

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.textoSuave,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              v.isEmpty ? '-' : v,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
                fontSize: 12.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final PerfilRepository repo = PerfilRepositoryMock.instance;

  final _formKey = GlobalKey<FormState>();

  PerfilServidorPublico? _perfil;

  late final TextEditingController _correoCtrl;
  late final TextEditingController _telCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _correoCtrl = TextEditingController();
    _telCtrl = TextEditingController();
    _boot();
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final p = await repo.obtenerPerfil();
    if (!mounted) return;
    setState(() {
      _perfil = p;
      _correoCtrl.text = p.correo;
      _telCtrl.text = p.telefono;
    });

    // Para detectar cambios y habilitar el botón sin drama
    _correoCtrl.addListener(_rebuild);
    _telCtrl.addListener(_rebuild);
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _dirty {
    final p = _perfil;
    if (p == null) return false;
    return _correoCtrl.text.trim() != p.correo.trim() || _telCtrl.text.trim() != p.telefono.trim();
  }

  String? _validarCorreo(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Escribe tu correo.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);
    if (!ok) return 'Correo inválido.';
    return null;
  }

  String? _validarTel(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Escribe tu teléfono.';
    // México típico: 10 dígitos (ajústalo si necesitas)
    if (s.length < 10) return 'Teléfono incompleto.';
    return null;
  }

  Future<void> _guardar() async {
    if (_perfil == null) return;

    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final updated = await repo.actualizarContacto(
        ActualizarContactoPayload(
          correo: _correoCtrl.text,
          telefono: _telCtrl.text,
        ),
      );

      if (!mounted) return;
      setState(() {
        _perfil = updated;
        _saving = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos de contacto actualizados.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = _perfil;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: ColoresApp.cafe,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Perfil',
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: ColoresApp.texto,
                fontSize: 17,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
      body: p == null
          ? const SizedBox.expand() // si quieres: aquí podrías meter tu “precache”
          : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  children: [
                    // ---------- Header ----------
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: ColoresApp.blanco,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: ColoresApp.bordeSuave),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: ColoresApp.dorado.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: ColoresApp.dorado.withOpacity(0.22)),
                            ),
                            child: Icon(Icons.person, color: ColoresApp.dorado, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nombreCompleto,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.texto,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Servidor público · ${p.numeroServidor}',
                                  style: t.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.textoSuave,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration( 
                              color: ColoresApp.inputBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: ColoresApp.bordeSuave),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock, size: 14, color: ColoresApp.textoSuave),
                                const SizedBox(width: 6),
                                Text(
                                  'No editable',
                                  style: t.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColoresApp.textoSuave,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ---------- Datos laborales (solo lectura) ----------
                    _SectionCard(
                      title: 'Datos laborales',
                      icon: Icons.badge_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _KV(k: 'No. servidor', v: p.numeroServidor),
                          _KV(k: 'Puesto', v: p.puesto),
                          _KV(k: 'Adscripción', v: p.adscripcion),
                          _KV(k: 'RFC', v: p.rfc),
                          _KV(k: 'CURP', v: p.curp),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ---------- Contacto (editable) ----------
                    _SectionCard(
                      title: 'Contacto',
                      icon: Icons.mail_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Si cambió tu correo o teléfono, actualízalo aquí.',
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ColoresApp.textoSuave,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _Input(
                            label: 'Correo',
                            controller: _correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validarCorreo,
                            prefixIcon: Icons.alternate_email,
                          ),
                          const SizedBox(height: 10),
                          _Input(
                            label: 'Teléfono',
                            controller: _telCtrl,
                            keyboardType: TextInputType.phone,
                            validator: _validarTel,
                            prefixIcon: Icons.phone_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            hintText: '10 dígitos',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // espacio para el botón fijo
                  ],
                ),
              ),
            ),

      // ---------- Botón Guardar (compacto) ----------
      bottomNavigationBar: (_perfil == null)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: (!_dirty || _saving) ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: ColoresApp.cafe,
                      disabledBackgroundColor: ColoresApp.bordeSuave,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Guardar cambios',
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ColoresApp.blanco,
                              fontSize: 12.6,
                            ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.validator,
    required this.prefixIcon,
    this.inputFormatters,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final IconData prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      style: t.bodySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: ColoresApp.texto,
        fontSize: 12.8,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 18, color: ColoresApp.textoSuave),
        filled: true,
        fillColor: ColoresApp.inputBg,
        labelStyle: t.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: ColoresApp.textoSuave,
          fontSize: 12.2,
        ),
        hintStyle: t.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: ColoresApp.textoSuave,
          fontSize: 12.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColoresApp.bordeSuave),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColoresApp.bordeSuave),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColoresApp.cafe.withOpacity(0.55)),
        ),
      ),
    );
  }
}
