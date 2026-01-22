import '../domain/servicio_detalle.dart';

final serviciosDetallesMock = <String, ServicioDetalle>{
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

  't_quinquenio': const ServicioDetalle(
    canal: ServicioCanal.presencial,
    descripcion:
        'Solicitud para reconocimiento por antigüedad. Puede requerir validación institucional.',
    requisitos: [
      'Identificación oficial vigente',
      'Último comprobante de percepciones (si aplica)',
      'Documento de antigüedad/nombramiento',
    ],
    pasos: [
      'Reúne tus documentos',
      'Acude a la ventanilla correspondiente',
      'Entrega requisitos y solicita acuse',
      'Da seguimiento con tu número de solicitud',
    ],
    horario: 'Lun a Vie • 09:00 a 15:00',
    ubicacionNombre: 'Ventanilla de Prestaciones',
    ubicacionDireccion: 'Av. Gobierno #123, Col. Centro, Toluca, EdoMéx.',
    telefonos: ['(722) 000 0000 ext. 123'],
    correos: ['prestaciones@edomex.gob.mx'],
  ),

  'c_fump': const ServicioDetalle(
    canal: ServicioCanal.digital,
    descripcion:
        'Consulta informativa de tu FUMP. Muestra datos generales protegidos y lectura segura.',
    requisitos: [
      'Sesión iniciada en el portal',
      'Validación de identidad (si aplica)',
    ],
    pasos: [
      'Ingresa a la consulta',
      'Selecciona el periodo a consultar',
      'Visualiza y descarga (si está habilitado)',
    ],
    accionLabel: 'Abrir consulta',
  ),
};
