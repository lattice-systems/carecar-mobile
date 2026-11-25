// Piezas compartidas por los cinco widgets de CareCar para iOS (V2-M25).
//
// ESTOS ARCHIVOS AUN NO ESTAN EN EL PROYECTO XCODE: falta crear el target
// "Widget Extension" (nombre CareCarWidgets) en Runner.xcodeproj, agregar a ese
// target todos los .swift de esta carpeta y activar el App Group
// group.com.carecar.carecarMobile en la app y en la extension. Pasos en
// plan/modulos/M25-widgets-y-wallet.md ("Avance de widgets multiples").
//
// Lee lo que Flutter guarda con home_widget en el App Group. Las claves llevan
// el prefijo de cada widget (cita_, taller_, mant_, bit_, acc_) y son el
// contrato con TipoWidget (Dart).

import SwiftUI
import WidgetKit

let grupoCareCar = "group.com.carecar.carecarMobile"

/// Lectura de las claves de un widget con su prefijo.
struct DatosWidget {
    let prefijo: String
    private let almacen = UserDefaults(suiteName: grupoCareCar)

    init(_ prefijo: String) { self.prefijo = prefijo }

    func texto(_ campo: String) -> String? {
        guard let valor = almacen?.string(forKey: "\(prefijo)_\(campo)"), !valor.isEmpty else { return nil }
        return valor
    }

    func bool(_ campo: String) -> Bool { almacen?.bool(forKey: "\(prefijo)_\(campo)") ?? false }

    func entero(_ campo: String, _ defecto: Int = 0) -> Int {
        (almacen?.object(forKey: "\(prefijo)_\(campo)") as? NSNumber)?.intValue ?? defecto
    }

    func enlace(_ campo: String = "enlace", respaldo: String) -> URL {
        URL(string: texto(campo) ?? respaldo) ?? URL(string: respaldo)!
    }
}

/// Entrada de línea de tiempo: solo la fecha; cada vista lee sus datos al pintarse.
struct EntradaCareCar: TimelineEntry {
    let date: Date
}

/// Se repinta cuando la app publica datos nuevos (reloadTimelines).
struct ProveedorCareCar: TimelineProvider {
    func placeholder(in context: Context) -> EntradaCareCar { EntradaCareCar(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (EntradaCareCar) -> Void) {
        completion(EntradaCareCar(date: Date()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<EntradaCareCar>) -> Void) {
        completion(Timeline(entries: [EntradaCareCar(date: Date())], policy: .never))
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    // Valores de los tokens de Pista (lib/nucleo/diseno/tokens/colores.dart).
    static let acentoCareCar = Color(hex: 0x2457F5)
    static let peligroCareCar = Color(hex: 0xC6291D)
}

/// Fondo con degradado sutil de la marca; en oscuro baja a tonos azul noche.
struct FondoCareCar: View {
    @Environment(\.colorScheme) private var esquema

    var body: some View {
        LinearGradient(
            colors: esquema == .dark
                ? [Color(hex: 0x14161C), Color(hex: 0x1B2540)]
                : [Color.white, Color(hex: 0xE8EEFF)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// Barra de avance de esquinas redondas.
struct BarraCareCar: View {
    let valor: Double
    var color: Color = .acentoCareCar

    var body: some View {
        GeometryReader { medida in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.12))
                Capsule().fill(color)
                    .frame(width: medida.size.width * min(max(valor, 0), 1))
            }
        }
        .frame(height: 8)
        .accessibilityHidden(true)
    }
}

/// Estado vacío compartido: mensaje corto y la acción como píldora.
struct VacioCareCar: View {
    let titulo: String
    let mensaje: String
    let accion: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.footnote.weight(.bold)).foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(mensaje).font(.subheadline).minimumScaleFactor(0.8)
            Text(accion)
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(Color.acentoCareCar))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

extension View {
    /// Fondo del widget con margen generoso y enlace al tocarlo.
    func marcoCareCar(enlace: URL, descripcion: String?) -> some View {
        self
            .padding(2)
            .widgetURL(enlace)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(descripcion ?? "")
            .containerBackground(for: .widget) { FondoCareCar() }
    }
}
