import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../../ayuda/ayuda.dart' show contactoDeAgenciaProvider;
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
    // Teléfono de la sucursal principal (V2-M27.02); `Agencia` si aún carga,
    // falla o no hay sucursales: la pantalla sirve sin datos.
    final agencia = ref.watch(contactoDeAgenciaProvider);
    // Mientras se lee la poliza no se dice que falta: seria falso un instante.
    final buscando =
        aseguradora == null && ref.watch(aseguradoraCargandoProvider);
    final contactos = contactosDeLlamada(
      telefonoAgencia: agencia.telefono,
      aseguradora: aseguradora,
    );

    return MarcoPantalla(
      icono: LucideIcons300.phone,
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
                  for (final contacto in contactos)
                    _fila(context, contacto, buscando: buscando),
                ],
              ),
              if (aseguradora == null && !buscando) ...[
                const SizedBox(height: Espaciado.e3),
                Aviso(mensaje: textos.asistenciaLlamarAseguradoraComoAgregar),
              ],
            ],
          ),
        ),
      ],
    );
  }

  FilaGrupo _fila(
    BuildContext context,
    ContactoDeLlamada contacto, {
    required bool buscando,
  }) {
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
            : buscando
            ? textos.asistenciaLlamarAseguradoraBuscando
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
