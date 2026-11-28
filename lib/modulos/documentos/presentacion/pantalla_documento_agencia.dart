import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../nucleo/diseno/componentes/barra_pantalla.dart';
import '../../../nucleo/diseno/componentes/visor_pdf.dart';
import 'proveedores_documentos.dart';

class PantallaDocumentoAgencia extends ConsumerWidget {
  const PantallaDocumentoAgencia({required this.documentoId, super.key});

  final int documentoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titulo = AppLocalizations.of(context).documentosPdfAgencia;
    return Scaffold(
      body: Column(
        children: [
          BarraPantalla(titulo: titulo),
          Expanded(
            child: VisorPdf(
              cargar: ref.watch(pdfDocumentoProvider(documentoId)),
              descripcion: titulo,
            ),
          ),
        ],
      ),
    );
  }
}
