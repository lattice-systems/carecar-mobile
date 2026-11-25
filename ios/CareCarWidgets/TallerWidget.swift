// Widget del taller en vivo (V2-M25.02): etapa, avance por etapas y entrega
// estimada. Un toque abre la orden. Sin orden invita a agendar.
// El `kind` debe coincidir con TipoWidget.taller.tipoIos (Dart).

import SwiftUI
import WidgetKit

struct VistaTaller: View {
    @Environment(\.widgetFamily) private var familia
    let entrada: EntradaCareCar
    private let d = DatosWidget("taller")

    var body: some View {
        Group {
            if d.bool("hay") { contenido } else {
                VacioCareCar(
                    titulo: d.texto("titulo") ?? "Taller en vivo",
                    mensaje: d.texto("mensaje") ?? "Abre CareCar para ver tu auto en el taller",
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
        let total = max(d.entero("total", 7), 1)
        let paso = min(max(d.entero("paso"), 0), total)
        return VStack(alignment: .leading, spacing: 6) {
            Text(d.texto("titulo") ?? "Taller en vivo")
                .font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(d.texto("etapa") ?? "")
                .font(.system(size: familia == .systemSmall ? 22 : 30, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6).lineLimit(2)
            BarraCareCar(valor: Double(paso) / Double(total))
            if let pasoTexto = d.texto("paso_texto") {
                Text(pasoTexto).font(.footnote).foregroundStyle(.secondary)
            }
            if familia != .systemSmall, let entrega = d.texto("entrega") {
                Text(entrega).font(.subheadline.weight(.semibold)).lineLimit(1)
            }
            if familia == .systemLarge, let vehiculo = d.texto("vehiculo") {
                Text(vehiculo).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TallerWidget: Widget {
    let kind = "TallerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCareCar()) { entrada in
            VistaTaller(entrada: entrada)
        }
        .configurationDisplayName("Taller en vivo")
        .description("La etapa de tu auto y la hora estimada de entrega.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
