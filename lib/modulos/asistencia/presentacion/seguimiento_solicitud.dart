import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/excepciones.dart';
import '../../../nucleo/eventos/eventos_en_vivo.dart';
import '../../../nucleo/eventos/proveedores_eventos.dart';
import '../dominio/solicitud_asistencia.dart';
import 'proveedores_asistencia.dart';

/// Lo que la pantalla sabe del avance de una solicitud (V2-M11.04).
///
/// [estado] es nulo mientras no llega nada nuevo: la pantalla usa entonces el
/// de la solicitud que ya tiene.
class SeguimientoSolicitud {
  const SeguimientoSolicitud({
    this.estado,
    this.actualizando = false,
    this.fallo = false,
  });

  final EstadoSolicitud? estado;
  final bool actualizando;

  /// La ultima consulta manual o de reconexion fallo.
  final bool fallo;

  SeguimientoSolicitud copiaCon({
    EstadoSolicitud? estado,
    bool? actualizando,
    bool? fallo,
  }) => SeguimientoSolicitud(
    estado: estado ?? this.estado,
    actualizando: actualizando ?? this.actualizando,
    fallo: fallo ?? this.fallo,
  );
}

/// Sigue una solicitud: aplica `asistencia.estado` al llegar, consulta de
/// nuevo `GET /asistencia/{id}` al reconectar y a pedido de la persona.
///
/// Solo escucha el canal mientras una pantalla lo mira (`autoDispose`).
class SeguimientoSolicitudNotifier extends Notifier<SeguimientoSolicitud> {
  SeguimientoSolicitudNotifier(this.id);

  final int id;

  @override
  SeguimientoSolicitud build() {
    ref.listen(eventosProvider, (_, evento) => evento.whenData(_alLlegar));
    return const SeguimientoSolicitud();
  }

  void _alLlegar(EventoEnVivo evento) {
    if (evento.nombre == eventoReconectado) {
      refrescar();
    } else if (evento.nombre == 'asistencia.estado' &&
        evento.datos['solicitudId'] == id) {
      state = state.copiaCon(
        estado: EstadoSolicitud.desde(evento.datos['estado'] as String?),
        fallo: false,
      );
    }
  }

  /// Vuelve a consultar el estado. Un fallo de red no borra lo que ya se sabe:
  /// solo marca [SeguimientoSolicitud.fallo].
  Future<void> refrescar() async {
    if (state.actualizando) return;
    state = state.copiaCon(actualizando: true);
    try {
      final solicitud = await ref
          .read(repositorioAsistenciaProvider)
          .obtener(id);
      if (!ref.mounted) return;
      state = state.copiaCon(
        estado: solicitud.estado,
        actualizando: false,
        fallo: false,
      );
    } on ExcepcionApi {
      if (!ref.mounted) return;
      state = state.copiaCon(actualizando: false, fallo: true);
    }
  }
}

/// Seguimiento en vivo de la solicitud `id`.
final seguimientoSolicitudProvider = NotifierProvider.autoDispose
    .family<SeguimientoSolicitudNotifier, SeguimientoSolicitud, int>(
      SeguimientoSolicitudNotifier.new,
      name: 'seguimientoSolicitudProvider',
    );
