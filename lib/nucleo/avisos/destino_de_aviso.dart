import 'package:flutter_riverpod/flutter_riverpod.dart';

/// La ruta interna a la que lleva un aviso, o `null` si no lleva a ninguna.
///
/// El destino viaja dentro del aviso y entra a la app **desde afuera**: en un
/// push lo escribe el servidor. Se trata como dato de fuera, no como ruta de
/// confianza.
///
/// Solo pasa una ruta interna: empieza con `/`, no es `//host` -que un
/// navegador leeria como otro servidor- y no trae esquema. Es la misma regla
/// que ya aplica la guardia al parametro `desde`, y por lo mismo: un destino
/// sin revisar es una redireccion abierta.
String? destinoDeAviso(String? cargaUtil) {
  if (cargaUtil == null) return null;
  final texto = cargaUtil.trim();
  if (texto.isEmpty || !texto.startsWith('/') || texto.startsWith('//')) {
    return null;
  }
  final uri = Uri.tryParse(texto);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return texto;
}

/// El destino de un aviso que todavia no se atiende · V2-M06.03.
///
/// Es un buzon de un solo uso entre quien recibe el toque -el plugin, fuera de
/// Flutter- y el enrutador. Hace falta porque el toque puede llegar **antes**
/// de que exista el enrutador: con la app cerrada, el sistema la arranca por
/// el aviso y el destino tiene que esperar ahi hasta que haya a donde navegar.
///
/// Se vacia al atenderlo. Si no, cada vez que el enrutador se reconstruyera
/// volveria a navegar al mismo lugar y la app se sentiria trabada.
class DestinoDeAvisoPendiente extends Notifier<String?> {
  @override
  String? build() => null;

  /// Llego un toque. Un destino que no sirve se ignora en silencio: el aviso
  /// ya se mostro y sacar un error ahora no le dice nada a nadie.
  void llego(String? cargaUtil) {
    final destino = destinoDeAviso(cargaUtil);
    if (destino == null) return;
    state = destino;
  }

  void atendido() => state = null;
}

final destinoDeAvisoProvider =
    NotifierProvider<DestinoDeAvisoPendiente, String?>(
      DestinoDeAvisoPendiente.new,
      name: 'destinoDeAvisoProvider',
    );
