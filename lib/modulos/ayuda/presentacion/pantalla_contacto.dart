import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/aviso.dart';
import '../../../nucleo/diseno/componentes/grupo_lista.dart';
import '../../../nucleo/diseno/componentes/insignia.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/componentes/tono.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';
import '../dominio/contacto_de_agencia.dart';
import 'proveedores_ayuda.dart';
import 'rutas_ayuda.dart';

/// Contactar a la agencia por el medio que prefiera: llamar, escribir un
/// correo o ver dónde está (V2-M27.03).
///
/// Los datos salen de la sucursal principal; si aún carga, falla o no hay
/// sucursales, de la config de la agencia, así que la pantalla nunca queda en
/// blanco ni en espera. El chat con el asesor llega con V2-M07.01: cuando
/// exista, es una fila más del primer grupo.
class PantallaContacto extends ConsumerStatefulWidget {
  const PantallaContacto({super.key});

  @override
  ConsumerState<PantallaContacto> createState() => _EstadoPantallaContacto();
}

class _EstadoPantallaContacto extends ConsumerState<PantallaContacto> {
  /// Lo que no se pudo abrir (el marcador o la app de correo).
  String? _aviso;

  Future<void> _abrir(Uri enlace, String siFalla) async {
    var abierto = false;
    try {
      abierto = await ref.read(abrirEnlaceDeSucursalProvider)(enlace);
    } on Object {
      // Sin app que lo atienda, o la plataforma lo rechazó: se avisa abajo.
    }
    if (!mounted) return;
    setState(() => _aviso = abierto ? null : siFalla);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final contacto = ref.watch(contactoDeAgenciaProvider);

    return MarcoPantalla(
      titulo: textos.contactoTitulo,
      conRegreso: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Espaciado.e4),
          sliver: SliverList.list(
            children: [
              Text(
                textos.contactoIntro,
                style: tokens.tipografia.cuerpo.copyWith(
                  color: c.textoSecundario,
                ),
              ),
              const SizedBox(height: Espaciado.e4),
              if (_aviso != null) ...[
                Aviso(
                  mensaje: _aviso!,
                  tono: Tono.advertencia,
                  alCerrar: () => setState(() => _aviso = null),
                ),
                const SizedBox(height: Espaciado.e3),
              ],
              GrupoLista(
                encabezado: textos.contactoGrupoMedios,
                filas: [
                  FilaGrupo(
                    titulo: textos.contactoLlamar,
                    subtitulo: contacto.telefono,
                    icono: LucideIcons300.phone,
                    colorIcono: c.acento,
                    alToque: () => _abrir(
                      contacto.enlaceDeLlamada,
                      textos.sucursalesNoSePudoLlamar,
                    ),
                  ),
                  FilaGrupo(
                    titulo: textos.contactoCorreo,
                    subtitulo: contacto.correo,
                    icono: LucideIcons300.atSign,
                    colorIcono: c.acento,
                    alToque: () => _abrir(
                      contacto.enlaceDeCorreo,
                      textos.contactoNoSePudoCorreo(contacto.correo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Espaciado.e5),
              GrupoLista(
                encabezado: textos.contactoGrupoDonde,
                filas: [_filaSucursales(context, contacto)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  FilaGrupo _filaSucursales(BuildContext context, ContactoDeAgencia contacto) {
    final textos = AppLocalizations.of(context);
    final c = TokensPista.de(context).colores;
    final abierta = contacto.abiertaAhora;
    return FilaGrupo(
      titulo: textos.contactoVerSucursales,
      subtitulo: contacto.esRespaldo
          ? textos.contactoVerSucursalesDetalle
          : '${contacto.nombreSucursal}\n${contacto.direccion}',
      icono: LucideIcons300.mapPin,
      colorIcono: c.acento,
      fin: abierta == null
          ? null
          : Insignia(
              texto: abierta
                  ? textos.sucursalesAbiertoAhora
                  : textos.sucursalesCerrado,
              tono: abierta ? Tono.exito : Tono.neutro,
              conIcono: true,
            ),
      etiquetaFin: abierta == null
          ? null
          : abierta
          ? textos.sucursalesAbiertoAhora
          : textos.sucursalesCerrado,
      alToque: () => GoRouter.of(context).push(rutaSucursales),
    );
  }
}
