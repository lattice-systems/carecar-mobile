import 'package:flutter/material.dart';

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
    super.key,
  });
  final Vehiculo vehiculo;
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
            color: TemaCareCar.tarjeta,
            border: Border.all(color: TemaCareCar.borde),
            borderRadius: BorderRadius.circular(EstiloMenu.radio),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: DibujoMenu(IconoMenu.vehiculos, tamano: 112)),
              const SizedBox(height: TemaCareCar.espacioCampos),
              Center(
                child: Text(
                  vehiculo.modelo,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
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
