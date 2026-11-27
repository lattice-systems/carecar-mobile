// Atributos y estado de la Live Activity del taller (V2-M25.05).
//
// ESTE ARCHIVO VA EN DOS TARGETS: Runner (PuenteActividadEnVivo.swift la
// inicia, actualiza y termina) y CareCarWidgets (ActividadTallerLiveActivity
// la pinta). ActivityKit une las dos mitades por el nombre del tipo, asi que
// tiene que ser exactamente este archivo en ambos. Aun no esta en el proyecto
// Xcode: pasos en plan/modulos/M25-widgets-y-wallet.md ("Avance de V2-M25.05 y
// V2-M25.06 (Apple)").
//
// El estado tiene las llaves y tipos EXACTOS del `content-state` que manda el
// backend por APNs (ActualizadorDeActividadesEnVivo) y de EstadoDeActividad en
// Dart (lib/modulos/widgets/dominio/actividad_en_vivo.dart). Si uno cambia,
// cambian los tres: un push que no decodifica deja la actividad sin actualizar.

import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct AtributosActividadTaller: ActivityAttributes {
    typealias ContentState = EstadoActividadTaller

    /// Lo unico fijo mientras dura la actividad. Nada de placas, VIN, auto ni
    /// nombre del cliente: la pantalla bloqueada la ve cualquiera.
    let ordenId: Int
}

@available(iOS 16.1, *)
struct EstadoActividadTaller: Codable, Hashable {
    /// Nombre del enum EtapaTaller del backend, p. ej. "EN_REPARACION".
    var etapa: String

    /// Nombre del enum EstatusOrden del backend, p. ej. "EN_PROCESO".
    var estatus: String

    /// De 0 a 100.
    var avance: Int

    /// Trabajos adicionales que esperan la respuesta del cliente.
    var adicionalesPendientes: Int

    /// Segundos desde 1970 (UTC); el backend omite la llave si el taller aun
    /// no la estima. Es un numero y no un Date a proposito: ActivityKit
    /// decodifica con el JSONDecoder por omision, que leeria un Date como
    /// segundos desde 2001.
    var entregaEstimada: Int?

    /// [entregaEstimada] como fecha, para mostrarla en la hora del telefono.
    var fechaEntregaEstimada: Date? {
        entregaEstimada.map { Date(timeIntervalSince1970: TimeInterval($0)) }
    }

    var entregado: Bool { estatus == "ENTREGADO" || etapa == "ENTREGADO" }

    var fraccionDeAvance: Double { min(max(Double(avance) / 100, 0), 1) }
}
