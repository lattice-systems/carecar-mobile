import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:carecar_mobile/modulos/privacidad/dominio/arco.dart';

/// Repositorio falso de los derechos ARCO: responde lo que se le asigna,
/// guarda lo que se pide y espera a las pruebas cuando se le pide.
class RepositorioArcoFalso implements RepositorioArco {
  /// Respuestas de `solicitudes`, una por llamada y en orden; la última se
  /// repite. Un [FalloArco] se lanza en vez de devolverse.
  final listas = <Object>[];
  int lecturas = 0;

  /// Si se asigna, leer la lista espera a que se complete.
  Completer<void>? esperaAlListar;

  /// Lo que devuelve `pedirAcceso`, o el fallo si es [FalloArco].
  Object? alPedir;
  int pedidos = 0;

  /// Si se asigna, pedir espera a que se complete.
  Completer<void>? esperaAlPedir;

  /// Lo que devuelve `descargar`, o el fallo si es [FalloArco].
  Object archivo = Uint8List.fromList(utf8.encode('{"cliente":{}}'));
  final descargados = <int>[];

  /// Si se asigna, descargar espera a que se complete.
  Completer<void>? esperaAlDescargar;

  @override
  Future<List<SolicitudDeArco>> solicitudes() async {
    final i = lecturas < listas.length ? lecturas : listas.length - 1;
    lecturas++;
    await esperaAlListar?.future;
    final respuesta = listas.isEmpty ? <SolicitudDeArco>[] : listas[i];
    if (respuesta is FalloArco) throw respuesta;
    return respuesta as List<SolicitudDeArco>;
  }

  @override
  Future<SolicitudDeArco> pedirAcceso() async {
    pedidos++;
    await esperaAlPedir?.future;
    final respuesta = alPedir;
    if (respuesta is FalloArco) throw respuesta;
    return respuesta! as SolicitudDeArco;
  }

  /// Lo que hace `cancelarCuenta`: nada si es nulo, o el fallo si es [FalloArco].
  Object? alCancelar;
  final cancelaciones = <String>[];

  /// Si se asigna, cancelar espera a que se complete.
  Completer<void>? esperaAlCancelar;

  @override
  Future<void> cancelarCuenta(String contrasena) async {
    cancelaciones.add(contrasena);
    await esperaAlCancelar?.future;
    final respuesta = alCancelar;
    if (respuesta is FalloArco) throw respuesta;
  }

  @override
  Future<Uint8List> descargar(int solicitudId) async {
    descargados.add(solicitudId);
    await esperaAlDescargar?.future;
    final respuesta = archivo;
    if (respuesta is FalloArco) throw respuesta;
    return respuesta as Uint8List;
  }
}

SolicitudDeArco solicitudArco(
  int id,
  EstadoArco estado, {
  TipoArco tipo = TipoArco.acceso,
  DateTime? creada,
  DateTime? resuelta,
  DateTime? vence,
}) => SolicitudDeArco(
  id: id,
  tipo: tipo,
  estado: estado,
  creadaEn: creada ?? DateTime.utc(2026, 11, 25, 18),
  resueltaEn: resuelta,
  venceEn: vence,
);
