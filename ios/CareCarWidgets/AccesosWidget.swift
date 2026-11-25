// Widget de accesos rapidos: Agendar, Mi auto, SOS y Comprobante. Cada boton es
// un enlace carecar:// propio (Link), asi que no depende de datos publicados.
// El `kind` debe coincidir con TipoWidget.accesos.tipoIos (Dart).

import SwiftUI
import WidgetKit

struct VistaAccesos: View {
    @Environment(\.widgetFamily) private var familia
    let entrada: EntradaCareCar
    private let d = DatosWidget("acc")

    private struct Acceso {
        let clave: String
        let etiqueta: String
        let icono: String
        let enlace: String
    }

    private var accesos: [Acceso] {
        [
            Acceso(clave: "agendar", etiqueta: "Agendar", icono: "calendar.badge.plus", enlace: "carecar://citas/agendar"),
            Acceso(clave: "mi_auto", etiqueta: "Mi auto", icono: "car.fill", enlace: "carecar://garaje"),
            Acceso(clave: "sos", etiqueta: "SOS", icono: "exclamationmark.triangle.fill", enlace: "carecar://asistencia/guias/pedir"),
            Acceso(clave: "comprobante", etiqueta: "Comprobante", icono: "qrcode", enlace: "carecar://citas"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if familia != .systemSmall {
                Text(d.texto("titulo") ?? "Accesos rápidos")
                    .font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            }
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: familia == .systemMedium ? 4 : 2),
                spacing: 8
            ) {
                ForEach(accesos, id: \.clave) { acceso in
                    let etiqueta = d.texto(acceso.clave) ?? acceso.etiqueta
                    Link(destination: d.enlace("enlace_\(acceso.clave)", respaldo: acceso.enlace)) {
                        VStack(spacing: 4) {
                            Image(systemName: acceso.icono)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(acceso.clave == "sos" ? Color.peligroCareCar : Color.acentoCareCar)
                            Text(etiqueta).font(.caption2.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity, minHeight: familia == .systemLarge ? 96 : 52)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.acentoCareCar.opacity(0.08)))
                    }
                    .accessibilityLabel(etiqueta)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(2)
        .containerBackground(for: .widget) { FondoCareCar() }
    }
}

struct AccesosWidget: Widget {
    let kind = "AccesosWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCareCar()) { entrada in
            VistaAccesos(entrada: entrada)
        }
        .configurationDisplayName("Accesos rápidos")
        .description("Agendar, Mi auto, SOS y Comprobante a un toque.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
