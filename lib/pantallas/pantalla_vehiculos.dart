import 'package:flutter/material.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../widgets/aviso.dart';
import '../widgets/carga_datos.dart';
import '../widgets/menu_carecar.dart';
import '../widgets/pagina_carecar.dart';
import 'pantalla_detalle_vehiculo.dart';

class PantallaVehiculos extends StatelessWidget {
  const PantallaVehiculos({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });
  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: 'Mis vehículos',
    alCerrarSesion: alCerrarSesion,
    contenido: CargaDatos<List<Vehiculo>>(
      cargar: api.misVehiculos,
      mensajeCarga: 'Cargando vehículos…',
      mensajeError: 'No se pudieron cargar tus vehículos',
      construir: (vehiculos) => vehiculos.isEmpty
          ? const Aviso.informacion(
              titulo: 'No tienes vehículos asociados',
              detalle: 'Contacta a tu agencia para revisar tus vehículos.',
            )
          : RejillaMenu(
              tarjetas: [
                for (final vehiculo in vehiculos)
                  TarjetaMenu(
                    titulo: '${vehiculo.modelo} ${vehiculo.anio}',
                    imagen: const DibujoMenu(IconoMenu.vehiculos),
                    alPulsar: () => abrirPantalla(
                      context,
                      PantallaDetalleVehiculo(
                        vehiculo: vehiculo,
                        alCerrarSesion: alCerrarSesion,
                      ),
                    ),
                  ),
              ],
            ),
    ),
  );
}
