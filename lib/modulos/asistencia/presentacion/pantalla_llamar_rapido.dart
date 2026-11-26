import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../config/agencia.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/contacto_de_llamada.dart';
import 'proveedores_asistencia.dart';

/// Llamadas rapidas (V2-M11.02): 911, la agencia y la aseguradora, un toque
/// cada una. No pide nada a la red, asi que sirve sin datos.
class PantallaLlamarRapido extends ConsumerStatefulWidget {
  const PantallaLlamarRapido({super.key});

  @override
  ConsumerState<PantallaLlamarRapido> createState() => _EstadoLlamar();
}

class _EstadoLlamar extends ConsumerState<PantallaLlamarRapido> {
  String? _error;

  Future<void> _llamar(ContactoDeLlamada contacto) async {
    final textos = AppLocalizations.of(context);
    final abrir = ref.read(abrirLlamadaProvider);
    var abierto = false;
    try {
      abierto = await abrir(contacto.enlace);
    } on Object {
      abierto = false;
    }
    if (!mounted || abierto) return;
    setState(
      () => _error = textos.asistenciaLlamarNoSePudo(contacto.telefono!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final aseguradora = ref.watch(aseguradoraProvider);
    final contactos = contactosDeLlamada(
      telefonoAgencia: Agencia.telefono,
      aseguradora: aseguradora,
    );

    return MarcoPantalla(
      titulo: textos.asistenciaLlamarTitulo,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              Text(
                textos.asistenciaLlamarIntro,
                style: tokens.tipografia.cuerpo.copyWith(
                  color: c.textoSecundario,
                ),
              ),
              const SizedBox(height: Espaciado.e4),
              if (_error != null) ...[
                Aviso(tono: Tono.peligro, mensaje: _error!),
                const SizedBox(height: Espaciado.e3),
              ],
              GrupoLista(
                encabezado: textos.asistenciaLlamarGrupo,
                filas: [
                  for (final contacto in contactos) _fila(context, contacto),
                ],
              ),
              if (aseguradora == null) ...[
                const SizedBox(height: Espaciado.e3),
                Aviso(mensaje: textos.asistenciaLlamarAseguradoraComoAgregar),
              ],
            ],
          ),
        ),
      ],
    );
  }

  FilaGrupo _fila(BuildContext context, ContactoDeLlamada contacto) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final (titulo, detalle, icono, color) = switch (contacto.tipo) {
      TipoContacto.emergencias => (
        textos.asistenciaLlamarEmergencias,
        textos.asistenciaLlamarEmergenciasDetalle,
        LucideIcons300.hospital,
        c.peligro,
      ),
      TipoContacto.agencia => (
        textos.asistenciaLlamarAgencia,
        contacto.telefono ?? '',
        LucideIcons300.store,
        c.acento,
      ),
      TipoContacto.aseguradora => (
        contacto.nombre ?? textos.asistenciaLlamarAseguradora,
        contacto.puedeLlamar
            ? contacto.telefono!
            : textos.asistenciaLlamarAseguradoraFalta,
        LucideIcons300.shield,
        c.acento,
      ),
    };
    return FilaGrupo(
      titulo: titulo,
      subtitulo: detalle,
      icono: contacto.puedeLlamar ? LucideIcons300.phone : icono,
      colorIcono: color,
      alToque: contacto.puedeLlamar ? () => _llamar(contacto) : null,
    );
  }
}
