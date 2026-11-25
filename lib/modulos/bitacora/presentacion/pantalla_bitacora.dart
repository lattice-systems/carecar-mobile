import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/estante.dart';
import '../../../nucleo/diseno/componentes/fila_acciones.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_metrica.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estadisticas.dart';
import '../dominio/gasto.dart';
import 'formato_bitacora.dart';
import 'pantalla_gasto.dart';
import 'proveedores_bitacora.dart';
import 'caminos_bitacora.dart';

/// Bitácora de un vehículo (V2-M18.01, .03 y .04).
///
/// Las dos altas («Nueva carga» y «Otro gasto») bajo el encabezado, un estante con
/// tres cifras grandes (km/l, $/km y gasto del mes), accesos a las
/// estadísticas y a la exportación, y los gastos agrupados por mes; tocar uno
/// lo edita. Resuelve los cinco estados: cargando, datos, vacío, error con
/// reintento y sin conexión.
class PantallaBitacora extends ConsumerWidget {
  const PantallaBitacora({required this.vehiculoId, super.key, this.nombre});

  final int vehiculoId;

  /// Nombre del vehículo para el subtítulo y el archivo exportado.
  final String? nombre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastos = ref.watch(gastosProvider(vehiculoId));
    final textos = AppLocalizations.of(context);

    final titulo = textos.bitacoraTitulo;
    final subtitulo = nombre ?? textos.bitacoraSubtituloSinNombre;

    return gastos.when(
      skipLoadingOnReload: true,
      loading: () => MarcoPantalla.estado(
        titulo: titulo,
        subtitulo: subtitulo,
        conRegreso: true,
        estado: const _Cargando(),
      ),
      error: (error, _) => MarcoPantalla.estado(
        titulo: titulo,
        subtitulo: subtitulo,
        conRegreso: true,
        estado: EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(gastosProvider(vehiculoId)),
        ),
      ),
      data: (lista) => _Contenido(
        vehiculoId: vehiculoId,
        nombre: nombre,
        gastos: lista,
        alRefrescar: () async {
          ref.invalidate(gastosProvider(vehiculoId));
          await ref.read(gastosProvider(vehiculoId).future);
        },
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({
    required this.vehiculoId,
    required this.nombre,
    required this.gastos,
    required this.alRefrescar,
  });

  final int vehiculoId;
  final String? nombre;
  final List<Gasto> gastos;
  final Future<void> Function() alRefrescar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final hoy = ref.read(relojBitacoraProvider)();
    final rendimiento = calcularRendimiento(gastos);
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.5);

    final porMes = <DateTime, List<Gasto>>{};
    for (final g in gastos) {
      porMes
          .putIfAbsent(DateTime(g.fecha.year, g.fecha.month), () => [])
          .add(g);
    }
    final meses = porMes.keys.toList()..sort((a, b) => b.compareTo(a));

