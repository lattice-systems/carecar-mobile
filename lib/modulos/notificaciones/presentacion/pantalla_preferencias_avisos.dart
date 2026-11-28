import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/control_binario.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/aviso_cliente.dart';
import '../dominio/preferencias_de_avisos.dart';
import 'proveedores_preferencias.dart';

/// Elegir que avisos recibir y el horario silencioso · V2-M06.05.
///
/// **No hay boton de guardar**: cada interruptor guarda al tocarse. Una
/// pantalla de interruptores con boton obliga a recordar que falta confirmar,
/// y la mitad de la gente se sale sin tocarlo.
class PantallaPreferenciasAvisos extends ConsumerWidget {
  const PantallaPreferenciasAvisos({super.key});

  static const interruptorSilencio = Key('preferencias_silencio');
  static const avisoFallo = Key('preferencias_fallo');
  static const botonDesde = Key('preferencias_desde');
  static const botonHasta = Key('preferencias_hasta');

  static Key categoria(CategoriaDeAviso c) => Key('preferencias_${c.name}');

  /// El orden en que se muestran. `desconocida` no aparece: no es una
  /// categoria real, solo el refugio de una que esta version no conoce.
  static const _orden = [
    CategoriaDeAviso.taller,
    CategoriaDeAviso.citas,
    CategoriaDeAviso.mantenimiento,
    CategoriaDeAviso.documentos,
    CategoriaDeAviso.mensajes,
    CategoriaDeAviso.promociones,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final estado = ref.watch(preferenciasDeAvisosProvider);

    if (estado.hasError && !estado.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.preferenciasAvisosTitulo,
        conRegreso: true,
        estado: EstadoError(
          causa: estado.error is SinConexion
              ? CausaError.sinConexion
              : CausaError.generico,
          alReintentar: () => ref.invalidate(preferenciasDeAvisosProvider),
        ),
      );
    }
    if (!estado.hasValue) {
      return MarcoPantalla.estado(
        titulo: textos.preferenciasAvisosTitulo,
        conRegreso: true,
        estado: Semantics(
          label: textos.preferenciasAvisosCargando,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final p = estado.requireValue;
    final notifier = ref.read(preferenciasDeAvisosProvider.notifier);

    return MarcoPantalla(
      titulo: textos.preferenciasAvisosTitulo,
      subtitulo: textos.preferenciasAvisosSubtitulo,
      conRegreso: true,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (notifier.ultimoFallo) ...[
                  Aviso(
                    key: avisoFallo,
                    tono: Tono.advertencia,
                    titulo: textos.preferenciasAvisosFalloTitulo,
                    mensaje: textos.preferenciasAvisosFalloMensaje,
                  ),
                  const SizedBox(height: Espaciado.e4),
                ],
                // Los interruptores van sueltos y no en `GrupoLista`: ese
                // widget envuelve sus filas en `Semantics(excludeSemantics)`,
                // asi que el lector de pantalla no leeria el control.
                for (final c in _orden)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Espaciado.e2),
                    child: Interruptor(
                      key: categoria(c),
                      etiqueta: _etiqueta(textos, c),
                      descripcion: _descripcion(textos, c),
                      valor: p.porCategoria[c] ?? false,
                      alCambiar: (valor) => notifier.cambiar(c, valor),
                    ),
                  ),
                const SizedBox(height: Espaciado.e5),
                _Silencio(preferencias: p),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _etiqueta(AppLocalizations t, CategoriaDeAviso c) => switch (c) {
    CategoriaDeAviso.taller => t.preferenciasAvisosTaller,
    CategoriaDeAviso.citas => t.preferenciasAvisosCitas,
    CategoriaDeAviso.mantenimiento => t.preferenciasAvisosMantenimiento,
    CategoriaDeAviso.documentos => t.preferenciasAvisosDocumentos,
    CategoriaDeAviso.mensajes => t.preferenciasAvisosMensajes,
    CategoriaDeAviso.promociones => t.preferenciasAvisosPromociones,
    CategoriaDeAviso.desconocida => t.preferenciasAvisosOtros,
  };

  String? _descripcion(AppLocalizations t, CategoriaDeAviso c) => switch (c) {
    CategoriaDeAviso.taller => t.preferenciasAvisosTallerDetalle,
    CategoriaDeAviso.citas => t.preferenciasAvisosCitasDetalle,
    CategoriaDeAviso.promociones => t.preferenciasAvisosPromocionesDetalle,
    _ => null,
  };
}

/// El horario silencioso: un interruptor y dos horas.
class _Silencio extends ConsumerWidget {
  const _Silencio({required this.preferencias});

  final PreferenciasDeAvisos preferencias;

  static const _porOmision = HorarioSilencioso(
    desde: HoraDelDia(22, 0),
    hasta: HoraDelDia(7, 0),
  );

  Future<void> _elegir(
    BuildContext context,
    WidgetRef ref, {
    required bool esDesde,
  }) async {
    final silencio = preferencias.silencio ?? _porOmision;
    final actual = esDesde ? silencio.desde : silencio.hasta;
    final elegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: actual.hora, minute: actual.minuto),
    );
    if (elegida == null) return;
    final nueva = HoraDelDia(elegida.hour, elegida.minute);
    await ref
        .read(preferenciasDeAvisosProvider.notifier)
        .ponerHorario(
          esDesde
              ? HorarioSilencioso(desde: nueva, hasta: silencio.hasta)
              : HorarioSilencioso(desde: silencio.desde, hasta: nueva),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final notifier = ref.read(preferenciasDeAvisosProvider.notifier);
    final silencio = preferencias.silencio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Interruptor(
          key: PantallaPreferenciasAvisos.interruptorSilencio,
          etiqueta: textos.preferenciasAvisosSilencio,
          descripcion: textos.preferenciasAvisosSilencioDetalle,
          valor: preferencias.haySilencio,
          alCambiar: (valor) => valor
              ? notifier.ponerHorario(_porOmision)
              : notifier.quitarHorario(),
        ),
        if (silencio != null) ...[
          const SizedBox(height: Espaciado.e3),
          Row(
            children: [
              Expanded(
                child: Boton(
                  key: PantallaPreferenciasAvisos.botonDesde,
                  texto: textos.preferenciasAvisosDesde(
                    silencio.desde.aTexto(),
                  ),
                  variante: VarianteBoton.secundario,
                  alPresionar: () => _elegir(context, ref, esDesde: true),
                ),
              ),
              const SizedBox(width: Espaciado.e2),
              Expanded(
                child: Boton(
                  key: PantallaPreferenciasAvisos.botonHasta,
                  texto: textos.preferenciasAvisosHasta(
                    silencio.hasta.aTexto(),
                  ),
                  variante: VarianteBoton.secundario,
                  alPresionar: () => _elegir(context, ref, esDesde: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: Espaciado.e2),
          // Que cruce la medianoche es el caso normal, no un error: conviene
          // decirlo para que nadie crea que lo configuro mal.
          Text(
            silencio.desde.compareTo(silencio.hasta) > 0
                ? textos.preferenciasAvisosCruzaMedianoche
                : textos.preferenciasAvisosMismoDia,
            style: tokens.tipografia.cuerpoChico.copyWith(
              color: tokens.colores.textoSecundario,
            ),
          ),
        ],
      ],
    );
  }
}
