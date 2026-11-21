import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../tema/tema_carecar.dart';
import '../widgets/dato_lectura.dart';
import '../widgets/menu_carecar.dart';
import '../widgets/pagina_carecar.dart';
import 'pantalla_proximamente.dart';
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
    contenido: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
          decoration: BoxDecoration(
            gradient: TemaCareCar.degradadoMarca,
            borderRadius: BorderRadius.circular(EstiloMenu.radio),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: TemaCareCar.turquesa,
                  size: 40,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  vehiculo.modelo,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
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
                  opcion.$2 == IconoMenu.manual
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
    ),
  );
}
