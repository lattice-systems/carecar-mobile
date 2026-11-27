import '../../../api/excepciones.dart';
import '../../../api/modelos/problema.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../dominio/pagos.dart';
import '../dominio/repositorio_pagos.dart';
import 'lectura_pagos.dart';

/// Pagos, mis pagos y tarjetas guardadas con el cliente del nucleo. Los 409
/// con `ORDEN_NO_PAGABLE`, `PAGO_EN_CURSO` y `PAGO_NO_PENDIENTE` llegan como
/// [PagoRechazado]; lo demas pasa tal cual.
class RepositorioPagosApi implements RepositorioPagos {
  const RepositorioPagosApi(this._cliente);

  final ApiCliente _cliente;

  static const _lectura = LecturaPagos();

  @override
  Future<OrdenPorPagar> orden(int ordenId) =>
      _cliente.obtener('/servicios/$ordenId', _lectura.orden);

  @override
  Future<Pago> pagar(
    int ordenId, {
    required String llave,
    required MedioElegido medio,
    int? perfilFiscalId,
  }) => _traducir(
    () => _cliente.enviar(
      '/ordenes/$ordenId/pagos',
      cuerpo: {
        ...switch (medio) {
          TarjetaNueva(
            :final token,
            :final mesVence,
            :final anioVence,
            :final guardar,
          ) =>
            {
              'tarjeta': {
                'token': token,
                'mesVence': mesVence,
                'anioVence': anioVence,
              },
              'guardarTarjeta': guardar,
            },
          TarjetaGuardada(:final metodoPagoId) => {
            'metodoPagoId': metodoPagoId,
          },
        },
        'perfilFiscalId': perfilFiscalId,
      },
      leer: _lectura.pago,
      encabezados: {'Idempotency-Key': llave},
    ),
  );

  @override
  Future<Pago> autenticar(int pagoId, {required bool confirmada}) => _traducir(
    () => _cliente.enviar(
      '/pagos/$pagoId/autenticacion',
      cuerpo: {'confirmada': confirmada},
      leer: _lectura.pago,
    ),
  );

  @override
  Future<Pago> pago(int pagoId) =>
      _cliente.obtener('/pagos/$pagoId', _lectura.pago);

  @override
  Future<PaginaPagos> pagos({int pagina = 0, int tamano = 20}) async {
    final respuesta = await _cliente.obtenerPagina(
      '/pagos',
      _lectura.pago,
      pagina: pagina,
      tamano: tamano,
    );
    return PaginaPagos(
      pagos: respuesta.contenido,
      pagina: respuesta.pagina,
      hayMas: respuesta.hayMas,
    );
  }

  @override
  Future<List<MetodoPago>> metodos() =>
      _cliente.obtenerLista('/metodos-pago', _lectura.metodo);

  @override
  Future<MetodoPago> predeterminar(int metodoPagoId) => _cliente.actualizar(
    '/metodos-pago/$metodoPagoId/predeterminado',
    cuerpo: null,
    leer: _lectura.metodo,
  );

  @override
  Future<void> borrarMetodo(int metodoPagoId) =>
      _cliente.eliminar('/metodos-pago/$metodoPagoId');

  static Future<Pago> _traducir(Future<Pago> Function() pedir) async {
    try {
      return await pedir();
    } on Conflicto catch (e) {
      final motivo = switch (e.problema?.codigo) {
        CodigoProblema.ordenNoPagable => MotivoRechazoPago.ordenNoPagable,
        CodigoProblema.pagoEnCurso => MotivoRechazoPago.pagoEnCurso,
        CodigoProblema.pagoNoPendiente => MotivoRechazoPago.pagoNoPendiente,
        _ => null,
      };
      if (motivo == null) rethrow;
      throw PagoRechazado(motivo, e.mensaje);
    }
  }
}
