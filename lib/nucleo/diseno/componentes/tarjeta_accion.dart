import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';
import 'tono.dart';

/// Tarjeta tocable para una accion rapida: icono, titulo y descripcion corta.
/// Ejemplo: "Agendar cita" o "Pedir ayuda".
///
/// Con `tono` distinto de neutro el icono y el fondo toman el color del estado
/// (por ejemplo `Tono.peligro` para ayuda en el camino). Mide al menos 48 y se
/// anuncia como un solo boton. Con `alToque` nulo queda deshabilitada.
class TarjetaAccion extends StatelessWidget {
  const TarjetaAccion({
    required this.titulo,
    required this.icono,
    required this.alToque,
    super.key,
    this.descripcion,
    this.tono = Tono.neutro,
  });

  final String titulo;
  final String? descripcion;
  final IconData icono;
  final VoidCallback? alToque;
  final Tono tono;

  static const double _tamanoIcono = 24;
  static const double _medallon = 44;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final habilitada = alToque != null;
    final resaltada = tono != Tono.neutro;
    final colores = ColoresTono.de(tono, c);
    final colorIcono = !habilitada
        ? c.textoTerciario
        : (resaltada ? colores.frente : c.acento);
    final fondoMedallon = !habilitada
        ? c.superficieHundida
        : (resaltada ? colores.fondo : c.acentoSuave);

    return Semantics(
      container: true,
      button: true,
      enabled: habilitada,
      label: descripcion == null ? titulo : '$titulo. $descripcion',
      onTap: alToque,
      excludeSemantics: true,
      child: ReboteTactil(
        habilitado: habilitada,
        child: Material(
          color: c.superficie,
          borderRadius: Radios.bordeTarjeta,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: alToque,
            splashFactory: NoSplash.splashFactory,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: Radios.bordeTarjeta,
                border: Border.all(color: c.borde),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.all(Espaciado.e3),
                  child: Row(
                    children: [
                      Container(
                        width: _medallon,
                        height: _medallon,
                        decoration: BoxDecoration(
                          color: fondoMedallon,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icono,
                          size: _tamanoIcono,
                          color: colorIcono,
                        ),
                      ),
                      const SizedBox(width: Espaciado.e3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              titulo,
                              style: t.cuerpoFuerte.copyWith(
                                color: habilitada ? c.texto : c.textoTerciario,
                              ),
                            ),
                            if (descripcion != null)
                              Text(
                                descripcion!,
                                style: t.cuerpoChico.copyWith(
                                  color: habilitada
                                      ? c.textoSecundario
                                      : c.textoTerciario,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
