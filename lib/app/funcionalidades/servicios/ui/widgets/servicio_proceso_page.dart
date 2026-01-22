import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:portal_servicios_usuario/app/tema/colores.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/servicios/data/servicios_detalle_mock.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/data/servicios_mock.dart';

import 'package:portal_servicios_usuario/app/funcionalidades/servicios/domain/servicio_detalle.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/domain/servicio_item.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/servicios/domain/servicio_proceso_models.dart';

import 'servicio_proceso_widgets.dart';

class ServicioProcesoPage extends StatefulWidget {
  const ServicioProcesoPage({
    super.key,
    required this.servicioId,
  });

  final String servicioId;

  @override
  State<ServicioProcesoPage> createState() => _ServicioProcesoPageState();
}

class _ServicioProcesoPageState extends State<ServicioProcesoPage> {
  DateTime? _fechaCita;
  TimeOfDay? _horaCita;

  String? _folioGenerado;
  bool _submitting = false;

  late List<DocReq> _docs;

  // Ajusta si tu app usa otra ruta principal como fallback.
  static const String _fallbackRoute = '/servicios';

  final _servidor = const ServidorPublicoMock(
    nombreCompleto: 'María Fernanda López Ramírez',
    numeroEmpleado: 'SP-104928',
    correo: 'mfernanda.lopez@ejemplo.gob.mx',
    telefono: '+52 722 123 4567',
    cargo: 'Analista Administrativo',
    adscripcion: 'Dirección de Prestaciones',
    dependencia: 'Gobierno del Estado (Mock)',
  );

  ServicioItem? get _item {
    try {
      return serviciosMock.firstWhere((x) => x.id == widget.servicioId);
    } catch (_) {
      return null;
    }
  }

  ServicioDetalle get _detalle {
    final it = _item;
    if (it == null) {
      return const ServicioDetalle(
        canal: ServicioCanal.digital,
        descripcion: 'Servicio no encontrado.',
        requisitos: ['—'],
        pasos: ['—'],
        accionLabel: 'Cerrar',
      );
    }

    return serviciosDetallesMock[it.id] ??
        ServicioDetalle(
          canal: ServicioCanal.digital,
          descripcion: 'Información detallada disponible próximamente.',
          requisitos: const ['—'],
          pasos: const ['—'],
          accionLabel: it.tipo == ServicioTipo.tramite ? 'Iniciar trámite' : 'Abrir consulta',
        );
  }

  @override
  void initState() {
    super.initState();
    _docs = _buildDocs();
  }

  void _safeClose() {
    // 1) GoRouter primero (si vienes de context.go / push)
    try {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        context.pop();
        return;
      }
    } catch (_) {
      // si no hay GoRouter arriba (raro), seguimos con Navigator
    }

