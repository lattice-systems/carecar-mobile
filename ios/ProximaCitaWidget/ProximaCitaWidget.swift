// Widget de la proxima cita (V2-M25.01) para iOS, con WidgetKit.
//
// ESTE ARCHIVO AUN NO ESTA EN EL PROYECTO XCODE: falta crear el target
// "Widget Extension" (nombre ProximaCitaWidget) en Runner.xcodeproj, agregar
// este archivo a ese target y activar el App Group en la app y en la extension.
// Pasos en plan/modulos/M25-widgets-y-wallet.md ("Avance de V2-M25.01").
//
// Lee lo que Flutter guarda con home_widget en el App Group. Las claves son el
// contrato con WidgetCitaHomeWidget (Dart); el `kind` tambien.

import SwiftUI
import WidgetKit

private let grupo = "group.com.carecar.carecarMobile"

struct EntradaCita: TimelineEntry {
    let date: Date
    let hayCita: Bool
    let titulo: String
    let fecha: String
    let horario: String
    let vehiculo: String
    let mensaje: String
    let accion: String
    let enlace: URL
}

struct ProveedorCita: TimelineProvider {
    private func leer() -> EntradaCita {
        let datos = UserDefaults(suiteName: grupo)
        let enlace = datos?.string(forKey: "proxima_cita_enlace")
            .flatMap(URL.init(string:)) ?? URL(string: "carecar://citas/agendar")!
        return EntradaCita(
            date: Date(),
            hayCita: datos?.bool(forKey: "proxima_cita_hay") ?? false,
            titulo: datos?.string(forKey: "proxima_cita_titulo") ?? "Próxima cita",
            fecha: datos?.string(forKey: "proxima_cita_fecha") ?? "",
            horario: datos?.string(forKey: "proxima_cita_horario") ?? "",
            vehiculo: datos?.string(forKey: "proxima_cita_vehiculo") ?? "",
            mensaje: datos?.string(forKey: "proxima_cita_mensaje") ?? "Abre CareCar para ver tu cita",
            accion: datos?.string(forKey: "proxima_cita_accion") ?? "Agendar cita",
            enlace: enlace
        )
    }

    func placeholder(in context: Context) -> EntradaCita { leer() }

    func getSnapshot(in context: Context, completion: @escaping (EntradaCita) -> Void) {
        completion(leer())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaCita>) -> Void) {
        // Se repinta cuando la app publica datos nuevos (reloadTimelines).
        completion(Timeline(entries: [leer()], policy: .never))
    }
}

struct VistaProximaCita: View {
    let entrada: EntradaCita

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entrada.titulo)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.secondary)
            if entrada.hayCita {
                Text(entrada.fecha).font(.title3.weight(.bold)).lineLimit(1)
                Text(entrada.horario).font(.subheadline).lineLimit(1)
                if !entrada.vehiculo.isEmpty {
                    Text(entrada.vehiculo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Text(entrada.mensaje).font(.subheadline)
                Text(entrada.accion)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.tint)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(entrada.enlace)
        .containerBackground(.background, for: .widget)
    }
}

struct ProximaCitaWidget: Widget {
    // Debe coincidir con WidgetCitaHomeWidget.tipoIos.
    let kind = "ProximaCitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCita()) { entrada in
            VistaProximaCita(entrada: entrada)
        }
        .configurationDisplayName("Próxima cita")
        .description("Tu próxima cita en el taller, sin abrir la app.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct ProximaCitaWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProximaCitaWidget()
    }
}
