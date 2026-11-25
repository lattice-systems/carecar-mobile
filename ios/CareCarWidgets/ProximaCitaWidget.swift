// Widget de la proxima cita (V2-M25.01): dia grande, mes, horario y vehiculo.
// Un toque abre el comprobante. Tamanos small, medium y large.
// El `kind` debe coincidir con TipoWidget.proximaCita.tipoIos (Dart).

import SwiftUI
import WidgetKit

struct VistaProximaCita: View {
    @Environment(\.widgetFamily) private var familia
    let entrada: EntradaCareCar
    private let d = DatosWidget("cita")

    var body: some View {
        Group {
            if d.bool("hay") { contenido } else {
                VacioCareCar(
                    titulo: d.texto("titulo") ?? "Próxima cita",
                    mensaje: d.texto("mensaje") ?? "Abre CareCar para ver tu cita",
                    accion: d.texto("accion") ?? "Agendar cita"
                )
            }
        }
        .marcoCareCar(
            enlace: d.enlace(respaldo: "carecar://citas/agendar"),
            descripcion: d.texto("descripcion") ?? d.texto("mensaje")
        )
    }

    private var contenido: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(d.texto("titulo") ?? "Próxima cita")
                .font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(d.texto("dia") ?? "")
                    .font(.system(size: familia == .systemLarge ? 96 : 52, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6).lineLimit(1)
                VStack(alignment: .leading, spacing: 0) {
                    Text((d.texto("mes") ?? "").uppercased())
                        .font(.headline).foregroundStyle(Color.acentoCareCar)
                    if familia != .systemSmall, let semana = d.texto("semana") {
                        Text(semana).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
            }
            if let horario = d.texto("horario") { Text(horario).font(.subheadline.weight(.semibold)).lineLimit(1) }
            if let vehiculo = d.texto("vehiculo") {
                Text(vehiculo).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct ProximaCitaWidget: Widget {
    let kind = "ProximaCitaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCareCar()) { entrada in
            VistaProximaCita(entrada: entrada)
        }
        .configurationDisplayName("Próxima cita")
        .description("Tu próxima cita en el taller, de un vistazo.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
