import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../api/carecar_api.dart';
import '../api/modelos/vehiculo.dart';
import '../tema/tema_carecar.dart';
import '../config/ficha_tecnica.dart';
import '../widgets/ficha_tecnica_widget.dart';
import '../widgets/foto_auto.dart';
import '../widgets/formato.dart';
import '../widgets/movimiento.dart';
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
  Widget build(BuildContext context) {
    final v = vehiculo;
    final ficha = fichaDeModelo(v.modelo, anio: v.anio, version: v.version);
    final temas = Theme.of(context).textTheme;
    final subtitulo = [v.marca, v.version].whereType<String>().join(' · ');

    // Cada bloque entra un poco despues del anterior.
    Widget entra(int i, Widget w) => w
        .animate(delay: (90 * i).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto grande con el nombre encima.
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              _conHero(FotoAuto(modelo: v.modelo, alto: 240, radio: 0)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        TemaCareCar.azulProfundo.withValues(alpha: 0.92),
                      ],
                      stops: const [0.4, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        _Pastilla('${v.anio}'),
                        if (subtitulo.isNotEmpty) _Pastilla(subtitulo),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${v.marca ?? ''} ${v.modelo}'.trim(),
                      style: temas.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).scaleXY(begin: 0.97),
        const SizedBox(height: TemaCareCar.espacioCampos),
        // Datos clave de la unidad.
        entra(1, _DatosClave(vehiculo: v)),
        if (ficha != null) ...[
          const SizedBox(height: TemaCareCar.espacioCampos),
          entra(2, TarjetaFichaTecnica(ficha: ficha)),
        ],
        const SizedBox(height: TemaCareCar.espacioCampos),
        entra(
          3,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TemaCareCar.espacioSecciones),
            decoration: BoxDecoration(
              color: TemaCareCar.tarjeta,
              border: Border.all(color: TemaCareCar.borde),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Identificación', style: temas.titleMedium),
                const SizedBox(height: 8),
                // Datos opcionales del mock. No inferirlos del nombre ni del VIN.
                DatoLectura('Marca', v.marca),
                DatoLectura('Tipo', v.tipo ?? ficha?.carroceria),
                DatoLectura('Versión', v.version),
                DatoLectura('Modelo (año)', '${v.anio}'),
                DatoLectura('Color', v.color),
                DatoLectura('Placas', v.placas),
                DatoLectura('Número de serie (VIN)', v.vin),
              ],
            ),
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
                icono: opcion.$2.icono,
                compacta: true,
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
}

class _Pastilla extends StatelessWidget {
  const _Pastilla(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: TemaCareCar.turquesa.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: TemaCareCar.turquesa.withValues(alpha: 0.6)),
    ),
    child: Text(
      texto,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}

/// Kilometraje, placas y proximo servicio de la unidad.
class _DatosClave extends StatelessWidget {
  const _DatosClave({required this.vehiculo});

  final Vehiculo vehiculo;

  static const _cadaKm = 10000;

  @override
  Widget build(BuildContext context) {
    final km = vehiculo.kilometraje;
    // Servicio cada 10,000 km (el mismo intervalo que explica el manual).
    final proximo = km == null ? null : (km ~/ _cadaKm + 1) * _cadaKm;
    return LayoutBuilder(
      builder: (context, c) {
        final columnas = c.maxWidth >= 520 ? 3 : 1;
        final ancho = (c.maxWidth - 12 * (columnas - 1)) / columnas;
        Widget celda(Widget w) => SizedBox(width: ancho, child: w);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            celda(
              _Clave(
                icono: Icons.speed_outlined,
                etiqueta: 'Kilometraje',
                valor: km == null
                    ? const Text('Sin capturar')
                    : NumeroAnimado(
                        valor: km,
                        construir: (n) => Text(formatoKm(n)),
                      ),
              ),
            ),
            celda(
              _Clave(
                icono: Icons.pin_outlined,
                etiqueta: 'Placas',
                valor: Text(
                  vehiculo.placas ?? 'Sin capturar',
                  style: vehiculo.placas == null ? null : TemaCareCar.mono,
                ),
              ),
            ),
            celda(
              _Clave(
                icono: Icons.build_circle_outlined,
                etiqueta: 'Próximo servicio',
                valor: Text(proximo == null ? 'Sin dato' : formatoKm(proximo)),
                nota: proximo == null || km == null
                    ? null
                    : 'faltan ${conMiles(proximo - km)} km',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Clave extends StatelessWidget {
  const _Clave({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.nota,
  });

  final IconData icono;
  final String etiqueta;
  final Widget valor;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaCareCar.tarjeta,
        border: Border.all(color: TemaCareCar.borde),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TemaCareCar.azulSuave,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: TemaCareCar.azulAgencia),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: temas.labelSmall?.copyWith(
                    color: TemaCareCar.textoSecundario,
                  ),
                ),
                DefaultTextStyle.merge(
                  style: temas.titleMedium?.copyWith(
                    color: TemaCareCar.textoPrincipal,
                  ),
                  child: valor,
                ),
                if (nota != null)
                  Text(
                    nota!,
                    style: temas.bodyMedium?.copyWith(
                      color: TemaCareCar.turquesaOscuro,
                      fontWeight: FontWeight.w600,
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
