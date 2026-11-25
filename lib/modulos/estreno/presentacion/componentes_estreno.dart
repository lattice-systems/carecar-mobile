import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/estreno.dart';
import 'proveedores_estreno.dart';

/// Pesos sin centavos; se escriben igual en cualquier idioma.
final pesosEstreno = NumberFormat.currency(
  locale: 'es_MX',
  symbol: r'$',
  decimalDigits: 0,
);

/// Texto de un fallo para el cliente.
String textoDeFalloEstreno(AppLocalizations textos, FalloEstreno fallo) =>
    switch (fallo) {
      EstrenoSinConexion() => textos.estrenoSinConexion,
      EstrenoSinPrecio() => textos.estrenoSinPrecio,
      EstrenoDuplicada() => textos.estrenoDuplicada,
      EstrenoDatosInvalidos(:final mensaje) => mensaje,
      EstrenoNoDisponible() => textos.estrenoNoDisponible,
    };

/// El dia corto («jue 26 nov») en el idioma de la app.
String diaCortoEstreno(BuildContext context, DateTime dia) => DateFormat(
  'EEE d MMM',
  Localizations.localeOf(context).toLanguageTag(),
).format(dia);

/// Lo que se pidio y quien atiende (V2-M16.01 y V2-M16.02): la persona ve que
/// quedo registrado y con que datos antes de irse.
class ConfirmacionEstreno extends StatelessWidget {
  const ConfirmacionEstreno({
    required this.solicitud,
    required this.alVerSolicitudes,
    super.key,
  });

  final SolicitudDeEstreno solicitud;
  final VoidCallback alVerSolicitudes;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final esPrueba = solicitud.tipo == TipoSolicitud.pruebaManejo;
    final fecha = solicitud.fecha;
    final cotizacion = solicitud.cotizacion;
    final vendedor = solicitud.vendedor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Aviso(mensaje: textos.estrenoListo, tono: Tono.exito),
        const SizedBox(height: Espaciado.e3),
        GrupoLista(
          filas: [
            FilaGrupo(
              titulo: solicitud.modelo,
              subtitulo: esPrueba
                  ? textos.estrenoPruebaTitulo
                  : textos.estrenoCotizacionTitulo,
              icono: esPrueba
                  ? Icons.directions_car_outlined
                  : Icons.request_quote_outlined,
              colorIcono: c.acento,
            ),
            if (fecha != null)
              FilaGrupo(
                titulo: diaCortoEstreno(context, fecha),
                subtitulo: switch (solicitud.franja) {
                  FranjaPreferida.manana => textos.estrenoManana,
                  FranjaPreferida.tarde => textos.estrenoTarde,
                  null => null,
                },
                icono: Icons.event_outlined,
                colorIcono: c.acento,
              ),
            if (cotizacion != null)
              FilaGrupo(
                titulo: pesosEstreno.format(cotizacion.mensualidad),
                subtitulo: [
                  textos.estrenoMensualidad,
                  textos.estrenoMeses(cotizacion.plazoMeses),
                ].join(' · '),
                icono: Icons.payments_outlined,
                colorIcono: c.acento,
              ),
            if (vendedor != null)
              FilaGrupo(
                titulo: textos.estrenoTeAtiende(vendedor),
                icono: Icons.person_outline,
                colorIcono: c.acento,
              ),
          ],
        ),
        const SizedBox(height: Espaciado.e3),
        BotonPildora(
          texto: textos.estrenoVerSolicitudes,
          variante: VarianteBotonPildora.vidrio,
          expandido: true,
          alPresionar: alVerSolicitudes,
        ),
      ],
    );
  }
}

/// Titulo de seccion de los formularios de estreno.
class SeccionEstreno extends StatelessWidget {
  const SeccionEstreno({required this.titulo, required this.hijo, super.key});

  final String titulo;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    return Padding(
      padding: const EdgeInsets.only(top: Espaciado.e5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              titulo,
              style: tokens.tipografia.titulo3.copyWith(
                color: tokens.colores.texto,
              ),
            ),
          ),
          const SizedBox(height: Espaciado.e2),
          hijo,
        ],
      ),
    );
  }
}

/// Elegir una estimacion de toma a cuenta o ninguna (V2-M16.03). Si el
/// cliente no tiene estimaciones, no se muestra.
class SelectorEstimacion extends ConsumerWidget {
  const SelectorEstimacion({
    required this.elegida,
    required this.alElegir,
    super.key,
  });

  final int? elegida;
  final ValueChanged<int?> alElegir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final estimaciones = ref.watch(estimacionesParaAdjuntarProvider).value;
    if (estimaciones == null || estimaciones.isEmpty) {
      return const SizedBox.shrink();
    }
    return SeccionEstreno(
      titulo: textos.estrenoTomaACuenta,
      hijo: Wrap(
        spacing: Espaciado.e2,
        runSpacing: Espaciado.e1,
        children: [
          ChipPista(
            texto: textos.estrenoSinTomaACuenta,
            seleccionado: elegida == null,
            alCambiar: (_) => alElegir(null),
          ),
          for (final e in estimaciones)
            ChipPista(
              texto: [
                e.titulo,
                textos.calculadoraRango(
                  pesosEstreno.format(e.minimo),
                  pesosEstreno.format(e.maximo),
                ),
              ].join(' · '),
              seleccionado: elegida == e.id,
              alCambiar: (_) => alElegir(e.id),
            ),
        ],
      ),
    );
  }
}
