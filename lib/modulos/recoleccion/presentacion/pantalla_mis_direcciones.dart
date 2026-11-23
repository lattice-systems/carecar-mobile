import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/direccion_guardada.dart';
import 'componentes/marco_pantalla_recoleccion.dart';
import 'pantalla_direccion.dart';
import 'proveedores_recoleccion.dart';

/// Direcciones guardadas del cliente (V2-M17.01).
///
/// Lista estilo «inset» con el alias y la dirección; tocar una abre su edición
/// y «Agregar dirección» abre el alta. Resuelve los cinco estados: cargando,
/// datos, vacío, error con reintento y sin conexión.
class PantallaMisDirecciones extends ConsumerWidget {
  const PantallaMisDirecciones({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final direcciones = ref.watch(direccionesProvider);

    Widget estado(Widget hijo) => MarcoPantallaRecoleccion.estado(
      titulo: textos.recoleccionDireccionesTitulo,
      estado: hijo,
    );

    return direcciones.when(
      skipLoadingOnReload: true,
      loading: () => estado(const _Cargando()),
      error: (error, _) => estado(
        EstadoError(
          causa: error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(direccionesProvider),
        ),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return estado(
            EstadoVacio(
              titulo: textos.recoleccionDireccionesVacioTitulo,
              mensaje: textos.recoleccionDireccionesVacioMensaje,
              icono: Icons.location_off_outlined,
              textoAccion: textos.recoleccionDireccionesAgregar,
              alAccion: () => abrirFormularioDireccion(context),
            ),
          );
        }
        return _Lista(direcciones: lista);
      },
    );
  }
}

/// Abre el formulario de alta (o de edición con `editando`) conservando el
/// tema de la pantalla de origen.
Future<void> abrirFormularioDireccion(
  BuildContext context, {
  DireccionGuardada? editando,
}) {
  final tema = Theme.of(context);
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => Theme(
        data: tema,
        child: PantallaDireccion(editando: editando),
      ),
    ),
  );
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.direcciones});

  final List<DireccionGuardada> direcciones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return MarcoPantallaRecoleccion(
      titulo: textos.recoleccionDireccionesTitulo,
      alRefrescar: () async {
        ref.invalidate(direccionesProvider);
        await ref.read(direccionesProvider.future);
      },
      barraInferior: BarraInferiorRecoleccion(
        hijos: [
          BotonPildora(
            texto: textos.recoleccionDireccionesAgregar,
            icono: Icons.add_location_alt_outlined,
            expandido: true,
            alPresionar: () => abrirFormularioDireccion(context),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: Espaciado.e2),
            child: GrupoLista(
              encabezado: textos.recoleccionDireccionesEncabezado,
              pie: textos.recoleccionDireccionesPie,
              filas: [
                for (final d in direcciones)
                  FilaGrupo(
                    titulo: d.alias,
                    subtitulo: d.resumen,
                    icono: Icons.place_outlined,
                    colorIcono: c.acento,
                    alToque: () =>
                        abrirFormularioDireccion(context, editando: d),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).recoleccionDireccionesCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(Espaciado.e4),
          child: Column(
            children: [
              Esqueleto(alto: 72, radio: 16),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 72, radio: 16),
              SizedBox(height: Espaciado.e3),
              Esqueleto(alto: 56),
            ],
          ),
        ),
      ),
    );
  }
}
