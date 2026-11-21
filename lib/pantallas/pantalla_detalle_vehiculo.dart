import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../tema/tema_carecar.dart';
import '../widgets/foto_auto.dart';
import '../widgets/dato_lectura.dart';
import '../widgets/menu_carecar.dart';
import '../widgets/pagina_carecar.dart';
import 'citas/pantalla_agendar_cita.dart';
import 'pantalla_proximamente.dart';
import 'servicios/pantalla_historial.dart';
import 'pantalla_manual.dart';

class PantallaDetalleVehiculo extends StatelessWidget {
  const PantallaDetalleVehiculo({
    required this.vehiculo,
    required this.alCerrarSesion,
    this.api,
    super.key,
  });
  final Vehiculo vehiculo;
  final CarecarApi? api;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) => PaginaCareCar(
    titulo: 'Detalle del vehículo',
    alCerrarSesion: alCerrarSesion,
    contenido: FichaVehiculo(
      vehiculo: vehiculo,
      api: api,
      alCerrarSesion: alCerrarSesion,
      conHero: true,
    ),
  );
}

/// Cuerpo del detalle. Se usa solo en su pantalla y, en tablet horizontal o
/// escritorio, a la derecha de la lista de Mis vehiculos.
class FichaVehiculo extends StatelessWidget {
  const FichaVehiculo({
    required this.vehiculo,
    required this.alCerrarSesion,
    this.api,
    this.conHero = false,
    super.key,
  });
  final Vehiculo vehiculo;
  final CarecarApi? api;
  final VoidCallback alCerrarSesion;

  /// Solo en la pantalla de detalle: la tarjeta de la lista vuela hasta aqui.
  final bool conHero;

  Widget _conHero(Widget hijo) =>
      conHero ? Hero(tag: 'carro-${vehiculo.id}', child: hijo) : hijo;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
        decoration: BoxDecoration(
          gradient: TemaCareCar.degradadoMarca,
          borderRadius: BorderRadius.circular(EstiloMenu.radio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _conHero(FotoAuto(modelo: vehiculo.modelo, alto: 190)),
            const SizedBox(height: 14),
            Text(
              '${vehiculo.modelo} ${vehiculo.anio}',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).scaleXY(begin: 0.97),
      const SizedBox(height: TemaCareCar.espacioCampos),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
        decoration: BoxDecoration(
          color: TemaCareCar.tarjeta,
          border: Border.all(color: TemaCareCar.borde),
          borderRadius: BorderRadius.circular(EstiloMenu.radio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ficha del vehículo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: TemaCareCar.espacioCampos),
            // Datos opcionales del mock. No inferirlos del nombre ni del VIN.
            DatoLectura('Marca', vehiculo.marca),
            DatoLectura('Tipo', vehiculo.tipo),
            DatoLectura('Versión', vehiculo.version),
            DatoLectura('Modelo (año)', '${vehiculo.anio}'),
            DatoLectura('Color', vehiculo.color),
            DatoLectura('Número de serie (VIN)', vehiculo.vin),
          ],
        ),
      ),
      const SizedBox(height: TemaCareCar.espacioSecciones),
      RejillaMenu(
        tarjetas: [
          for (final opcion in const [
            ('Agendar cita', IconoMenu.cita),
            ('Historial de servicios', IconoMenu.historial),
            ('Manual del propietario', IconoMenu.manual),
          ])
            TarjetaMenu(
              titulo: opcion.$1,
              imagen: DibujoMenu(opcion.$2),
              alPulsar: () => abrirPantalla(
                context,
                opcion.$2 == IconoMenu.cita && api != null
                    ? PantallaAgendarCita(
                        api: api!,
                        alCerrarSesion: alCerrarSesion,
                      )
                    : opcion.$2 == IconoMenu.historial && api != null
                    ? PantallaHistorial(
                        api: api!,
                        vehiculo: vehiculo,
                        alCerrarSesion: alCerrarSesion,
                      )
                    : opcion.$2 == IconoMenu.manual
                    ? PantallaManual(
                        vehiculo: vehiculo,
                        api: api,
                        alCerrarSesion: alCerrarSesion,
                      )
                    : PantallaProximamente(
                        titulo: opcion.$1,
                        vehiculo: vehiculo,
                        alCerrarSesion: alCerrarSesion,
                      ),
              ),
            ),
        ],
      ),
    ],
  );
}
