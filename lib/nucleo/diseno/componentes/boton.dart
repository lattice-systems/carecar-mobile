import 'package:flutter/material.dart';

import '../movimiento_contexto.dart';
import '../tokens/espaciado.dart';
import '../tokens/movimiento.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Peso visual del boton. Debe haber una sola accion principal por pantalla.
enum VarianteBoton { principal, secundario, terciario, peligro }

enum TamanoBoton { chico, normal, grande }

/// Boton del sistema de diseno v2.
///
/// Con `alPresionar` nulo queda deshabilitado. Con `cargando` no responde,
/// conserva su aspecto y avisa "cargando" al lector de pantalla. Siempre deja
/// una zona tactil de al menos 48.
class Boton extends StatelessWidget {
  const Boton({
    required this.texto,
    required this.alPresionar,
    super.key,
    this.variante = VarianteBoton.principal,
    this.tamano = TamanoBoton.normal,
    this.icono,
    this.cargando = false,
    this.anchoCompleto = false,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final VarianteBoton variante;
  final TamanoBoton tamano;
  final IconData? icono;
  final bool cargando;
  final bool anchoCompleto;

  static const double _anchoBordeFoco = 2;
  static const double _tamanoIndicador = 18;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final estilo = _estilo(context, tokens);
    final alToque = cargando ? null : alPresionar;
    final contenido = _contenido(context, tokens);

    final Widget boton = switch (variante) {
      VarianteBoton.principal || VarianteBoton.peligro => FilledButton(
        onPressed: alToque,
        style: estilo,
        child: contenido,
      ),
      VarianteBoton.secundario => OutlinedButton(
        onPressed: alToque,
        style: estilo,
        child: contenido,
      ),
      VarianteBoton.terciario => TextButton(
        onPressed: alToque,
        style: estilo,
        child: contenido,
      ),
    };

    final dimensionado = anchoCompleto
        ? SizedBox(width: double.infinity, child: boton)
        : boton;

    if (!cargando) return dimensionado;
    return Semantics(
      button: true,
      label: '$texto, cargando',
      excludeSemantics: true,
      child: dimensionado,
    );
  }

  Widget _contenido(BuildContext context, TokensPista tokens) {
    final Widget? adorno = cargando
        ? const SizedBox(
            width: _tamanoIndicador,
            height: _tamanoIndicador,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icono == null ? null : Icon(icono, size: _tamanoIndicador));

    final etiqueta = Text(texto, textAlign: TextAlign.center);
    if (adorno == null) return etiqueta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        adorno,
        const SizedBox(width: Espaciado.e2),
        Flexible(child: etiqueta),
      ],
    );
  }

  ButtonStyle _estilo(BuildContext context, TokensPista tokens) {
    final c = tokens.colores;
    final t = tokens.tipografia;
    final (fondo, texto) = switch (variante) {
      VarianteBoton.principal => (c.acento, c.sobreAcento),
      VarianteBoton.peligro => (c.peligro, c.sobreAcento),
      VarianteBoton.secundario => (Colors.transparent, c.acento),
      VarianteBoton.terciario => (Colors.transparent, c.acento),
    };
    final relleno =
        variante == VarianteBoton.principal ||
        variante == VarianteBoton.peligro;
    final atenuarDeshabilitado = !cargando;

    final alto = switch (tamano) {
      TamanoBoton.chico => 40.0,
      TamanoBoton.normal => 48.0,
      TamanoBoton.grande => 56.0,
    };
    final lateral = switch (tamano) {
      TamanoBoton.chico => Espaciado.e3,
      TamanoBoton.normal => Espaciado.e5,
      TamanoBoton.grande => Espaciado.e6,
    };
    final letra = tamano == TamanoBoton.chico ? t.etiqueta : t.cuerpoFuerte;

    bool apagado(Set<WidgetState> e) =>
        atenuarDeshabilitado && e.contains(WidgetState.disabled);

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, alto)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: lateral, vertical: Espaciado.e2),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Radios.bordeControl),
      ),
      textStyle: WidgetStatePropertyAll(letra),
      backgroundColor: WidgetStateProperty.resolveWith((e) {
        if (apagado(e)) {
          return relleno ? c.superficieHundida : Colors.transparent;
        }
        return fondo;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((e) {
        if (apagado(e)) {
          return c.textoTerciario;
        }
        return texto;
      }),
      overlayColor: WidgetStateProperty.resolveWith((e) {
        if (e.contains(WidgetState.pressed)) {
          return texto.withValues(alpha: 0.16);
        }
        if (e.contains(WidgetState.hovered) ||
            e.contains(WidgetState.focused)) {
          return texto.withValues(alpha: 0.08);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((e) {
        if (e.contains(WidgetState.focused)) {
          final anillo = relleno ? c.texto : c.acento;
          return BorderSide(color: anillo, width: _anchoBordeFoco);
        }
        if (variante == VarianteBoton.secundario) {
          return BorderSide(color: c.borde);
        }
        return BorderSide.none;
      }),
      animationDuration: context.movimiento(Movimiento.rapido).duracion,
    );
  }
}
