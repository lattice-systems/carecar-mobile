import 'package:flutter/material.dart';

import '../tokens/espaciado.dart';
import '../tokens/radios.dart';
import '../tokens/tokens_pista.dart';

/// Quién escribió el mensaje: la persona que usa la app o la otra parte
/// (el asistente, el asesor).
enum AutorMensaje { propio, ajeno }

/// Estado de envío de un mensaje propio.
enum EstadoEnvio { enviando, enviado, fallido }

/// Una fuente citada al pie de un mensaje, p. ej. "Manual, pág. 214".
class FuenteMensaje {
  const FuenteMensaje({
    required this.texto,
    required this.alTocar,
    this.etiquetaLector,
  });

  /// Texto visible, corto.
  final String texto;

  /// Lo que anuncia el lector de pantalla; si es nulo, [texto].
  final String? etiquetaLector;

  final VoidCallback alTocar;
}

/// Burbuja de un mensaje de chat (V2-T02.15), compartida por el asistente
/// (M24) y la mensajería con el asesor (M07).
///
/// La propia va a la derecha con el acento; la ajena a la izquierda sobre una
/// superficie. Nunca pasa del 80 % del ancho. La esquina del lado de quien
/// habla es más cerrada, como una cola. El lector de pantalla oye
/// `autor: texto, hora` en un solo nodo; cada fuente es un botón aparte
/// de al menos 48 de alto. Los estados de envío solo se muestran en mensajes
/// propios.
class BurbujaMensaje extends StatelessWidget {
  const BurbujaMensaje({
    required this.texto,
    required this.autor,
    required this.nombreAutor,
    super.key,
    this.hora,
    this.fuentes = const [],
    this.estado,
    this.alReintentar,
    this.textoEnviando = 'Enviando…',
    this.textoFallido = 'No se envió',
    this.textoReintentar = 'Reintentar',
  });

  final String texto;
  final AutorMensaje autor;

  /// Nombre que oye el lector de pantalla antes del texto ("Tú", "CareCar").
  final String nombreAutor;
  final String? hora;
  final List<FuenteMensaje> fuentes;
  final EstadoEnvio? estado;
  final VoidCallback? alReintentar;
  final String textoEnviando;
  final String textoFallido;
  final String textoReintentar;

  static const double _anchoMaximo = 0.8;
  static const double _radioCola = 4;

  bool get _propio => autor == AutorMensaje.propio;

  @override
  Widget build(BuildContext context) {
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;

    final fondo = _propio ? c.acento : c.superficieHundida;
    final frente = _propio ? c.sobreAcento : c.texto;
    final secundario = _propio
        ? c.sobreAcento.withValues(alpha: 0.85)
        : c.textoSecundario;

    const radio = Radius.circular(Radios.tarjeta);
    const cola = Radius.circular(_radioCola);
    final borde = BorderRadius.only(
      topLeft: radio,
      topRight: radio,
      bottomLeft: _propio ? radio : cola,
      bottomRight: _propio ? cola : radio,
    );

    final etiqueta = ['$nombreAutor: $texto', ?hora].join(', ');

    final burbuja = DecoratedBox(
      key: const ValueKey('burbuja-mensaje-fondo'),
      decoration: BoxDecoration(color: fondo, borderRadius: borde),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Espaciado.e4,
          vertical: Espaciado.e3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: etiqueta,
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(texto, style: t.cuerpo.copyWith(color: frente)),
                  if (hora != null) ...[
                    const SizedBox(height: Espaciado.e1),
                    Text(hora!, style: t.micro.copyWith(color: secundario)),
                  ],
                ],
              ),
            ),
            for (var i = 0; i < fuentes.length; i++)
              _Fuente(
                key: ValueKey('fuente-mensaje-$i'),
                fuente: fuentes[i],
                color: _propio ? c.sobreAcento : c.acento,
              ),
          ],
        ),
      ),
    );

    return Align(
      alignment: _propio ? Alignment.centerRight : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, limites) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: limites.maxWidth * _anchoMaximo,
          ),
          child: Column(
            crossAxisAlignment: _propio
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [burbuja, ..._estado(context)],
          ),
        ),
      ),
    );
  }

  List<Widget> _estado(BuildContext context) {
    if (!_propio || estado == null || estado == EstadoEnvio.enviado) {
      return const [];
    }
    final tokens = TokensPista.de(context);
    final c = tokens.colores;
    final t = tokens.tipografia;
    if (estado == EstadoEnvio.enviando) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: Espaciado.e1),
          child: Text(
            textoEnviando,
            style: t.micro.copyWith(color: c.textoSecundario),
          ),
        ),
      ];
    }
    return [
      Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(textoFallido, style: t.cuerpoChico.copyWith(color: c.peligro)),
          TextButton(
            key: const ValueKey('reintentar-mensaje'),
            onPressed: alReintentar,
            style: TextButton.styleFrom(
              minimumSize: const Size(
                Espaciado.objetivoTactilMinimo,
                Espaciado.objetivoTactilMinimo,
              ),
              foregroundColor: c.acento,
            ),
            child: Text(textoReintentar),
          ),
        ],
      ),
    ];
  }
}

class _Fuente extends StatelessWidget {
  const _Fuente({required this.fuente, required this.color, super.key});

  final FuenteMensaje fuente;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = TokensPista.de(context).tipografia;
    return Semantics(
      button: true,
      label: fuente.etiquetaLector ?? fuente.texto,
      excludeSemantics: true,
      onTap: fuente.alTocar,
      child: InkWell(
        onTap: fuente.alTocar,
        borderRadius: Radios.bordeControl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: Espaciado.objetivoTactilMinimo,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 16, color: color),
              const SizedBox(width: Espaciado.e1),
              Flexible(
                child: Text(
                  fuente.texto,
                  style: t.etiqueta.copyWith(
                    color: color,
                    decoration: TextDecoration.underline,
                    decorationColor: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
