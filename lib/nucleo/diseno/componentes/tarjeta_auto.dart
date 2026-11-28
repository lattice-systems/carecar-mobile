import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'rebote_tactil.dart';
import 'silueta_auto.dart';

/// La tarjeta del auto: un bloque de color con su silueta, el modelo, las
/// placas y el kilometraje. Es lo único con color pleno de la pantalla en la
/// que aparece (el inicio, el garaje, el detalle del vehículo), así que el auto
/// es siempre lo primero que se ve.
///
/// Todos los textos llegan ya formateados y traducidos; la tarjeta solo los
/// coloca. Sin `titulo` (cuando el encabezado de la pantalla ya lo dice) queda
/// la silueta con las placas y el kilometraje. `tinte` es el color del auto
/// (ver `tinteDeColorAuto`); sin él usa el acento. Con `alToque` toda la tarjeta
/// es un botón. `etiqueta` es lo que lee el lector de pantalla: por omisión, los
/// textos en orden.
///
/// Con `foto` (la ruta de un asset, ver `fotoDeModelo`) es una tarjeta como
/// [TarjetaResumen]: misma superficie, radio, sombra y letra, con la foto real
/// del modelo arriba y el nombre y los datos debajo (V2-T02.27).
///
/// Con letra grande las placas bajan debajo del nombre y la tarjeta crece.
class TarjetaAuto extends StatelessWidget {
  const TarjetaAuto({
    super.key,
    this.titulo,
    this.marca,
    this.placas,
    this.kilometraje,
    this.tinte,
    this.alToque,
    this.etiqueta,
    this.alto,
    this.foto,
  });

  /// Ruta del asset con la foto del modelo; sin ella va la silueta.
  final String? foto;

  final String? titulo;
  final String? marca;
  final String? placas;

  /// Kilometraje ya formateado, por ejemplo «18,450 km».
  final String? kilometraje;
  final Color? tinte;
  final VoidCallback? alToque;
  final String? etiqueta;

  /// Alto fijo; por omisión depende de si hay título y del tamaño de letra.
  final double? alto;

  /// Alto por omisión con letra a 100 %.
  static const double altoBase = 232;
  static const double _altoSinTitulo = 188;

  /// Alto que le toca con esta escala de letra.
  static double altoPara({required bool conTitulo, required double escala}) =>
      (conTitulo ? altoBase : _altoSinTitulo) +
      (escala - 1).clamp(0.0, 1.0) * 190;

  /// Alto con foto: la foto toma lo fijo y los textos crecen con la letra.
  static double altoConFoto({required double escala}) =>
      _altoConFoto + (escala - 1).clamp(0.0, 1.0) * 60;
  static const double _altoConFoto = 264;

  /// Por encima de esta escala las placas bajan bajo el nombre.
  static const double _escalaPlacasAbajo = 1.3;

