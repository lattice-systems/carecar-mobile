import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/guia_emergencia.dart';
import 'rutas_asistencia.dart';
import 'textos_guias.dart';

/// Lista de guias de emergencia (V2-M11.03).
///
/// Las guias vienen empaquetadas en la app: no hay carga, vacio ni error de
/// red, asi que la lista siempre esta lista y se ve igual en modo avion.
class PantallaGuias extends StatelessWidget {
  const PantallaGuias({super.key});

  static IconData _icono(TipoGuia tipo) => switch (tipo) {
    TipoGuia.llanta => Icons.tire_repair_outlined,
    TipoGuia.corriente => Icons.battery_charging_full_outlined,
    TipoGuia.choque => Icons.car_crash_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;

    return Scaffold(
      appBar: AppBar(title: Text(textos.asistenciaGuiasTitulo)),
      body: ListView(
        padding: const EdgeInsets.all(Espaciado.e4),
        children: [
          Aviso(mensaje: textos.asistenciaGuiasAvisoSinConexion),
          const SizedBox(height: Espaciado.e4),
          for (final guia in guiasDeEmergencia)
            FilaLista(
              titulo: textos.tituloDeGuia(guia.tipo),
              subtitulo: textos.resumenDeGuia(guia.tipo),
              inicio: Icon(_icono(guia.tipo), color: c.acento),
              alToque: () => context.go(rutaGuiaDeEmergencia(guia.tipo)),
            ),
        ],
      ),
    );
  }
}