    return MarcoPantalla(
      titulo: textos.bitacoraTitulo,
      subtitulo: nombre ?? textos.bitacoraSubtituloSinNombre,
      conRegreso: true,
      alRefrescar: alRefrescar,
      slivers: [
        SliverList.list(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
              child: FilaAcciones(
                principal: AccionPantalla(
                  texto: textos.bitacoraNuevaCarga,
                  icono: Icons.local_gas_station_outlined,
                  alPresionar: () =>
                      abrirFormularioGasto(context, vehiculoId: vehiculoId),
                ),
                secundaria: AccionPantalla(
                  texto: textos.bitacoraOtroGasto,
                  icono: Icons.receipt_long_outlined,
                  alPresionar: () => abrirFormularioGasto(
                    context,
                    vehiculoId: vehiculoId,
                    tipo: TipoGasto.estacionamiento,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Espaciado.e4),
            if (gastos.isEmpty)
              EstadoVacio(
                titulo: textos.bitacoraVacioTitulo,
                mensaje: textos.bitacoraVacioMensaje,
                icono: Icons.local_gas_station_outlined,
              )
            else ...[
              Estante(
                titulo: textos.bitacoraResumenTitulo,
                alto: 172 * escala,
                anchoTarjeta: 176,
                hijos: [
                  TarjetaMetrica(
                    cifra: rendimiento == null
                        ? textos.bitacoraCifraSinDatos
                        : textos.bitacoraCifraKmPorLitro(
                            numero(
                              context,
                              rendimiento.kmPorLitro,
                              decimales: 1,
                            ),
                          ),
                    etiqueta: textos.bitacoraEtiquetaRendimiento,
                    detalle: rendimiento == null
                        ? textos.bitacoraDetalleSinDatos
                        : null,
                  ),
                  TarjetaMetrica(
                    cifra: rendimiento == null
                        ? textos.bitacoraCifraSinDatos
                        : textos.bitacoraCifraCostoPorKm(
                            pesos(context, rendimiento.costoPorKm),
                          ),
                    etiqueta: textos.bitacoraEtiquetaCostoPorKm,
                    detalle: rendimiento == null
                        ? textos.bitacoraDetalleSinDatos
                        : null,
                  ),
                  TarjetaMetrica(
                    cifra: pesos(context, gastoDelMes(gastos, hoy)),
                    etiqueta: textos.bitacoraEtiquetaGastoMes,
                    detalle: mesLegible(context, hoy),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
                child: GrupoLista(
                  filas: [
                    FilaGrupo(
                      titulo: textos.bitacoraVerEstadisticas,
                      icono: Icons.insights_outlined,
                      colorIcono: c.acento,
                      alToque: () =>
                          context.push(rutaEstadisticasBitacora(vehiculoId)),
                    ),
                    FilaGrupo(
                      titulo: textos.bitacoraExportar,
                      icono: Icons.ios_share_outlined,
                      colorIcono: c.exito,
                      alToque: () => context.push(
                        rutaExportarBitacora(vehiculoId, nombre: nombre),
                      ),
                    ),
                  ],
                ),
              ),
              for (final mes in meses)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Espaciado.e4,
                    Espaciado.e4,
                    Espaciado.e4,
                    0,
                  ),
                  child: GrupoLista(
                    encabezado: mesLegible(context, mes),
                    filas: [
                      for (final g in porMes[mes]!)
                        _fila(context, textos, tokens, g),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  FilaGrupo _fila(
    BuildContext context,
    AppLocalizations textos,
    TokensPista tokens,
    Gasto g,
  ) {
    final c = tokens.colores;
    final nombreTipoGasto = nombreTipo(textos, g.tipo);
    final detalle = g.descripcion;
    final titulo = g.tipo == TipoGasto.otro && detalle != null
        ? detalle
        : nombreTipoGasto;
    final subtitulo = g.esCarga && g.litros != null && g.km != null
        ? textos.bitacoraDetalleCarga(
            fechaCorta(context, g.fecha),
            numero(context, g.litros!, decimales: 2),
            numero(context, g.km!),
          )
        : [
            fechaCorta(context, g.fecha),
            if (detalle != null && g.tipo != TipoGasto.otro) detalle,
          ].join(' · ');
    return FilaGrupo(
      titulo: titulo,
      subtitulo: subtitulo,
      icono: iconoTipo(g.tipo),
      colorIcono: colorTipo(tokens, g.tipo),
      fin: Text(
        pesos(context, g.monto),
        style: tokens.tipografia.cuerpoFuerte.copyWith(color: c.texto),
      ),
      alToque: () =>
          abrirFormularioGasto(context, vehiculoId: vehiculoId, editando: g),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).bitacoraCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 56),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 120),
            SizedBox(height: Espaciado.e3),
            Esqueleto(alto: 56),
          ],
        ),
      ),
    );
  }
}

/// Abre el formulario de alta (o de edición con [editando]) conservando el
/// tema de la pantalla de origen.
Future<void> abrirFormularioGasto(
  BuildContext context, {
  required int vehiculoId,
  TipoGasto tipo = TipoGasto.gasolina,
  Gasto? editando,
}) {
  final tema = Theme.of(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => Theme(
        data: tema,
        child: PantallaGasto(
          vehiculoId: vehiculoId,
          tipoInicial: tipo,
          editando: editando,
        ),
      ),
    ),
  );
}
