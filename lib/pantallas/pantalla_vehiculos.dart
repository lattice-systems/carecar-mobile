import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../widgets/aviso.dart';
import '../tema/tema_carecar.dart';
import '../widgets/carga_datos.dart';
import '../widgets/formato.dart';
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
          : Column(
              children: [
                for (final (i, vehiculo) in vehiculos.indexed)
                  Padding(
                        padding: const EdgeInsets.only(
                          bottom: TemaCareCar.espacioCampos,
                        ),
                        child: TarjetaVehiculo(
                          vehiculo: vehiculo,
                          alPulsar: () => abrirPantalla(
                            context,
                            PantallaDetalleVehiculo(
                              vehiculo: vehiculo,
                              api: api,
                              alCerrarSesion: alCerrarSesion,
                            ),
                          ),
                        ),
                      )
                      .animate(delay: (80 * i).ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.12, curve: Curves.easeOutCubic),
              ],
            ),
    ),
  );
}

/// Tarjeta de un vehiculo con sus placas y su kilometraje.
class TarjetaVehiculo extends StatelessWidget {
  const TarjetaVehiculo({
    required this.vehiculo,
    required this.alPulsar,
    super.key,
  });

  final Vehiculo vehiculo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final v = vehiculo;
    final subtitulo = [v.marca, v.version].whereType<String>().join(' · ');

    return Material(
      color: TemaCareCar.tarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(EstiloMenu.radio),
        side: const BorderSide(color: TemaCareCar.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: TemaCareCar.degradadoMarca,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${v.modelo} ${v.anio}', style: temas.titleMedium),
                        if (subtitulo.isNotEmpty)
                          Text(
                            subtitulo,
                            style: temas.bodyMedium?.copyWith(
                              color: TemaCareCar.textoSecundario,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: TemaCareCar.textoSecundario,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Dato(
                      icono: Icons.pin_outlined,
                      etiqueta: 'Placas',
                      valor: v.placas,
                      mono: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Dato(
                      icono: Icons.speed_outlined,
                      etiqueta: 'Kilometraje',
                      valor: v.kilometraje == null
                          ? null
                          : formatoKm(v.kilometraje!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.mono = false,
  });

  final IconData icono;
  final String etiqueta;
  final String? valor;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final sinDato = valor == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TemaCareCar.fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, size: 18, color: TemaCareCar.turquesaOscuro),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: TemaCareCar.textoSecundario),
                ),
                // Con letra grande del sistema se encoge en vez de cortarse.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valor ?? 'Sin capturar',
                    maxLines: 1,
                    style:
                        (mono && !sinDato
                                ? TemaCareCar.mono
                                : const TextStyle())
                            .merge(
                              TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: sinDato
                                    ? TemaCareCar.textoSecundario
                                    : TemaCareCar.textoPrincipal,
                                fontStyle: sinDato ? FontStyle.italic : null,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
