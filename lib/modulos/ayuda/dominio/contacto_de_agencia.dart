import '../../../config/agencia.dart';
import 'sucursal.dart';

/// Cómo contactar a la agencia y dónde está (V2-M27.03).
///
/// Sale de la sucursal principal; lo que ella no trae, y todo si no hay
/// sucursales o la lectura falló, sale de [Agencia] (`lib/config/agencia.dart`).
/// Es lo que leen V2-M02.12 (dirección del evento de calendario) y V2-M11.02
/// (teléfono de la asistencia).
class ContactoDeAgencia {
  const ContactoDeAgencia({
    required this.telefono,
    required this.correo,
    required this.direccion,
    this.nombreSucursal,
    this.abiertaAhora,
    this.esRespaldo = false,
  });

  /// Los datos de [Agencia]: no hay sucursal de donde tomarlos.
  const ContactoDeAgencia.respaldo()
    : this(
        telefono: Agencia.telefono,
        correo: Agencia.correo,
        direccion: Agencia.direccion,
        esRespaldo: true,
      );

  /// Los datos de la [sucursal]; lo que no tenga lo completa [Agencia].
  factory ContactoDeAgencia.deSucursal(Sucursal sucursal) => ContactoDeAgencia(
    telefono: _conTexto(sucursal.telefono) ?? Agencia.telefono,
    correo: _conTexto(sucursal.correo) ?? Agencia.correo,
    direccion: sucursal.direccion,
    nombreSucursal: sucursal.nombre,
    abiertaAhora: sucursal.abiertaAhora,
  );

  static String? _conTexto(String? valor) =>
      valor == null || valor.trim().isEmpty ? null : valor.trim();

  final String telefono;
  final String correo;
  final String direccion;

  /// Nombre de la sucursal; nulo si son los datos de respaldo.
  final String? nombreSucursal;

  /// Si la sucursal atiende ahora; nulo si se desconoce (respaldo).
  final bool? abiertaAhora;

  /// Verdadero si son los datos de [Agencia] y no los de una sucursal.
  final bool esRespaldo;

  /// Lo que va en el lugar del evento de calendario: «Nombre, dirección».
  String get direccionParaEvento =>
      nombreSucursal == null ? direccion : '$nombreSucursal, $direccion';

  /// `tel:` solo con el signo más y los dígitos.
  Uri get enlaceDeLlamada =>
      Uri(scheme: 'tel', path: telefono.replaceAll(RegExp('[^+0-9]'), ''));

  /// `mailto:` al correo de atención.
  Uri get enlaceDeCorreo => Uri(scheme: 'mailto', path: correo);
}
