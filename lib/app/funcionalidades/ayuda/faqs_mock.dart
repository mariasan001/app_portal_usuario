import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:portal_servicios_usuario/app/funcionalidades/ayuda/domain/faq_item.dart';

final faqsMock = <FaqItem>[
  FaqItem(
    id: 'p1',
    tema: FaqTema.portal,
    icon: PhosphorIcons.info(PhosphorIconsStyle.light),
    pregunta: '¿Qué puedo consultar en este portal?',
    respuesta:
        'Puedes consultar recibos, trámites y consultas, documentos/constancias, notificaciones y tu información de perfil.',
  ),
  FaqItem(
    id: 't1',
    tema: FaqTema.tramites,
    icon: PhosphorIcons.listChecks(PhosphorIconsStyle.light),
    pregunta: '¿Cómo realizo un trámite en línea?',
    respuesta:
        'Entra a Servicios, elige el trámite, revisa requisitos y sigue los pasos hasta enviar. El estatus se verá en Mis trámites.',
  ),
  FaqItem(
    id: 't2',
    tema: FaqTema.tramites,
    icon: PhosphorIcons.clock(PhosphorIconsStyle.light),
    pregunta: '¿Puedo consultar mis trámites anteriores o en proceso?',
    respuesta:
        'Sí. En Mis trámites verás en proceso y concluidos, con su estatus e historial.',
  ),
  FaqItem(
    id: 'd1',
    tema: FaqTema.documentos,
    icon: PhosphorIcons.fileText(PhosphorIconsStyle.light),
    pregunta: '¿Dónde encuentro normativas y lineamientos vigentes?',
    respuesta:
        'En Mis documentos podrás ver constancias y referencias vigentes. Cuando se conecte la fuente oficial, podrás consultar normativas desde aquí.',
  ),
  FaqItem(
    id: 'd2',
    tema: FaqTema.documentos,
    icon: PhosphorIcons.sealCheck(PhosphorIconsStyle.light),
    pregunta: '¿Qué significa “Vigente”, “Pendiente” o “Vencido”?',
    respuesta:
        'Vigente: válido. Pendiente: en generación/validación. Vencido: requiere actualización o un nuevo trámite.',
  ),
  FaqItem(
    id: 'c1',
    tema: FaqTema.cuenta,
    icon: PhosphorIcons.lockKey(PhosphorIconsStyle.light),
    pregunta: 'Olvidé mi contraseña, ¿cómo recupero el acceso?',
    respuesta:
        'Usa Recuperar contraseña. Te llegará un token al correo y podrás crear una nueva contraseña.',
  ),
  FaqItem(
    id: 'c2',
    tema: FaqTema.cuenta,
    icon: PhosphorIcons.envelopeSimple(PhosphorIconsStyle.light),
    pregunta: 'No me llega el token al correo, ¿qué hago?',
    respuesta:
        'Revisa spam, valida tu correo, espera unos minutos y reintenta. Si falla, contacta soporte desde el chat.',
  ),
  FaqItem(
    id: 's1',
    tema: FaqTema.soporte,
    icon: PhosphorIcons.bug(PhosphorIconsStyle.light),
    pregunta: '¿Cómo reporto un problema técnico?',
    respuesta:
        'En Ayuda y soporte puedes usar el Chat. Describe qué pasó, en qué pantalla, y si puedes adjunta una captura (cuando se conecte).',
  ),
  // 👉 agrega más copiando el patrón
];
