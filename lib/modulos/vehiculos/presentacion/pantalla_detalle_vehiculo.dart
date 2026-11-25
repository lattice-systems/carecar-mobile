import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/barra_portada.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../asistente/asistente.dart';
import '../../bitacora/bitacora.dart';
import '../../citas/citas.dart';
import '../../historial/historial.dart';
import '../../mantenimiento/mantenimiento.dart';
import '../dominio/vehiculo_garaje.dart';
import 'portada_vehiculo.dart';
import 'proveedores_vehiculos.dart';
import 'rutas_vehiculos.dart';

/// Detalle de un vehiculo del garaje en estilo portada (V2-M02.02): el auto
/// como portada con sus acciones, VIN copiable y kilometraje con la fecha en
/// que el taller lo actualizo, datos del auto y accesos a manual, ficha tecnica
/// e historial.
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: TokensPista.de(context).colores.fondo,
      appBar: BarraPortada(titulo: textos.vehiculosDetalleTitulo),
      body: vehiculo.when(
        skipLoadingOnReload: true,
        loading: () => const _Cargando(),
        error: (error, _) => SafeArea(
          child: EstadoError(
            causa: error is SinConexion
                ? CausaError.sinConexion
                : CausaError.generico,
            alReintentar: () => ref.invalidate(garajeProvider),
          ),
        ),
        data: (v) => v == null
            ? SafeArea(
                child: EstadoVacio(
                  titulo: textos.vehiculosNoEncontradoTitulo,
                  mensaje: textos.vehiculosNoEncontradoMensaje,
                  icono: Icons.directions_car_outlined,
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(garajeProvider.future),
                child: _Detalle(
                  vehiculo: v,
                  // La fecha del km ya no viene en GET /vehiculos (V2-T05.06):
                  // se lee del plan, y solo si el vehiculo no trae la suya.
                  kmDelTaller: v.kilometrajeActualizadoEn == null
                      ? ref.watch(kmDelTallerProvider(v.id)).value
                      : null,
                ),
              ),
      ),
    );
  }
}

class _Detalle extends StatefulWidget {
  const _Detalle({required this.vehiculo, this.kmDelTaller});

  final VehiculoGaraje vehiculo;
  final KmDelTaller? kmDelTaller;

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
    final tinte = tinteDeColor(tokens, v.color);
    final vin = v.vin;
    final placas = v.placas;
    final sinPlacas = placas == null || placas.isEmpty;

    return ListView(
      padding: const EdgeInsets.only(bottom: Espaciado.e8),
      children: [
        CabeceraPortada(
          titulo: v.titulo,
          subtitulo: sinPlacas
              ? textos.vehiculosSinPlacas
              : textos.vehiculosPlacas(placas),
          descripcion: textos.fotoDeModelo(v.titulo),
          tinte: tinte,
          portada: PortadaVehiculo(tinte: tinte),
          principal: AccionPortada(
            texto: textos.vehiculosAgendarServicio,
            icono: Icons.event_available_outlined,
            alPresionar: () => context.push(rutaAgendarCita),
          ),
          secundaria: AccionPortada(
            texto: textos.vehiculosBotonManual,
            icono: Icons.menu_book_outlined,
            alPresionar: () => context.push(rutaManualVehiculo(v.id)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              _AccionesTuAuto(
                titulo: textos.vehiculosEncabezadoTuAuto,
                acciones: [
                  (
                    texto: textos.vehiculosAccesoFicha,
                    icono: Icons.fact_check_outlined,
                    ruta: rutaFichaTecnicaVehiculo(v.id),
                  ),
                  (
                    texto: textos.vehiculosAccesoHistorial,
                    icono: Icons.history,
                    ruta: rutaHistorialVehiculo(v.id),
                  ),
                  (
                    texto: textos.mantenimientoAcceso,
                    icono: Icons.build_circle_outlined,
                    ruta: rutaMantenimientoVehiculo(v.id),
                  ),
                  (
                    texto: textos.bitacoraAccesoFila,
                    icono: Icons.local_gas_station_outlined,
                    ruta: rutaBitacoraVehiculo(v.id, nombre: v.titulo),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e6),
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
    final idioma = Localizations.localeOf(context).languageCode;
    final cierre = vehiculo.kilometrajeActualizadoEn ?? kmDelTaller?.fecha;
    final vin = vehiculo.vin;

    final String valorKm;
    final String notaKm;
    if (km == null) {
      valorKm = textos.vehiculosKmSinDato;
      notaKm = '';
    } else {
      valorKm = textos.vehiculosKilometros(
        NumberFormat.decimalPattern(idioma == 'es' ? 'es_MX' : idioma)
            .format(km),
      );
      notaKm = cierre == null
          ? textos.vehiculosKmSinActualizar
          : textos.vehiculosKmActualizado(
              MaterialLocalizations.of(context).formatFullDate(cierre),
            );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
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
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 240),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Tu auto» como cuadricula de pildoras de vidrio de dos columnas
/// (V2-M24.10), como las acciones rapidas de la propuesta.
class _AccionesTuAuto extends StatelessWidget {
  const _AccionesTuAuto({required this.titulo, required this.acciones});

  final String titulo;
  final List<({String texto, IconData icono, String ruta})> acciones;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final filas = <List<({String texto, IconData icono, String ruta})>>[
      for (var i = 0; i < acciones.length; i += 2)
        acciones.sublist(i, i + 2 > acciones.length ? acciones.length : i + 2),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            titulo,
            style: tokens.tipografia.titulo3.copyWith(
              color: tokens.colores.texto,
            ),
          ),
        ),
        const SizedBox(height: Espaciado.e3),
        for (final fila in filas) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < fila.length; i++) ...[
                if (i > 0) const SizedBox(width: Espaciado.e2),
                Expanded(
                  child: BotonPildora(
                    texto: fila[i].texto,
                    icono: fila[i].icono,
                    variante: VarianteBotonPildora.vidrio,
                    expandido: true,
                    alPresionar: () => context.push(fila[i].ruta),
                  ),
                ),
              ],
              if (fila.length == 1) ...[
                const SizedBox(width: Espaciado.e2),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
          const SizedBox(height: Espaciado.e2),
        ],
      ],
    );
  }
}
