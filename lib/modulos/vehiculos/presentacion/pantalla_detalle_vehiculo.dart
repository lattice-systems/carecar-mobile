import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/cabecera_portada.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/presentacion/rutas_citas.dart';
import '../dominio/vehiculo_garaje.dart';
import 'portada_vehiculo.dart';
import 'proveedores_vehiculos.dart';
import 'rutas_vehiculos.dart';

/// Detalle de un vehiculo del garaje en estilo portada (V2-M02.02): el auto
/// como portada con sus acciones, VIN copiable y kilometraje con la fecha en
/// que el taller lo actualizo, datos del auto y accesos a manual, ficha tecnica
/// e historial.
///
/// Manual (V2-M02.03) y ficha tecnica (V2-M02.04) abren su pantalla; el
/// historial (V2-M02.05) aun no la tiene: se ve sin accion y dice
/// "Disponible pronto" en vez de fallar. Resuelve los cinco estados; si el id
/// ya no esta en el garaje lo explica.
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
      appBar: AppBar(
        title: Text(textos.vehiculosDetalleTitulo),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
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
                child: _Detalle(vehiculo: v),
              ),
      ),
    );
  }
}

class _Detalle extends StatefulWidget {
  const _Detalle({required this.vehiculo});

  final VehiculoGaraje vehiculo;

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
              const SizedBox(height: Espaciado.e4),
              GrupoLista(
                encabezado: textos.vehiculosEncabezadoTuAuto,
                filas: [
                  FilaGrupo(
                    titulo: textos.vehiculosAccesoManuales,
                    icono: Icons.menu_book_outlined,
                    colorIcono: c.acento,
                    alToque: () => context.push(rutaManualVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.vehiculosAccesoFicha,
                    icono: Icons.fact_check_outlined,
                    colorIcono: c.exito,
                    alToque: () => context.push(rutaFichaTecnicaVehiculo(v.id)),
                  ),
                  FilaGrupo(
                    titulo: textos.vehiculosAccesoHistorial,
                    subtitulo: textos.vehiculosAccesoPronto,
                    icono: Icons.history,
                    colorIcono: c.textoTerciario,
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
  const _TarjetaCifras({required this.vehiculo, required this.alCopiarVin});

  final VehiculoGaraje vehiculo;
  final VoidCallback? alCopiarVin;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final km = vehiculo.kilometraje;
    final idioma = Localizations.localeOf(context).languageCode;
    final cierre = vehiculo.kilometrajeActualizadoEn;
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
                label:
                    '${textos.vehiculosVin}. $vin. '
                    '${textos.vehiculosCopiarVin}',
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
