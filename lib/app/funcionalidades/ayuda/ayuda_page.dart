// lib/app/funcionalidades/ayuda/ui/ayuda_soporte_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/tema/colores.dart';

class AyudaSoportePage extends StatefulWidget {
  const AyudaSoportePage({super.key});

  @override
  State<AyudaSoportePage> createState() => _AyudaSoportePageState();
}

class _AyudaSoportePageState extends State<AyudaSoportePage> {
  _AyudaTab _tab = _AyudaTab.faq;
  _FaqTema _tema = _FaqTema.portal;

  final _chatCtrl = TextEditingController();
  final _scroll = ScrollController();

  bool _botTyping = false;

  late final List<_FaqItem> _faqs = _buildFaqs();
  late final List<_ChatMsg> _msgs = [
    _ChatMsg.bot(
      text:
          'Hola 👋 Soy el asistente del portal.\n'
          'Puedo ayudarte con trámites, documentos, recibos, citas, acceso y normativas.',
      actions: [
        _ChatAction.quick('Trámites', icon: PhosphorIcons.fileText(PhosphorIconsStyle.light), intent: _Intent.tramites),
        _ChatAction.quick('Documentos', icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light), intent: _Intent.documentos),
        _ChatAction.quick('Recibos', icon: PhosphorIcons.receipt(PhosphorIconsStyle.light), intent: _Intent.recibos),
        _ChatAction.quick('Citas', icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.light), intent: _Intent.citas),
        _ChatAction.quick('Acceso', icon: PhosphorIcons.key(PhosphorIconsStyle.light), intent: _Intent.acceso),
        _ChatAction.quick('Soporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), intent: _Intent.soporte),
      ],
    ),
  ];

  @override
  void dispose() {
    _chatCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ======================= FAQ =======================

  List<_FaqItem> _buildFaqs() {
    return [
      _FaqItem(
        tema: _FaqTema.portal,
        icon: PhosphorIcons.house(PhosphorIconsStyle.light),
        pregunta: '¿Qué puedo consultar en este portal?',
        respuesta:
            'Servicios disponibles, trámites/consultas en proceso, citas, recibos y documentos (constancias y vigencias). '
            'Todo en un solo lugar para que no andes brincando entre sistemas.',
      ),
      _FaqItem(
        tema: _FaqTema.portal,
        icon: PhosphorIcons.userCircle(PhosphorIconsStyle.light),
        pregunta: '¿Puedo actualizar mis datos?',
        respuesta:
            'Sí. En “Perfil” puedes actualizar datos como correo y teléfono (según permisos). '
            'Algunos campos pueden estar bloqueados por seguridad.',
      ),
      _FaqItem(
        tema: _FaqTema.portal,
        icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.light),
        pregunta: '¿Mi información está segura?',
        respuesta:
            'El portal maneja sesión y permisos por usuario. Si detectas algo raro, cierra sesión y reporta al soporte.',
      ),
      _FaqItem(
        tema: _FaqTema.tramites,
        icon: PhosphorIcons.fileText(PhosphorIconsStyle.light),
        pregunta: '¿Cómo realizo un trámite en línea?',
        respuesta:
            'En “Servicios” selecciona el trámite, revisa requisitos, confirma y continúa. '
            'Si requiere documentos, el sistema te indicará cuáles y en qué formato.',
      ),
      _FaqItem(
        tema: _FaqTema.tramites,
        icon: PhosphorIcons.clock(PhosphorIconsStyle.light),
        pregunta: '¿Puedo consultar mis trámites anteriores o en proceso?',
        respuesta: 'Sí. En “Trámites” verás historial, estatus y fechas. Si hay folio, úsalo para seguimiento.',
      ),
      _FaqItem(
        tema: _FaqTema.tramites,
        icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.light),
        pregunta: '¿Qué hago si mi trámite aparece “Pendiente” o “Vencido”?',
        respuesta:
            'Pendiente suele ser validación o falta de información. Vencido indica expiración de vigencia/plazo. '
            'Abre el detalle para ver motivo y pasos.',
      ),
      _FaqItem(
        tema: _FaqTema.documentos,
        icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light),
        pregunta: '¿Qué encuentro en “Mis documentos”?',
        respuesta:
            'Constancias, vigencias e información relevante. Algunos documentos se descargan/comparten y otros solo se consultan.',
      ),
      _FaqItem(
        tema: _FaqTema.documentos,
        icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.light),
        pregunta: '¿Cómo descargo una constancia?',
        respuesta:
            'En “Mis documentos” abre el documento y usa descarga. Si no aparece, puede estar en generación o requerir permisos.',
      ),
      _FaqItem(
        tema: _FaqTema.normativas,
        icon: PhosphorIcons.bookOpenText(PhosphorIconsStyle.light),
        pregunta: '¿Dónde encuentro normativas y lineamientos vigentes?',
        respuesta:
            'En la sección correspondiente del servicio (detalle) o dentro de documentos. Cuando haya repositorio oficial, se mostrará enlace directo.',
      ),
      _FaqItem(
        tema: _FaqTema.soporte,
        icon: PhosphorIcons.headset(PhosphorIconsStyle.light),
        pregunta: '¿Cómo solicito soporte?',
        respuesta:
            'Primero revisa FAQ. Si necesitas ayuda específica, escribe en el chat e incluye: servicio/trámite, fecha y el error.',
      ),
      _FaqItem(
        tema: _FaqTema.soporte,
        icon: PhosphorIcons.bugBeetle(PhosphorIconsStyle.light),
        pregunta: '¿Qué hago si el portal falla o se cierra?',
        respuesta: 'Cierra sesión e inicia nuevamente. Si persiste, reporta: pantalla, pasos realizados y captura (si puedes).',
      ),
    ];
  }

  List<_FaqItem> get _filteredFaqs => _faqs.where((f) => f.tema == _tema).toList(growable: false);

  // ======================= CHAT PRO =======================

  void _sendChat(String text) {
    final msg = text.trim();
    if (msg.isEmpty) return;

    HapticFeedback.selectionClick();
    setState(() => _msgs.add(_ChatMsg.user(msg)));
    _chatCtrl.clear();
    _scrollToBottom();

    _replyBot(msg);
  }

  void _onBotQuickAction(_ChatAction a) {
    // Acción rápida: o navega o responde con intención
    if (a.route != null) {
      _safeNav(a.route!);
      return;
    }
    if (a.intent != null) {
      _replyBot('', forcedIntent: a.intent);
    }
  }

  void _replyBot(String input, { _Intent? forcedIntent }) {
    setState(() => _botTyping = true);
    _scrollToBottom();

    final ans = _botAnswer(input, forcedIntent: forcedIntent);

    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() {
        _botTyping = false;
        _msgs.add(_ChatMsg.bot(text: ans.text, actions: ans.actions));
      });
      _scrollToBottom();
    });
  }

  _BotAnswer _botAnswer(String input, { _Intent? forcedIntent }) {
    final s = input.toLowerCase();
    final intent = forcedIntent ?? _detectIntent(s);

    switch (intent) {
      case _Intent.tramites:
        return _BotAnswer(
          text:
              'Perfecto ✅ Trámites.\n'
              '1) Ve a “Servicios” para iniciar uno nuevo.\n'
              '2) Ve a “Trámites” para ver estatus/historial.\n'
              'Si me dices el trámite y el estatus (Pendiente/Vencido/En proceso), te digo el siguiente paso.',
          actions: [
            _ChatAction.nav('Ir a Servicios', icon: PhosphorIcons.gridFour(PhosphorIconsStyle.light), route: _Routes.servicios),
            _ChatAction.nav('Ver mis Trámites', icon: PhosphorIcons.fileText(PhosphorIconsStyle.light), route: _Routes.tramites),
            _ChatAction.nav('Levantar reporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), route: _Routes.reporteSoporte),
          ],
        );

      case _Intent.documentos:
        return _BotAnswer(
          text:
              'Va ✅ Documentos.\n'
              'En “Mis documentos” puedes ver constancias y vigencias.\n'
              'Si un documento no aparece: puede estar en generación, sin permisos o con periodo incorrecto.\n'
              'Dime el nombre del documento y el periodo que buscas.',
          actions: [
            _ChatAction.nav('Ir a Documentos', icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light), route: _Routes.documentos),
            _ChatAction.nav('Abrir Recibos', icon: PhosphorIcons.receipt(PhosphorIconsStyle.light), route: _Routes.recibos),
            _ChatAction.nav('Levantar reporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), route: _Routes.reporteSoporte),
          ],
        );

      case _Intent.recibos:
        return _BotAnswer(
          text:
              'Recibos 💳\n'
              'Entra a “Recibos” y filtra por periodo/quincena.\n'
              'Si falta uno, puede estar en carga o no disponible aún.\n'
              '¿Qué quincena/mes necesitas?',
          actions: [
            _ChatAction.nav('Ir a Recibos', icon: PhosphorIcons.receipt(PhosphorIconsStyle.light), route: _Routes.recibos),
            _ChatAction.nav('Levantar reporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), route: _Routes.reporteSoporte),
          ],
        );

      case _Intent.citas:
        return _BotAnswer(
          text:
              'Citas 📅\n'
              'Puedes consultar tus citas desde “Citas” (o dentro del servicio relacionado).\n'
              'Si quieres reagendar, dime si es Trámite o Consulta y la fecha.',
          actions: [
            _ChatAction.nav('Ir a Citas', icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.light), route: _Routes.citas),
            _ChatAction.nav('Ir a Servicios', icon: PhosphorIcons.gridFour(PhosphorIconsStyle.light), route: _Routes.servicios),
          ],
        );

      case _Intent.acceso:
        return _BotAnswer(
          text:
              'Acceso 🔐\n'
              'Si no puedes iniciar sesión:\n'
              '• Revisa usuario/contraseña.\n'
              '• Valida conexión.\n'
              '• Si usas código/token, usa el más reciente.\n'
              '¿Qué mensaje de error te muestra?',
          actions: [
            _ChatAction.nav('Ir a Perfil', icon: PhosphorIcons.userCircle(PhosphorIconsStyle.light), route: _Routes.perfil),
            _ChatAction.nav('Levantar reporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), route: _Routes.reporteSoporte),
          ],
        );

      case _Intent.normativas:
        return _BotAnswer(
          text:
              'Normativas 📚\n'
              'Normalmente aparecen en el detalle del servicio o dentro de documentos.\n'
              'Dime el tema (ej. escalafón, constancias, descuentos, etc.) y te digo dónde verlo.',
          actions: [
            _ChatAction.nav('Ir a Servicios', icon: PhosphorIcons.gridFour(PhosphorIconsStyle.light), route: _Routes.servicios),
            _ChatAction.nav('Ir a Documentos', icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light), route: _Routes.documentos),
          ],
        );

      case _Intent.soporte:
        final looksLikeError = s.contains('error') || s.contains('exception') || s.contains('fall') || s.contains('crash');

        return _BotAnswer(
          text: looksLikeError
              ? 'Ok, eso suena a error 🐛\n'
                'Pásame:\n'
                '1) Pantalla donde ocurre\n'
                '2) Pasos para reproducir\n'
                '3) Texto del error (o captura)\n'
                'Y lo convertimos en reporte de soporte.'
              : 'Soporte ✅\n'
                'Si algo no cuadra (trámite, documento, recibo, acceso), podemos levantar un reporte.\n'
                '¿Qué módulo es y qué estabas intentando hacer?',
          actions: [
            _ChatAction.nav('Levantar reporte', icon: PhosphorIcons.headset(PhosphorIconsStyle.light), route: _Routes.reporteSoporte),
            _ChatAction.quick('Trámites', icon: PhosphorIcons.fileText(PhosphorIconsStyle.light), intent: _Intent.tramites),
            _ChatAction.quick('Documentos', icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light), intent: _Intent.documentos),
          ],
        );

      case _Intent.general:
        return _BotAnswer(
          text:
              'Entendido ✅\n'
              'Dime si es sobre: trámites, documentos, recibos, citas, acceso o normativas.\n'
              'Si puedes, pega el texto del error o describe la pantalla.',
          actions: [
            _ChatAction.quick('Trámites', icon: PhosphorIcons.fileText(PhosphorIconsStyle.light), intent: _Intent.tramites),
            _ChatAction.quick('Documentos', icon: PhosphorIcons.folderOpen(PhosphorIconsStyle.light), intent: _Intent.documentos),
            _ChatAction.quick('Recibos', icon: PhosphorIcons.receipt(PhosphorIconsStyle.light), intent: _Intent.recibos),
            _ChatAction.quick('Acceso', icon: PhosphorIcons.key(PhosphorIconsStyle.light), intent: _Intent.acceso),
          ],
        );
    }
  }

  _Intent _detectIntent(String s) {
    bool hasAny(List<String> k) => k.any((x) => s.contains(x));

    if (hasAny(['trámite', 'tramite', 'folio', 'pendiente', 'vencid', 'estatus'])) return _Intent.tramites;
    if (hasAny(['documento', 'constancia', 'vigencia', 'pdf', 'firma'])) return _Intent.documentos;
    if (hasAny(['recibo', 'nómina', 'nomina', 'quincena', 'pago'])) return _Intent.recibos;
    if (hasAny(['cita', 'reagendar', 'agenda', 'calendario'])) return _Intent.citas;
    if (hasAny(['login', 'sesión', 'sesion', 'acceso', 'token', 'contraseña', 'password'])) return _Intent.acceso;
    if (hasAny(['norma', 'lineamiento', 'regla', 'normativa'])) return _Intent.normativas;
    if (hasAny(['soporte', 'error', 'bug', 'fall', 'crash', 'report'])) return _Intent.soporte;

    return _Intent.general;
  }

  void _safeNav(String route) {
    HapticFeedback.selectionClick();
    try {
      Navigator.of(context).pushNamed(route);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta no configurada: $route 😅')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  // ======================= UI =======================

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      color: ColoresApp.blanco,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER “INTOCABLE”
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 18,
                    decoration: BoxDecoration(
                      color: ColoresApp.cafe.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ayuda y soporte',
                    style: t.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.texto,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _AyudaTabs(
                value: _tab,
                onChanged: (v) => setState(() => _tab = v),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _tab == _AyudaTab.faq ? _buildFaq(context) : _buildChat(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaq(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = _filteredFaqs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _FaqTema.values.map((tema) {
              final selected = tema == _tema;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SoftChip(
                  text: tema.label,
                  selected: selected,
                  onTap: () => setState(() => _tema = tema),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    'Sin información por ahora 😄',
                    style: t.bodyMedium?.copyWith(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                      color: ColoresApp.textoSuave,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final Color accent = switch (item.tema) {
                      _FaqTema.tramites => ColoresApp.vino,
                      _FaqTema.documentos => ColoresApp.dorado,
                      _FaqTema.normativas => ColoresApp.cafe.withOpacity(0.85),
                      _FaqTema.soporte => ColoresApp.vino.withOpacity(0.85),
                      _FaqTema.portal => ColoresApp.dorado.withOpacity(0.85),
                    };
                    return _FaqAccordionCool(item: item, accent: accent);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChat(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            itemCount: _msgs.length + (_botTyping ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (_botTyping && i == _msgs.length) {
                return const _TypingBubble();
              }
              return _ChatBubble(
                msg: _msgs[i],
                onAction: _onBotQuickAction,
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _QuickPrompt(text: '¿Cómo hago un trámite?', onTap: () => _sendChat('¿Cómo realizo un trámite en línea?')),
              _QuickPrompt(text: 'No veo mi recibo', onTap: () => _sendChat('No veo mi recibo de nómina')),
              _QuickPrompt(text: 'Constancias y vigencias', onTap: () => _sendChat('Necesito una constancia vigente')),
              _QuickPrompt(text: 'Normativas', onTap: () => _sendChat('¿Dónde encuentro normativas vigentes?')),
              _QuickPrompt(text: 'Levantar reporte', onTap: () => _replyBot('Soporte', forcedIntent: _Intent.soporte)),
            ],
          ),
        ),

        const SizedBox(height: 10),

        _ChatInput(
          controller: _chatCtrl,
          onSend: () => _sendChat(_chatCtrl.text),
        ),
      ],
    );
  }
}

/* =======================================================================
  ROUTES (AJUSTA A TU APP)
======================================================================= */

class _Routes {
  static const servicios = '/servicios';
  static const tramites = '/tramites';
  static const documentos = '/documentos';
  static const recibos = '/recibos';
  static const citas = '/citas';
  static const perfil = '/perfil';
  static const reporteSoporte = '/soporte/reporte'; // ← cámbiala si tu ruta es otra
}

/* =======================================================================
  MODELOS CHAT PRO
======================================================================= */

enum _Intent { general, tramites, documentos, recibos, citas, acceso, normativas, soporte }

class _BotAnswer {
  final String text;
  final List<_ChatAction> actions;
  _BotAnswer({required this.text, this.actions = const []});
}

class _ChatAction {
  final String label;
  final IconData icon;
  final String? route;
  final _Intent? intent;

  const _ChatAction._({
    required this.label,
    required this.icon,
    this.route,
    this.intent,
  });

  factory _ChatAction.nav(String label, {required IconData icon, required String route}) =>
      _ChatAction._(label: label, icon: icon, route: route);

  factory _ChatAction.quick(String label, {required IconData icon, required _Intent intent}) =>
      _ChatAction._(label: label, icon: icon, intent: intent);
}

class _ChatMsg {
  final bool isUser;
  final String text;
  final List<_ChatAction> actions;

  _ChatMsg._(this.isUser, this.text, this.actions);

  factory _ChatMsg.user(String t) => _ChatMsg._(true, t, const []);
  factory _ChatMsg.bot({required String text, List<_ChatAction> actions = const []}) =>
      _ChatMsg._(false, text, actions);
}

/* =======================================================================
  TABS
======================================================================= */

enum _AyudaTab { faq, chat }

class _AyudaTabs extends StatelessWidget {
  final _AyudaTab value;
  final ValueChanged<_AyudaTab> onChanged;

  const _AyudaTabs({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColoresApp.inputBg.withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.bordeSuave),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              selected: value == _AyudaTab.faq,
              icon: PhosphorIcons.question(PhosphorIconsStyle.light),
              text: 'Preguntas',
              onTap: () => onChanged(_AyudaTab.faq),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabPill(
              selected: value == _AyudaTab.chat,
              icon: PhosphorIcons.chatCircleText(PhosphorIconsStyle.light),
              text: 'Chat',
              onTap: () => onChanged(_AyudaTab.chat),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _TabPill({
    required this.selected,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final Color accent = const Color.fromARGB(255, 0, 0, 0);

    return Material(
      color: selected ? accent.withOpacity(0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? accent : ColoresApp.textoSuave),
              const SizedBox(width: 8),
              Text(
                text,
                style: t.labelMedium?.copyWith(
                  fontSize: 11.4,
                  fontWeight: FontWeight.w900,
                  color: selected ? accent : ColoresApp.textoSuave,
                  letterSpacing: 0.12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =======================================================================
  FAQ
======================================================================= */

enum _FaqTema { portal, tramites, documentos, normativas, soporte }

extension on _FaqTema {
  String get label {
    switch (this) {
      case _FaqTema.portal:
        return 'Portal';
      case _FaqTema.tramites:
        return 'Trámites';
      case _FaqTema.documentos:
        return 'Documentos';
      case _FaqTema.normativas:
        return 'Normativas';
      case _FaqTema.soporte:
        return 'Soporte';
    }
  }
}

class _FaqItem {
  final _FaqTema tema;
  final IconData icon;
  final String pregunta;
  final String respuesta;

  _FaqItem({
    required this.tema,
    required this.icon,
    required this.pregunta,
    required this.respuesta,
  });
}

class _SoftChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SoftChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = ColoresApp.vino;

    return Material(
      color: selected ? accent.withOpacity(0.10) : ColoresApp.inputBg.withOpacity(0.75),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? accent.withOpacity(0.26) : ColoresApp.bordeSuave),
          ),
          child: Text(
            text,
            style: t.labelMedium?.copyWith(
              fontSize: 11.2,
              fontWeight: FontWeight.w900,
              color: selected ? accent : ColoresApp.textoSuave,
              letterSpacing: 0.12,
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqAccordionCool extends StatefulWidget {
  final _FaqItem item;
  final Color accent;

  const _FaqAccordionCool({
    required this.item,
    required this.accent,
  });

  @override
  State<_FaqAccordionCool> createState() => _FaqAccordionCoolState();
}

class _FaqAccordionCoolState extends State<_FaqAccordionCool> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final Color accent = widget.accent;
    final Color border = _open ? accent.withOpacity(0.28) : ColoresApp.bordeSuave;
    final Color bgIcon = accent.withOpacity(0.10);

    return Material(
      color: ColoresApp.blanco,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgIcon,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.20)),
                    ),
                    child: Icon(widget.item.icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.pregunta,
                      style: t.bodyMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w900,
                        color: ColoresApp.texto,
                        letterSpacing: 0.12,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOut,
                    turns: _open ? 0.25 : 0.0,
                    child: Icon(
                      PhosphorIcons.caretRight(PhosphorIconsStyle.light),
                      size: 18,
                      color: ColoresApp.textoSuave.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: ColoresApp.inputBg.withOpacity(0.60),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ColoresApp.bordeSuave),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.item.respuesta,
                                style: t.bodySmall?.copyWith(
                                  fontSize: 11.8,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: ColoresApp.textoSuave,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =======================================================================
  CHAT UI
======================================================================= */

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: ColoresApp.inputBg.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.bordeSuave),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Escribiendo…'),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  final void Function(_ChatAction) onAction;

  const _ChatBubble({required this.msg, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final bg = msg.isUser ? ColoresApp.vino.withOpacity(0.10) : ColoresApp.inputBg.withOpacity(0.75);

    final bd = msg.isUser ? ColoresApp.vino.withOpacity(0.22) : ColoresApp.bordeSuave;

    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: t.bodySmall?.copyWith(
                fontSize: 12.0,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: ColoresApp.texto,
              ),
            ),
            if (!msg.isUser && msg.actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.actions.map((a) {
                  return Material(
                    color: ColoresApp.blanco,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: () => onAction(a),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: ColoresApp.bordeSuave),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(a.icon, size: 16, color: ColoresApp.texto),
                            const SizedBox(width: 8),
                            Text(
                              a.label,
                              style: t.labelMedium?.copyWith(
                                fontSize: 11.2,
                                fontWeight: FontWeight.w900,
                                color: ColoresApp.texto,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickPrompt({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: ColoresApp.dorado.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ColoresApp.dorado.withOpacity(0.22)),
            ),
            child: Text(
              text,
              style: t.labelMedium?.copyWith(
                fontSize: 11.1,
                fontWeight: FontWeight.w900,
                color: ColoresApp.dorado,
                letterSpacing: 0.10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: ColoresApp.blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColoresApp.bordeSuave),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: t.bodyMedium?.copyWith(
                fontSize: 12.6,
                fontWeight: FontWeight.w600,
                color: ColoresApp.texto,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Escribe tu duda…',
                hintStyle: t.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: ColoresApp.textoSuave,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: ColoresApp.vino.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ColoresApp.vino.withOpacity(0.25)),
                ),
                child: Icon(
                  PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.light),
                  size: 18,
                  color: ColoresApp.vino,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