    // 2) Navigator fallback
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }

    // 3) Último recurso: manda a una ruta “home/listado”
    // (Evita pantalla negra si esta pantalla quedó como root)
    if (mounted) context.go(_fallbackRoute);
  }

  List<DocReq> _buildDocs() {
    final it = _item;
    if (it == null) return <DocReq>[];

    final detalle = _detalle;
    final isDigital = detalle.canal == ServicioCanal.digital;
    final isTramite = it.tipo == ServicioTipo.tramite;
    if (!isDigital || !isTramite) return <DocReq>[];

    switch (it.id) {
      case 't_no_adeudo':
        return const [
          DocReq(id: 'ine', label: 'Identificación oficial (INE)', hint: 'Frente y reverso'),
          DocReq(id: 'comprobante', label: 'Último comprobante de pago', hint: 'PDF o foto legible'),
        ];
      case 't_finiquito':
        return const [
          DocReq(id: 'ine', label: 'Identificación oficial (INE)', hint: 'Vigente'),
          DocReq(id: 'baja', label: 'Documento de baja / término', hint: 'Oficio o constancia'),
          DocReq(id: 'pago', label: 'Último comprobante de percepciones', hint: 'PDF o foto'),
        ];
      case 't_historico_laboral':
        return const [
          DocReq(id: 'ine', label: 'Identificación oficial (INE)', hint: 'Vigente'),
        ];
      case 't_reexpedicion_pagos':
        return const [
          DocReq(id: 'ine', label: 'Identificación oficial (INE)', hint: 'Vigente'),
          DocReq(id: 'detalle', label: 'Detalle del pago a reexpedir', hint: 'Periodo / fecha / monto'),
        ];
      default:
        return const [
          DocReq(id: 'ine', label: 'Identificación oficial (INE)', hint: 'Vigente'),
          DocReq(id: 'comprobante', label: 'Último comprobante relacionado', hint: 'PDF o foto legible'),
        ];
    }
  }

  bool get _docsOk => _docs.isEmpty ? true : _docs.every((d) => d.attachedName != null);
  bool get _isPresencial => _detalle.canal == ServicioCanal.presencial;
  bool get _isDigital => _detalle.canal == ServicioCanal.digital;
  bool get _isTramite => (_item?.tipo == ServicioTipo.tramite);
  bool get _isConsulta => (_item?.tipo == ServicioTipo.consulta);

  String _fmtFecha(BuildContext context, DateTime d) =>
      MaterialLocalizations.of(context).formatFullDate(d);

  String _fmtHora(BuildContext context, TimeOfDay t) =>
      MaterialLocalizations.of(context).formatTimeOfDay(t, alwaysUse24HourFormat: true);

  List<String> _uiSteps() {
    if (_isPresencial) return const ['Revisar', 'Agendar', 'Confirmar'];
    if (_isConsulta) return const ['Revisar', 'Abrir'];
    return const ['Revisar', 'Documentos', 'Confirmar'];
  }

  int _uiCurrentStepIndex() {
    final steps = _uiSteps();
    if (_folioGenerado != null) return steps.length - 1;
    if (_submitting) return steps.length - 1;

    if (_isPresencial) {
      if (_fechaCita != null && _horaCita != null) return 2;
      return 1;
    }

    if (_isConsulta) return 0;

    if (_docs.isEmpty) return 2;
    return _docsOk ? 2 : 1;
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCita ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Selecciona el día de tu cita',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: ColoresApp.cafe,
                  surface: ColoresApp.blanco,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _fechaCita = picked);
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaCita ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Selecciona la hora',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: ColoresApp.cafe,
                  surface: ColoresApp.blanco,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _horaCita = picked);
  }

  String _genFolio({required String prefix}) {
    final r = Random();
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final code = List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$prefix-$y$m$d-$code';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<String?> _pickAttachOption(DocReq doc) async {
    return showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: ColoresApp.blanco,
      barrierColor: Colors.black.withOpacity(0.40),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: ColoresApp.bordeSuave,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Adjuntar documento',
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  doc.label,
                  style: t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ColoresApp.textoSuave,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SheetOption(
                icon: Icons.photo_camera_outlined,
                title: 'Tomar foto (simulado)',
                subtitle: 'Ideal si es un documento físico',
                onTap: () => Navigator.pop(ctx, 'foto_${doc.id}.jpg'),
              ),
              const SizedBox(height: 10),
              SheetOption(
                icon: Icons.upload_file_outlined,
                title: 'Elegir archivo (simulado)',
                subtitle: 'PDF o imagen desde tu dispositivo',
                onTap: () => Navigator.pop(ctx, 'archivo_${doc.id}.pdf'),
              ),
              const SizedBox(height: 10),
              SheetOption(
                icon: Icons.delete_outline_rounded,
                title: 'Quitar adjunto',
                subtitle: 'Dejar este requisito pendiente',
                danger: true,
                onTap: () => Navigator.pop(ctx, '__remove__'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onAttachDoc(int index) async {
    final doc = _docs[index];
    final selected = await _pickAttachOption(doc);
    if (selected == null) return;

    setState(() {
      if (selected == '__remove__') {
        _docs = [
          for (int i = 0; i < _docs.length; i++)
            if (i == index) _docs[i].copyWith(attachedName: null) else _docs[i],
        ];
      } else {
        _docs = [
          for (int i = 0; i < _docs.length; i++)
            if (i == index) _docs[i].copyWith(attachedName: selected) else _docs[i],
        ];
      }
    });
  }

  Future<void> _confirmPresencial() async {
    if (_fechaCita == null) return _toast('Selecciona el día de la cita.');
    if (_horaCita == null) return _toast('Selecciona la hora de la cita.');

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 650));

    final folio = _genFolio(prefix: 'CITA');
    setState(() {
      _folioGenerado = folio;
      _submitting = false;
    });

    if (!mounted) return;
    await _showSuccessDialog(
      title: 'Cita agendada',
      folio: folio,
      extra: const [
        'Recuerda llegar 10 minutos antes.',
        'Tolerancia sugerida: 10 minutos (mock).',
        'Lleva tus documentos en original y copia (si aplica).',
      ],
    );
  }

  Future<void> _confirmDigital() async {
    if (_isTramite && !_docsOk) return _toast('Adjunta todos los documentos requeridos.');

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 650));

    final folio = _genFolio(prefix: _isTramite ? 'TRM' : 'CON');
    setState(() {
      _folioGenerado = folio;
      _submitting = false;
    });

    if (!mounted) return;
    await _showSuccessDialog(
      title: _isTramite ? 'Trámite iniciado' : 'Consulta lista',
      folio: folio,
      extra: [
        if (_isTramite) 'Podrás ver el estatus en “Mis trámites” (cuando conectemos backend).',
        'Guarda tu folio: es tu llave maestra 😄',
      ],
    );
  }

  Future<void> _showSuccessDialog({
    required String title,
    required String folio,
    required List<String> extra,
  }) async {
    final t = Theme.of(context).textTheme;
    final item = _item;

    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: ColoresApp.blanco,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ColoresApp.cafe.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ColoresApp.cafe.withOpacity(0.22)),
                      ),
                      child: Icon(Icons.check_rounded, color: ColoresApp.cafe),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColoresApp.texto,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (item != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.titulo,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ColoresApp.texto,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: ColoresApp.inputBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColoresApp.bordeSuave),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.confirmation_number_outlined, color: ColoresApp.textoSuave),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          folio,
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ColoresApp.texto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...extra.map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: ColoresApp.textoSuave),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            x,
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: ColoresApp.textoSuave,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: BtnPrimary(
                    text: 'Listo',
                    accent: ColoresApp.cafe,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final it = _item;
    final detalle = _detalle;
    final t = Theme.of(context).textTheme;

    if (it == null) {
      return Scaffold(
        backgroundColor: ColoresApp.blanco,
        appBar: AppBar(
          backgroundColor: ColoresApp.blanco,
          elevation: 0,
          title: const Text('Servicio'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _safeClose,
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Servicio no encontrado.'),
        ),
      );
    }

    final tipoLabel = it.tipo == ServicioTipo.tramite ? 'Trámite' : 'Consulta';
    final canalLabel = detalle.canal == ServicioCanal.digital ? 'En línea' : 'Presencial';

    final primaryText = _isPresencial
        ? ((detalle.accionLabel ?? '').trim().isNotEmpty ? detalle.accionLabel!.trim() : 'Agendar cita')
        : (_isConsulta
            ? ((detalle.accionLabel ?? '').trim().isNotEmpty ? detalle.accionLabel!.trim() : 'Abrir consulta')
            : ((detalle.accionLabel ?? '').trim().isNotEmpty ? detalle.accionLabel!.trim() : 'Iniciar trámite'));

    final primaryEnabled = _submitting
        ? false
        : _isPresencial
            ? true
            : (_isConsulta ? true : _docsOk);

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      appBar: AppBar(
        backgroundColor: ColoresApp.blanco,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _safeClose,
        ),
        title: Text(
          'Confirmar y continuar',
          style: t.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: ColoresApp.texto,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: ColoresApp.blanco,
            border: Border(top: BorderSide(color: ColoresApp.bordeSuave.withOpacity(0.9))),
          ),
          child: Row(
            children: [
              Expanded(
                child: BtnSecondary(
                  text: 'Cancelar',
                  onTap: _safeClose,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BtnPrimary(
                  text: _submitting ? 'Procesando...' : primaryText,
                  accent: it.accent,
                  enabled: primaryEnabled,
                  onTap: () async {
                    if (_submitting) return;
                    if (_isPresencial) return _confirmPresencial();
                    return _confirmDigital();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          HeroClean(
            accent: it.accent,
            icon: it.icon,
            title: it.titulo,
            subtitle: detalle.descripcion,
            chips: [
              ChipData(text: tipoLabel, fg: it.accent, bd: it.accent.withOpacity(0.22), bg: ColoresApp.blanco),
              ChipData(text: canalLabel, fg: ColoresApp.textoSuave, bd: ColoresApp.bordeSuave, bg: ColoresApp.inputBg),
              ChipData(text: it.categoria.texto, fg: ColoresApp.textoSuave, bd: ColoresApp.bordeSuave, bg: ColoresApp.inputBg),
            ],
          ),
          const SizedBox(height: 10),
          StepChips(
            accent: it.accent,
            steps: _uiSteps(),
            currentIndex: _uiCurrentStepIndex(),
          ),
          const SizedBox(height: 12),

          SectionCard(
            title: 'Datos del servidor público',
            accent: it.accent,
            icon: Icons.badge_outlined,
            child: Column(
              children: [
                KVRow(label: 'Nombre', value: _servidor.nombreCompleto),
                KVRow(label: 'No. empleado', value: _servidor.numeroEmpleado),
                KVRow(label: 'Correo', value: _servidor.correo),
                KVRow(label: 'Teléfono', value: _servidor.telefono),
                KVRow(label: 'Cargo', value: _servidor.cargo),
                KVRow(label: 'Adscripción', value: _servidor.adscripcion),
                KVRow(label: 'Dependencia', value: _servidor.dependencia),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_isPresencial) ...[
            SectionCard(
              title: 'Agendar cita',
              accent: it.accent,
              icon: Icons.event_available_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PickRow(
                    label: 'Día',
                    value: _fechaCita == null ? 'Seleccionar' : _fmtFecha(context, _fechaCita!),
                    onTap: _pickFecha,
                  ),
                  const SizedBox(height: 10),
                  PickRow(
                    label: 'Hora',
                    value: _horaCita == null ? 'Seleccionar' : _fmtHora(context, _horaCita!),
                    onTap: _pickHora,
                  ),
                  const SizedBox(height: 12),
                  const HintBox(text: 'Llega 10 minutos antes. (Sí, aunque el sistema diga “rápido” 😄)'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Atención presencial',
              accent: it.accent,
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  if ((detalle.horario ?? '').trim().isNotEmpty) KVRow(label: 'Horario', value: detalle.horario!.trim()),
                  if ((detalle.ubicacionNombre ?? '').trim().isNotEmpty) KVRow(label: 'Lugar', value: detalle.ubicacionNombre!.trim()),
                  if ((detalle.ubicacionDireccion ?? '').trim().isNotEmpty) KVRow(label: 'Dirección', value: detalle.ubicacionDireccion!.trim()),
                  if (detalle.telefonos.isNotEmpty) KVRow(label: 'Teléfono', value: detalle.telefonos.join(' • ')),
                  if (detalle.correos.isNotEmpty) KVRow(label: 'Correo', value: detalle.correos.join(' • ')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Recuerda llevar',
              accent: it.accent,
              icon: Icons.checklist_rounded,
              child: Column(
                children: detalle.requisitos.map((x) => BulletItem(text: x, accent: it.accent)).toList(),
              ),
            ),
          ],

          if (_isDigital && _isTramite) ...[
            SectionCard(
              title: 'Documentos requeridos',
              accent: it.accent,
              icon: Icons.upload_file_outlined,
              child: Column(
                children: [
                  if (_docs.isEmpty)
                    const HintBox(text: 'Este trámite no requiere adjuntos (mock).')
                  else
                    for (int i = 0; i < _docs.length; i++) ...[
                      DocTile(
                        doc: _docs[i],
                        accent: it.accent,
                        onTap: () => _onAttachDoc(i),
                      ),
                      if (i != _docs.length - 1) const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 12),
                  HintBox(text: _docsOk ? 'Listo. Puedes iniciar el proceso.' : 'Adjunta todo para habilitar el botón.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Pasos del trámite',
              accent: it.accent,
              icon: Icons.alt_route_rounded,
              child: Column(
                children: detalle.pasos.map((x) => BulletItem(text: x, accent: it.accent)).toList(),
              ),
            ),
          ],

          if (_isDigital && _isConsulta) ...[
            SectionCard(
              title: 'Consulta',
              accent: it.accent,
              icon: Icons.search_rounded,
              child: Column(
                children: [
                  const HintBox(text: 'Esta acción abre la consulta y muestra información protegida.'),
                  const SizedBox(height: 10),
                  ...detalle.pasos.map((x) => BulletItem(text: x, accent: it.accent)),
                ],
              ),
            ),
          ],

          if (_folioGenerado != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              title: 'Folio generado',
              accent: it.accent,
              icon: Icons.confirmation_number_outlined,
              child: KVRow(label: 'Folio', value: _folioGenerado!),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
