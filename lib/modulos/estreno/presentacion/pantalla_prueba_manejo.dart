import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton_pildora.dart';
import '../../../nucleo/diseno/componentes/chip_pista.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../catalogo/catalogo.dart';
import '../dominio/estreno.dart';
import 'componentes_estreno.dart';
import 'proveedores_estreno.dart';
import 'rutas_estreno.dart';

/// Quiero probarlo (V2-M16.01): dia desde mañana, franja y, si tiene, una
/// estimacion de toma a cuenta (V2-M16.03).
class PantallaPruebaManejo extends ConsumerStatefulWidget {
  const PantallaPruebaManejo({required this.modeloId, super.key});

  final int modeloId;

  @override
  ConsumerState<PantallaPruebaManejo> createState() =>
      _PantallaPruebaManejoState();
}

class _PantallaPruebaManejoState extends ConsumerState<PantallaPruebaManejo> {
  static const _diasAMostrar = 7;

  DateTime? _dia;
  FranjaPreferida? _franja;
  int? _estimacion;
  bool _enviando = false;
  SolicitudDeEstreno? _solicitud;
  FalloEstreno? _fallo;

  Future<void> _enviar() async {
    final dia = _dia;
    final franja = _franja;
    if (dia == null || franja == null) return;
    setState(() {
      _enviando = true;
      _fallo = null;
    });
    try {
      final solicitud = await ref
          .read(repositorioEstrenoProvider)
          .pedirPrueba(
            modeloId: widget.modeloId,
            fecha: dia,
            franja: franja,
            estimacionId: _estimacion,
          );
      ref.invalidate(misSolicitudesProvider);
      if (mounted) setState(() => _solicitud = solicitud);
    } on FalloEstreno catch (fallo) {
      if (mounted) setState(() => _fallo = fallo);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final hoy = ref.watch(relojEstrenoProvider)();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    final dias = [
      for (var i = 0; i < _diasAMostrar; i++)
        DateTime(manana.year, manana.month, manana.day + i),
    ];
    final modelo = ref.watch(detalleModeloProvider(widget.modeloId)).value;

    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(title: Text(textos.estrenoPruebaTitulo)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Espaciado.e4),
          children: [
            if (modelo != null)
              Text(
                modelo.modelo.titulo,
                style: TokensPista.de(context).tipografia.titulo2
                    .copyWith(color: c.texto),
              ),
            if (_solicitud case final solicitud?) ...[
              const SizedBox(height: Espaciado.e4),
              ConfirmacionEstreno(
                solicitud: solicitud,
                alVerSolicitudes: () =>
                    context.pushReplacement(rutaMisSolicitudesEstreno),
              ),
            ] else ...[
              SeccionEstreno(
                titulo: textos.estrenoDia,
                hijo: Wrap(
                  spacing: Espaciado.e2,
                  runSpacing: Espaciado.e1,
                  children: [
                    for (final d in dias)
                      ChipPista(
                        texto: diaCortoEstreno(context, d),
                        seleccionado: _dia == d,
                        alCambiar: (_) => setState(() => _dia = d),
                      ),
                  ],
                ),
              ),
              SeccionEstreno(
                titulo: textos.estrenoFranja,
                hijo: Wrap(
                  spacing: Espaciado.e2,
                  runSpacing: Espaciado.e1,
                  children: [
                    ChipPista(
                      texto: textos.estrenoManana,
                      seleccionado: _franja == FranjaPreferida.manana,
                      alCambiar: (_) =>
                          setState(() => _franja = FranjaPreferida.manana),
                    ),
                    ChipPista(
                      texto: textos.estrenoTarde,
                      seleccionado: _franja == FranjaPreferida.tarde,
                      alCambiar: (_) =>
                          setState(() => _franja = FranjaPreferida.tarde),
                    ),
                  ],
                ),
              ),
              SelectorEstimacion(
                elegida: _estimacion,
                alElegir: (id) => setState(() => _estimacion = id),
              ),
              if (_fallo != null) ...[
                const SizedBox(height: Espaciado.e4),
                Aviso(
                  mensaje: textoDeFalloEstreno(textos, _fallo!),
                  tono: _fallo is EstrenoDuplicada
                      ? Tono.informacion
                      : Tono.peligro,
                ),
              ],
              const SizedBox(height: Espaciado.e5),
              BotonPildora(
                texto: _enviando
                    ? textos.estrenoEnviando
                    : textos.estrenoEnviar,
                expandido: true,
                alPresionar: _enviando || _dia == null || _franja == null
                    ? null
                    : _enviar,
              ),
              AccesoMisSolicitudes(
                alToque: () => context.push(rutaMisSolicitudesEstreno),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
