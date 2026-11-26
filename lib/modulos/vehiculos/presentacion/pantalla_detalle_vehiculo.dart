import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/rebote_tactil.dart';
import '../../../nucleo/diseno/componentes/tarjeta_auto.dart';
import '../../../nucleo/diseno/componentes/tinte_auto.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
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
                icono: LucideIcons300.car,
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
                  icono: LucideIcons300.calendarCheck,
                  alPresionar: () => context.push(rutaAgendarCita),
                ),
                secundaria: AccionPantalla(
                  texto: textos.vehiculosBotonManual,
                  icono: LucideIcons300.bookOpen,
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
              _AccionesTuAuto(
                titulo: textos.vehiculosEncabezadoTuAuto,
                acciones: [
                  (
                    texto: textos.vehiculosAccesoFicha,
                    icono: LucideIcons300.clipboardCheck,
                    ruta: rutaFichaTecnicaVehiculo(v.id),
                  ),
                  (
                    texto: textos.vehiculosAccesoHistorial,
                    icono: LucideIcons300.history,
                    ruta: rutaHistorialVehiculo(v.id),
                  ),
                  (
                    texto: textos.mantenimientoAcceso,
                    icono: LucideIcons300.wrench,
                    ruta: rutaMantenimientoVehiculo(v.id),
                  ),
                  (
                    texto: textos.bitacoraAccesoFila,
                    icono: LucideIcons300.fuel,
                    ruta: rutaBitacoraVehiculo(v.id, nombre: v.titulo),
                  ),
                  (
                    texto: textos.garantiaAcceso,
                    icono: LucideIcons300.shieldCheck,
                    ruta: rutaGarantiaVehiculo(v.id),
                  ),
                  (
                    texto: textos.campanasAcceso,
                    icono: LucideIcons300.megaphone,
                    ruta: rutaCampanasVehiculo(v.id),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e6),
              GrupoLista(
                encabezado: textos.vehiculosEncabezadoDatos,
                filas: [
                  _dato(
                    LucideIcons300.hash,
                    textos.vehiculosPlacasEtiqueta,
                    sinPlacas ? textos.vehiculosSinPlacas : placas,
                    c.acento,
                  ),
                  _dato(
                    LucideIcons300.calendar,
                    textos.vehiculosAnio,
                    '${v.anio}',
                    c.marca,
                  ),
                  if (v.color != null)
                    _dato(
                      LucideIcons300.palette,
                      textos.vehiculosColor,
                      v.color!,
                      tinte,
                    ),
                  if (v.version != null)
                    _dato(
                      LucideIcons300.slidersHorizontal,
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
                            Icon(LucideIcons300.copy, color: c.acento),
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

/// «Tu auto» como cuadricula de tarjetas iguales de dos columnas (V2-M24.10):
/// cada una con su icono en un medallon y el nombre centrado debajo. Las dos
/// de una fila miden lo mismo; con letra al 200 % pasa a una sola columna para
/// que el texto no se parta ni desborde.
class _AccionesTuAuto extends StatelessWidget {
  const _AccionesTuAuto({required this.titulo, required this.acciones});

  final String titulo;
  final List<({String texto, IconData icono, String ruta})> acciones;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final escala = MediaQuery.textScalerOf(context);
    final columnas = escala.scale(1) > 1.3 ? 1 : 2;
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
        LayoutBuilder(
          builder: (context, caja) {
            // Alto unico de todas las tarjetas: se mide el nombre que mas
            // lineas ocupa (hasta tres) con el ancho real de la tarjeta, para
            // que un nombre largo no haga mas alta a una que a otra.
            final ancho =
                (caja.maxWidth - Espaciado.e3 * (columnas - 1)) / columnas -
                _TarjetaTuAuto.relleno * 2 -
                2;
            var texto = 0.0;
            for (final accion in acciones) {
              final medida = TextPainter(
                text: TextSpan(
                  text: accion.texto,
                  style: tokens.tipografia.cuerpoFuerte,
                ),
                textAlign: TextAlign.center,
                textDirection: Directionality.of(context),
                textScaler: escala,
                maxLines: _TarjetaTuAuto.lineasMaximas,
              )..layout(maxWidth: ancho);
              texto = math.max(texto, medida.height);
              medida.dispose();
            }
            final alto =
                _TarjetaTuAuto.medallon +
                Espaciado.e2 +
                texto +
                _TarjetaTuAuto.relleno * 2 +
                2;
            return GridView.count(
              crossAxisCount: columnas,
              mainAxisSpacing: Espaciado.e3,
              crossAxisSpacing: Espaciado.e3,
              mainAxisExtent: alto,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final accion in acciones)
                  _TarjetaTuAuto(
                    texto: accion.texto,
                    icono: accion.icono,
                    alToque: () => context.push(accion.ruta),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TarjetaTuAuto extends StatelessWidget {
  const _TarjetaTuAuto({
    required this.texto,
    required this.icono,
    required this.alToque,
  });

  final String texto;
  final IconData icono;
  final VoidCallback alToque;

  static const double medallon = 44;
  static const double relleno = Espaciado.e4;
  static const int lineasMaximas = 3;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    return Semantics(
      key: const Key('accion-tu-auto'),
      container: true,
      button: true,
      label: texto,
      onTap: alToque,
      excludeSemantics: true,
      child: ReboteTactil(
        child: Material(
          color: c.superficie,
          borderRadius: Radios.bordeTarjeta,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: alToque,
            splashFactory: NoSplash.splashFactory,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: Radios.bordeTarjeta,
                border: Border.all(color: c.borde),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(relleno),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: medallon,
                        height: medallon,
                        decoration: BoxDecoration(
                          color: c.acentoSuave,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icono, size: 24, color: c.acento),
                      ),
                      const SizedBox(height: Espaciado.e2),
                      Text(
                        texto,
                        maxLines: lineasMaximas,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: tokens.tipografia.cuerpoFuerte.copyWith(
                          color: c.texto,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
