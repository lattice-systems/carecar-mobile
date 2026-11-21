import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../widgets/aviso.dart';
import '../tema/tema_carecar.dart';
import '../widgets/carga_datos.dart';
import '../widgets/formato.dart';
import '../widgets/movimiento.dart';
import '../widgets/menu_carecar.dart';
import '../widgets/pagina_carecar.dart';
import '../widgets/pantalla.dart';
import 'pantalla_detalle_vehiculo.dart';

class PantallaVehiculos extends StatefulWidget {
  const PantallaVehiculos({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });
  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  @override
  State<PantallaVehiculos> createState() => _PantallaVehiculosState();
}

class _PantallaVehiculosState extends State<PantallaVehiculos> {
  final _recargador = Recargador();

  /// En pantalla amplia, el vehiculo cuya ficha se ve a la derecha.
  int? _elegidoId;

  @override
  Widget build(BuildContext context) {
    final amplia = Pantalla.de(context) == Pantalla.amplio;
    return PaginaCareCar(
      titulo: 'Mis vehículos',
      alCerrarSesion: widget.alCerrarSesion,
      alRefrescar: _recargador.recargar,
      contenido: CargaDatos<List<Vehiculo>>(
        recargador: _recargador,
        cargar: widget.api.misVehiculos,
        mensajeCarga: 'Cargando vehículos…',
        mensajeError: 'No se pudieron cargar tus vehículos',
        construir: (vehiculos) => vehiculos.isEmpty
            ? const Aviso.informacion(
                titulo: 'No tienes vehículos asociados',
                detalle: 'Contacta a tu agencia para revisar tus vehículos.',
              )
            : amplia
            ? _maestroDetalle(vehiculos)
            : RejillaAdaptable(
                maxColumnas: 2,
                hijos: [
                  for (final (i, v) in vehiculos.indexed)
                    _animar(i, _tarjeta(v, () => _abrir(v))),
                ],
              ),
      ),
    );
  }

  /// Tablet horizontal o escritorio: lista a la izquierda, ficha a la derecha.
  Widget _maestroDetalle(List<Vehiculo> vehiculos) {
    final elegido = vehiculos.firstWhere(
      (v) => v.id == _elegidoId,
      orElse: () => vehiculos.first,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              for (final (i, v) in vehiculos.indexed)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: TemaCareCar.espacioCampos,
                  ),
                  child: _animar(
                    i,
                    _tarjeta(
                      v,
                      () => setState(() => _elegidoId = v.id),
                      elegido: v.id == elegido.id,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: TemaCareCar.espacioSecciones),
        Expanded(
          child: AnimatedSwitcher(
            duration: 300.ms,
            switchInCurve: Curves.easeOutCubic,
            child: FichaVehiculo(
              key: ValueKey(elegido.id),
              vehiculo: elegido,
              api: widget.api,
              alCerrarSesion: widget.alCerrarSesion,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tarjeta(Vehiculo v, VoidCallback alPulsar, {bool elegido = false}) =>
      TarjetaVehiculo(vehiculo: v, alPulsar: alPulsar, elegido: elegido);

  Widget _animar(int i, Widget hijo) => hijo
      .animate(delay: (80 * i).ms)
      .fadeIn(duration: 350.ms)
      .slideY(begin: 0.12, curve: Curves.easeOutCubic);

  void _abrir(Vehiculo v) => abrirPantalla(
    context,
    PantallaDetalleVehiculo(
      vehiculo: v,
      api: widget.api,
      alCerrarSesion: widget.alCerrarSesion,
    ),
  );
}

/// Tarjeta de un vehiculo con sus placas y su kilometraje.
class TarjetaVehiculo extends StatelessWidget {
  const TarjetaVehiculo({
    required this.vehiculo,
    required this.alPulsar,
    this.elegido = false,
    super.key,
  });

  final Vehiculo vehiculo;
  final VoidCallback alPulsar;

  /// Resaltada cuando su ficha se ve al lado (maestro-detalle).
  final bool elegido;

  /// En fila cada dato toma la mitad; apilados conservan su alto natural.
  static Widget _envolver(bool apilar, Widget dato) =>
      apilar ? dato : Expanded(child: dato);

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final v = vehiculo;
    final subtitulo = [v.marca, v.version].whereType<String>().join(' · ');
    final apilar = MediaQuery.textScalerOf(context).scale(1) > 1.4;

    return Rebote(
      child: Material(
        color: TemaCareCar.tarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EstiloMenu.radio),
          side: BorderSide(
            color: elegido ? TemaCareCar.azulAgencia : TemaCareCar.borde,
            width: elegido ? 2 : 1,
          ),
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
                          Text(
                            '${v.modelo} ${v.anio}',
                            style: temas.titleMedium,
                          ),
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
                // Con letra muy grande los datos van uno debajo del otro.
                Flex(
                  direction: apilar ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: apilar
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: [
                    _envolver(
                      apilar,
                      _Dato(
                        icono: Icons.pin_outlined,
                        etiqueta: 'Placas',
                        valor: v.placas,
                        mono: true,
                      ),
                    ),
                    const SizedBox(width: 10, height: 10),
                    _envolver(
                      apilar,
                      _Dato(
                        icono: Icons.speed_outlined,
                        etiqueta: 'Kilometraje',
                        valor: v.kilometraje == null
                            ? null
                            : formatoKm(v.kilometraje!),
                        kilometros: v.kilometraje,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    this.kilometros,
  });

  final IconData icono;
  final String etiqueta;
  final String? valor;
  final bool mono;

  /// Si viene, el valor cuenta hasta esa cifra al aparecer.
  final int? kilometros;

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
                  child: _Valor(
                    texto: valor ?? 'Sin capturar',
                    kilometros: kilometros,
                    sinDato: sinDato,
                    mono: mono,
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

class _Valor extends StatelessWidget {
  const _Valor({
    required this.texto,
    required this.sinDato,
    required this.mono,
    this.kilometros,
  });

  final String texto;
  final int? kilometros;
  final bool sinDato;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final estilo = (mono && !sinDato ? TemaCareCar.mono : const TextStyle())
        .merge(
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: sinDato
                ? TemaCareCar.textoSecundario
                : TemaCareCar.textoPrincipal,
            fontStyle: sinDato ? FontStyle.italic : null,
          ),
        );
    if (kilometros == null) return Text(texto, maxLines: 1, style: estilo);
    return NumeroAnimado(
      valor: kilometros!,
      construir: (n) => Text(formatoKm(n), maxLines: 1, style: estilo),
    );
  }
}
