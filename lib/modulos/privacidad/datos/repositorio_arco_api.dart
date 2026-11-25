import 'dart:typed_data';

import '../../../api/carecar_api.dart';
import '../../../api/excepciones.dart';
import '../../../api/modelos/arco.dart';
import '../dominio/arco.dart';

/// [RepositorioArco] contra el contrato 2.15.0 (V2-M22.02 y V2-M22.03).
class RepositorioArcoApi implements RepositorioArco {
  const RepositorioArcoApi(this._api);

  final CarecarApi _api;

  @override
  Future<List<SolicitudDeArco>> solicitudes() => _traducir(() async {
    final lista = await _api.misSolicitudesArco();
    // Una solicitud de un tipo que esta version no conoce se descarta: la app
    // solo sabe mostrar los suyos.
    return [for (final s in lista) ?_solicitud(s)];
  });

  @override
  Future<SolicitudDeArco> pedirAcceso() => _traducir(() async {
    final s = _solicitud(await _api.pedirAccesoArco());
    if (s == null) throw const ArcoNoDisponible();
    return s;
  });

  @override
  Future<Uint8List> descargar(int solicitudId) => _traducir(
    () => _api.descargarArchivoArco(solicitudId),
    noEncontrado: const ArchivoArcoNoDisponible(),
  );

  @override
  Future<void> cancelarCuenta(String contrasena) => _traducir(() async {
    try {
      await _api.cancelarCuentaArco(contrasena);
    } on DatosInvalidos {
      // El servidor responde 400 y no 401 a proposito: un 401 se leeria como
      // sesion vencida y cerraria la sesion sin decirle nada a la persona.
      throw const ContrasenaIncorrecta();
    } on DemasiadosIntentos catch (e) {
      final segundos = e.esperaSegundos;
      throw CancelacionBloqueada(
        segundos == null || segundos <= 0 ? null : Duration(seconds: segundos),
      );
    } on CuentaDesactivada {
      throw const CuentaYaCerrada();
    }
  });

  /// [noEncontrado] es lo que significa un 404 en esa operacion: solo al
  /// descargar quiere decir «ya no esta».
  static Future<T> _traducir<T>(
    Future<T> Function() llamada, {
    FalloArco noEncontrado = const ArcoNoDisponible(),
  }) async {
    try {
      return await llamada();
    } on SinConexion {
      throw const ArcoSinConexion();
    } on NoEncontrado {
      throw noEncontrado;
    } on ExcepcionApi {
      throw const ArcoNoDisponible();
    }
  }

  static SolicitudDeArco? _solicitud(SolicitudArco s) {
    final tipo = switch (s.tipo) {
      'ACCESO' => TipoArco.acceso,
      'RECTIFICACION' => TipoArco.rectificacion,
      'CANCELACION' => TipoArco.cancelacion,
      'OPOSICION' => TipoArco.oposicion,
      _ => null,
    };
    if (tipo == null) return null;
    return SolicitudDeArco(
      id: s.id,
      tipo: tipo,
      // Un estado nuevo se trata como fallido: se puede volver a pedir.
      estado: switch (s.estado) {
        'PENDIENTE' => EstadoArco.pendiente,
        'RESUELTA' => EstadoArco.resuelta,
        'VENCIDA' => EstadoArco.vencida,
        _ => EstadoArco.fallida,
      },
      creadaEn: s.creadaEn,
      resueltaEn: s.resueltaEn,
      venceEn: s.venceEn,
    );
  }
}
