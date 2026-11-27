import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/camara/selector_foto.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/burbuja_mensaje.dart';
import '../../../nucleo/diseno/componentes/campo_mensaje.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/hoja_inferior.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../asistencia/asistencia.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/repositorio_asistente.dart';
import 'proveedores_asistente.dart';

/// Pregúntale a tu auto (V2-M24.03): chat con el asistente sobre el manual de
/// un vehiculo. Las respuestas citan la pagina del manual; tocar la cita abre
/// el manual. El aviso de IA esta siempre visible (ADR 0007).
class PantallaAsistente extends ConsumerStatefulWidget {
  const PantallaAsistente({
    required this.vehiculoId,
    super.key,
    this.preguntaInicial,
  });

  final int vehiculoId;

  /// Pregunta que se envia al abrir (V2-M24.10, desde la tarjeta del detalle
  /// del vehiculo). Solo si la conversacion esta vacia.
  final String? preguntaInicial;

  @override
  ConsumerState<PantallaAsistente> createState() => _PantallaAsistenteState();
}

class _PantallaAsistenteState extends ConsumerState<PantallaAsistente> {
  @override
  void initState() {
    super.initState();
    final pregunta = widget.preguntaInicial?.trim();
    if (pregunta == null || pregunta.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final proveedor = conversacionAsistenteProvider(widget.vehiculoId);
      if (ref.read(proveedor).isEmpty) {
        ref.read(proveedor.notifier).preguntar(pregunta);
      }
    });
  }

  /// Se nego el permiso de camara o fotos (V2-M24.05).
  bool _sinPermiso = false;

  Future<void> _tomarFoto() async {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final origen = await mostrarHojaInferior<OrigenFoto>(
      context,
      titulo: textos.asistenteFotoAdjuntar,
      builder: (hoja) => GrupoLista(
        filas: [
          FilaGrupo(
            titulo: textos.asistenteFotoTomar,
            icono: LucideIcons300.camera,
            colorIcono: c.acento,
            alToque: () => Navigator.of(hoja).pop(OrigenFoto.camara),
          ),
          FilaGrupo(
            titulo: textos.asistenteFotoGaleria,
            icono: LucideIcons300.images,
            colorIcono: c.marca,
            alToque: () => Navigator.of(hoja).pop(OrigenFoto.galeria),
          ),
        ],
      ),
    );
    if (origen == null || !mounted) return;
    final selector = ref.read(selectorFotoProvider);
    final FotoElegida? foto;
    try {
      foto = await selector.elegir(origen);
    } on PermisoFotoDenegado {
      if (mounted) setState(() => _sinPermiso = true);
      return;
    }
    if (foto == null || !mounted) return;
    setState(() => _sinPermiso = false);
    await ref
        .read(conversacionAsistenteProvider(widget.vehiculoId).notifier)
        .identificar(foto);
  }

  @override
  Widget build(BuildContext context) => _ContenidoAsistente(
    vehiculoId: widget.vehiculoId,
    alTomarFoto: _tomarFoto,
    sinPermiso: _sinPermiso,
    alAbrirAjustes: () => ref.read(selectorFotoProvider).abrirAjustes(),
  );
}

class _ContenidoAsistente extends ConsumerWidget {
  const _ContenidoAsistente({
    required this.vehiculoId,
    required this.alTomarFoto,
    required this.sinPermiso,
    required this.alAbrirAjustes,
  });

  final int vehiculoId;
  final VoidCallback alTomarFoto;
  final bool sinPermiso;
  final VoidCallback alAbrirAjustes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final proveedor = conversacionAsistenteProvider(vehiculoId);
    final mensajes = ref.watch(proveedor);
    final conversacion = ref.read(proveedor.notifier);
    final esperando = mensajes.any((m) => m.envio == EnvioPregunta.enviando);
    // Con texto en camino, la burbuja que crece reemplaza a «Buscando…».
    final escribiendo = mensajes.any((m) => m.escribiendo);

    // La lista va al reves para que lo nuevo quede abajo, junto al campo.
    final elementos = <Widget>[
      for (var i = 0; i < mensajes.length; i++)
        _Mensaje(
          mensaje: mensajes[i],
          vehiculoId: vehiculoId,
          alReintentar: () => conversacion.reintentar(i),
          alCalificar: (util) => conversacion.calificar(i, util),
        ),
      if (esperando && !escribiendo)
        BurbujaMensaje(
          texto:
              mensajes
                      .lastWhere((m) => m.envio == EnvioPregunta.enviando)
                      .foto ==
                  null
              ? textos.asistentePensando
              : textos.asistenteRevisandoFoto,
          autor: AutorMensaje.ajeno,
          nombreAutor: textos.asistenteNombre,
        ),
    ].reversed.toList();

