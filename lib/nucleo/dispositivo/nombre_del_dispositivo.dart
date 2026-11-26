/// El nombre con el que esta app se presenta al entrar · V2-M01.09.
///
/// `POST /auth/login` acepta un `dispositivo` opcional, y es lo unico que
/// despues le permite al cliente reconocer sus sesiones en la lista de «mis
/// sesiones abiertas»: sin el, todas se ven iguales.
///
/// Este archivo **no toca la plataforma**: recibe lo que alguien mas leyo. La
/// lectura real vive en `lector_del_dispositivo.dart`, que es la unica parte
/// que depende del plugin.
library;

/// Lo que la plataforma puede decir del equipo. Las dos partes son opcionales:
/// un emulador o un equipo raro puede no dar ninguna.
typedef DatosDelDispositivo = ({String? equipo, String? sistema});

/// De donde salen esos datos. Se inyecta para poder probar sin plataforma.
typedef LectorDelDispositivo = Future<DatosDelDispositivo> Function();

const _separador = ' · ';

/// Arma «Pixel 7 · Android 14» con lo que haya.
///
/// Devuelve **nulo** cuando no hay nada que decir, y no una cadena vacia: nulo
/// significa «no mandes la llave `dispositivo`», mientras que una vacia si se
/// mandaria y el cliente acabaria con una sesion llamada «».
///
/// No recorta a 80 caracteres a proposito: ese limite es del contrato y lo
/// aplica `PeticionLogin`, que es la frontera. Repetirlo aqui seria tener la
/// misma regla en dos lugares.
String? componerNombreDelDispositivo({String? equipo, String? sistema}) {
  final partes = [
    equipo?.trim(),
    sistema?.trim(),
  ].where((p) => p != null && p.isNotEmpty);

  return partes.isEmpty ? null : partes.join(_separador);
}

/// «Google Pixel 7», pero «Pixel 7» si el modelo ya trae la marca.
///
/// Android devuelve las dos por separado y a veces el modelo ya empieza con el
/// fabricante («Xiaomi Redmi Note 12»), que leido junto sonaria repetido. Es la
/// misma regla que usa el titulo de la tarjeta del garaje.
String equipoDe({required String marca, required String modelo}) {
  final m = modelo.trim();
  final f = marca.trim();
  if (f.isEmpty) return m;
  if (m.toLowerCase().startsWith(f.toLowerCase())) return m;
  return '$f $m'.trim();
}

/// El nombre del equipo, o nulo si no se pudo averiguar.
///
/// **Nunca propaga un error.** El plugin puede fallar en un equipo raro o con
/// permisos recortados, y entrar a la app no puede depender de saber como se
/// llama el telefono: sin nombre la sesion se abre igual y la lista muestra un
/// texto generico.
Future<String?> nombreDelDispositivo({
  required LectorDelDispositivo leer,
}) async {
  try {
    final datos = await leer();
    return componerNombreDelDispositivo(
      equipo: datos.equipo,
      sistema: datos.sistema,
    );
  } catch (_) {
    return null;
  }
}
