/// Contenido de los widgets de pantalla de inicio (V2-M25).
///
/// Dart puro. Cada widget (próxima cita, taller en vivo, mantenimiento,
/// bitácora y accesos rápidos) se agrega por separado desde el selector del
/// sistema y publica sus propias claves, con el prefijo de su [TipoWidget]. Aquí
/// se decide qué textos viajan y a qué enlace `carecar://` abre cada uno; cómo
/// se entregan al sistema vive detrás de [PuertoWidgets].
///
/// Solo viajan textos de pantalla (ya traducidos) y el id de la cita, orden o
/// vehículo dentro del enlace. Nunca asesor, montos de órdenes, placas, VIN,
/// datos del cliente ni el código firmado del QR.
library;

import '../../../nucleo/navegacion/enlaces.dart';

/// Los widgets que ofrece la app, en el orden del selector.
enum TipoWidget {
  proximaCita('cita', 'ProximaCitaWidgetProvider', 'ProximaCitaWidget', [
    'hay',
    'titulo',
    'dia',
    'mes',
    'semana',
    'horario',
    'vehiculo',
    'mensaje',
    'accion',
    'descripcion',
    'enlace',
  ]),
  taller('taller', 'TallerWidgetProvider', 'TallerWidget', [
    'hay',
    'titulo',
    'etapa',
    'paso',
    'total',
    'paso_texto',
    'entrega',
    'vehiculo',
    'mensaje',
    'accion',
    'descripcion',
    'enlace',
  ]),
  mantenimiento('mant', 'MantenimientoWidgetProvider', 'MantenimientoWidget', [
    'hay',
    'titulo',
    'servicio',
    'faltan',
    'fecha',
    'progreso',
    'urgente',
    'vehiculo',
    'mensaje',
    'accion',
    'descripcion',
    'enlace',
  ]),
  bitacora('bit', 'BitacoraWidgetProvider', 'BitacoraWidget', [
    'hay',
    'titulo',
    'rendimiento',
    'unidad',
    'etiqueta_rendimiento',
    'gasto',
    'etiqueta_gasto',
    'vehiculo',
    'mensaje',
    'accion',
    'descripcion',
    'enlace',
  ]),
  accesos('acc', 'AccesosWidgetProvider', 'AccesosWidget', [
    'hay',
    'titulo',
    'agendar',
    'mi_auto',
    'sos',
    'comprobante',
    'enlace_agendar',
    'enlace_mi_auto',
    'enlace_sos',
    'enlace_comprobante',
    'enlace',
  ]);

  const TipoWidget(
    this.prefijo,
    this.proveedorAndroid,
    this.tipoIos,
    this.campos,
  );

  /// Prefijo de todas las claves de este widget en el almacén compartido.
  final String prefijo;

  /// Nombre simple del `AppWidgetProvider` de Android (paquete de la app).
  final String proveedorAndroid;

  /// `kind` del widget de WidgetKit en iOS.
  final String tipoIos;

  /// Todos los campos que este widget puede publicar (sin prefijo). Sirven para
  /// borrar sus datos por completo al cerrar sesión.
  final List<String> campos;

  /// Clave del almacén para [campo]: `taller_etapa`.
  String clave(String campo) => '${prefijo}_$campo';
}

/// Enlace `carecar://` de una ruta interna: `/garaje` es `carecar://garaje`.
String enlaceDeRuta(String ruta) => '${EnlacesApp.esquema}:/$ruta';

/// Lo que se le entrega a un widget: sus datos ya traducidos y su enlace.
///
/// Dos contenidos con los mismos datos son iguales, así el sincronizador no
/// repinta el widget cuando nada cambió.
class ContenidoWidget {
  const ContenidoWidget._(this.tipo, this.datos);

  /// Próxima cita confirmada. El día va aparte en grande ([dia], [mes],
  /// [semana]); [descripcion] es el texto para el lector de pantalla.
  factory ContenidoWidget.proximaCita({
    required String titulo,
    required String dia,
    required String mes,
    required String semana,
    required String horario,
    required String descripcion,
    required int citaId,
    String? vehiculo,
  }) => ContenidoWidget._(TipoWidget.proximaCita, {
    'hay': true,
    'titulo': titulo,
    'dia': dia,
    'mes': mes,
    'semana': semana,
    'horario': horario,
    'vehiculo': ?vehiculo,
    'descripcion': descripcion,
    'enlace': enlaceDeRuta('/citas/$citaId/comprobante'),
  });

  /// Sin cita: invita a agendar.
  factory ContenidoWidget.proximaCitaVacia({
    required String titulo,
    required String mensaje,
    required String accion,
  }) => ContenidoWidget._(
    TipoWidget.proximaCita,
    _vacio(titulo, mensaje, accion, enlaceDeRuta('/citas/agendar')),
  );

  /// Orden abierta: etapa actual con su avance ([paso] de [total]).
  factory ContenidoWidget.taller({
    required String titulo,
    required String etapa,
    required int paso,
    required int total,
    required String pasoTexto,
    required String vehiculo,
    required String descripcion,
    required int ordenId,
    String? entrega,
  }) => ContenidoWidget._(TipoWidget.taller, {
    'hay': true,
    'titulo': titulo,
    'etapa': etapa,
    'paso': paso,
    'total': total,
    'paso_texto': pasoTexto,
    'entrega': ?entrega,
    'vehiculo': vehiculo,
    'descripcion': descripcion,
    'enlace': enlaceDeRuta('/taller/$ordenId'),
  });

