import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_auto.dart';
import '../../../nucleo/diseno/componentes/tinte_auto.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/idioma/formato_numeros.dart';
import '../../asistente/asistente.dart';
import '../../bitacora/bitacora.dart';
import '../../citas/citas.dart';
import '../../garantia/garantia.dart';
import '../../historial/historial.dart';
import '../../mantenimiento/mantenimiento.dart';
import '../dominio/vehiculo_garaje.dart';
import 'proveedores_vehiculos.dart';
import 'rutas_vehiculos.dart';

/// Detalle de un vehiculo del garaje (V2-M02.02): el auto en su tarjeta con las
/// acciones debajo, VIN copiable y kilometraje con la fecha en que el taller lo
/// actualizo, datos del auto y accesos a manual, ficha tecnica e historial.
///
/// Manual (V2-M02.03), ficha tecnica (V2-M02.04) e historial (V2-M02.05) abren
/// su pantalla. Resuelve los cinco estados; si el id ya no esta en el garaje
/// lo explica.
class PantallaDetalleVehiculo extends ConsumerWidget {
  const PantallaDetalleVehiculo({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculo = ref.watch(vehiculoProvider(vehiculoId));
    final textos = AppLocalizations.of(context);

    final titulo = textos.vehiculosDetalleTitulo;

    return vehiculo.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(garajeProvider),
        ),
      ),
      data: (v) => v == null
          ? MarcoPantalla.estado(
              titulo: titulo,
              conRegreso: true,
              estado: EstadoVacio(
                titulo: textos.vehiculosNoEncontradoTitulo,
                mensaje: textos.vehiculosNoEncontradoMensaje,
                icono: Icons.directions_car_outlined,
              ),
            )
          : _Detalle(
              vehiculo: v,
              // La fecha del km ya no viene en GET /vehiculos (V2-T05.06): se
              // lee del plan, y solo si el vehiculo no trae la suya.
              kmDelTaller: v.kilometrajeActualizadoEn == null
                  ? ref.watch(kmDelTallerProvider(v.id)).value
                  : null,
              alRefrescar: () => ref.refresh(garajeProvider.future),
            ),
    );
  }
}

class _Detalle extends StatefulWidget {
  const _Detalle({
    required this.vehiculo,
    required this.alRefrescar,
    this.kmDelTaller,
  });

  final VehiculoGaraje vehiculo;
  final KmDelTaller? kmDelTaller;
  final Future<void> Function() alRefrescar;

  @override
  State<_Detalle> createState() => _DetalleState();
}

class _DetalleState extends State<_Detalle> {
  bool _vinCopiado = false;

