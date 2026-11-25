// Widget de la bitacora: rendimiento en km/l y gasto del mes en cifras grandes.
// Un toque abre la bitacora del vehiculo.
// El `kind` debe coincidir con TipoWidget.bitacora.tipoIos (Dart).

import SwiftUI
import WidgetKit

struct VistaBitacora: View {
    @Environment(\.widgetFamily) private var familia
    let entrada: EntradaCareCar
    private let d = DatosWidget("bit")

    var body: some View {
        Group {
            if d.bool("hay") { contenido } else {
                VacioCareCar(
                    titulo: d.texto("titulo") ?? "Bitácora",
                    mensaje: d.texto("mensaje") ?? "Abre CareCar para ver tu bitácora",
                    accion: d.texto("accion") ?? "Abrir"
                )
            }
        }
        .marcoCareCar(
            enlace: d.enlace(respaldo: "carecar://garaje"),
            descripcion: d.texto("descripcion") ?? d.texto("mensaje")
        )
    }

    private var contenido: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(d.texto("titulo") ?? "Bitácora")
                .font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(d.texto("rendimiento") ?? "—")
                    .font(.system(size: familia == .systemLarge ? 80 : 44, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5).lineLimit(1)
                Text(d.texto("unidad") ?? "km/l").font(.headline).foregroundStyle(Color.acentoCareCar)
            }
            if familia != .systemSmall, let etiqueta = d.texto("etiqueta_rendimiento") {
                Text(etiqueta).font(.footnote).foregroundStyle(.secondary)
            }
            Text(d.texto("gasto") ?? "")
                .font(.system(size: familia == .systemSmall ? 20 : 28, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.6).lineLimit(1)
            if let etiqueta = d.texto("etiqueta_gasto") {
                Text(etiqueta).font(.footnote).foregroundStyle(.secondary).lineLimit(1)
            }
            if familia == .systemLarge, let vehiculo = d.texto("vehiculo") {
                Text(vehiculo).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct BitacoraWidget: Widget {
    let kind = "BitacoraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCareCar()) { entrada in
            VistaBitacora(entrada: entrada)
        }
        .configurationDisplayName("Bitácora")
        .description("Rendimiento en km/l y gasto del mes.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
