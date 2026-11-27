/// Áreas de la agencia con horario propio. El orden es el de la pantalla.
enum Departamento { ventas, servicio, refacciones }

/// Un tramo de horario de un departamento (ver `HorarioSucursal` del contrato).
///
/// `abre` y `cierra` son `HH:mm` en la hora de la agencia; `dias` son ISO
/// (1 lunes a 7 domingo). `abiertoAhora` lo calculó el servidor.
class HorarioDeDepartamento {
  const HorarioDeDepartamento({
    required this.departamento,
    required this.dias,
    required this.abre,
    required this.cierra,
    required this.abiertoAhora,
  });

  final Departamento departamento;
  final List<int> dias;
  final String abre;
  final String cierra;
  final bool abiertoAhora;
}

/// Todos los tramos de un departamento (por ejemplo lunes a viernes y sábado).
class HorariosDelDepartamento {
  const HorariosDelDepartamento({
    required this.departamento,
    required this.tramos,
  });

  final Departamento departamento;
  final List<HorarioDeDepartamento> tramos;

  /// Está abierto si alguno de sus tramos lo está.
  bool get abiertoAhora => tramos.any((t) => t.abiertoAhora);
}

/// Una sucursal de la agencia (V2-M27.02).
///
/// `abiertaAhora` significa que algún departamento atiende en este momento, en
/// la hora de la agencia. Cambia con el reloj: no se guarda en el teléfono.
class Sucursal {
  const Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.abiertaAhora,
    this.telefono,
    this.correo,
    this.horarios = const [],
  });

  final int id;
  final String nombre;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? telefono;
  final String? correo;
  final bool abiertaAhora;
  final List<HorarioDeDepartamento> horarios;

  /// Los horarios agrupados por departamento, en el orden de [Departamento].
  /// Un departamento sin horario no aparece: está cerrado.
  List<HorariosDelDepartamento> get horariosPorDepartamento => [
    for (final d in Departamento.values)
      if (horarios.any((h) => h.departamento == d))
        HorariosDelDepartamento(
          departamento: d,
          tramos: [
            for (final h in horarios)
              if (h.departamento == d) h,
          ],
        ),
  ];
}
