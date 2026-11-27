import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/biometria/candado_biometrico.dart';
import '../../../nucleo/biometria/lector_biometrico.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/centrado_desplazable.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import '../../../nucleo/sesion/proveedores_sesion.dart';

/// Desbloqueo con huella o rostro · V2-M01.05.
///
/// Aparece al abrir la app cuando hay sesion guardada y el candado esta
/// prendido. **No es un login**: la sesion ya existe, esto solo decide si la
/// app se abre sin escribir la contrasena.
///
/// Siempre hay salida con la contrasena. Es el requisito que vuelve segura la
/// comodidad: si la huella deja de funcionar -el sensor, un dedo mojado, la
/// biometria borrada- nadie se queda fuera de su cuenta.
class PantallaDesbloqueo extends ConsumerStatefulWidget {
  const PantallaDesbloqueo({super.key});

  static const botonIntentar = Key('desbloqueo_intentar');
  static const botonContrasena = Key('desbloqueo_contrasena');
  static const avisoCambio = Key('desbloqueo_cambio');
  static const avisoFallo = Key('desbloqueo_fallo');

  @override
  ConsumerState<PantallaDesbloqueo> createState() =>
      _EstadoPantallaDesbloqueo();
}

class _EstadoPantallaDesbloqueo extends ConsumerState<PantallaDesbloqueo> {
  bool _pidiendo = false;
  bool _fallo = false;

  /// La biometria del equipo ya no es la de cuando se prendio el candado.
  bool _cambio = false;

  @override
  void initState() {
    super.initState();
    // Se pide en cuanto la pantalla existe: hacer que la persona toque un boton
    // para que luego aparezca el del sistema es un toque de mas en el camino
    // que mas se repite.
    WidgetsBinding.instance.addPostFrameCallback((_) => _intentar());
  }

  Future<void> _intentar() async {
    if (_pidiendo) return;
    final textos = AppLocalizations.of(context);
    final lector = ref.read(lectorBiometricoProvider);
    final candado = ref.read(candadoProvider.notifier);

    // Sin lector o sin biometria utilizable no hay nada que intentar: se apaga
    // el candado y se pide la contrasena, que es la unica salida que queda.
    if (lector == null || !await lector.disponible()) {
      await candado.apagar();
      if (mounted) setState(() => _cambio = true);
      return;
    }

    if (biometriaCambio(
      guardada: candado.firmaGuardada,
      ahora: await lector.firma(),
    )) {
      // Criterio de la historia: si cambio la biometria del equipo se pide la
      // contrasena. El candado se apaga para que se vuelva a prender a
      // conciencia, con la firma nueva.
      await candado.apagar();
      if (mounted) setState(() => _cambio = true);
      return;
    }

    setState(() {
      _pidiendo = true;
      _fallo = false;
    });
    final reconocido = await lector.identificar(
      motivo: textos.desbloqueoMotivo,
    );
    if (!mounted) return;

    if (reconocido) {
      candado.abrir();
      GoRouter.of(context).go(Rutas.inicio);
      return;
    }
    setState(() {
      _pidiendo = false;
      _fallo = true;
    });
  }

  /// Sale por la puerta de la contrasena: cierra la sesion y vuelve al login.
  ///
  /// Se cierra de verdad -no solo se navega- porque si no, la guardia volveria
  /// a traer aqui en cuanto se intente ir a otra pantalla.
  Future<void> _conContrasena() async {
    final router = GoRouter.of(context);
    await ref.read(controladorSesionProvider).cerrarSesion();
    router.go(Rutas.acceso);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);

    return Scaffold(
      body: SafeArea(
        child: CentradoDesplazable(
          child: Padding(
            padding: const EdgeInsets.all(Espaciado.e5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    LucideIcons300.fingerprint,
                    size: 40,
                    color: tokens.colores.acento,
                  ),
                  const SizedBox(height: Espaciado.e4),
                  Text(
                    textos.desbloqueoTitulo,
                    style: tokens.tipografia.titulo2,
                  ),
                  const SizedBox(height: Espaciado.e2),
                  Text(
                    textos.desbloqueoExplicacion,
                    style: tokens.tipografia.cuerpo.copyWith(
                      color: tokens.colores.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: Espaciado.e5),
                  if (_cambio) ...[
                    Aviso(
                      key: PantallaDesbloqueo.avisoCambio,
                      tono: Tono.advertencia,
                      titulo: textos.desbloqueoCambioTitulo,
                      mensaje: textos.desbloqueoCambioMensaje,
                    ),
                    const SizedBox(height: Espaciado.e4),
                  ] else if (_fallo) ...[
                    Aviso(
                      key: PantallaDesbloqueo.avisoFallo,
                      tono: Tono.advertencia,
                      titulo: textos.desbloqueoFalloTitulo,
                      mensaje: textos.desbloqueoFalloMensaje,
                    ),
                    const SizedBox(height: Espaciado.e4),
                  ],
                  // Cuando la biometria cambio no se ofrece reintentar: no hay
                  // nada que reintentar hasta que se vuelva a prender.
                  if (!_cambio) ...[
                    Boton(
                      key: PantallaDesbloqueo.botonIntentar,
                      texto: textos.desbloqueoIntentar,
                      alPresionar: _pidiendo ? null : _intentar,
                      cargando: _pidiendo,
                      anchoCompleto: true,
                    ),
                    const SizedBox(height: Espaciado.e2),
                  ],
                  Boton(
                    key: PantallaDesbloqueo.botonContrasena,
                    texto: textos.desbloqueoContrasena,
                    variante: _cambio
                        ? VarianteBoton.principal
                        : VarianteBoton.terciario,
                    alPresionar: _conContrasena,
                    anchoCompleto: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
