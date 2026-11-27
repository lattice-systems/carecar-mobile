import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../diseno/componentes/control_binario.dart';
import 'proveedores_analitica.dart';

class InterruptorAnalitica extends ConsumerWidget {
  const InterruptorAnalitica({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final preferencia = ref.watch(consentimientoAnaliticaProvider);
    return Interruptor(
      etiqueta: textos.analiticaTitulo,
      descripcion: preferencia.error
          ? textos.analiticaError
          : textos.analiticaDescripcion,
      valor: preferencia.activa,
      alCambiar: preferencia.guardando
          ? null
          : ref.read(consentimientoAnaliticaProvider.notifier).elegir,
    );
  }
}
