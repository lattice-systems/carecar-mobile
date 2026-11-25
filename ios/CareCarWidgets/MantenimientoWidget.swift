// Widget de mantenimiento: proximo servicio, km faltantes, fecha y avance.
// Un toque abre el plan del vehiculo. En rojo cuando ya toca.
// El `kind` debe coincidir con TipoWidget.mantenimiento.tipoIos (Dart).

import SwiftUI
import WidgetKit

struct VistaMantenimiento: View {
    @Environment(\.widgetFamily) private var familia
    let entrada: EntradaCareCar
    private let d = DatosWidget("mant")

    var body: some View {
        Group {
            if d.bool("hay") { contenido } else {
                VacioCareCar(
                    titulo: d.texto("titulo") ?? "Mantenimiento",
                    mensaje: d.texto("mensaje") ?? "Abre CareCar para ver tu mantenimiento",
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
        let urgente = d.bool("urgente")
        let color: Color = urgente ? .peligroCareCar : .acentoCareCar
        return VStack(alignment: .leading, spacing: 6) {
            Text(d.texto("titulo") ?? "Mantenimiento")
                .font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            if familia != .systemSmall, let servicio = d.texto("servicio") {
                Text(servicio).font(.subheadline.weight(.semibold)).lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(d.texto("faltan") ?? "")
                .font(.system(size: familia == .systemSmall ? 24 : 34, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.5).lineLimit(2)
            BarraCareCar(valor: Double(d.entero("progreso")) / 100, color: color)
            if let fecha = d.texto("fecha") { Text(fecha).font(.footnote).foregroundStyle(.secondary).lineLimit(1) }
            if familia == .systemLarge, let vehiculo = d.texto("vehiculo") {
                Text(vehiculo).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct MantenimientoWidget: Widget {
    let kind = "MantenimientoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProveedorCareCar()) { entrada in
            VistaMantenimiento(entrada: entrada)
        }
        .configurationDisplayName("Mantenimiento")
        .description("Tu próximo servicio, los km que faltan y su fecha.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
