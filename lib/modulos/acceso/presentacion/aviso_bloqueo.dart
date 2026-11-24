import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../dominio/bloqueo_por_intentos.dart';

/// Cuenta regresiva del bloqueo por intentos · V2-M01.01.
///
/// Cumple «el bloqueo por intentos muestra minutos restantes»: el numero baja
/// de verdad. La v1 armaba el texto una sola vez, al fallar, asi que a los diez
/// minutos de un bloqueo de quince seguia diciendo quince.
///
/// Va en **advertencia** y no en error: no es algo que la persona pueda
/// corregir en el formulario, es una espera, y reintentar antes no va a servir.
///
/// Al terminar **se quita solo**. Dejarlo seria pedirle que espere cuando ya
/// no hace falta.
class AvisoBloqueo extends StatefulWidget {
  const AvisoBloqueo({required this.bloqueo, required this.reloj, super.key});

  final BloqueoPorIntentos bloqueo;

  /// De donde sale «ahora». Se inyecta para que las pruebas puedan mover el
  /// tiempo sin esperarlo.
  final DateTime Function() reloj;

  @override
  State<AvisoBloqueo> createState() => _EstadoAvisoBloqueo();
}

class _EstadoAvisoBloqueo extends State<AvisoBloqueo> {
  Timer? _tictac;

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  @override
  void didUpdateWidget(AvisoBloqueo anterior) {
    super.didUpdateWidget(anterior);
    // Otro bloqueo (otro intento fallido) reinicia la cuenta.
    if (widget.bloqueo.termina != anterior.bloqueo.termina) _arrancar();
  }

  @override
  void dispose() {
    _tictac?.cancel();
    super.dispose();
  }

  void _arrancar() {
    _tictac?.cancel();
    if (widget.bloqueo.yaTermino(widget.reloj())) return;
    // Cada segundo: en el ultimo minuto se cuentan segundos, asi que un paso
    // mas largo se veria saltado.
    _tictac = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      // No se deja un temporizador corriendo detras de un aviso que ya no se
      // ve.
      if (widget.bloqueo.yaTermino(widget.reloj())) _tictac?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ahora = widget.reloj();
    if (widget.bloqueo.yaTermino(ahora)) return const SizedBox.shrink();

    final textos = AppLocalizations.of(context);
    return Aviso(
      tono: Tono.advertencia,
      titulo: textos.accesoBloqueoTitulo,
      mensaje: widget.bloqueo.seMuestraEnMinutos(ahora)
          ? textos.accesoBloqueoMinutos(widget.bloqueo.minutosRestantes(ahora))
          : textos.accesoBloqueoSegundos(
              widget.bloqueo.segundosRestantes(ahora),
            ),
    );
  }
}
