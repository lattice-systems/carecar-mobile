import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_circular.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/burbuja_mensaje.dart';
import '../../../nucleo/diseno/componentes/campo_mensaje.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import '../dominio/repositorio_asistente.dart';
import 'proveedores_asistente.dart';

/// Pregúntale a tu auto (V2-M24.03): chat con el asistente sobre el manual de
/// un vehiculo. Las respuestas citan la pagina del manual; tocar la cita abre
/// el manual. El aviso de IA esta siempre visible (ADR 0007).
class PantallaAsistente extends ConsumerWidget {
  const PantallaAsistente({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final proveedor = conversacionAsistenteProvider(vehiculoId);
    final mensajes = ref.watch(proveedor);
    final conversacion = ref.read(proveedor.notifier);
    final esperando = mensajes.any((m) => m.envio == EnvioPregunta.enviando);

    // La lista va al reves para que lo nuevo quede abajo, junto al campo.
    final elementos = <Widget>[
      for (var i = 0; i < mensajes.length; i++)
        _Mensaje(
          mensaje: mensajes[i],
          vehiculoId: vehiculoId,
          alReintentar: () => conversacion.reintentar(i),
          alCalificar: (util) => conversacion.calificar(i, util),
        ),
      if (esperando)
        BurbujaMensaje(
          texto: textos.asistentePensando,
          autor: AutorMensaje.ajeno,
          nombreAutor: textos.asistenteNombre,
        ),
    ].reversed.toList();

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(title: Text(textos.asistenteTitulo)),
      body: SafeArea(
        child: Column(
          children: [
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
            Expanded(
              child: mensajes.isEmpty
                  ? CentradoDesplazable(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EstadoVacio(
                            titulo: textos.asistenteVacioTitulo,
                            mensaje: textos.asistenteVacioMensaje,
                            icono: Icons.auto_awesome_outlined,
                          ),
                          _PreguntasSugeridas(alElegir: conversacion.preguntar),
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
                habilitado: !esperando,
                sugerencia: textos.asistenteSugerencia,
                etiquetaEnviar: textos.asistenteEnviar,
              ),
            ),
          ],
        ),
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
        texto: mensaje.texto,
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
    final burbuja = BurbujaMensaje(
      texto: fallo == null ? mensaje.texto : _textoDe(textos, fallo),
      autor: AutorMensaje.ajeno,
      nombreAutor: textos.asistenteNombre,
      fuentes: [
        for (final cita in mensaje.fuentes)
          FuenteMensaje(
            texto: textos.asistenteFuente(cita.pagina),
            etiquetaLector: textos.asistenteFuenteLector(cita.pagina),
            alTocar: () => context.push(rutaManualVehiculo(vehiculoId)),
          ),
      ],
    );
    if (fallo != null) return burbuja;
    // V2-M24.06: atender el problema sin volver a explicarlo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        burbuja,
        const SizedBox(height: Espaciado.e2),
        Wrap(
          spacing: Espaciado.e1,
          runSpacing: Espaciado.e1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BotonPildora(
              texto: textos.asistenteAgendarRevision,
              icono: Icons.event_available_outlined,
              variante: VarianteBotonPildora.tonal,
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
                icono: Icons.thumb_up_outlined,
                iconoMarcado: Icons.thumb_up,
                marcado: mensaje.util == true,
                alPresionar: () => alCalificar(true),
              ),
              BotonCircular(
                etiqueta: textos.asistenteNoMeSirvio,
                icono: Icons.thumb_down_outlined,
                iconoMarcado: Icons.thumb_down,
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
