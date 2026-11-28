import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../config/agencia.dart';
import '../../../config/version_app.dart';
import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/boton.dart';
import '../../../nucleo/diseno/componentes/estado_error.dart';
import '../../../nucleo/diseno/componentes/fila_lista.dart';
import '../../../nucleo/diseno/componentes/marco_pantalla.dart';
import '../../../nucleo/diseno/tokens/espaciado.dart';

final _versionAplicacionProvider = FutureProvider<String>(
  (ref) => leerVersionApp(),
);

class _PantallaTerminos extends StatefulWidget {
  const _PantallaTerminos();

  @override
  State<_PantallaTerminos> createState() => _PantallaTerminosState();
}

class _PantallaTerminosState extends State<_PantallaTerminos> {
  late final WebViewController _visor = WebViewController();
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      await _visor.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (solicitud) {
            final url = Uri.tryParse(solicitud.url);
            return url?.scheme == 'file' &&
                    url?.pathSegments.lastOrNull == 'terminos.htm'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != false && mounted) {
              setState(() => _error = true);
            }
          },
        ),
      );
      await _visor.loadFlutterAsset('terminos.htm');
    } on PlatformException {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          BarraPantalla(titulo: textos.ayudaTerminos),
          Expanded(
            child: _error
                ? EstadoError(
                    titulo: textos.ayudaTerminosAusentes,
                    alReintentar: () {
                      setState(() => _error = false);
                      _cargar();
                    },
                  )
                : WebViewWidget(controller: _visor),
          ),
        ],
      ),
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
