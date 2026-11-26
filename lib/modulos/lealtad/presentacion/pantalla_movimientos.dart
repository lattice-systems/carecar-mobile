import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/lealtad.dart';
import 'esqueleto_lealtad.dart';
import 'formato_lealtad.dart';
import 'proveedores_lealtad.dart';

/// Movimientos de puntos (V2-M12.05), del mas nuevo, de 20 en 20: los puntos
/// (positivos en verde, negativos en el color del texto), el motivo en
/// palabras, la fecha y a que se refiere. La pagina siguiente se pide al
/// llegar al final; si falla, lo cargado se queda con un reintento. Se
/// actualiza sola con `puntos.movidos`. Resuelve esqueleto, datos, vacio,
/// error y sin conexion; se recarga jalando hacia abajo.
class PantallaMovimientos extends ConsumerWidget {
  const PantallaMovimientos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.movimientosTitulo;

    return ref
        .watch(movimientosProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EsqueletoLealtad(
              altos: const [64, 64, 64, 64],
              etiqueta: textos.lealtadCargando,
            ),
          ),
          error: (error, _) => MarcoPantalla.estado(
            titulo: titulo,
            conRegreso: true,
            estado: EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.lealtadReintentar,
              alReintentar: () => ref.invalidate(movimientosProvider),
            ),
          ),
          data: (estado) => estado.movimientos.isEmpty
              ? MarcoPantalla.estado(
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.movimientosVaciaTitulo,
                    mensaje: textos.movimientosVaciaMensaje,
                    icono: Icons.receipt_long_outlined,
                  ),
                )
              : MarcoPantalla(
                  titulo: titulo,
                  subtitulo: textos.lealtadMovimientosResumen,
                  conRegreso: true,
                  alRefrescar: () => ref.refresh(movimientosProvider.future),
                  slivers: _lista(context, ref, estado),
                ),
        );
  }

  List<Widget> _lista(
    BuildContext context,
    WidgetRef ref,
    EstadoMovimientos estado,
  ) {
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
            filas: [
              for (final m in estado.movimientos) filaMovimiento(context, m),
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
                Aviso(mensaje: textos.movimientosErrorMas, tono: Tono.peligro),
                const SizedBox(height: Espaciado.e2),
                BotonPildora(
                  texto: textos.lealtadReintentar,
                  variante: VarianteBotonPildora.vidrio,
                  icono: Icons.refresh_rounded,
                  alPresionar: () =>
                      ref.read(movimientosProvider.notifier).cargarMas(),
                ),
              ],
            ),
          ),
        )
      else if (estado.hayMas)
        SliverToBoxAdapter(
          child: _CargarAlLlegar(
            key: ValueKey(('pagina', estado.pagina)),
            etiqueta: textos.movimientosCargandoMas,
            alLlegar: () => ref.read(movimientosProvider.notifier).cargarMas(),
          ),
        ),
    ];
  }
}

/// Un movimiento como fila: motivo, fecha y referencia, y los puntos al
/// final. El lector oye «Ganaste 230 puntos» o «Usaste 300 puntos» en lugar
/// del signo (V2-T02, `etiquetaFin`).
FilaGrupo filaMovimiento(BuildContext context, MovimientoPuntos m) {
  final textos = AppLocalizations.of(context);
  final tokens = TokensPista.de(context);
  final c = tokens.colores;
  final gano = m.puntos > 0;
  final cantidad = puntosLealtad(context, m.puntos.abs());
  final fecha = fechaLealtad(context, m.creadoEn);
  final referencia = textoReferencia(textos, m);
  return FilaGrupo(
    titulo: textoMotivo(textos, m.motivo),
    subtitulo: referencia == null || m.motivo == MotivoPuntos.referido
        ? fecha
        : textos.movimientosFechaYReferencia(fecha, referencia),
    icono: switch (m.motivo) {
      MotivoPuntos.servicio => Icons.build_circle_outlined,
      MotivoPuntos.canje => Icons.card_giftcard_outlined,
      MotivoPuntos.devolucionCanje => Icons.undo_rounded,
      MotivoPuntos.referido => Icons.group_add_outlined,
      MotivoPuntos.ajuste => Icons.tune_rounded,
      MotivoPuntos.desconocido => Icons.help_outline_rounded,
    },
    colorIcono: gano ? c.exito : c.textoSecundario,
    fin: Text(
      gano ? '+$cantidad' : '−$cantidad',
      textAlign: TextAlign.end,
      style: tokens.tipografia.cuerpoFuerte.copyWith(
        color: gano ? c.exito : c.texto,
      ),
    ),
    etiquetaFin: gano
        ? textos.movimientosGanaste(cantidad)
        : textos.movimientosUsaste(cantidad),
  );
}

/// Se construye cuando el final de la lista entra en pantalla y pide la pagina
/// siguiente una sola vez. Mientras llega se ve un indicador.
class _CargarAlLlegar extends StatefulWidget {
  const _CargarAlLlegar({
    required this.etiqueta,
    required this.alLlegar,
    super.key,
  });

  final String etiqueta;
  final VoidCallback alLlegar;

  @override
  State<_CargarAlLlegar> createState() => _CargarAlLlegarState();
}

class _CargarAlLlegarState extends State<_CargarAlLlegar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.alLlegar();
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Espaciado.e4),
    child: Center(
      child: Semantics(
        label: widget.etiqueta,
        child: const SizedBox.square(
          dimension: Espaciado.e6,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
  );
}