  Future<void> _copiarVin(String vin) async {
    await Clipboard.setData(ClipboardData(text: vin));
    if (mounted) setState(() => _vinCopiado = true);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehiculo;
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final tinte = tinteDeColorAuto(c, v.color);
    final vin = v.vin;
    final placas = v.placas;
    final sinPlacas = placas == null || placas.isEmpty;

    return MarcoPantalla(
      titulo: v.titulo,
      subtitulo: sinPlacas
          ? textos.vehiculosSinPlacas
          : textos.vehiculosPlacas(placas),
      conRegreso: true,
      alRefrescar: widget.alRefrescar,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: Espaciado.e2),
              TarjetaAuto(tinte: tinte, alto: 150),
              const SizedBox(height: Espaciado.e4),
              FilaAcciones(
                principal: AccionPantalla(
                  texto: textos.vehiculosAgendarServicio,
                  icono: Icons.event_available_outlined,
                  alPresionar: () => context.push(rutaAgendarCita),
                ),
                secundaria: AccionPantalla(
                  texto: textos.vehiculosBotonManual,
                  icono: Icons.menu_book_outlined,
                  alPresionar: () => context.push(rutaManualVehiculo(v.id)),
                ),
              ),
              const SizedBox(height: Espaciado.e4),
              _TarjetaCifras(
                vehiculo: v,
                kmDelTaller: widget.kmDelTaller,
                alCopiarVin: vin == null || vin.isEmpty
                    ? null
                    : () => _copiarVin(vin),
              ),
              if (_vinCopiado)
                Padding(
                  padding: const EdgeInsets.only(top: Espaciado.e2),
                  child: Aviso(
                    mensaje: textos.vehiculosVinCopiado,
                    tono: Tono.exito,
                    alCerrar: () => setState(() => _vinCopiado = false),
                  ),
                ),
              const SizedBox(height: Espaciado.e4),
              TarjetaAsistente(vehiculoId: v.id),
              const SizedBox(height: Espaciado.e6),
              // Ir a pantallas hijas es una lista con chevron, como en Privacidad
              // y Mantenimiento (V2-T02.23).
              GrupoLista(
                encabezado: textos.vehiculosEncabezadoTuAuto,
                filas: [
                  FilaGrupo(
                    titulo: textos.vehiculosAccesoFicha,
                    icono: Icons.fact_check_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaFichaTecnicaVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.vehiculosAccesoHistorial,
                    icono: Icons.history,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaHistorialVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.mantenimientoAcceso,
                    icono: Icons.build_circle_outlined,
                    colorIcono: c.acento,
                    alToque: () =>
                        context.push(rutaMantenimientoVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.bitacoraAccesoFila,
                    icono: Icons.local_gas_station_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(
                      rutaBitacoraVehiculo(v.id, nombre: v.titulo),
                    ),
                  ),
                  FilaGrupo(
                    titulo: textos.garantiaAcceso,
                    icono: Icons.verified_user_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaGarantiaVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.campanasAcceso,
                    icono: Icons.campaign_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaCampanasVehiculo(v.id)),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e4),
              GrupoLista(
                encabezado: textos.vehiculosEncabezadoDatos,
                filas: [
                  _dato(
                    Icons.pin_outlined,
                    textos.vehiculosPlacasEtiqueta,
                    sinPlacas ? textos.vehiculosSinPlacas : placas,
                    c.acento,
                  ),
                  _dato(
                    Icons.calendar_today_outlined,
                    textos.vehiculosAnio,
                    '${v.anio}',
                    c.marca,
                  ),
                  if (v.color != null)
                    _dato(
                      Icons.palette_outlined,
                      textos.vehiculosColor,
                      v.color!,
                      tinte,
                    ),
                  if (v.version != null)
                    _dato(
                      Icons.tune,
                      textos.vehiculosVersion,
                      v.version!,
                      c.exito,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Fila de dato: el valor va arriba y la etiqueta debajo, como una sola
  /// frase para el lector de pantalla.
  FilaGrupo _dato(IconData icono, String etiqueta, String valor, Color color) =>
      FilaGrupo(
        titulo: valor,
        subtitulo: etiqueta,
        icono: icono,
        colorIcono: color,
      );
}

/// Tarjeta con las dos cifras del auto: el kilometraje grande, con la fecha en
/// que lo actualizo el taller (o que aun no hay), y el VIN en monoespaciado que
/// se copia al tocarlo. Sin fecha de cierre lo dice; nunca la inventa.
class _TarjetaCifras extends StatelessWidget {
  const _TarjetaCifras({
    required this.vehiculo,
    required this.alCopiarVin,
    this.kmDelTaller,
  });

  final VehiculoGaraje vehiculo;

  /// El km y la fecha que dejo el taller segun el plan; gana al km del
  /// vehiculo cuando este no trae fecha.
  final KmDelTaller? kmDelTaller;
  final VoidCallback? alCopiarVin;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final km = kmDelTaller?.km ?? vehiculo.kilometraje;
    final cierre = vehiculo.kilometrajeActualizadoEn ?? kmDelTaller?.fecha;
    final vin = vehiculo.vin;

    final String valorKm;
    final String notaKm;
    if (km == null) {
      valorKm = textos.vehiculosKmSinDato;
      notaKm = '';
    } else {
      valorKm = textos.vehiculosKilometros(formatearMiles(context, km));
      notaKm = cierre == null
          ? textos.vehiculosKmSinActualizar
          : textos.vehiculosKmActualizado(
              MaterialLocalizations.of(context).formatFullDate(cierre),
            );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textos.vehiculosKilometraje,
                    style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                  ),
                  Text(
                    valorKm,
                    style: (km == null ? t.cuerpoFuerte : t.cifra).copyWith(
                      color: c.texto,
                    ),
                  ),
                  if (notaKm.isNotEmpty)
                    Text(
                      notaKm,
                      style: t.cuerpoChico.copyWith(color: c.textoSecundario),
                    ),
                ],
              ),
            ),
            if (vin != null && vin.isNotEmpty) ...[
              const SizedBox(height: Espaciado.e3),
              Divider(height: 1, color: c.borde),
              Semantics(
                button: true,
                excludeSemantics: true,
                label: [
                  textos.vehiculosVin,
                  vin,
                  textos.vehiculosCopiarVin,
                ].join('. '),
                onTap: alCopiarVin,
                child: Tooltip(
                  message: textos.vehiculosCopiarVin,
                  child: InkWell(
                    onTap: alCopiarVin,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: Espaciado.objetivoTactilMinimo,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: Espaciado.e3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    textos.vehiculosVin,
                                    style: t.cuerpoChico.copyWith(
                                      color: c.textoSecundario,
                                    ),
                                  ),
                                  Text(
                                    vin,
                                    style: t.cifra.copyWith(
                                      fontSize: 18,
                                      color: c.texto,
                                    ),
                                  ),
                                  Text(
                                    textos.vehiculosToqueCopiarVin,
                                    style: t.cuerpoChico.copyWith(
                                      color: c.textoTerciario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.copy_outlined, color: c.acento),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).vehiculosCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 188, radio: 28),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}
