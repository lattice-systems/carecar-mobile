import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'proveedores_analitica.dart';

class InterruptorAnalitica extends ConsumerWidget {
  const InterruptorAnalitica({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = AppLocalizations.of(context);
    final preferencia = ref.watch(consentimientoAnaliticaProvider);
    return SwitchListTile(
      title: Text(textos.analiticaTitulo),
      subtitle: Text(
        preferencia.error ? textos.analiticaError : textos.analiticaDescripcion,
      ),
      value: preferencia.activa,
      onChanged: preferencia.guardando
          ? null
          : ref.read(consentimientoAnaliticaProvider.notifier).elegir,
    );
  }
}
