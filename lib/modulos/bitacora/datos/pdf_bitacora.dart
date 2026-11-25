import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Lo que lleva el PDF de la bitácora, ya con los textos en el idioma de la
/// persona: este archivo no sabe de idiomas ni de pesos.
class DatosPdfBitacora {
  const DatosPdfBitacora({
    required this.titulo,
    required this.periodo,
    required this.columnas,
    required this.filas,
    required this.total,
  });

  final String titulo;
  final String periodo;
  final List<String> columnas;
  final List<List<String>> filas;
  final String total;
}

/// Arma el PDF de la bitácora (V2-M18.05): título, periodo, tabla paginada y
/// el total. Incrusta Inter (ya viene en la app) para que acentos y «ñ» salgan
/// bien; la fuente base del PDF no soporta Unicode.
Future<Uint8List> generarPdfBitacora(DatosPdfBitacora datos) async {
  final normal = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Inter-400.ttf'),
  );
  final negrita = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Inter-700.ttf'),
  );
  final documento = pw.Document(
    title: datos.titulo,
    theme: pw.ThemeData.withFont(base: normal, bold: negrita),
  );
  documento.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (contexto) => [
        pw.Header(
          level: 0,
          child: pw.Text(
            datos.titulo,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(datos.periodo),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: datos.columnas,
          data: datos.filas,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            for (var i = 0; i < datos.columnas.length; i++)
              i: (i >= 2 && i <= 4)
                  ? pw.Alignment.centerRight
                  : pw.Alignment.centerLeft,
          },
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            datos.total,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  return documento.save();
}
