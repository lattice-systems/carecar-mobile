// Live Activity del taller (V2-M25.05): la etapa de la orden en la pantalla
// bloqueada y en la Dynamic Island mientras el auto esta en el taller.
//
// La inicia la app (PuenteActividadEnVivo.swift, target Runner) y la mantiene
// el backend por APNs; termina al entregar el auto. Solo va en el target
// CareCarWidgets (iOS 17 por containerBackground de los widgets de inicio) y
// usa ActividadTallerAtributos.swift, que tambien va en Runner. Aun no esta en
// el proyecto Xcode: ver plan/modulos/M25-widgets-y-wallet.md.
//
// Lo que se ve sale solo del estado: etapa, avance, hora estimada y si hay
// trabajo por aprobar. Nada de placas, VIN, auto ni datos del cliente.

import ActivityKit
import SwiftUI
import WidgetKit

/// Textos de la actividad, en el idioma del telefono (es por omision, en si
/// el telefono esta en ingles). Las etapas son las mismas de la app
/// (claves tallerEtapa* de los ARB).
@available(iOS 16.1, *)
enum TextosActividadTaller {
    static var enIngles: Bool { Locale.preferredLanguages.first?.hasPrefix("en") ?? false }

    static var titulo: String { enIngles ? "Your car at the shop" : "Tu auto en el taller" }
    static var entrega: String { enIngles ? "Pickup around" : "Entrega aprox." }

    static func etapa(_ nombre: String) -> String {
        switch nombre {
        case "RECIBIDO": return enIngles ? "Received" : "Recibido"
        case "DIAGNOSTICO": return enIngles ? "Diagnosis" : "Diagnóstico"
        case "ESPERANDO_APROBACION": return enIngles ? "Waiting for approval" : "Esperando aprobación"
        case "EN_REPARACION": return enIngles ? "In repair" : "En reparación"
        case "CONTROL_DE_CALIDAD": return enIngles ? "Quality check" : "Control de calidad"
        case "LAVADO": return enIngles ? "Car wash" : "Lavado"
        case "LISTO_PARA_ENTREGA": return enIngles ? "Ready for pickup" : "Listo para entrega"
        case "ENTREGADO": return enIngles ? "Delivered" : "Entregado"
        // Una etapa que esta version aun no conoce no rompe la actividad.
        default: return enIngles ? "At the shop" : "En el taller"
        }
    }

    static func porAprobar(_ cuantos: Int) -> String {
        if enIngles { return cuantos == 1 ? "1 job to approve" : "\(cuantos) jobs to approve" }
        return cuantos == 1 ? "1 trabajo por aprobar" : "\(cuantos) trabajos por aprobar"
    }

    static func avance(_ porcentaje: Int) -> String {
        enIngles ? "\(porcentaje) percent done" : "\(porcentaje) por ciento de avance"
    }
}

@available(iOS 16.1, *)
private func enlaceDeOrden(_ ordenId: Int) -> URL {
    // La ruta /taller/:ordenId de V2-M04.02, igual que el widget del taller.
    URL(string: "carecar://taller/\(ordenId)") ?? URL(string: "carecar://taller")!
}

/// Aviso de trabajo por aprobar: en naranja del sistema, que se lee como
/// «pendiente», no como error.
@available(iOS 16.1, *)
struct AvisoPorAprobar: View {
    let cuantos: Int

    var body: some View {
        Label(TextosActividadTaller.porAprobar(cuantos), systemImage: "exclamationmark.circle.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.orange)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

/// Hora estimada en la hora del telefono.
@available(iOS 16.1, *)
struct HoraEstimada: View {
    let fecha: Date

    var body: some View {
        Label {
            Text(TextosActividadTaller.entrega) + Text(" ") + Text(fecha, style: .time)
        } icon: {
            Image(systemName: "clock")
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .lineLimit(1)
    }
}

/// Pantalla bloqueada (y banner en iPhone sin Dynamic Island): etapa grande,
/// barra de avance, hora estimada y aviso si hay trabajo por aprobar.
@available(iOS 16.1, *)
struct VistaBloqueoTaller: View {
    let estado: EstadoActividadTaller

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "car.fill").foregroundStyle(Color.acentoCareCar)
                Text(TextosActividadTaller.titulo)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 8)
                Text(verbatim: "\(estado.avance)%")
                    .font(.footnote.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }
            Text(TextosActividadTaller.etapa(estado.etapa))
                .font(.system(.title2, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            BarraCareCar(valor: estado.fraccionDeAvance)
            HStack(spacing: 8) {
                if let fecha = estado.fechaEntregaEstimada, !estado.entregado {
                    HoraEstimada(fecha: fecha)
                }
                Spacer(minLength: 0)
                if estado.adicionalesPendientes > 0 {
                    AvisoPorAprobar(cuantos: estado.adicionalesPendientes)
                }
            }
        }
        .padding(16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DescripcionActividad.de(estado))
    }
}

/// Lo que lee VoiceOver: titulo, etapa, avance, hora y pendientes.
@available(iOS 16.1, *)
enum DescripcionActividad {
    static func de(_ estado: EstadoActividadTaller) -> String {
        var partes = [
            TextosActividadTaller.titulo,
            TextosActividadTaller.etapa(estado.etapa),
            TextosActividadTaller.avance(estado.avance),
        ]
        if let fecha = estado.fechaEntregaEstimada, !estado.entregado {
            partes.append("\(TextosActividadTaller.entrega) \(fecha.formatted(date: .omitted, time: .shortened))")
        }
        if estado.adicionalesPendientes > 0 {
            partes.append(TextosActividadTaller.porAprobar(estado.adicionalesPendientes))
        }
        return partes.joined(separator: ". ")
    }
}

@available(iOS 16.1, *)
struct ActividadTallerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AtributosActividadTaller.self) { contexto in
            VistaBloqueoTaller(estado: contexto.state)
                .activitySystemActionForegroundColor(Color.acentoCareCar)
                .widgetURL(enlaceDeOrden(contexto.attributes.ordenId))
        } dynamicIsland: { contexto in
            let estado = contexto.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "car.fill")
                        .font(.title3)
                        .foregroundStyle(Color.acentoCareCar)
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(verbatim: "\(estado.avance)%")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .accessibilityLabel(TextosActividadTaller.avance(estado.avance))
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(TextosActividadTaller.etapa(estado.etapa))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        BarraCareCar(valor: estado.fraccionDeAvance)
                        HStack(spacing: 8) {
                            if let fecha = estado.fechaEntregaEstimada, !estado.entregado {
                                HoraEstimada(fecha: fecha)
                            }
                            Spacer(minLength: 0)
                            if estado.adicionalesPendientes > 0 {
                                AvisoPorAprobar(cuantos: estado.adicionalesPendientes)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "car.fill")
                    .foregroundStyle(Color.acentoCareCar)
                    .accessibilityLabel(TextosActividadTaller.titulo)
            } compactTrailing: {
                if estado.adicionalesPendientes > 0 {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel(TextosActividadTaller.porAprobar(estado.adicionalesPendientes))
                } else {
                    Text(verbatim: "\(estado.avance)%")
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .accessibilityLabel(TextosActividadTaller.avance(estado.avance))
                }
            } minimal: {
                Gauge(value: estado.fraccionDeAvance) {
                    Image(systemName: "car.fill")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(Color.acentoCareCar)
                .accessibilityLabel(DescripcionActividad.de(estado))
            }
            .widgetURL(enlaceDeOrden(contexto.attributes.ordenId))
            .keylineTint(Color.acentoCareCar)
        }
    }
}
