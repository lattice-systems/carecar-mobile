import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/carecar_api.dart';
import '../../api/modelos/modelos.dart';
import '../../tema/tema_carecar.dart';
import '../../widgets/aviso.dart';
import '../../widgets/carga_datos.dart';
import '../../widgets/formato.dart';
import '../../widgets/menu_carecar.dart';
import '../../widgets/movimiento.dart';
import '../../widgets/pagina_carecar.dart';
import '../../widgets/pantalla.dart';

/// APP-4.1 · Catalogo de modelos vigentes de la agencia.
class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({
    required this.api,
    required this.alCerrarSesion,
    super.key,
  });

  final CarecarApi api;
  final VoidCallback alCerrarSesion;

  Widget _tarjeta(BuildContext context, int i, ModeloCatalogo m) =>
      Padding(
            padding: const EdgeInsets.only(bottom: TemaCareCar.espacioCampos),
            child: _TarjetaModelo(
              modelo: m,
              alPulsar: () => abrirPantalla(
                context,
                PantallaDetalleModelo(
                  modelo: m,
                  alCerrarSesion: alCerrarSesion,
                ),
              ),
            ),
          )
          .animate(delay: (80 * i).ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.12, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final recargador = Recargador();
    return PaginaCareCar(
      titulo: 'Catálogo',
      anchoMaximo: Pantalla.anchoLectura,
      alCerrarSesion: alCerrarSesion,
      alRefrescar: recargador.recargar,
      contenido: CargaDatos<List<ModeloCatalogo>>(
        recargador: recargador,
        cargar: api.catalogo,
        mensajeCarga: 'Cargando catálogo…',
        mensajeError: 'No se pudo cargar el catálogo',
        construir: (modelos) => modelos.isEmpty
            ? const Aviso.informacion(
                titulo: 'Aún no hay modelos en el catálogo',
                detalle: 'Vuelve a revisar más tarde.',
              )
            : Column(
                children: [
                  for (final (i, m) in modelos.indexed) _tarjeta(context, i, m),
                ],
              ),
      ),
    );
  }
}

/// «Marca · Modelo · 2025».
String tituloModelo(ModeloCatalogo m) => [
  if (m.marca != null) m.marca!,
  m.modelo,
  if (m.anio != null) '${m.anio}',
].join(' · ');

/// «Desde $350,000» o null si no hay precio.
String? textoPrecio(ModeloCatalogo m) {
  final p = m.precioDesde;
  return p == null ? null : 'Desde \$${conMiles(p.round())}';
}

class _TarjetaModelo extends StatelessWidget {
  const _TarjetaModelo({required this.modelo, required this.alPulsar});

  final ModeloCatalogo modelo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final precio = textoPrecio(modelo);
    return Rebote(
      child: Material(
        color: TemaCareCar.tarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TemaCareCar.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: alPulsar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagenModelo(url: modelo.imagenUrl, alto: 160),
              Padding(
                padding: const EdgeInsets.all(TemaCareCar.rellenoTarjeta),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tituloModelo(modelo), style: temas.titleMedium),
                    if (modelo.version != null) ...[
                      const SizedBox(height: 6),
                      ShadBadge.secondary(child: Text(modelo.version!)),
                    ],
                    if (precio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        precio,
                        style: temas.titleSmall?.copyWith(
                          color: TemaCareCar.turquesaOscuro,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (modelo.descripcion != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        modelo.descripcion!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: temas.bodyMedium?.copyWith(
                          color: TemaCareCar.textoSecundario,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagen del modelo con marcador si no hay URL o falla la descarga.
class ImagenModelo extends StatelessWidget {
  const ImagenModelo({required this.url, required this.alto, super.key});

  final String? url;
  final double alto;

  static const marcador = Key('catalogo_imagen_marcador');

  @override
  Widget build(BuildContext context) {
    final u = url;
    final vacio = Container(
      key: marcador,
      height: alto,
      width: double.infinity,
      color: TemaCareCar.azulSuave,
      child: const Icon(
        Icons.directions_car_outlined,
        size: 56,
        color: TemaCareCar.azulAgencia,
      ),
    );
    if (u == null) return vacio;
    return Image.network(
      u,
      height: alto,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => vacio,
      loadingBuilder: (_, hijo, avance) => avance == null
          ? hijo
          : SizedBox(
              height: alto,
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

/// Detalle de un modelo del catalogo.
class PantallaDetalleModelo extends StatelessWidget {
  const PantallaDetalleModelo({
    required this.modelo,
    required this.alCerrarSesion,
    super.key,
  });

  final ModeloCatalogo modelo;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final temas = Theme.of(context).textTheme;
    final precio = textoPrecio(modelo);
    return PaginaCareCar(
      titulo: modelo.modelo,
      anchoMaximo: Pantalla.anchoLectura,
      alCerrarSesion: alCerrarSesion,
      contenido:
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ImagenModelo(url: modelo.imagenUrl, alto: 220),
                  ),
                  const SizedBox(height: TemaCareCar.espacioCampos),
                  Text(tituloModelo(modelo), style: temas.titleLarge),
                  if (modelo.version != null) ...[
                    const SizedBox(height: 8),
                    ShadBadge.secondary(child: Text(modelo.version!)),
                  ],
                  if (precio != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      precio,
                      style: temas.headlineSmall?.copyWith(
                        color: TemaCareCar.turquesaOscuro,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (modelo.descripcion != null) ...[
                    const SizedBox(height: 12),
                    Text(modelo.descripcion!, style: temas.bodyLarge),
                  ],
                ],
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, curve: Curves.easeOutCubic),
    );
  }
}
