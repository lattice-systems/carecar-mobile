import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/datos_fiscales.dart';
import 'formato_datos_fiscales.dart';
import 'proveedores_datos_fiscales.dart';
import 'rutas_pagos.dart';

/// Mis datos fiscales (V2-M08.05): un perfil por fila con su razon social, RFC,
/// tipo de persona y regimen; el predeterminado primero y con su insignia.
/// Tocar uno abre su edicion y «Agregar datos fiscales» el alta. Resuelve los
/// cinco estados: cargando, datos, vacio, error con reintento y sin conexion.
class PantallaDatosFiscales extends ConsumerWidget {
  const PantallaDatosFiscales({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);

    Widget estado(Widget hijo) => MarcoPantalla.estado(
      icono: LucideIcons300.fileText,
      titulo: textos.datosFiscalesTitulo,
      conRegreso: true,
      estado: hijo,
    );

    return ref
        .watch(perfilesFiscalesProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => estado(
            Semantics(
              label: textos.datosFiscalesCargando,
              liveRegion: true,
              child: const Padding(
                padding: EdgeInsets.all(Espaciado.e4),
                child: Column(
                  children: [
                    Esqueleto(alto: 72),
                    SizedBox(height: Espaciado.e3),
                    Esqueleto(alto: 72),
                  ],
                ),
              ),
            ),
          ),
          error: (error, _) => estado(
            EstadoError(
              causa: error is SinConexion
                  ? CausaError.sinConexion
                  : CausaError.generico,
              textoReintentar: textos.datosFiscalesReintentar,
              alReintentar: () => ref.invalidate(perfilesFiscalesProvider),
            ),
          ),
          data: (perfiles) => perfiles.isEmpty
              ? estado(
                  EstadoVacio(
                    titulo: textos.datosFiscalesVacioTitulo,
                    mensaje: textos.datosFiscalesVacioMensaje,
                    icono: LucideIcons300.fileText,
                    textoAccion: textos.datosFiscalesAgregar,
                    alAccion: () => context.push(rutaPerfilFiscalNuevo),
                  ),
                )
              : _Lista(perfiles: perfiles),
        );
  }
}

class _Lista extends ConsumerWidget {
  const _Lista({required this.perfiles});

  final List<PerfilFiscal> perfiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    return MarcoPantalla(
      icono: LucideIcons300.fileText,
      titulo: textos.datosFiscalesTitulo,
      subtitulo: textos.datosFiscalesSubtitulo,
      conRegreso: true,
      alRefrescar: () => ref.refresh(perfilesFiscalesProvider.future),
      barraInferior: BarraInferior(
        hijos: [
          BotonPildora(
            texto: textos.datosFiscalesAgregar,
            icono: LucideIcons300.plus,
            expandido: true,
            alPresionar: () => context.push(rutaPerfilFiscalNuevo),
          ),
        ],
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: Espaciado.e2),
            child: GrupoLista(
              encabezado: textos.datosFiscalesEncabezado,
              pie: textos.datosFiscalesPie,
              filas: [for (final p in perfiles) filaPerfilFiscal(context, p)],
            ),
          ),
        ),
      ],
    );
  }
}

/// Un perfil como fila: razon social, RFC con tipo de persona y regimen, y la
/// insignia del predeterminado (que el lector oye en palabras).
FilaGrupo filaPerfilFiscal(BuildContext context, PerfilFiscal perfil) {
  final textos = AppLocalizations.of(context);
  final c = TokensPista.de(context).colores;
  return FilaGrupo(
    titulo: perfil.razonSocial,
    subtitulo: textos.datosFiscalesFilaSubtitulo(
      perfil.rfc,
      textoPersona(textos, perfil.tipoPersona),
      perfil.regimenFiscal,
    ),
    icono: LucideIcons300.fileText,
    colorIcono: perfil.predeterminado ? c.marca : c.acento,
    fin: perfil.predeterminado
        ? Insignia(texto: textos.datosFiscalesPredeterminado, tono: Tono.exito)
        : null,
    etiquetaFin: perfil.predeterminado
        ? textos.datosFiscalesPredeterminado
        : null,
    alToque: () => context.push(rutaPerfilFiscal(perfil.id)),
  );
}