    return Scaffold(
      backgroundColor: c.fondo,
      body: Column(
        children: [
          BarraPantalla(titulo: textos.asistenteTitulo),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Los avisos no pueden comerse la conversación con letra
                  // grande: ocupan un tercio como mucho y se desplazan.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height / 3,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (sinPermiso)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Espaciado.e4,
                                Espaciado.e2,
                                Espaciado.e4,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Aviso(
                                    mensaje: textos.asistentePermisoCamara,
                                    tono: Tono.advertencia,
                                  ),
                                  const SizedBox(height: Espaciado.e2),
                                  BotonPildora(
                                    texto: textos.asistenteAbrirAjustes,
                                    icono: LucideIcons300.settings,
                                    variante: VarianteBotonPildora.vidrio,
                                    alPresionar: alAbrirAjustes,
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Espaciado.e4,
                              Espaciado.e2,
                              Espaciado.e4,
                              0,
                            ),
                            child: Aviso(
                              mensaje: textos.asistenteAvisoIa,
                              tono: Tono.informacion,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: mensajes.isEmpty
                        ? CentradoDesplazable(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EstadoVacio(
                                  titulo: textos.asistenteVacioTitulo,
                                  mensaje: textos.asistenteVacioMensaje,
                                  icono: LucideIcons300.sparkles,
                                ),
                                _PreguntasSugeridas(
                                  alElegir: conversacion.preguntar,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            reverse: true,
                            padding: const EdgeInsets.all(Espaciado.e4),
                            itemCount: elementos.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: Espaciado.e3),
                            itemBuilder: (_, i) => elementos[i],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Espaciado.e3,
                      0,
                      Espaciado.e3,
                      Espaciado.e3,
                    ),
                    child: CampoMensaje(
                      alEnviar: conversacion.preguntar,
                      alAdjuntar: alTomarFoto,
                      iconoAdjuntar: LucideIcons300.camera,
                      etiquetaAdjuntar: textos.asistenteFotoAdjuntar,
                      habilitado: !esperando,
                      sugerencia: textos.asistenteSugerencia,
                      etiquetaEnviar: textos.asistenteEnviar,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Preguntas sugeridas con la conversacion vacia (V2-M24.08). La lista es
/// generica y vive en la app; tocar una la envia como pregunta.
class _PreguntasSugeridas extends StatelessWidget {
  const _PreguntasSugeridas({required this.alElegir});

  final ValueChanged<String> alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final preguntas = [
      textos.asistentePreguntaMantenimiento,
      textos.asistentePreguntaLlantas,
      textos.asistentePreguntaTestigos,
      textos.asistentePreguntaAceite,
      textos.asistentePreguntaGasolina,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              textos.asistenteSugerenciasTitulo,
              style: tokens.tipografia.etiqueta.copyWith(
                color: tokens.colores.textoSecundario,
              ),
            ),
          ),
          const SizedBox(height: Espaciado.e2),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Espaciado.e2,
            children: [
              for (final pregunta in preguntas)
                ChipPista(
                  texto: pregunta,
                  seleccionado: false,
                  alCambiar: (_) => alElegir(pregunta),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.mensaje,
    required this.vehiculoId,
    required this.alReintentar,
    required this.alCalificar,
  });

  final MensajeConversacion mensaje;
  final int vehiculoId;
  final VoidCallback alReintentar;
  final ValueChanged<bool> alCalificar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    if (mensaje.autor == AutorConversacion.cliente) {
      return BurbujaMensaje(
        texto: mensaje.foto == null
            ? mensaje.texto
            : textos.asistenteFotoEnviada,
        autor: AutorMensaje.propio,
        nombreAutor: textos.asistenteTu,
        estado: mensaje.envio == EnvioPregunta.fallida
            ? EstadoEnvio.fallido
            : null,
        alReintentar: alReintentar,
        textoFallido: textos.asistenteNoSeEnvio,
        textoReintentar: textos.asistenteReintentar,
      );
    }
    final fallo = mensaje.fallo;
    final testigo = mensaje.testigo;
    if (fallo == null && testigo != null && !testigo.reconocido) {
      return BurbujaMensaje(
        texto: textos.asistenteTestigoNoReconocido,
        autor: AutorMensaje.ajeno,
        nombreAutor: textos.asistenteNombre,
      );
    }
    final burbuja = BurbujaMensaje(
      texto: fallo == null ? mensaje.texto : _textoDe(textos, fallo),
      autor: AutorMensaje.ajeno,
      nombreAutor: textos.asistenteNombre,
      fuentes: [
        for (final cita in mensaje.fuentes)
          FuenteMensaje(
            texto: textos.asistenteFuente(cita.pagina),
            etiquetaLector: textos.asistenteFuenteLector(cita.pagina),
            alTocar: () => context.push(
              rutaManualVehiculo(vehiculoId, pagina: cita.pagina),
            ),
          ),
      ],
    );
    if (fallo != null || mensaje.escribiendo) return burbuja;
    final gravedad = testigo?.gravedad;
    final roja = gravedad == GravedadTestigo.roja;
    // Un testigo informativo no necesita taller (V2-M24.05).
    final ofrecerAgendar = gravedad != GravedadTestigo.informativa;
    // V2-M24.06: atender el problema sin volver a explicarlo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (testigo != null) ...[
          _EncabezadoTestigo(testigo: testigo),
          const SizedBox(height: Espaciado.e2),
          if (roja) ...[
            Aviso(mensaje: textos.asistenteTestigoDetente, tono: Tono.peligro),
            const SizedBox(height: Espaciado.e2),
          ],
        ],
        burbuja,
        const SizedBox(height: Espaciado.e2),
        Wrap(
          spacing: Espaciado.e1,
          runSpacing: Espaciado.e1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (roja)
              BotonPildora(
                texto: textos.asistentePedirAyuda,
                icono: LucideIcons300.siren,
                alPresionar: () => context.push(rutaPedirAyuda),
              ),
            if (ofrecerAgendar)
              BotonPildora(
                texto: textos.asistenteAgendarRevision,
                icono: LucideIcons300.calendarCheck,
                variante: VarianteBotonPildora.vidrio,
                alPresionar: () => context.push(
                  rutaAgendarCitaCon(
                    vehiculoId: vehiculoId,
                    motivo: MotivoCita.revision,
                  ),
                ),
              ),
            if (mensaje.consultaId != null) ...[
              BotonCircular(
                etiqueta: textos.asistenteMeSirvio,
                icono: LucideIcons300.thumbsUp,
                iconoMarcado: LucideIcons300.thumbsUp,
                marcado: mensaje.util == true,
                alPresionar: () => alCalificar(true),
              ),
              BotonCircular(
                etiqueta: textos.asistenteNoMeSirvio,
                icono: LucideIcons300.thumbsDown,
                iconoMarcado: LucideIcons300.thumbsDown,
                marcado: mensaje.util == false,
                alPresionar: () => alCalificar(false),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static String _textoDe(AppLocalizations textos, FalloAsistente fallo) =>
      switch (fallo) {
        AsistenteSinConexion() => textos.asistenteSinConexion,
        AsistenteSinManual() => textos.asistenteSinManual,
        AsistenteLimiteDiario() => textos.asistenteLimite,
        AsistenteNoDisponible() => textos.asistenteNoDisponible,
      };
}

/// Nombre del testigo con su gravedad en una insignia que lleva texto, no
/// solo color (V2-M24.05).
class _EncabezadoTestigo extends StatelessWidget {
  const _EncabezadoTestigo({required this.testigo});

  final TestigoDelTablero testigo;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final (texto, tono) = switch (testigo.gravedad) {
      GravedadTestigo.roja => (textos.asistenteTestigoRoja, Tono.peligro),
      GravedadTestigo.amarilla => (
        textos.asistenteTestigoAmarilla,
        Tono.advertencia,
      ),
      GravedadTestigo.informativa => (
        textos.asistenteTestigoInformativa,
        Tono.informacion,
      ),
    };
    return Semantics(
      header: true,
      child: Wrap(
        spacing: Espaciado.e2,
        runSpacing: Espaciado.e1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            testigo.nombre ?? '',
            style: tokens.tipografia.titulo3.copyWith(
              color: tokens.colores.texto,
            ),
          ),
          Insignia(texto: texto, tono: tono, conIcono: true),
        ],
      ),
    );
  }
}
