/// Datos de la agencia que muestra la app. Se cambian SOLO aqui.
///
/// Los valores actuales son de ejemplo: reemplazalos antes de entregar.
class Agencia {
  const Agencia._();

  /// Telefono con lada (se usa en `tel:`).
  static const telefono = '+52 000 000 0000';

  /// Correo de atencion a clientes.
  static const correo = 'contacto@agencia.example.com';

  /// Direccion de la agencia.
  static const direccion = 'Calle Ejemplo 123, Colonia Centro, Ciudad';

  /// Texto del aviso de privacidad (aviso simplificado conforme a la
  /// LFPDPPP). Es la versión 2 del backend (V2-M22.10): la pantalla de perfil
  /// v1 lo muestra sin pedir red. Debe decir lo mismo que `V45` del backend.
  static const avisoPrivacidad =
      'Agencia360, con domicilio en el indicado en esta app, es responsable '
      'del tratamiento de tus datos personales.\n\n'
      'Datos que usamos: nombre, correo electrónico, teléfono y los datos '
      'de tus vehículos (marca, modelo, placas, número de serie y '
      'kilometraje), así como el historial de servicios y citas.\n\n'
      'Finalidades: identificarte al iniciar sesión, mostrarte tus '
      'vehículos, manuales, servicios y tickets, agendar y recordarte tus '
      'citas en el taller y atender tus solicitudes. No usamos tus datos '
      'con fines publicitarios ni los vendemos a terceros.\n\n'
      'Proveedores externos: para darte el servicio, parte de tus datos '
      'llega a estos proveedores.\n\n'
      'Alojamiento: Microsoft Azure y Neon guardan y procesan tu '
      'información en sus servidores, por cuenta de la agencia.\n\n'
      'Mapa: OpenStreetMap, el proveedor del mapa, recibe tu dirección IP y '
      'la zona que estás viendo cuando abres un mapa.\n\n'
      'Direcciones: al buscar una dirección o ubicarla en el mapa, el '
      'servicio de ubicación de tu teléfono (por lo general Google en '
      'Android y Apple en iPhone) recibe el texto de la dirección o las '
      'coordenadas.\n\n'
      'Asistente CareCar: solo si lo usas, Gemini (de Google) recibe tu '
      'pregunta (le quitamos lo que parezca correo, teléfono, placas o '
      'número de serie), el modelo y el año de tu auto y, si la mandas, la '
      'foto del tablero sin ubicación ni datos de la cámara. Google puede '
      'usar ese contenido para mejorar sus productos.\n\n'
      'Transferencias: fuera de estos proveedores, solo compartimos tus '
      'datos con autoridades cuando la ley lo exige.\n\n'
      'Derechos ARCO: puedes acceder, rectificar, cancelar u oponerte al '
      'uso de tus datos, o revocar tu consentimiento, escribiendo al correo '
      'de contacto de la agencia. Te responderemos en un plazo máximo de 20 '
      'días hábiles.\n\n'
      'Seguridad: tu sesión se guarda cifrada en tu dispositivo y la '
      'comunicación con la agencia requiere autenticación.\n\n'
      'Cambios: cualquier modificación a este aviso se publicará en esta '
      'misma sección de la app.\n\n'
      'Última actualización: noviembre de 2026.';
}
