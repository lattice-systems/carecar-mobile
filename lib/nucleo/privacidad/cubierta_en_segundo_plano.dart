import 'package:flutter/material.dart';

import '../diseno/tokens/colores.dart';

/// Tapa la app cuando pasa a segundo plano (V2-M22.06).
///
/// Al quedar `inactive`, `hidden` o `paused` se pinta encima una capa opaca
/// con la marca, para que la vista previa del selector de apps no muestre
/// datos del cliente. Al volver a `resumed` se retira. En iOS la cubierta
/// nativa de `SceneDelegate` cubre el instante en que el sistema toma la
/// imagen; esta cubre Android y la transicion.
///
/// El contenido sigue montado debajo (no se pierde el estado ni la navegacion).
class CubiertaEnSegundoPlano extends StatefulWidget {
  const CubiertaEnSegundoPlano({required this.child, super.key});

  final Widget child;

  static const cubierta = Key('cubierta_segundo_plano');

  @override
  State<CubiertaEnSegundoPlano> createState() => _CubiertaEnSegundoPlanoState();
}

class _CubiertaEnSegundoPlanoState extends State<CubiertaEnSegundoPlano>
    with WidgetsBindingObserver {
  late bool _tapada = _estaTapada(
    WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed,
  );

  static bool _estaTapada(AppLifecycleState e) =>
      e != AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final tapada = _estaTapada(state);
    if (tapada != _tapada) setState(() => _tapada = tapada);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_tapada) const Positioned.fill(child: _Cubierta()),
      ],
    );
  }
}

class _Cubierta extends StatelessWidget {
  const _Cubierta();

  @override
  Widget build(BuildContext context) {
    // Esta capa vive sobre el Navigator, a veces fuera de un tema Pista: toma
    // la paleta v2 segun el brillo del sistema.
    final oscuro = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final paleta = oscuro ? PaletaColores.oscuro : PaletaColores.claro;
    return ExcludeSemantics(
      child: ColoredBox(
        key: CubiertaEnSegundoPlano.cubierta,
        color: paleta.fondo,
        child: Center(
          child: Image.asset(
            'assets/marca/agencia360-icono.png',
            width: 96,
            height: 96,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
