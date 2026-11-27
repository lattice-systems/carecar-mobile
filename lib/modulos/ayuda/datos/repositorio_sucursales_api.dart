import '../../../api/carecar_api.dart';
import '../../../api/modelos/sucursal.dart';
import '../dominio/repositorio_sucursales.dart';
import '../dominio/sucursal.dart';

/// Lee `GET /sucursales` y lo traduce a modelos de dominio (V2-M27.02).
///
/// Las excepciones de la API (`SinConexion`, `ExcepcionApi`) pasan tal cual: la
/// presentación decide cómo mostrarlas.
class RepositorioSucursalesApi implements RepositorioSucursales {
  const RepositorioSucursalesApi(this._api);

  final CarecarApi _api;

  @override
  Future<List<Sucursal>> sucursales() async {
    final dto = await _api.sucursales();
    return dto.map(_aSucursal).toList(growable: false);
  }

  static Sucursal _aSucursal(SucursalApi s) => Sucursal(
    id: s.id,
    nombre: s.nombre,
    direccion: s.direccion,
    latitud: s.latitud,
    longitud: s.longitud,
    telefono: s.telefono,
    correo: s.correo,
    abiertaAhora: s.abiertaAhora,
    horarios: [
      for (final h in s.horarios)
        // Un departamento nuevo del backend no rompe la pantalla: se omite
        // hasta que la app lo conozca.
        if (_departamento(h.departamento) case final departamento?)
          HorarioDeDepartamento(
            departamento: departamento,
            dias: h.dias,
            abre: h.abre,
            cierra: h.cierra,
            abiertoAhora: h.abiertoAhora,
          ),
    ],
  );

  static Departamento? _departamento(String codigo) => switch (codigo) {
    'VENTAS' => Departamento.ventas,
    'SERVICIO' => Departamento.servicio,
    'REFACCIONES' => Departamento.refacciones,
    _ => null,
  };
}
