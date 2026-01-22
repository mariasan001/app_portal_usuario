import '../domain/servicio_detalle.dart';

final serviciosDetallesMock = <String, ServicioDetalle>{
  // =======================
  // CONSULTAS
  // =======================
  'c_fump': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Consulta informativa del FUMP. Muestra datos protegidos y lectura segura.',
    requisitos: [
      'Sesión iniciada en el portal',
      'Validación de identidad (si aplica)',
    ],
    pasos: [
      'Ingresa a la consulta',
      'Selecciona el periodo a consultar',
      'Visualiza la información disponible',
      'Descarga/guarda (si está habilitado)',
    ],
    accionLabel: 'Abrir consulta',
  ),

  'c_puntualidad': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Consulta de puntualidad y asistencia para control personal.',
    requisitos: [
      'Sesión iniciada en el portal',
    ],
    pasos: [
      'Selecciona el periodo',
      'Revisa incidencias y totales',
      'Guarda la información si lo necesitas',
    ],
    accionLabel: 'Abrir consulta',
  ),

  // =======================
  // TRÁMITES DIGITALES
  // =======================
  't_no_adeudo': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Genera una constancia de no adeudo para validar que no tienes pendientes registrados.',
    requisitos: [
      'CURP y número de servidor público',
      'Correo activo para notificaciones',
      'Documentos digitales (si aplica)',
    ],
    pasos: [
      'Confirma tus datos',
      'Adjunta documentos requeridos',
      'Envía la solicitud',
      'Guarda tu folio para seguimiento',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_reexpedicion_pagos': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Solicitud para reexpedir un pago. Genera folio y permite seguimiento.',
    requisitos: [
      'Número de servidor público',
      'Periodo/fecha del pago a reexpedir',
      'Documento soporte (si aplica)',
    ],
    pasos: [
      'Confirma tus datos',
      'Captura la información del pago',
      'Adjunta documento soporte (si aplica)',
      'Envía y conserva el folio',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_finiquito': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Trámite de finiquito con carga de documentación para validación.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento de término/baja (si aplica)',
      'Último comprobante de percepciones (si aplica)',
    ],
    pasos: [
      'Confirma tus datos',
      'Adjunta documentos',
      'Revisa el resumen',
      'Envía y guarda el folio',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  't_historico_laboral': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion: 'Solicitud de histórico laboral (constancia). Puede generar folio para seguimiento.',
    requisitos: [
      'Identificación oficial vigente',
      'Sesión iniciada en el portal',
    ],
    pasos: [
      'Confirma tus datos',
      'Solicita el histórico',
      'Espera validación (si aplica)',
      'Descarga o recibe notificación',
    ],
    accionLabel: 'Iniciar trámite',
  ),

  // =======================
  // TRÁMITES PRESENCIALES
  // =======================
  't_quinquenio': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion: 'Solicitud de reconocimiento por antigüedad. Requiere validación institucional.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento de nombramiento/antigüedad',
      'Último comprobante de percepciones (si aplica)',
    ],
    pasos: [
      'Reúne tus documentos',
      'Agenda tu cita',
      'Acude a ventanilla y entrega requisitos',
      'Conserva tu folio/acuse',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Ventanilla de Prestaciones (Mock)',
    ubicacionDireccion: 'Centro Administrativo (Mock), Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 123'],
    correos: ['prestaciones@ejemplo.gob.mx'],
  ),

  't_foremex': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion: 'Gestión relacionada a FOREMEX. Requiere revisión documental en ventanilla.',
    requisitos: [
      'Identificación oficial vigente',
      'Solicitud o formato correspondiente',
      'Comprobante o documento soporte',
    ],
    pasos: [
      'Reúne documentos',
      'Agenda tu cita',
      'Acude a ventanilla',
      'Recibe folio/acuse',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Atención a Prestaciones (Mock)',
    ubicacionDireccion: 'Módulo de Atención (Mock), Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 210'],
    correos: ['atencion@ejemplo.gob.mx'],
  ),

  't_prima_antiguedad': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion: 'Solicitud de prima de antigüedad. Proceso con requisitos y validación institucional.',
    requisitos: [
      'Identificación oficial vigente',
      'Documento que acredite antigüedad',
      'Último comprobante de percepciones (si aplica)',
    ],
    pasos: [
      'Reúne documentos',
      'Agenda tu cita',
      'Entrega requisitos en ventanilla',
      'Conserva tu folio/acuse',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Ventanilla de Remuneraciones (Mock)',
    ubicacionDireccion: 'Centro Administrativo (Mock), Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 305'],
    correos: ['remuneraciones@ejemplo.gob.mx'],
  ),

  't_seguro_vida': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion: 'Gestión de seguro de vida. Requiere validación y entrega documental.',
    requisitos: [
      'Identificación oficial vigente',
      'Documentación del caso (según aplique)',
      'Formato de solicitud (si aplica)',
    ],
    pasos: [
      'Reúne documentos',
      'Agenda tu cita',
      'Acude a ventanilla',
      'Recibe folio/acuse',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Seguro de Vida (Mock)',
    ubicacionDireccion: 'Módulo de Atención (Mock), Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 410'],
    correos: ['segurovida@ejemplo.gob.mx'],
  ),

  't_jubilacion': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion: 'Trámite de jubilación con seguimiento por estatus (posteriormente en “Mis trámites”).',
    requisitos: [
      'Identificación oficial vigente',
      'Documentación requerida (según el caso)',
      'Comprobantes/constancias (si aplica)',
    ],
    pasos: [
      'Reúne documentos',
      'Agenda tu cita',
      'Entrega requisitos en ventanilla',
      'Conserva folio para seguimiento',
    ],
    accionLabel: 'Agendar cita',
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Jubilaciones (Mock)',
    ubicacionDireccion: 'Centro Administrativo (Mock), Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 520'],
    correos: ['jubilaciones@ejemplo.gob.mx'],
  ),
};
