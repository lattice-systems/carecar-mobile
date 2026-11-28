import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tarjeta_resumen.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/documento_vehiculo.dart';
import 'formato_documentos.dart';
import 'proveedores_documentos.dart';
import 'rutas_documentos.dart';

/// Los documentos del vehiculo con su estado (V2-M09.01): una portada que
/// resume lo que necesita atencion y, debajo, las listas agrupadas por estado
/// de lo mas urgente a lo menos (vencidos, por vencer, vigentes y sin fecha),
/// cada documento con su insignia.
///
/// El estado lo calcula el servidor con la fecha de la agencia, asi que se
/// pide de nuevo cada vez que se abre la pantalla o se jala para recargar.
/// Resuelve los cinco estados: cargando con esqueleto, datos, vacio, error con
/// reintento y sin conexion.
class PantallaDocumentos extends ConsumerWidget {
  const PantallaDocumentos({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final titulo = textos.documentosTitulo;

    return ref
        .watch(documentosProvider(vehiculoId))
        .when(
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
              alReintentar: () =>
                  ref.invalidate(documentosProvider(vehiculoId)),
            ),
          ),
          data: (documentos) => documentos.isEmpty
              ? MarcoPantalla.estado(
                  titulo: titulo,
                  conRegreso: true,
                  estado: EstadoVacio(
                    titulo: textos.documentosVaciaTitulo,
                    mensaje: textos.documentosVaciaMensaje,
                    textoAccion: GoRouter.maybeOf(context) == null
                        ? null
                        : textos.documentosCalendario,
                    alAccion: GoRouter.maybeOf(context) == null
                        ? null
                        : () => context.push(rutaCalendarioDocumentos),
                    icono: LucideIcons300.folderOpen,
                  ),
                )
              : _Documentos(
                  documentos: documentos,
                  alRefrescar: () =>
                      ref.refresh(documentosProvider(vehiculoId).future),
                ),
        );
  }
}

class _Documentos extends StatelessWidget {
  const _Documentos({required this.documentos, required this.alRefrescar});

  final List<DocumentoVehiculo> documentos;
  final Future<void> Function() alRefrescar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);

    // De lo mas urgente a lo menos; dentro de cada grupo se conserva el orden
    // del servidor (por vencimiento).
    final grupos = <(EstadoDocumento, String)>[
      (EstadoDocumento.vencido, textos.documentosGrupoVencidos),
      (EstadoDocumento.porVencer, textos.documentosGrupoPorVencer),
      (EstadoDocumento.vigente, textos.documentosGrupoVigentes),
      (EstadoDocumento.sinFecha, textos.documentosGrupoSinFecha),
    ];

    return MarcoPantalla(
      titulo: textos.documentosTitulo,
      subtitulo: textos.documentosSubtitulo(documentos.length),
      conRegreso: true,
      alRefrescar: alRefrescar,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              const SizedBox(height: Espaciado.e2),
              _Portada(documentos: documentos),
              FilaLista(
                titulo: textos.documentosCalendario,
                inicio: const Icon(LucideIcons300.calendarDays),
                alToque: GoRouter.maybeOf(context) == null
                    ? null
                    : () => context.push(rutaCalendarioDocumentos),
              ),
              for (final (estado, encabezado) in grupos)
                if (documentos.any((d) => d.estado == estado)) ...[
                  const SizedBox(height: Espaciado.e6),
                  GrupoLista(
                    encabezado: encabezado,
                    filas: [
                      for (final documento in documentos)
                        if (documento.estado == estado)
                          _fila(context, documento),
                    ],
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }

  FilaGrupo _fila(BuildContext context, DocumentoVehiculo documento) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final tono = tonoEstado(documento.estado);
    final estado = textoEstado(textos, documento.estado);
    return FilaGrupo(
      titulo: nombreDocumento(textos, documento),
      subtitulo: subtituloDocumento(context, documento),
      icono: iconoTipo(documento.tipo),
      colorIcono: ColoresTono.de(tono, c).frente,
      fin: Insignia(texto: estado, tono: tono, conIcono: true),
      etiquetaFin: estado,
    );
  }
}

/// La portada: cuantos documentos piden atencion y cual es el mas urgente, o
/// que todo esta en orden. El color acompana al icono y al texto, no los
/// sustituye.
class _Portada extends StatelessWidget {
  const _Portada({required this.documentos});

  final List<DocumentoVehiculo> documentos;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final conAtencion = [
      for (final documento in documentos)
        if (documento.estado == EstadoDocumento.vencido ||
            documento.estado == EstadoDocumento.porVencer)
          documento,
    ];

    if (conAtencion.isEmpty) {
      return TarjetaResumen(
        titulo: textos.documentosResumenAlDia,
        detalle: textos.documentosResumenAlDiaDetalle,
        icono: LucideIcons300.fileCheck,
        tono: Tono.exito,
      );
    }

    // El servidor las manda por vencimiento: la primera es la mas urgente.
    final urgente = conAtencion.first;
    final cuando = cuandoVence(textos, urgente);
    final nombre = nombreDocumento(textos, urgente);
    final vencido = conAtencion.any((d) => d.estado == EstadoDocumento.vencido);
    return TarjetaResumen(
      titulo: textos.documentosResumenAtencion(conAtencion.length),
      detalle: cuando == null
          ? null
          : urgente.estado == EstadoDocumento.vencido
          ? textos.documentosResumenVencio(nombre, cuando)
          : textos.documentosResumenVence(nombre, cuando),
      icono: vencido ? LucideIcons300.fileWarning : LucideIcons300.clock,
      tono: vencido ? Tono.peligro : Tono.advertencia,
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).documentosCargando,
      liveRegion: true,
      child: const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Esqueleto(alto: 96, radio: 28),
            SizedBox(height: Espaciado.e6),
            Esqueleto(alto: 56),
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
