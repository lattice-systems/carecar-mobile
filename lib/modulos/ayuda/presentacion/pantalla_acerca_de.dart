import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/agencia.dart';
import '../../../config/version_app.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/esqueleto.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';
import '../../../nucleo/diseno/tokens/tokens_pista.dart';

final _versionAplicacionProvider = FutureProvider<String>(
  (ref) => leerVersionApp(),
);

class _PantallaTerminos extends StatefulWidget {
  const _PantallaTerminos();

  @override
  State<_PantallaTerminos> createState() => _PantallaTerminosState();
}

class _PantallaTerminosState extends State<_PantallaTerminos> {
  Future<String> _lectura = rootBundle.loadString('terminos.txt');

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return FutureBuilder<String>(
      future: _lectura,
      builder: (context, estado) {
        if (estado.hasError) {
          return MarcoPantalla.estado(
            titulo: textos.ayudaTerminos,
            conRegreso: true,
            estado: EstadoError(
              titulo: textos.ayudaTerminosAusentes,
              alReintentar: () => setState(
                () => _lectura = rootBundle.loadString('terminos.txt'),
              ),
            ),
          );
        }

        final contenido = estado.data;
        if (contenido == null) {
          return MarcoPantalla.estado(
            titulo: textos.ayudaTerminos,
            conRegreso: true,
            estado: const Esqueleto(alto: 120),
          );
        }

        final tipografia = TokensPista.de(context).tipografia;
        return MarcoPantalla(
          titulo: textos.ayudaTerminos,
          conRegreso: true,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(Espaciado.e4),
              sliver: SliverList.list(
                children: [
                  for (final bloque in contenido.trim().split('\n\n'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: Espaciado.e4),
                      child: switch (bloque) {
                        final texto when texto.startsWith('# ') => Semantics(
                          header: true,
                          child: Text(
                            texto.substring(2),
                            style: tipografia.titulo3,
                          ),
                        ),
                        final texto when texto.startsWith('## ') => Semantics(
                          header: true,
                          child: Text(
                            texto.substring(3),
                            style: tipografia.cuerpoFuerte,
                          ),
                        ),
                        _ => Text(bloque, style: tipografia.cuerpo),
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class PantallaAcercaDe extends ConsumerWidget {
  const PantallaAcercaDe({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MarcoPantalla(
    titulo: AppLocalizations.of(context).ayudaAcerca,
    conRegreso: true,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(Espaciado.e4),
        sliver: SliverList.list(
          children: [
            FutureBuilder<String>(
              future: ref.watch(_versionAplicacionProvider.future),
              builder: (context, snapshot) => FilaLista(
                titulo: AppLocalizations.of(context).ayudaVersion,
                subtitulo:
                    snapshot.data ?? AppLocalizations.of(context).ayudaCargando,
                conChevron: false,
              ),
            ),
            FilaLista(
              titulo: AppLocalizations.of(context).ayudaLicencias,
              subtitulo: AppLocalizations.of(context).ayudaLicenciasDetalle,
              alToque: () =>
                  showLicensePage(context: context, applicationName: 'CareCar'),
            ),
            FilaLista(
              titulo: AppLocalizations.of(context).ayudaPrivacidad,
              alToque: () => _texto(
                context,
                AppLocalizations.of(context).ayudaPrivacidad,
                Agencia.avisoPrivacidad,
              ),
            ),
            FilaLista(
              titulo: AppLocalizations.of(context).ayudaTerminos,
              alToque: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => InheritedTheme.captureAll(
                    context,
                    const _PantallaTerminos(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
  static void _texto(BuildContext context, String titulo, String texto) =>
      showDialog<void>(
        context: context,
        builder: (dialogo) => AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(child: Text(texto)),
          actions: [
            Boton(
              texto: AppLocalizations.of(context).ayudaCerrar,
              alPresionar: () => Navigator.pop(dialogo),
            ),
          ],
        ),
      );
}
