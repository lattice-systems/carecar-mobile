/// A quien se puede llamar con un toque cuando se necesita ayuda (V2-M11.02).
enum TipoContacto { emergencias, agencia, aseguradora }

/// Aseguradora del cliente. La registra V2-M09.01 (documentos); mientras esa
/// historia no se integra, nadie la entrega y el boton explica como agregarla.
class Aseguradora {
  const Aseguradora({required this.nombre, required this.telefono});

  final String nombre;
  final String telefono;
}

/// Un boton de llamada: tipo, numero (si hay) y, para la aseguradora, su nombre.
class ContactoDeLlamada {
  const ContactoDeLlamada({required this.tipo, this.telefono, this.nombre});

  final TipoContacto tipo;
  final String? telefono;

  /// Nombre propio del contacto (solo la aseguradora lo trae).
  final String? nombre;

  String get _digitos => (telefono ?? '').replaceAll(RegExp(r'[^0-9+]'), '');

  /// Hay un numero marcable.
  bool get puedeLlamar => RegExp(r'\d').hasMatch(_digitos);

  /// `tel:` listo para abrir el marcador del telefono.
  Uri get enlace => Uri(scheme: 'tel', path: _digitos);
}

/// Numero de emergencias de Mexico.
const telefonoEmergencias = '911';

/// Arma los tres contactos en el orden en que se muestran.
List<ContactoDeLlamada> contactosDeLlamada({
  required String telefonoAgencia,
  required Aseguradora? aseguradora,
}) => [
  const ContactoDeLlamada(
    tipo: TipoContacto.emergencias,
    telefono: telefonoEmergencias,
  ),
  ContactoDeLlamada(tipo: TipoContacto.agencia, telefono: telefonoAgencia),
  ContactoDeLlamada(
    tipo: TipoContacto.aseguradora,
    telefono: aseguradora?.telefono,
    nombre: aseguradora?.nombre,
  ),
];
