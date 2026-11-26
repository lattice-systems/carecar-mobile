import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import 'proveedores_garantia.dart';

/// Insignia del garaje para un vehiculo con alguna campana de seguridad
/// pendiente (V2-M10.02). Sin campanas pendientes, mientras carga o si falla,
/// no ocupa lugar.
class InsigniaCampanas extends ConsumerWidget {
  const InsigniaCampanas({required this.vehiculoId, super.key});

  final int vehiculoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(hayCampanaAbiertaProvider(vehiculoId))) {
      return const SizedBox.shrink();
    }
    return Insignia(
      texto: AppLocalizations.of(context).campanasInsignia,
      tono: Tono.advertencia,
      conIcono: true,
    );
  }
}
