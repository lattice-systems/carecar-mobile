import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/cotizacion_recoleccion.dart';
import '../dominio/fallos_recoleccion.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import 'formato_pesos.dart';
import 'pantalla_mis_direcciones.dart';
import 'proveedores_recoleccion.dart';

/// Opción «Que recojan mi auto» del flujo de agendar (V2-M17.02).
///
/// Sin estado propio: quien la usa guarda si se pidió recolección y qué
/// dirección se eligió, y entra aquí con el día de la cita para cotizar. Dos
/// opciones en chips; con la de recolección se listan las direcciones
/// guardadas (con acceso a administrarlas) y, elegida una, se muestra el costo
/// y las franjas que cotiza el servidor. Si la dirección queda fuera de la
/// zona de cobertura lo dice y la recolección no se puede confirmar.
class SeleccionRecoleccion extends ConsumerWidget {
  const SeleccionRecoleccion({
    required this.pedida,
    required this.direccionId,
    required this.fecha,
    required this.alCambiarPedida,
    required this.alElegirDireccion,
    super.key,
  });

  final bool pedida;
  final int? direccionId;

  /// Día de la cita elegida; nulo mientras no se elige.
  final DateTime? fecha;
  final ValueChanged<bool> alCambiarPedida;
  final ValueChanged<int> alElegirDireccion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);

    return SeccionPantalla(
      titulo: textos.recoleccionSelectorTitulo,
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Espaciado.e2,
            runSpacing: Espaciado.e1,
            children: [
              ChipPista(
                texto: textos.recoleccionSelectorLoLlevo,
                seleccionado: !pedida,
                alCambiar: (_) => alCambiarPedida(false),
              ),
              ChipPista(
                texto: textos.recoleccionSelectorQueRecojan,
                seleccionado: pedida,
                icono: LucideIcons300.truck,
                alCambiar: (_) => alCambiarPedida(true),
              ),
            ],
          ),
          if (pedida) ...[
            const SizedBox(height: Espaciado.e4),
            _Direcciones(direccionId: direccionId, alElegir: alElegirDireccion),
            const SizedBox(height: Espaciado.e4),
            _Cotizacion(direccionId: direccionId, fecha: fecha),
          ],
        ],
      ),
    );
  }
}

class _Direcciones extends ConsumerWidget {
  const _Direcciones({required this.direccionId, required this.alElegir});

  final int? direccionId;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final direcciones = ref.watch(direccionesProvider);

    return direcciones.when(
      skipLoadingOnReload: true,
      loading: () => Semantics(
        label: textos.recoleccionDireccionesCargando,
        liveRegion: true,
        child: const Esqueleto(alto: 72, radio: 16),
      ),
      error: (error, _) => _ErrorInline(
        mensaje: error is SinConexion
            ? textos.recoleccionErrorSinConexion
            : textos.recoleccionCotizacionErrorMensaje,
        alReintentar: () => ref.invalidate(direccionesProvider),
      ),
      data: (lista) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lista.isEmpty)
            Text(
              textos.recoleccionSelectorSinDirecciones,
              style: TokensPista.de(context).tipografia.cuerpo
                  .copyWith(color: c.textoSecundario),
            )
          else
            GrupoLista(
              encabezado: textos.recoleccionSelectorDireccion,
              filas: [
                for (final d in lista)
                  FilaGrupo(
                    titulo: d.alias,
                    // La fila entera es un solo nodo para el lector de
                    // pantalla: «Elegida» va en el texto para que se escuche.
                    subtitulo: d.id == direccionId
                        ? '${textos.recoleccionSelectorElegida} · ${d.resumen}'
                        : d.resumen,
                    icono: LucideIcons300.mapPin,
                    colorIcono: c.acento,
                    fin: d.id == direccionId
                        ? Icon(LucideIcons300.circleCheck, color: c.acento)
                        : null,
                    alToque: () => alElegir(d.id),
                  ),
              ],
            ),
          const SizedBox(height: Espaciado.e3),
          BotonPildora(
            texto: lista.isEmpty
                ? textos.recoleccionDireccionesAgregar
                : textos.recoleccionSelectorAdministrar,
            icono: lista.isEmpty
                ? LucideIcons300.mapPinPlus
                : LucideIcons300.mapPinPen,
            variante: VarianteBotonPildora.vidrio,
            expandido: true,
            alPresionar: () => lista.isEmpty
                ? abrirFormularioDireccion(context)
                : _abrirLista(context),
          ),
        ],
      ),
    );
  }

  static Future<void> _abrirLista(BuildContext context) {
    final tema = Theme.of(context);
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            Theme(data: tema, child: const PantallaMisDirecciones()),
      ),
    );
  }
}

