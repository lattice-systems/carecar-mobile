import '../../../api/excepciones.dart';
import '../../../api/modelos/comun.dart';
import '../../../nucleo/api/api_cliente.dart';
import '../../../nucleo/mapas/mapas.dart';
import '../dominio/cotizacion_recoleccion.dart';
import '../dominio/direccion_guardada.dart';
import '../dominio/fallos_recoleccion.dart';
import '../dominio/repositorio_recoleccion.dart';

/// Direcciones y cotización de recolección con el cliente HTTP del núcleo.
///
/// Las excepciones de la API (`SinConexion`, `NoEncontrado`…) pasan tal cual:
/// la presentación decide cómo mostrarlas. Solo se traducen los dos casos que
/// la interfaz explica distinto: el 422 de cobertura y el 409 de dirección en
/// uso. El cliente HTTP convierte todo 422 en `SinParametrosDeValuacion`; en
/// estos caminos solo puede significar «fuera de cobertura».
class RepositorioRecoleccionApi implements RepositorioRecoleccion {
  const RepositorioRecoleccionApi(this._cliente);

  final ApiCliente _cliente;

  @override
  Future<List<DireccionGuardada>> direcciones() =>
      _cliente.obtenerLista('/direcciones', _leerDireccion);

  @override
  Future<DireccionGuardada> guardar(BorradorDireccion borrador) async {
    try {
      return await _cliente.enviar(
        '/direcciones',
        cuerpo: _cuerpo(borrador),
        leer: _leerDireccion,
      );
    } on SinParametrosDeValuacion {
      throw const FueraDeCobertura();
    }
  }

  @override
  Future<DireccionGuardada> editar(int id, BorradorDireccion borrador) async {
    try {
      return await _cliente.actualizar(
        '/direcciones/$id',
        cuerpo: _cuerpo(borrador),
        leer: _leerDireccion,
      );
    } on SinParametrosDeValuacion {
      throw const FueraDeCobertura();
    }
  }

  @override
  Future<void> borrar(int id) async {
    try {
      await _cliente.eliminar('/direcciones/$id');
    } on Conflicto {
      throw const DireccionEnUso();
    }
  }

  @override
  Future<CotizacionRecoleccion> cotizar({
    required int direccionId,
    required DateTime fecha,
  }) async {
    try {
      return await _cliente.obtener(
        '/recoleccion/cotizacion',
        _leerCotizacion,
        consulta: {
          'direccionId': '$direccionId',
          'fecha': escribirFecha(fecha),
        },
      );
    } on SinParametrosDeValuacion {
      throw const FueraDeCobertura();
    }
  }

  static Map<String, Object?> _cuerpo(BorradorDireccion b) => {
    'alias': b.alias.trim(),
    'calle': b.calle.trim(),
    'colonia': b.colonia.trim(),
    'cp': b.cp.trim(),
    'ciudad': b.ciudad.trim(),
    'lat': b.ubicacion!.latitud,
    'lng': b.ubicacion!.longitud,
  };

  static DireccionGuardada _leerDireccion(Map<String, Object?> json) =>
      DireccionGuardada(
        id: leerEntero(json['id'], 'id'),
        alias: leerTexto(json['alias'], 'alias'),
        calle: leerTexto(json['calle'], 'calle'),
        colonia: leerTexto(json['colonia'], 'colonia'),
        cp: leerTexto(json['cp'], 'cp'),
        ciudad: leerTexto(json['ciudad'], 'ciudad'),
        ubicacion: Coordenada(
          leerDecimal(json['lat'], 'lat'),
          leerDecimal(json['lng'], 'lng'),
        ),
      );

  static CotizacionRecoleccion _leerCotizacion(Map<String, Object?> json) =>
      CotizacionRecoleccion(
        direccionId: leerEntero(json['direccionId'], 'direccionId'),
        fecha: leerFecha(json['fecha'], 'fecha'),
        costoPorTraslado: leerDecimal(
          json['costoPorTraslado'],
          'costoPorTraslado',
        ),
        costoTotal: leerDecimal(json['costoTotal'], 'costoTotal'),
        recoleccion: _leerVentana(json['recoleccion'], 'recoleccion'),
        entrega: _leerVentana(json['entrega'], 'entrega'),
      );

  static VentanaHoraria _leerVentana(Object? valor, String campo) {
    if (valor is! Map) {
      throw FormatException('El campo «$campo» no es un objeto: $valor');
    }
    return VentanaHoraria(
      inicio: leerTexto(valor['inicio'], '$campo.inicio'),
      fin: leerTexto(valor['fin'], '$campo.fin'),
    );
  }
}