  @override
  Widget build(BuildContext context) {
    if (foto != null) return _conFoto(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final oscuro = tokens.brillo == Brightness.dark;
    final escala = MediaQuery.textScalerOf(context).scale(1);
    final placasAbajo = escala > _escalaPlacasAbajo;
    final conPlacas = (placas ?? '').isNotEmpty;
    // `sobreAcento` es el color que el sistema define para leer sobre un
    // relleno saturado: blanco en claro, casi negro en oscuro.
    final frente = c.sobreAcento;
    final color = tinte ?? c.acento;
    // Con el acento (el de siempre) el degradado baja hacia el marino de la
    // marca; con el color propio de un auto, a una variante de su tonalidad.
    final fin = color == c.acento
        ? Color.lerp(c.acento, c.marca, 0.85)!
        : _variar(color, oscuro: oscuro);
    final suave = frente.withValues(alpha: 0.85);

    final detalle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons300.gauge, size: 16, color: suave),
        const SizedBox(width: Espaciado.e1),
        Flexible(
          child: Text(
            kilometraje ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.cuerpoChico.copyWith(color: suave),
          ),
        ),
      ],
    );

    final texto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (marca != null)
          Text(marca!, style: t.cuerpoChico.copyWith(color: suave)),
        if (titulo != null)
          Text(
            titulo!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.titulo1.copyWith(
              color: frente,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (placasAbajo && conPlacas) ...[
          const SizedBox(height: Espaciado.e2),
          _Placas(texto: placas!, color: frente),
        ],
        if (kilometraje != null) ...[
          const SizedBox(height: Espaciado.e1),
          detalle,
        ],
      ],
    );

    final cuerpo = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _borde,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, fin],
        ),
        boxShadow: tokens.sombras,
      ),
      child: ClipRRect(
        borderRadius: _borde,
        child: SizedBox(
          height: alto ?? altoPara(conTitulo: titulo != null, escala: escala),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Espaciado.e5,
              Espaciado.e5,
              Espaciado.e5,
              Espaciado.e3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titulo != null || marca != null || kilometraje != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: texto),
                      if (!placasAbajo && conPlacas) ...[
                        const SizedBox(width: Espaciado.e3),
                        _Placas(texto: placas!, color: frente),
                      ],
                    ],
                  )
                else if (conPlacas)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _Placas(texto: placas!, color: frente),
                  ),
                // La silueta toma el alto que sobra y nunca es más ancha que
                // 340: en pantallas anchas no crece hasta desbordar.
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: SiluetaAuto(
                        carroceria: frente,
                        cristal: c.marca.withValues(alpha: oscuro ? 0.9 : 0.85),
                        llanta: oscuro
                            ? frente
                            : Color.lerp(c.marca, Colors.black, 0.5)!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final partes = [?marca, ?titulo, ?placas, ?kilometraje];
    return Semantics(
      button: alToque != null,
      container: true,
      label: etiqueta ?? partes.join(', '),
      excludeSemantics: true,
      onTap: alToque,
      child: alToque == null
          ? cuerpo
          : ReboteTactil(alPulsar: alToque, child: cuerpo),
    );
  }

  /// La variante con foto, con la forma de [TarjetaResumen].
  Widget _conFoto(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    final escala = MediaQuery.textScalerOf(context).scale(1);
    final datos = [?marca, ?placas, ?kilometraje].join(' · ');
    final conTextos = titulo != null || datos.isNotEmpty || alToque != null;

    final tarjeta = DecoratedBox(
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: Radios.bordeTarjeta,
        boxShadow: tokens.sombras,
      ),
      child: SizedBox(
        height: alto ?? altoConFoto(escala: escala),
        child: Padding(
          padding: const EdgeInsets.all(Espaciado.e4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: Radios.bordeControl,
                  child: ColoredBox(
                    color: c.superficieHundida,
                    child: Image.asset(
                      foto!,
                      fit: BoxFit.cover,
                      // Si el asset faltara queda el fondo hundido, sin error.
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              // Sin textos ni toque (el encabezado ya dice qué auto es) es solo
              // la foto en su tarjeta.
              if (conTextos) ...[
                const SizedBox(height: Espaciado.e3),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (titulo != null)
                            Text(
                              titulo!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.titulo3.copyWith(color: c.texto),
                            ),
                          if (datos.isNotEmpty)
                            Text(
                              datos,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.cuerpoChico.copyWith(
                                color: c.textoSecundario,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (alToque != null)
                      Padding(
                        padding: const EdgeInsets.only(left: Espaciado.e2),
                        child: Icon(
                          LucideIcons300.chevronRight,
                          color: c.textoTerciario,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );

    final partes = [?marca, ?titulo, ?placas, ?kilometraje];
    return Semantics(
      button: alToque != null,
      container: true,
      label: etiqueta ?? partes.join(', '),
      excludeSemantics: true,
      onTap: alToque,
      child: alToque == null
          ? tarjeta
          : ReboteTactil(alPulsar: alToque, child: tarjeta),
    );
  }

  /// Esquinas de las cuatro puntas (`Radios.bordeHoja` solo redondea arriba).
  static const BorderRadius _borde = BorderRadius.all(
    Radius.circular(Radios.hoja),
  );

  /// El otro extremo del degradado, de la misma tonalidad: más oscuro en claro,
  /// más claro en oscuro, para que el texto lea en los dos extremos.
  static Color _variar(Color base, {required bool oscuro}) {
    final hsl = HSLColor.fromColor(base);
    final l = oscuro
        ? hsl.lightness + (1 - hsl.lightness) * 0.3
        : hsl.lightness * 0.62;
    return hsl.withLightness(l.clamp(0.0, 1.0)).toColor();
  }
}

class _Placas extends StatelessWidget {
  const _Placas({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = TokensPista.de(context).tipografia;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: Radios.bordePildora,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e3,
          vertical: Espaciado.e1,
        ),
        child: Text(
          texto,
          style: t.cuerpoChico.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
