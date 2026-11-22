import '../../api/cliente_api.dart';

/// Cliente HTTP del nucleo v2.
///
/// Es el [ClienteApi] de la v1 (maneja tokens, refresco ante 401, errores del
/// contrato y tiempo limite) con el nombre que usa la arquitectura v2. No se
/// reescribio: en la migracion (V2-T01.05) el codigo se mueve aqui sin cambiar
/// su comportamiento.
typedef ApiCliente = ClienteApi;
