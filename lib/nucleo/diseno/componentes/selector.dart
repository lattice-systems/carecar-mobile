import 'package:flutter/material.dart';

import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';
import 'campo_base.dart';

/// Una opcion de [Selector].
class OpcionSelector<T> {
  const OpcionSelector({required this.valor, required this.texto});

  final T valor;
  final String texto;
}

/// Lista desplegable para elegir una opcion entre varias.
///
/// Con `alCambiar` nulo queda deshabilitado. Para menos de cuatro opciones
/// visibles a la vez conviene mostrar chips en lugar de un selector.
class Selector<T> extends StatelessWidget {
  const Selector({
    required this.etiqueta,
    required this.opciones,
    required this.valor,
    required this.alCambiar,
    super.key,
    this.sugerencia,
    this.ayuda,
    this.error,
  });

  final String etiqueta;
  final List<OpcionSelector<T>> opciones;
  final T? valor;
  final ValueChanged<T?>? alCambiar;
  final String? sugerencia;
  final String? ayuda;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final habilitado = alCambiar != null;

    return CampoBase(
      etiqueta: etiqueta,
      ayuda: ayuda,
      error: error,
      habilitado: habilitado,
      hijo: DropdownButtonFormField<T>(
        initialValue: valor,
        isExpanded: true,
        onChanged: alCambiar,
        borderRadius: Radios.bordeControl,
        dropdownColor: tokens.superficieNivel(2),
        icon: Icon(Icons.expand_more, color: c.textoSecundario),
        style: tokens.tipografia.cuerpo.copyWith(color: c.texto),
        decoration: CampoBase.decoracion(
          context,
          sugerencia: sugerencia,
          conError: error != null,
        ),
        items: [
          for (final o in opciones)
            DropdownMenuItem<T>(
              value: o.valor,
              child: Text(o.texto, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}
