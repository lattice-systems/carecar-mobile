import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/selector.dart';
import 'proveedores_idioma.dart';

/// Selector del idioma de la app para Ajustes: el del sistema, espanol o ingles.
///
/// Cambia al instante, sin reiniciar, y se recuerda en el dispositivo. Los
/// nombres de los idiomas se muestran en su propio idioma para que se
/// reconozcan aunque la app este en uno que la persona no lee.
class SelectorIdioma extends ConsumerWidget {
  const SelectorIdioma({super.key});

  static const _sistema = 'sistema';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final elegido = ref.watch(idiomaElegidoProvider);
    return Selector<String>(
      etiqueta: textos.idiomaEtiqueta,
      valor: elegido?.languageCode ?? _sistema,
      opciones: [
        OpcionSelector(valor: _sistema, texto: textos.idiomaSistema),
        OpcionSelector(valor: 'es', texto: textos.idiomaEspanol),
        OpcionSelector(valor: 'en', texto: textos.idiomaIngles),
      ],
      alCambiar: (codigo) => ref
          .read(idiomaElegidoProvider.notifier)
          .elegir(codigo == null || codigo == _sistema ? null : Locale(codigo)),
    );
  }
}
