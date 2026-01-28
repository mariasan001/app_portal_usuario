import 'dart:async';

import 'package:portal_servicios_usuario/app/funcionalidades/mas/perfil/perfil_models.dart';

import 'perfil_repository.dart';

class PerfilRepositoryMock implements PerfilRepository {
  PerfilRepositoryMock._();
  static final instance = PerfilRepositoryMock._();

  PerfilServidorPublico _store = PerfilServidorPublico(
    numeroServidor: '123456',
    nombre: 'María',
    apellidoPaterno: 'San',
    apellidoMaterno: 'Gómez',
    rfc: 'SAGM900101ABC',
    curp: 'SAGM900101MDFXXX09',
    adscripcion: 'Dirección General (Mock)',
    puesto: 'Analista',
    correo: 'maria.san@ejemplo.gob.mx',
    telefono: '7221234567',
    updatedAt: DateTime.now(),
  );

  Future<T> _delay<T>(T v, [int ms = 180]) async {
    await Future.delayed(Duration(milliseconds: ms));
    return v;
  }

  @override
  Future<PerfilServidorPublico> obtenerPerfil() async {
    return _delay(_store, 220);
  }

  @override
  Future<PerfilServidorPublico> actualizarContacto(ActualizarContactoPayload payload) async {
    // mock update
    _store = _store.copyWith(
      correo: payload.correo.trim(),
      telefono: payload.telefono.trim(),
      updatedAt: DateTime.now(),
    );
    return _delay(_store, 260);
  }
}
