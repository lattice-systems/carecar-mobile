import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/pagos.dart';
import 'esqueleto_pagos.dart';
import 'formato_pagos.dart';
import 'proveedores_pagos.dart';

/// Que se eligio en la hoja de una tarjeta.
enum _Accion { predeterminar, borrar }

/// Mis tarjetas guardadas (V2-M08.04): marca, ultimos 4 y vencimiento, la
/// predeterminada primero y las vencidas marcadas. Al tocar una se puede usar
/// como predeterminada o borrar (con confirmacion). Nunca se ve el numero:
/// el servidor no lo tiene. Resuelve esqueleto, datos, vacio, error y sin
/// conexion; se recarga jalando hacia abajo.
class PantallaMetodosPago extends ConsumerStatefulWidget {
  const PantallaMetodosPago({super.key});

  static const botonPredeterminar = Key('pagos_metodo_predeterminar');
  static const botonBorrar = Key('pagos_metodo_borrar');

  @override
  ConsumerState<PantallaMetodosPago> createState() =>
      _EstadoPantallaMetodosPago();
}

class _EstadoPantallaMetodosPago extends ConsumerState<PantallaMetodosPago> {
  bool _ocupado = false;
  String? _error;

  Future<void> _abrir(MetodoPago metodo) async {
    final textos = AppLocalizations.of(context);
    final accion = await mostrarHojaInferior<_Accion>(
      context,
      titulo: textoTarjetaGuardada(textos, metodo),
      builder: (contexto) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!metodo.predeterminado) ...[
            Boton(
              key: PantallaMetodosPago.botonPredeterminar,
              texto: textos.pagosUsarPredeterminada,
              variante: VarianteBoton.secundario,
              anchoCompleto: true,
              alPresionar: () =>
                  Navigator.of(contexto).pop(_Accion.predeterminar),
            ),
            const SizedBox(height: Espaciado.e3),
          ],
          Boton(
            key: PantallaMetodosPago.botonBorrar,
            texto: textos.pagosBorrarTarjeta,
            variante: VarianteBoton.peligro,
            icono: LucideIcons300.trash2,
            anchoCompleto: true,
            alPresionar: () => Navigator.of(contexto).pop(_Accion.borrar),
          ),
        ],
      ),
    );
    if (!mounted || accion == null) return;
    switch (accion) {
      case _Accion.predeterminar:
        await _hacer(
          () => ref.read(metodosPagoProvider.notifier).predeterminar(metodo.id),
        );
      case _Accion.borrar:
        await _borrar(metodo);
    }
  }

  Future<void> _borrar(MetodoPago metodo) async {
    final textos = AppLocalizations.of(context);
    final confirmo = await mostrarDialogo<bool>(
      context,
      builder: (contexto) => Dialogo(
        titulo: textos.pagosBorrarTitulo,
        mensaje: textos.pagosBorrarMensaje(
          textoTarjetaGuardada(textos, metodo),
        ),
        textoPrincipal: textos.pagosBorrarConfirmar,
        alPrincipal: () => Navigator.of(contexto).pop(true),
        textoSecundario: textos.pagosBorrarCancelar,
        alSecundario: () => Navigator.of(contexto).pop(false),
        peligro: true,
      ),
    );
    if (confirmo != true || !mounted) return;
    await _hacer(
      () => ref.read(metodosPagoProvider.notifier).borrar(metodo.id),
    );
  }

  Future<void> _hacer(Future<void> Function() cambio) async {
    final textos = AppLocalizations.of(context);
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await cambio();
    } on SinConexion {
      if (mounted) setState(() => _error = textos.pagosSinConexion);
    } on Object {
      if (mounted) setState(() => _error = textos.pagosErrorMetodo);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.pagosMetodosTitulo;

    return ref
        .watch(metodosPagoProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            icono: LucideIcons300.creditCard,
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoPagos(
              altos: const [64, 64],
              etiqueta: textos.pagosCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            icono: LucideIcons300.creditCard,
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.pagosReintentar,
              alReintentar: () => ref.invalidate(metodosPagoProvider),
            ),
          ),
          data: (metodos) => metodos.isEmpty
              ? MarcoPantalla.estado(
                  icono: LucideIcons300.creditCard,
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.pagosMetodosVacioTitulo,
                    mensaje: textos.pagosMetodosVacioMensaje,
                    icono: LucideIcons300.creditCard,
                  ),
                )
              : MarcoPantalla(
                  icono: LucideIcons300.creditCard,
                  titulo: titulo,
                  conRegreso: true,
                  alRefrescar: () => ref.refresh(metodosPagoProvider.future),
                  slivers: [
                    SliverToBoxAdapter(
                      child: AbsorbPointer(
                        absorbing: _ocupado,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Espaciado.e4,
                            Espaciado.e2,
                            Espaciado.e4,
                            Espaciado.e4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_error case final error?) ...[
                                Aviso(mensaje: error, tono: Tono.peligro),
                                const SizedBox(height: Espaciado.e3),
                              ],
                              GrupoLista(
                                pie: textos.pagosMetodosPie,
                                filas: [
                                  for (final metodo in metodos)
                                    _fila(context, metodo),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
  }

  FilaGrupo _fila(BuildContext context, MetodoPago metodo) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final vence = textoVencimiento(metodo.mesVence, metodo.anioVence);
    final tipo = switch (metodo.tipo) {
      TipoTarjeta.credito => textos.pagosCredito,
      TipoTarjeta.debito => textos.pagosDebito,
      null => null,
    };
    final insignia = metodo.vencida
        ? textos.pagosVencidaInsignia
        : metodo.predeterminado
        ? textos.pagosPredeterminada
        : null;
    return FilaGrupo(
      llave: ValueKey('metodo-${metodo.id}'),
      titulo: textoTarjetaGuardada(textos, metodo),
      subtitulo: tipo == null
          ? textos.pagosVence(vence)
          : textos.pagosVenceYTipo(vence, tipo),
      icono: LucideIcons300.creditCard,
      colorIcono: metodo.vencida ? c.textoSecundario : c.acento,
      fin: insignia == null
          ? null
          : Insignia(
              texto: insignia,
              tono: metodo.vencida ? Tono.advertencia : Tono.exito,
            ),
      etiquetaFin: insignia,
      alToque: () => _abrir(metodo),
    );
  }
}