  /// Sin orden abierta: invita a agendar.
  factory ContenidoWidget.tallerVacio({
    required String titulo,
    required String mensaje,
    required String accion,
  }) => ContenidoWidget._(
    TipoWidget.taller,
    _vacio(titulo, mensaje, accion, enlaceDeRuta('/citas/agendar')),
  );

  /// Próximo servicio del plan: [progreso] de 0 a 100 hacia el km objetivo.
  factory ContenidoWidget.mantenimiento({
    required String titulo,
    required String servicio,
    required String faltan,
    required int progreso,
    required bool urgente,
    required String descripcion,
    required int vehiculoId,
    String? fecha,
    String? vehiculo,
  }) => ContenidoWidget._(TipoWidget.mantenimiento, {
    'hay': true,
    'titulo': titulo,
    'servicio': servicio,
    'faltan': faltan,
    'fecha': ?fecha,
    'progreso': progreso,
    'urgente': urgente,
    'vehiculo': ?vehiculo,
    'descripcion': descripcion,
    'enlace': enlaceDeRuta('/mantenimiento/$vehiculoId'),
  });

  /// Sin plan ni vehículo: lleva al garaje.
  factory ContenidoWidget.mantenimientoVacio({
    required String titulo,
    required String mensaje,
    required String accion,
  }) => ContenidoWidget._(
    TipoWidget.mantenimiento,
    _vacio(titulo, mensaje, accion, enlaceDeRuta('/garaje')),
  );

  /// Rendimiento y gasto del mes. Sin rendimiento calculado (menos de dos
  /// cargas) se publica una raya.
  factory ContenidoWidget.bitacora({
    required String titulo,
    required String unidad,
    required String etiquetaRendimiento,
    required String gasto,
    required String etiquetaGasto,
    required String descripcion,
    required int vehiculoId,
    String? rendimiento,
    String? vehiculo,
  }) => ContenidoWidget._(TipoWidget.bitacora, {
    'hay': true,
    'titulo': titulo,
    'rendimiento': rendimiento ?? '—',
    'unidad': unidad,
    'etiqueta_rendimiento': etiquetaRendimiento,
    'gasto': gasto,
    'etiqueta_gasto': etiquetaGasto,
    'vehiculo': ?vehiculo,
    'descripcion': descripcion,
    'enlace': enlaceDeRuta('/bitacora/$vehiculoId'),
  });

  /// Sin gastos o sin vehículo: lleva al garaje.
  factory ContenidoWidget.bitacoraVacia({
    required String titulo,
    required String mensaje,
    required String accion,
  }) => ContenidoWidget._(
    TipoWidget.bitacora,
    _vacio(titulo, mensaje, accion, enlaceDeRuta('/garaje')),
  );

  /// Botones de acceso rápido. Cada uno abre su pantalla por su enlace.
  factory ContenidoWidget.accesos({
    required String titulo,
    required String agendar,
    required String miAuto,
    required String sos,
    required String comprobante,
    required String enlaceComprobante,
    required String enlaceSos,
  }) => ContenidoWidget._(TipoWidget.accesos, {
    'hay': true,
    'titulo': titulo,
    'agendar': agendar,
    'mi_auto': miAuto,
    'sos': sos,
    'comprobante': comprobante,
    'enlace_agendar': enlaceDeRuta('/citas/agendar'),
    'enlace_mi_auto': enlaceDeRuta('/garaje'),
    'enlace_sos': enlaceSos,
    'enlace_comprobante': enlaceComprobante,
    'enlace': enlaceDeRuta('/citas/agendar'),
  });

  static Map<String, Object> _vacio(
    String titulo,
    String mensaje,
    String accion,
    String enlace,
  ) => {
    'hay': false,
    'titulo': titulo,
    'mensaje': mensaje,
    'accion': accion,
    'enlace': enlace,
  };

  final TipoWidget tipo;

  /// Los datos con sus claves sin prefijo.
  final Map<String, Object> datos;

  /// Si el widget muestra datos y no su estado vacío.
  bool get hayDatos => datos['hay'] == true;

  /// Enlace `carecar://` que abre el widget al tocarlo.
  String get enlace => datos['enlace']! as String;

  /// Lo que se guarda en el almacén compartido, con el prefijo del widget.
  Map<String, Object> get almacen => {
    for (final entrada in datos.entries) tipo.clave(entrada.key): entrada.value,
  };

  @override
  bool operator ==(Object other) =>
      other is ContenidoWidget &&
      other.tipo == tipo &&
      other.datos.length == datos.length &&
      datos.entries.every((e) => other.datos[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    tipo,
    Object.hashAllUnordered(
      datos.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}

/// Lo que el módulo necesita del sistema para mostrar los widgets; el paquete
/// `home_widget` queda detrás de esta interfaz para sustituirlo en pruebas.
abstract interface class PuertoWidgets {
  /// Guarda [contenido] para su widget y le pide repintarse.
  Future<void> publicar(ContenidoWidget contenido);

  /// Borra los datos de todos los widgets y los repinta sin información (al
  /// cerrar sesión).
  Future<void> borrarTodo();
}
