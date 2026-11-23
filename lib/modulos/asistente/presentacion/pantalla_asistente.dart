import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/burbuja_mensaje.dart';
import '../../../nucleo/diseno/componentes/campo_mensaje.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/estado_vacio.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
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
                      child: EstadoVacio(
                        titulo: textos.asistenteVacioTitulo,
                        mensaje: textos.asistenteVacioMensaje,
                        icono: Icons.auto_awesome_outlined,
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

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.mensaje,
    required this.vehiculoId,
    required this.alReintentar,
  });

  final MensajeConversacion mensaje;
  final int vehiculoId;
  final VoidCallback alReintentar;

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
    return BurbujaMensaje(
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
  }

  static String _textoDe(AppLocalizations textos, FalloAsistente fallo) =>
      switch (fallo) {
        AsistenteSinConexion() => textos.asistenteSinConexion,
        AsistenteSinManual() => textos.asistenteSinManual,
        AsistenteLimiteDiario() => textos.asistenteLimite,
        AsistenteNoDisponible() => textos.asistenteNoDisponible,
      };
}
