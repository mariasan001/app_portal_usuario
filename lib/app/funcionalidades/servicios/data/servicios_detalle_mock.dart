import '../domain/servicio_detalle.dart';

final serviciosDetallesMock = <String, ServicioDetalle>{
  /// =====================
  /// CONSULTAS (DIGITAL)
  /// =====================

  'c_fump': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Consulta informativa del FUMP. Permite revisar información general protegida y visualizar datos de forma segura.',
    requisitos: [
      'Sesión iniciada en el portal',
      'Conexión a internet estable',
      'Validación de identidad (si aplica)',
    ],
    pasos: [
      'Ingresa a la consulta',
      'Selecciona el periodo a consultar',
      'Visualiza el resumen disponible',
      'Descarga o guarda (si está habilitado)',
    ],
    accionLabel: 'Abrir consulta',
  ),

  'c_puntualidad': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Consulta tu resumen de puntualidad y asistencia por periodos. Visualización informativa para control personal.',
    requisitos: [
      'Sesión iniciada en el portal',
      'Permisos de consulta habilitados',
      'Validación de identidad (si aplica)',
    ],
    pasos: [
      'Ingresa a la consulta',
      'Elige el periodo o rango de fechas',
      'Revisa el resumen de incidencias (si aplica)',
      'Descarga o guarda (si está habilitado)',
    ],
    accionLabel: 'Abrir consulta',
  ),

  /// =====================
  /// TRÁMITES (DIGITAL)
  /// =====================

  't_no_adeudo': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Genera una constancia de no adeudo para validar que no tienes pendientes registrados.',
    requisitos: [
      'CURP y número de servidor público',
      'Correo activo para notificaciones',
      'Validación de identidad (si aplica)',
    ],
    pasos: [
      'Revisa requisitos y confirma tus datos',
      'Inicia el trámite y captura la información solicitada',
      'Adjunta documentación si el sistema lo solicita',
      'Envía y guarda tu folio para seguimiento',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_reexpedicion_pagos': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Solicita la reexpedición de pagos cuando exista extravío, inconsistencias o necesidad de reemisión. Se genera folio para seguimiento.',
    requisitos: [
      'Número de servidor público y CURP',
      'Periodo/fecha del pago a reexpedir',
      'Motivo de la solicitud (descripción breve)',
      'Correo activo para notificaciones',
      'Evidencia de soporte (si aplica)',
    ],
    pasos: [
      'Revisa requisitos y selecciona el periodo del pago',
      'Captura el motivo de la reexpedición',
      'Adjunta evidencia si el sistema lo solicita',
      'Envía la solicitud y guarda tu folio',
      'Da seguimiento en “Mis trámites”',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_finiquito': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Solicitud de finiquito. Permite iniciar el proceso, adjuntar documentación y recibir notificaciones del avance.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento de baja/terminación (si aplica)',
      'CLABE interbancaria (si aplica)',
      'Correo activo para notificaciones',
      'Documentación adicional según el caso',
    ],
    pasos: [
      'Inicia el trámite y confirma tus datos',
      'Captura la información requerida',
      'Adjunta documentos solicitados',
      'Envía la solicitud y guarda tu folio',
      'Espera validación y notificación del resultado',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_foremex': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Trámite relacionado con FOREMEX. Inicia la solicitud y adjunta requisitos para revisión institucional.',
    requisitos: [
      'Número de servidor público y CURP',
      'Identificación oficial vigente',
      'Comprobante/documento relacionado al trámite (según el caso)',
      'Correo activo para notificaciones',
    ],
    pasos: [
      'Revisa requisitos y confirma tu información',
      'Captura los datos solicitados',
      'Adjunta documentación requerida',
      'Envía la solicitud y guarda tu folio',
      'Da seguimiento en “Mis trámites”',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_historico_laboral': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Solicita una constancia o histórico laboral para fines administrativos. Se genera folio y se notifica el resultado.',
    requisitos: [
      'Número de servidor público y CURP',
      'Motivo de solicitud (si aplica)',
      'Correo activo para notificaciones',
      'Identificación oficial (si el sistema lo solicita)',
    ],
    pasos: [
      'Inicia el trámite y confirma tus datos',
      'Selecciona el tipo de constancia/histórico requerido',
      'Captura información adicional si aplica',
      'Envía y guarda tu folio',
      'Descarga la constancia cuando esté disponible',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  /// =====================
  /// TRÁMITES (PRESENCIAL)
  /// (Tu UI mostrará “Agendar cita” cuando haya route)
  /// =====================

  't_quinquenio': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion:
        'Solicitud para reconocimiento por antigüedad. Puede requerir validación institucional y cotejo documental.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento de antigüedad/nombramiento',
      'Último comprobante de percepciones (si aplica)',
      'Formato/solicitud firmada (si aplica)',
    ],
    pasos: [
      'Reúne tus documentos',
      'Agenda tu cita o acude a la ventanilla correspondiente',
      'Entrega requisitos y solicita acuse',
      'Da seguimiento con tu número de solicitud',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Ventanilla de Prestaciones',
    ubicacionDireccion: 'Toluca, Estado de México (Dirección referencial para mock).',
    telefonos: ['(722) 000 0000 ext. 123'],
    correos: ['prestaciones@ejemplo.gob.mx'],
  ),

  't_prima_antiguedad': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion:
        'Solicitud de prima de antigüedad. Trámite sujeto a validación documental y revisión de historial laboral.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento que acredite antigüedad',
      'Constancia de situación laboral (si aplica)',
      'Formato de solicitud firmado',
    ],
    pasos: [
      'Reúne tus requisitos y documentación',
      'Agenda tu cita o acude a la ventanilla indicada',
      'Entrega documentos y solicita acuse',
      'Da seguimiento con el folio o número de recepción',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Módulo de Remuneraciones',
    ubicacionDireccion: 'Toluca, Estado de México (Dirección referencial para mock).',
    telefonos: ['(722) 000 0000 ext. 210'],
    correos: ['remuneraciones@ejemplo.gob.mx'],
  ),

  't_seguro_vida': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion:
        'Gestión relacionada con seguro de vida. Requiere cotejo de documentos y atención de acuerdo al caso.',
    requisitos: [
      'Identificación oficial vigente',
      'Documentación del caso (según aplique)',
      'Formato de solicitud firmado (si aplica)',
      'Medio de contacto (correo o teléfono)',
    ],
    pasos: [
      'Reúne tus documentos',
      'Agenda cita o acude al módulo de atención',
      'Entrega requisitos y recibe orientación del proceso',
      'Solicita acuse o número de atención para seguimiento',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Módulo de Seguros y Prestaciones',
    ubicacionDireccion: 'Toluca, Estado de México (Dirección referencial para mock).',
    telefonos: ['(722) 000 0000 ext. 330'],
    correos: ['seguros@ejemplo.gob.mx'],
  ),

  't_jubilacion': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion:
        'Trámite de jubilación. Proceso administrativo que requiere validación documental y revisión de historial.',
    requisitos: [
      'Identificación oficial vigente',
      'Histórico laboral / constancias (si aplica)',
      'Documentación soporte (según el caso)',
      'Formato de solicitud firmado',
    ],
    pasos: [
      'Reúne tus requisitos y documentación',
      'Agenda cita o acude al módulo de jubilaciones',
      'Entrega requisitos y solicita acuse',
      'Da seguimiento conforme a la orientación del módulo',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Módulo de Jubilaciones y Pensiones',
    ubicacionDireccion: 'Toluca, Estado de México (Dirección referencial para mock).',
    telefonos: ['(722) 000 0000 ext. 450'],
    correos: ['jubilaciones@ejemplo.gob.mx'],
  ),
};
