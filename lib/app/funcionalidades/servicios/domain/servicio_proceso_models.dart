import 'package:flutter/material.dart';

class ServidorPublicoMock {
  final String nombreCompleto;
  final String numeroEmpleado;
  final String correo;
  final String telefono;
  final String cargo;
  final String adscripcion;
  final String dependencia;

  const ServidorPublicoMock({
    required this.nombreCompleto,
    required this.numeroEmpleado,
    required this.correo,
    required this.telefono,
    required this.cargo,
    required this.adscripcion,
    required this.dependencia,
  });
}

class DocReq {
  final String id;
  final String label;
  final String? hint;
  final String? attachedName;

  const DocReq({
    required this.id,
    required this.label,
    this.hint,
    this.attachedName,
  });

  DocReq copyWith({String? attachedName}) {
    return DocReq(
      id: id,
      label: label,
      hint: hint,
      attachedName: attachedName,
    );
  }
}

class ChipData {
  final String text;
  final Color bg;
  final Color bd;
  final Color fg;

  const ChipData({
    required this.text,
    required this.bg,
    required this.bd,
    required this.fg,
  });
}
