import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../manuales/guardar_pdf.dart';
import '../../../manuales/servicio_manuales.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/campo_busqueda_liquido.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_acciones_pildora.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/indice_de_manual.dart';
import 'proveedores_vehiculos.dart';

/// Manual del vehiculo por su modelo y ano (V2-M02.03): visor de PDF con zoom
/// de pellizco, busqueda de texto, descarga y compartir.
///
/// El manual sale de la agencia y, si no hay o no hay red, del PDF incluido en
/// la app. Resuelve los cinco estados. `fabricaVisor` solo existe para probar
/// sin el motor nativo de PDF.
class PantallaManual extends ConsumerStatefulWidget {
  const PantallaManual({
    required this.vehiculoId,
    super.key,
    this.fabricaVisor,
    this.paginaInicial,
  });

  final int vehiculoId;
  final FabricaVisorPdf? fabricaVisor;

  /// Pagina en la que abre el manual (V2-M24.04, la que cito el asistente).
  final int? paginaInicial;

  @override
  ConsumerState<PantallaManual> createState() => _PantallaManualState();
}

class _PantallaManualState extends ConsumerState<PantallaManual> {
  /// `null` sin aviso; verdadero = guardado, falso = fallo al guardar.
  bool? _guardado;

  /// Panel de busqueda abierto.
  bool _buscando = false;
  String _consulta = '';

  /// Pagina a la que saltó la ultima busqueda; manda sobre `paginaInicial`.
  int? _pagina;

  Future<void> _descargar(DocumentoManual manual) async {
    bool? resultado;
    try {
      final r = await ref.read(guardarManualProvider)(
        manual.bytes,
        manual.titulo,
      );
      resultado = r == ResultadoGuardado.guardado ? true : null;
    } on Exception {
      resultado = false;
    }
    if (mounted) setState(() => _guardado = resultado);
  }

  Future<void> _compartir(DocumentoManual manual) => ref.read(
    compartirManualProvider,
  )(manual.bytes, nombreArchivoPdf(manual.titulo));

  void _irAPagina(int pagina) => setState(() {
    _pagina = pagina;
    _buscando = false;
    _consulta = '';
  });

