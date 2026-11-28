import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/idioma/proveedores_idioma.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';
import '../../../sesion/controlador_sesion.dart';
import 'coordinador_de_push.dart';
import 'estado_avisos.dart';
import 'proveedores_push.dart';

/// Engancha el registro del token de push a la app (V2-M06.02): no pinta
/// nada, solo envuelve a [child].
///
/// Le avisa al [CoordinadorDePush] cuando cambian la sesión o el permiso de
/// avisos (V2-M06.01) y cuando la app vuelve a primer plano, que es cuando
/// se reintenta un registro que falló sin red. Registra la baja con
/// `registrarAntesDeCerrarSesion` para que corra mientras el access token
/// todavía vale. `main.dart` lo pone una sola vez por encima de la app.
class RegistradorDePush extends ConsumerStatefulWidget {
  const RegistradorDePush({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RegistradorDePush> createState() => _RegistradorDePushState();
}

class _RegistradorDePushState extends ConsumerState<RegistradorDePush>
    with WidgetsBindingObserver {
  late final CoordinadorDePush _coordinador;
  late final void Function() _quitarBaja;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coordinador = CoordinadorDePush(
      servicio: ref.read(servicioPushProvider),
      repositorio: () => ref.read(repositorioDispositivosProvider),
      instalacion: () => ref.read(instalacionDeLaAppProvider).obtener(),
      plataforma: ref.read(plataformaPushProvider),
      idioma: _idioma,
    );
    _quitarBaja = ref
        .read(controladorSesionProvider)
        .registrarAntesDeCerrarSesion(_coordinador.alCerrarSesion);
    ref.listenManual(estadoSesionProvider, (_, _) => _avisar());
    ref.listenManual(permisoDeAvisosProvider, (_, _) => _avisar());
    _avisar();
  }

  void _avisar() => unawaited(
    _coordinador.alCambiar(
      haySesion: ref.read(estadoSesionProvider) is Autenticada,
      permitidos: ref.read(permisoDeAvisosProvider) == EstadoAvisos.permitidos,
    ),
  );

  /// El idioma en que la persona usa la app; el servidor solo redacta en
  /// español e inglés, así que cualquier otro va como español.
  String _idioma() {
    final codigo =
        ref.read(idiomaElegidoProvider)?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return codigo == 'en' ? 'en' : 'es';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _avisar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _quitarBaja();
    _coordinador.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