class _Cotizacion extends ConsumerWidget {
  const _Cotizacion({required this.direccionId, required this.fecha});

  final int? direccionId;
  final DateTime? fecha;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;

    Widget pista(String texto) => Text(
      texto,
      style: tokens.tipografia.cuerpoChico.copyWith(color: c.textoSecundario),
    );

    final dia = fecha;
    final id = direccionId;
    if (id == null) return pista(textos.recoleccionSelectorElegirDireccion);
    if (dia == null) return pista(textos.recoleccionSelectorElegirDia);

    final clave = (direccionId: id, fecha: dia);
    final cotizacion = ref.watch(cotizacionRecoleccionProvider(clave));
    return cotizacion.when(
      skipLoadingOnReload: true,
      loading: () => Semantics(
        label: textos.recoleccionSelectorCotizando,
        liveRegion: true,
        child: const Esqueleto(alto: 160, radio: 16),
      ),
      error: (error, _) => error is FueraDeCobertura
          ? Aviso(
              titulo: textos.recoleccionCoberturaTitulo,
              mensaje: textos.recoleccionCotizacionFueraDeCobertura,
              tono: Tono.advertencia,
            )
          : _ErrorInline(
              titulo: textos.recoleccionCotizacionErrorTitulo,
              mensaje: error is SinConexion
                  ? textos.recoleccionErrorSinConexion
                  : textos.recoleccionCotizacionErrorMensaje,
              alReintentar: () =>
                  ref.invalidate(cotizacionRecoleccionProvider(clave)),
            ),
      data: (cot) => _Detalle(cotizacion: cot),
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.cotizacion});

  final CotizacionRecoleccion cotizacion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    String ventana(VentanaHoraria v) =>
        textos.recoleccionCotizacionVentana(cotizacion.fecha, v.inicio, v.fin);

    return GrupoLista(
      encabezado: textos.recoleccionCotizacionEncabezado,
      filas: [
        FilaGrupo(
          titulo: textos.recoleccionCotizacionRecogemos,
          subtitulo: ventana(cotizacion.recoleccion),
          icono: LucideIcons300.truck,
          colorIcono: c.acento,
        ),
        FilaGrupo(
          titulo: textos.recoleccionCotizacionEntregamos,
          subtitulo: ventana(cotizacion.entrega),
          icono: LucideIcons300.house,
          colorIcono: c.exito,
        ),
        FilaGrupo(
          titulo: textos.recoleccionCotizacionPorTraslado,
          subtitulo: formatearPesos(context, cotizacion.costoPorTraslado),
          icono: LucideIcons300.arrowRightLeft,
          colorIcono: c.marca,
        ),
        FilaGrupo(
          titulo: textos.recoleccionCotizacionTotal,
          subtitulo: formatearPesos(context, cotizacion.costoTotal),
          icono: LucideIcons300.banknote,
          colorIcono: c.advertencia,
        ),
      ],
    );
  }
}

class _ErrorInline extends StatelessWidget {
  const _ErrorInline({
    required this.mensaje,
    required this.alReintentar,
    this.titulo,
  });

  final String? titulo;
  final String mensaje;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Aviso(titulo: titulo, mensaje: mensaje, tono: Tono.peligro),
        const SizedBox(height: Espaciado.e2),
        BotonPildora(
          texto: textos.recoleccionCotizacionReintentar,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
          alPresionar: alReintentar,
        ),
      ],
    );
  }
}
