import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/privacidad/estado_aviso.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../../sesion/controlador_sesion.dart';
import 'proveedores_privacidad.dart';

/// Averigua, cada vez que hay una sesión nueva, si la cuenta ya aceptó el
/// aviso de privacidad vigente y se lo dice a la guardia del enrutador
/// (V2-M22.01).
///
/// No pinta nada: envuelve la app. Mientras pregunta, la guardia retiene a la
/// persona en la puerta para que no vea el inicio un instante antes de que le
/// pidan aceptar. Si no se puede averiguar (sin conexión, error del servidor)
/// no bloquea a nadie: la falta de red no deja a la persona fuera de su auto.
/// La puerta vuelve a aparecer en cuanto se pueda leer el aviso.
class VerificadorDeAviso extends ConsumerStatefulWidget {
  const VerificadorDeAviso({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<VerificadorDeAviso> createState() => _VerificadorDeAvisoState();
}

class _VerificadorDeAvisoState extends ConsumerState<VerificadorDeAviso> {
  @override
  void initState() {
    super.initState();
    ref.listenManual<EstadoSesion>(estadoSesionProvider, (anterior, estado) {
      if (estado is Autenticada && anterior is! Autenticada) _verificar();
    });
    // Una sesión restaurada al arrancar ya está autenticada cuando esto se
    // monta: no habrá un cambio que escuchar. Se espera al cuadro porque
    // avisar al enrutador a media construcción no se puede.
    if (ref.read(estadoSesionProvider) is Autenticada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _verificar();
      });
    }
  }

  Future<void> _verificar() async {
    final estado = ref.read(estadoAvisoProvider.notifier);
    estado.verificando();
    // Otra cuenta, otro estado de aceptación: nunca se reutiliza la lectura de
    // la sesión anterior.
    ref.invalidate(avisoVigenteProvider);
    try {
      final aviso = await ref.read(avisoVigenteProvider.future);
      if (!mounted || ref.read(estadoSesionProvider) is! Autenticada) return;
      if (aviso.aceptado) {
        estado.aceptado();
      } else {
        estado.pendiente();
      }
    } catch (_) {
      // Sin conexión o error del servidor: no se bloquea a nadie.
      if (mounted && ref.read(estadoAvisoProvider) == EstadoAviso.verificando) {
        estado.noRequerido();
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