  @override
  Widget build(BuildContext context) {
    final manual = ref.watch(manualProvider(widget.vehiculoId));
    final indice = ref
        .watch(indiceDeManualProvider(widget.vehiculoId))
        .asData
        ?.value;
    final textos = AppLocalizations.of(context);
    final doc = manual.asData?.value;

    return Scaffold(
      backgroundColor: TokensPista.de(context).colores.fondo,
      body: Column(
        children: [
          // El visor necesita todo el alto posible: la pantalla es una barra
          // fija con las acciones del documento, no un encabezado grande.
          BarraPantalla(
            titulo: textos.vehiculosManualTitulo,
            subtitulo: doc?.titulo,
            acciones: [
              if (doc != null)
                GrupoAccionesPildora(
                  acciones: [
                    if (indice != null)
                      AccionIcono(
                        icono: _buscando ? Icons.close : Icons.search_outlined,
                        etiqueta: _buscando
                            ? textos.vehiculosManualBuscarCerrar
                            : textos.vehiculosManualBuscarAccion,
                        alPresionar: () =>
                            setState(() => _buscando = !_buscando),
                      ),
                    AccionIcono(
                      icono: Icons.download_outlined,
                      etiqueta: textos.vehiculosBotonDescargar,
                      alPresionar: () => _descargar(doc),
                    ),
                    AccionIcono(
                      icono: Icons.share_outlined,
                      etiqueta: textos.vehiculosBotonCompartir,
                      alPresionar: () => _compartir(doc),
                    ),
                  ],
                ),
            ],
          ),
          if (_guardado != null)
            Padding(
              padding: const EdgeInsets.all(Espaciado.e3),
              child: Aviso(
                mensaje: _guardado!
                    ? textos.vehiculosManualGuardado
                    : textos.vehiculosManualGuardadoError,
                tono: _guardado! ? Tono.exito : Tono.peligro,
                alCerrar: () => setState(() => _guardado = null),
              ),
            ),
          Expanded(
            child: manual.when(
              skipLoadingOnReload: true,
              loading: () => const _Cargando(),
              error: (error, _) => EstadoError(
                causa: error is SinConexion
                    ? CausaError.sinConexion
                    : CausaError.generico,
                alReintentar: () =>
                    ref.invalidate(manualProvider(widget.vehiculoId)),
              ),
              data: (m) => m == null
                  ? EstadoVacio(
                      titulo: textos.vehiculosManualVacioTitulo,
                      mensaje: textos.vehiculosManualVacioMensaje,
                      icono: Icons.menu_book_outlined,
                    )
                  : Stack(
                      children: [
                        _visor(m, textos),
                        if (_buscando && indice != null)
                          _PanelBusqueda(
                            indice: indice,
                            consulta: _consulta,
                            alCambiar: (q) => setState(() => _consulta = q),
                            alElegir: _irAPagina,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visor(DocumentoManual m, AppLocalizations textos) {
    final descripcion = textos.vehiculosManualDescripcion(m.titulo);
    Future<Uint8List> cargar() async => m.bytes;
    final fabrica = widget.fabricaVisor;
    final pagina = _pagina ?? widget.paginaInicial ?? 1;
    // La clave con la pagina reconstruye el visor cuando la busqueda salta: el
    // componente solo acepta la pagina al crearse.
    return fabrica == null
        ? VisorPdf(
            key: ValueKey('visor-$pagina'),
            cargar: cargar,
            descripcion: descripcion,
            paginaInicial: pagina,
          )
        : VisorPdf(
            key: ValueKey('visor-$pagina'),
            cargar: cargar,
            descripcion: descripcion,
            fabrica: fabrica,
            paginaInicial: pagina,
          );
  }
}

/// Panel que cubre el visor mientras se busca: campo y resultados que, al
/// tocarse, abren esa pagina del manual (V2-M02.03).
class _PanelBusqueda extends StatelessWidget {
  const _PanelBusqueda({
    required this.indice,
    required this.consulta,
    required this.alCambiar,
    required this.alElegir,
  });

  final IndiceDeManual indice;
  final String consulta;
  final ValueChanged<String> alCambiar;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final resultados = indice.buscar(consulta);
    final corta = consulta.trim().length < 2;

    return Positioned.fill(
      child: ColoredBox(
        color: c.fondo,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Espaciado.e4),
              child: CampoBusquedaLiquido(
                sugerencia: textos.vehiculosManualBuscarSugerencia,
                autoFoco: true,
                alCambiar: alCambiar,
                alLimpiar: () => alCambiar(''),
              ),
            ),
            Expanded(
              child: corta
                  ? _Aviso(texto: textos.vehiculosManualBuscarAyuda)
                  : resultados.isEmpty
                  ? EstadoVacio(
                      titulo: textos.vehiculosManualSinResultados(consulta),
                      icono: Icons.search_off_outlined,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Espaciado.e4,
                        0,
                        Espaciado.e4,
                        Espaciado.e6,
                      ),
                      children: [
                        GrupoLista(
                          filas: [
                            for (final r in resultados)
                              FilaGrupo(
                                titulo: textos.vehiculosManualResultadoPagina(
                                  r.pagina,
                                ),
                                subtitulo: r.fragmento,
                                icono: Icons.menu_book_outlined,
                                colorIcono: c.acento,
                                alToque: () => alElegir(r.pagina),
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = TokensPista.de(context).colores;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espaciado.e6),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TokensPista.de(context).tipografia.cuerpo
              .copyWith(color: c.textoSecundario),
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
      label: AppLocalizations.of(context).vehiculosManualCargando,
      liveRegion: true,
      child: const Padding(
        padding: EdgeInsets.all(Espaciado.e4),
        child: Column(
          children: [
            Expanded(child: Esqueleto(alto: double.infinity)),
            SizedBox(height: Espaciado.e3),
            Esqueleto.linea(),
          ],
        ),
      ),
    );
  }
}
