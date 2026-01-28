import 'package:flutter/foundation.dart';

@immutable
class PerfilServidorPublico {
  const PerfilServidorPublico({
    required this.numeroServidor,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.rfc,
    required this.curp,
    required this.adscripcion,
    required this.puesto,
    required this.correo,
    required this.telefono,
    required this.updatedAt,
  });

  final String numeroServidor; // 🔒 no editable
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;

  final String rfc; // 🔒
  final String curp; // 🔒
  final String adscripcion; // 🔒
  final String puesto; // 🔒

  final String correo; // ✅ editable
  final String telefono; // ✅ editable

  final DateTime updatedAt;

  String get nombreCompleto =>
      [nombre, apellidoPaterno, apellidoMaterno].where((x) => x.trim().isNotEmpty).join(' ');

  PerfilServidorPublico copyWith({
    String? correo,
    String? telefono,
    DateTime? updatedAt,
  }) {
    return PerfilServidorPublico(
      numeroServidor: numeroServidor,
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      rfc: rfc,
      curp: curp,
      adscripcion: adscripcion,
      puesto: puesto,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ActualizarContactoPayload {
  const ActualizarContactoPayload({
    required this.correo,
    required this.telefono,
  });

  final String correo;
  final String telefono;
}
