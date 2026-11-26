import 'package:flutter/material.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/dialogo.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/radios.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../citas/citas.dart';
import '../../vehiculos/vehiculos.dart';
import 'formato_tienda.dart';

/// El esqueleto del módulo, con la forma del contenido que viene.
class EsqueletoTienda extends StatelessWidget {
  const EsqueletoTienda({required this.altos, super.key});

  final List<double> altos;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).tiendaCargando,
    liveRegion: true,
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Espaciado.e4),
      child: Column(
        children: [
          for (final alto in altos) ...[
            Esqueleto(alto: alto),
            const SizedBox(height: Espaciado.e3),
          ],
        ],
      ),
    ),
  );
}

/// El error de carga del módulo: sin conexión o genérico, con reintento.
class ErrorTienda extends StatelessWidget {
  const ErrorTienda({
    required this.error,
    required this.alReintentar,
    super.key,
  });

  final Object error;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final sinConexion = error is SinConexion;
    return EstadoError(
      causa: sinConexion ? CausaError.sinConexion : CausaError.generico,
      titulo: sinConexion ? t.tiendaSinConexionTitulo : t.tiendaErrorTitulo,
      mensaje: sinConexion ? t.tiendaSinConexionMensaje : t.tiendaErrorMensaje,
      textoReintentar: t.tiendaReintentar,
      alReintentar: alReintentar,
    );
  }
}

/// Una tarjeta del módulo para contenido propio (un renglón del carrito).
class SuperficieTienda extends StatelessWidget {
  const SuperficieTienda({required this.hijo, super.key});

  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.colores.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: Padding(padding: const EdgeInsets.all(Espaciado.e4), child: hijo),
    );
  }
}

/// El selector de citas confirmadas futuras (V2-M14.03). La elegida se marca
/// con una palomita y el lector de pantalla lo dice.
class ListaDeCitas extends StatelessWidget {
  const ListaDeCitas({
    required this.citas,
    required this.garaje,
    required this.elegida,
    required this.alElegir,
    super.key,
  });

  final List<CitaCliente> citas;
  final List<VehiculoGaraje> garaje;
  final int? elegida;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GrupoLista(
      filas: [
        for (final cita in citas)
          FilaGrupo(
            titulo: textoCita(context, cita, garaje),
            subtitulo: cita.id == elegida ? t.tiendaCitaElegida : null,
            icono: cita.id == elegida
                ? Icons.check_rounded
                : Icons.event_outlined,
            alToque: () => alElegir(cita.id),
          ),
      ],
    );
  }
}

/// Explica en un diálogo por qué no se pudo hacer algo. Con
/// [textoSecundario] ofrece otra salida y devuelve `true` si se eligió.
Future<bool> avisarFalloTienda(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String? textoSecundario,
}) async {
  final t = AppLocalizations.of(context);
  final otra = await mostrarDialogo<bool>(
    context,
    builder: (dialogo) => Dialogo(
      titulo: titulo,
      mensaje: mensaje,
      textoPrincipal: t.tiendaEntendido,
      alPrincipal: () => Navigator.of(dialogo).pop(false),
      textoSecundario: textoSecundario,
      alSecundario: textoSecundario == null
          ? null
          : () => Navigator.of(dialogo).pop(true),
    ),
  );
  return otra ?? false;
}
