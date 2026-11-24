import 'dart:convert';
import 'dart:typed_data';

import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/orden_taller.dart';
import '../dominio/repositorio_taller.dart';
import 'lectura_taller.dart';

/// `GET /ordenes/activas`, `GET /ordenes/{id}` y
/// `POST /ordenes/{id}/adicionales/{aid}/respuesta` con el cliente del nucleo.
/// Sin cache: el estado de la orden cambia mientras el auto esta en el taller.
class RepositorioTallerApi implements RepositorioTaller {
  RepositorioTallerApi(this._cliente)
    : _lectura = LecturaTaller(_cliente.config.base);

  final ApiCliente _cliente;
  final LecturaTaller _lectura;

  @override
  Future<List<OrdenEnCurso>> enCurso() =>
      _cliente.obtenerLista('/ordenes/activas', _lectura.enCurso);

  @override
  Future<OrdenEnVivo> orden(int ordenId) =>
      _cliente.obtener('/ordenes/$ordenId', _lectura.orden);

  @override
  Future<OrdenEnVivo> responder({
    required int ordenId,
    required int adicionalId,
    required bool aprobado,
    required Uint8List firmaPng,
  }) async {
    try {
      return await _cliente.enviar(
        '/ordenes/$ordenId/adicionales/$adicionalId/respuesta',
        cuerpo: {'aprobado': aprobado, 'firma': base64Encode(firmaPng)},
        leer: _lectura.orden,
      );
    } on Conflicto catch (conflicto) {
      switch (conflicto.problema?.codigo) {
        case CodigoProblema.adicionalYaRespondido:
          throw const AdicionalYaRespondido();
        case CodigoProblema.ordenCerrada:
          throw const OrdenCerrada();
        default:
          rethrow;
      }
    }
  }
}
