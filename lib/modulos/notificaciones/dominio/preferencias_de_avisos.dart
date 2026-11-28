import 'aviso_cliente.dart';

/// Una hora del dia en la zona de la agencia · V2-M06.05.
///
/// Dart puro, sin `TimeOfDay`: el dominio no depende de Flutter. El contrato
/// la manda como `HH:mm`, y eso es lo unico que hay que leer y escribir.
class HoraDelDia implements Comparable<HoraDelDia> {
  const HoraDelDia(this.hora, this.minuto);

  /// `null` si el texto no es una hora. **No se inventa una**: un horario mal
  /// leido silenciaria avisos a una hora que nadie eligio.
  static HoraDelDia? deTexto(String? texto) {
    if (texto == null) return null;
    final partes = texto.split(':');
    if (partes.length != 2) return null;
    final hora = int.tryParse(partes[0]);
    final minuto = int.tryParse(partes[1]);
    if (hora == null || minuto == null) return null;
    if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) return null;
    return HoraDelDia(hora, minuto);
  }

  final int hora;
  final int minuto;

  int get _enMinutos => hora * 60 + minuto;

  /// Siempre con dos digitos: es lo que el contrato exige (`^([01][0-9]|2[0-3]):[0-5][0-9]$`).
  String aTexto() =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  @override
  int compareTo(HoraDelDia otra) => _enMinutos.compareTo(otra._enMinutos);

  @override
  bool operator ==(Object other) =>
      other is HoraDelDia && other.hora == hora && other.minuto == minuto;

  @override
  int get hashCode => Object.hash(hora, minuto);

  @override
  String toString() => aTexto();
}

/// El rango en que no se avisa · V2-M06.05.
///
/// Es de la cuenta, no de cada categoria, y lo respeta **el servidor** al
/// enviar: un aviso que no se manda no despierta a nadie, y filtrarlo en la
/// app no sirve con la app cerrada. Esto vive aqui para poder decirselo a la
/// persona y para probarlo.
class HorarioSilencioso {
  const HorarioSilencioso({required this.desde, required this.hasta});

  final HoraDelDia desde;
  final HoraDelDia hasta;

  /// Si [cuando] cae dentro del silencio, extremos incluidos.
  ///
  /// **El rango que cruza la medianoche es el caso normal**, no un error:
  /// 22:00 a 07:00 es lo que la gente configura. Tratarlo como un rango
  /// cualquiera dejaria la noche entera sin silencio, que es justo lo
  /// contrario de lo que se pidio.
  ///
  /// `desde == hasta` no silencia nada. Silenciar el dia entero seria una
  /// sorpresa desagradable para quien eligio dos horas iguales.
  bool silencia(HoraDelDia cuando) {
    if (desde == hasta) return false;
    final cruzaMedianoche = desde.compareTo(hasta) > 0;
    final despuesDelInicio = cuando.compareTo(desde) >= 0;
    final antesDelFin = cuando.compareTo(hasta) <= 0;
    return cruzaMedianoche
        ? despuesDelInicio || antesDelFin
        : despuesDelInicio && antesDelFin;
  }
}

/// Que avisos quiere recibir el cliente · V2-M06.05.
class PreferenciasDeAvisos {
  const PreferenciasDeAvisos({
    required this.porCategoria,
    required this.silencio,
  });

  /// Todas las categorias que el servidor declara, con su valor.
  ///
  /// Vienen completas a proposito -tambien las que nadie ha tocado, con su
  /// valor por omision- para que la pantalla no tenga que saber cuales existen
  /// ni que se asume cuando falta una.
  final Map<CategoriaDeAviso, bool> porCategoria;

  final HorarioSilencioso? silencio;

  bool get haySilencio => silencio != null;

  PreferenciasDeAvisos con(CategoriaDeAviso categoria, bool recibir) =>
      PreferenciasDeAvisos(
        porCategoria: {...porCategoria, categoria: recibir},
        silencio: silencio,
      );

  PreferenciasDeAvisos conHorario(HorarioSilencioso nuevo) =>
      PreferenciasDeAvisos(porCategoria: porCategoria, silencio: nuevo);

  PreferenciasDeAvisos sinHorario() =>
      PreferenciasDeAvisos(porCategoria: porCategoria, silencio: null);

  /// Lo que se le manda al servidor.
  ///
  /// [CategoriaDeAviso.desconocida] se queda fuera: el contrato no la declara,
  /// existe solo para que una categoria nueva del backend no tumbe la
  /// pantalla. Mandarla seria un 400.
  Map<CategoriaDeAviso, bool> paraGuardar() => {
    for (final e in porCategoria.entries)
      if (e.key != CategoriaDeAviso.desconocida) e.key: e.value,
  };
}

/// Lo que la pantalla de preferencias necesita del servidor.
abstract interface class RepositorioPreferenciasAvisos {
  Future<PreferenciasDeAvisos> preferencias();

  /// Reemplaza las preferencias completas y devuelve como quedaron.
  Future<PreferenciasDeAvisos> guardar(PreferenciasDeAvisos nuevas);
}
