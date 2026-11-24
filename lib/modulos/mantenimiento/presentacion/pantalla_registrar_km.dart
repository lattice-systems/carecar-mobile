import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/campo_texto.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/fallos_mantenimiento.dart';
import 'componentes/marco_pantalla_mantenimiento.dart';
import 'formato_mantenimiento.dart';
import 'proveedores_mantenimiento.dart';

/// Por qué no se pudo guardar el último intento.
enum _Fallo { vacio, formato, menor, servidor, red }

/// Registrar el kilometraje actual del vehículo (V2-M05.03).
///
/// No deja guardar un km vacío, cero o menor a la última lectura que se
/// conoce; si el servidor aun así lo rechaza (422 `KM_INVALIDO`) lo explica. El
/// km oficial del taller no se sobrescribe: la lectura queda como del cliente.
/// Con éxito cierra con `true` para que el plan avise y se recargue; sin
/// conexión conserva lo escrito y permite reintentar.
class PantallaRegistrarKm extends ConsumerStatefulWidget {
  const PantallaRegistrarKm({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  ConsumerState<PantallaRegistrarKm> createState() =>
      _EstadoPantallaRegistrarKm();
}

class _EstadoPantallaRegistrarKm extends ConsumerState<PantallaRegistrarKm> {
  final _controlador = TextEditingController();
  bool _enviando = false;
  _Fallo? _fallo;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// La última lectura que se conoce, si el plan ya cargó.
  int? get _ultimoKm =>
      ref.read(planMantenimientoProvider(widget.vehiculoId)).value?.kmActual;

  Future<void> _guardar() async {
    final texto = _controlador.text.trim();
    final km = int.tryParse(texto);
    final ultimo = _ultimoKm;
    if (texto.isEmpty) return setState(() => _fallo = _Fallo.vacio);
    if (km == null || km <= 0) return setState(() => _fallo = _Fallo.formato);
    if (ultimo != null && km < ultimo) {
      return setState(() => _fallo = _Fallo.menor);
    }

    setState(() {
      _enviando = true;
      _fallo = null;
    });
    try {
      await ref
          .read(repositorioMantenimientoProvider)
          .registrarKm(widget.vehiculoId, km);
      ref.invalidate(planMantenimientoProvider(widget.vehiculoId));
      if (mounted) Navigator.of(context).pop(true);
    } on KmInvalido {
      if (mounted) setState(() => _fallo = _Fallo.servidor);
    } on Object {
      if (mounted) setState(() => _fallo = _Fallo.red);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final ultimo = ref
        .watch(planMantenimientoProvider(widget.vehiculoId))
        .value
        ?.kmActual;

    final String? errorCampo = switch (_fallo) {
      _Fallo.vacio => textos.mantenimientoKmErrorVacio,
      _Fallo.formato => textos.mantenimientoKmErrorFormato,
      _Fallo.menor => textos.mantenimientoKmErrorMenor(
        formatearKm(context, ultimo ?? 0),
      ),
      _Fallo.servidor => textos.mantenimientoKmErrorServidor,
      _Fallo.red || null => null,
    };

    return MarcoPantallaMantenimiento(
      titulo: textos.mantenimientoKmTitulo,
      barraInferior: BarraInferiorMantenimiento(
        hijos: [
          if (_fallo == _Fallo.red) ...[
            Aviso(mensaje: textos.mantenimientoKmErrorRed, tono: Tono.peligro),
            const SizedBox(height: Espaciado.e3),
          ],
          Semantics(
            liveRegion: _enviando,
            label: _enviando ? textos.mantenimientoKmGuardando : null,
            child: BotonPildora(
              texto: textos.mantenimientoKmGuardar,
              icono: Icons.check_rounded,
              expandido: true,
              alPresionar: _enviando ? null : _guardar,
            ),
          ),
        ],
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(Espaciado.e4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoTexto(
                  etiqueta: textos.mantenimientoKmCampo,
                  controlador: _controlador,
                  ayuda: ultimo == null
                      ? textos.mantenimientoKmAyudaSinRegistro
                      : textos.mantenimientoKmAyuda(
                          formatearKm(context, ultimo),
                        ),
                  error: errorCampo,
                  habilitado: !_enviando,
                  teclado: TextInputType.number,
                  accionTeclado: TextInputAction.done,
                  formatos: [FilteringTextInputFormatter.digitsOnly],
                  alCambiar: (_) {
                    if (_fallo != null) setState(() => _fallo = null);
                  },
                  alEnviar: (_) => _enviando ? null : _guardar(),
                ),
                const SizedBox(height: Espaciado.e4),
                Text(
                  textos.mantenimientoKmNota,
                  style: tokens.tipografia.cuerpoChico.copyWith(
                    color: c.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
