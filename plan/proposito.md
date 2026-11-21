# Propósito, visión y objetivos de CareCar v2

## Propósito

Que el cliente de la agencia **viva toda la vida de su vehículo desde el celular**: desde que recibe las llaves hasta que lo vende o lo cambia por uno nuevo, sin llamadas, sin filas y sin papeles. La agencia, a cambio, conserva al cliente en su taller, le vende servicio, refacciones, accesorios y su siguiente auto.

## Visión

> CareCar es la app que un dueño de auto **abre por gusto**: le dice qué necesita su coche antes de que falle, le resuelve el servicio con dos toques, le muestra en vivo qué pasa en el taller, guarda todos sus papeles y lo premia por volver.

## Principios de producto

1. **La ficha técnica es el piso, no el techo.** Sus 58 funcionalidades se cumplen al 100 %; todo lo demás se suma encima.
2. **Cero callejones sin salida.** Toda pantalla tiene estado de carga, vacío, error, sin conexión y una acción siguiente.
3. **Dos toques al valor.** Lo más frecuente (próxima cita, estado del servicio, documentos) a dos toques del inicio.
4. **Proactiva, no reactiva.** La app avisa (mantenimiento, vencimientos, recalls, cita lista) antes de que el cliente pregunte.
5. **Confianza visible.** Precios, estados y tiempos claros; nada de letras chiquitas; estimaciones marcadas como no vinculantes.
6. **Para todos.** Accesible (WCAG 2.2 AA), letra grande, lector de pantalla, modo oscuro, español e inglés.
7. **Funciona en el estacionamiento del taller.** Sin conexión lee lo último guardado y encola acciones.
8. **Segura por defecto.** Datos personales mínimos, cifrados y bajo control del cliente (derechos ARCO).
9. **Bonita de verdad.** Sistema de diseño v2 propio, con movimiento, fotos grandes y tipografía cuidada (ver `docs/diseno/`).

## Objetivos de producto (sin fechas)

Cada objetivo tiene un indicador. Se mide desde la analítica de producto (M23).

| ID | Objetivo | Indicador de éxito |
| --- | --- | --- |
| O1 | Cumplir la ficha técnica al 100 % en v2 | Matriz `cumplimiento-ficha.md` toda en ✅ con prueba automática por requisito |
| O2 | Hacer de la app el canal principal para agendar servicio | Mayoría de las citas del taller nacen en la app |
| O3 | Eliminar la incertidumbre del cliente mientras su auto está en el taller | Cada orden abierta muestra estado en vivo; baja de llamadas "¿ya está mi carro?" |
| O4 | Aumentar la retención en el taller de la agencia | Clientes que regresan a su siguiente mantenimiento recomendado |
| O5 | Generar ingreso desde la app | Pagos de servicio, refacciones/accesorios y leads de auto nuevo originados en la app |
| O6 | Que el cliente tenga todo su expediente en un lugar | Vehículos con documentos cargados y alertas de vencimiento activas |
| O7 | Satisfacción medible | NPS por servicio capturado en la app y respondido por la agencia |
| O8 | Calidad de ingeniería ejemplar | CI verde siempre; cobertura alta en dominio; cero crashes críticos abiertos; arranque rápido |
| O9 | Accesibilidad e inclusión | Auditoría WCAG 2.2 AA sin hallazgos críticos |
| O10 | Equipo que entrega en paralelo | Las 6 personas con PR integrados en cada hito; ningún módulo depende de una sola persona |

## Qué NO es (por ahora)

- No reemplaza al CRM ni al ERP web (congelados); solo consume y alimenta al backend compartido.
- No es una app de venta de autos usados entre particulares.
- No ofrece registro público: la cuenta la crea la agencia (ficha, M01).
