import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/pagos.dart';
import 'esqueleto_pagos.dart';
import 'formato_pagos.dart';
import 'proveedores_pagos.dart';
import 'rutas_pagos.dart';

/// Mis pagos (V2-M08.07), del mas nuevo, de 20 en 20: la orden, el estado, con
/// que y cuando, y el monto. La pagina siguiente se pide al llegar al final;
/// si falla, lo cargado se queda con un reintento. Se actualiza sola con
/// `pago.confirmado`. Desde aqui se llega a las tarjetas guardadas. Resuelve
/// esqueleto, datos, vacio, error y sin conexion; se recarga jalando hacia
/// abajo.
class PantallaMisPagos extends ConsumerWidget {
  const PantallaMisPagos({super.key});

  static const botonMetodos = Key('pagos_metodos');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.pagosMisPagosTitulo;
    final acciones = [
      BotonCircular(
        key: botonMetodos,
        etiqueta: textos.pagosMetodosTitulo,
        icono: LucideIcons300.creditCard,
        alPresionar: () => context.push(rutaMetodosPago),
      ),
    ];

    return ref
        .watch(pagosProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoPagos(
              altos: const [64, 64, 64, 64],
              etiqueta: textos.pagosCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.pagosReintentar,
              alReintentar: () => ref.invalidate(pagosProvider),
            ),
          ),
          data: (estado) => estado.pagos.isEmpty
              ? MarcoPantalla(
                  titulo: titulo,
                  conRegreso: true,
                  acciones: acciones,
                  alRefrescar: () => ref.refresh(pagosProvider.future),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EstadoVacio(
                        titulo: textos.pagosMisPagosVacioTitulo,
                        mensaje: textos.pagosMisPagosVacioMensaje,
                        icono: LucideIcons300.receiptText,
                      ),
                    ),
                  ],
                )
              : MarcoPantalla(
                  titulo: titulo,
                  subtitulo: textos.pagosMisPagosSubtitulo,
                  conRegreso: true,
                  acciones: acciones,
                  alRefrescar: () => ref.refresh(pagosProvider.future),
                  slivers: _lista(context, ref, estado),
                ),
        );
  }

  List<Widget> _lista(BuildContext context, WidgetRef ref, EstadoPagos estado) {
    final textos = AppLocalizations.of(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Espaciado.e4,
            Espaciado.e2,
            Espaciado.e4,
            0,
          ),
          child: GrupoLista(
            pie: textos.pagosSimuladoPie,
            filas: [
              for (final pago in estado.pagos)
                filaPago(
                  context,
                  pago,
                  alToque: () => context.push(rutaPago(pago.id)),
                ),
            ],
          ),
        ),
      ),
      if (estado.errorAlCargarMas)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              children: [
                Aviso(mensaje: textos.pagosErrorCargarMas, tono: Tono.peligro),
                const SizedBox(height: Espaciado.e2),
                BotonPildora(
                  texto: textos.pagosReintentar,
                  variante: VarianteBotonPildora.vidrio,
                  icono: LucideIcons300.refreshCw,
                  alPresionar: () =>
                      ref.read(pagosProvider.notifier).cargarMas(),
                ),
              ],
            ),
          ),
        )
      else if (estado.hayMas)
        SliverToBoxAdapter(
          child: CargarAlLlegar(
            key: ValueKey(('pagina', estado.pagina)),
            etiqueta: textos.pagosCargandoMas,
            alLlegar: () => ref.read(pagosProvider.notifier).cargarMas(),
          ),
        ),
    ];
  }
}

/// Un pago como fila: la orden, el estado y la fecha con que se pago, y el
/// monto al final. El lector oye el monto en palabras con su estado.
FilaGrupo filaPago(BuildContext context, Pago pago, {VoidCallback? alToque}) {
  final textos = AppLocalizations.of(context);
  final tokens = TokensPista.de(context);
  final c = tokens.colores;
  final estado = textoEstadoPago(textos, pago.estado);
  final monto = pesos(context, pago.monto);
  return FilaGrupo(
    llave: ValueKey('pago-${pago.id}'),
    titulo: textos.pagosOrden('${pago.ordenId}'),
    subtitulo: textos.pagosFilaSubtitulo(
      estado,
      textoMedio(textos, pago),
      fechaPago(context, pago.pagadoEn ?? pago.creadoEn),
    ),
    icono: switch (pago.estado) {
      EstadoPago.pagado => LucideIcons300.circleCheckBig,
      EstadoPago.pendiente => LucideIcons300.hourglass,
      EstadoPago.fallido => LucideIcons300.circleX,
      EstadoPago.reembolsado => LucideIcons300.undo2,
    },
    colorIcono: switch (pago.estado) {
      EstadoPago.pagado => c.exito,
      EstadoPago.pendiente => c.advertencia,
      EstadoPago.fallido => c.peligro,
      EstadoPago.reembolsado => c.acento,
    },
    fin: Text(
      monto,
      textAlign: TextAlign.end,
      style: tokens.tipografia.cuerpoFuerte.copyWith(
        color: pago.estado == EstadoPago.pagado ? c.texto : c.textoSecundario,
      ),
    ),
    etiquetaFin: textos.pagosMontoConEstado(monto, estado),
    alToque: alToque,
  );
}
