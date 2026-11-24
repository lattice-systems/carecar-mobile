import 'package:flutter/foundation.dart';

import 'fallo.dart';

/// Base de los repositorios · V2-T01.08, criterio 2.
///
/// Garantiza **la regla que hace util a todo lo demas**: de un repositorio sale
/// un dato o sale un [Fallo]. La unica excepcion son los `Error`, que son bugs
/// nuestros y viajan tal cual —ver [pedir]—; de ellos se encarga
/// [VistaAsincrona] al pintar, asi que la vista tampoco los ve sin tipar.
///
/// Se usa envolviendo la llamada completa, no solo la peticion de red:
///
/// ```dart
/// class RepositorioCatalogoApi
///     with RepositorioBase
///     implements RepositorioCatalogo {
///   const RepositorioCatalogoApi(this._api);
///
///   final CarecarApi _api;
///
///   @override
///   Future<List<ModeloVigente>> modelos() => pedir(() async {
///     final dto = await _api.catalogo();
///     return dto.map(_aModelo).toList(growable: false);
///   });
/// }
/// ```
///
/// El `map` va **dentro** a proposito. El cliente ya tipa sus propios errores,
/// asi que envolver solo `_api.catalogo()` no agregaria nada; lo que hoy no
/// esta protegido es la traduccion del DTO, que revienta con un `TypeError`
/// cuando el backend cambia un campo. Ese es el error que hoy llega a la
/// pantalla sin tipar y se pinta como «ocurrio un error».
mixin RepositorioBase {
  /// Corre [hacer] y convierte cualquier falla en un [Fallo].
  ///
  /// Una [Fallo] que ya venia tipada sale **identica**, no envuelta: quien la
  /// recibe decide por su clase, y envolverla la perderia. Por eso tambien es
  /// seguro que un repositorio llame a otro sin apilar conversiones.
  ///
  /// La pila del error original se conserva con [Error.throwWithStackTrace].
  /// Sin eso, todas las fallas apuntarian a este archivo y depurar el
  /// `TypeError` de un mapeo seria adivinar.
  ///
  /// **Los `Error` se propagan tal cual**, sin convertirse. Un `TypeError` del
  /// mapeo o un indice fuera de rango no son fallas previstas: son bugs
  /// nuestros, y convertirlos en `ExcepcionApi` tendria dos efectos malos.
  /// Primero, el reporte de fallos veria «error del servidor» en vez del tipo
  /// real. Segundo, y peor: Riverpod 3 **no** reintenta los `Error` pero si
  /// las `Exception`, asi que convertirlos haria que un bug se ejecutara
  /// cuatro veces en lugar de una.
  ///
  /// La pantalla sigue protegida igual: [VistaAsincrona] convierte con
  /// [falloDe] al pintar, asi que la vista nunca ve un error sin tipar y nunca
  /// se filtra detalle tecnico. La garantia que importa se mantiene; lo que
  /// cambia es que el bug viaja con su identidad hasta la bitacora.
  @protected
  Future<T> pedir<T>(Future<T> Function() hacer) async {
    try {
      return await hacer();
    } on Error {
      rethrow;
    } catch (error, pila) {
      Error.throwWithStackTrace(falloDe(error), pila);
    }
  }
}
