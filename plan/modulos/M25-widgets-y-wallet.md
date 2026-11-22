# M25 · Widgets, Wallet y accesos rápidos

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Juan Pablo |
| Revisa | Cristian |
| Ficha técnica | No (frente transversal; se cumple dentro de las funcionalidades de la ficha) |
| Estado | Listo para historias |

## Propósito

CareCar fuera de la app: widget de inicio con próxima cita y estado del taller, pase de cita en Google Wallet / Apple Wallet, accesos rápidos desde el ícono. Mueve O2 y O3.

## Pantallas

- **Widget de inicio** (Android Glance, iOS WidgetKit) — próxima cita o, si hay una orden abierta, la etapa del taller.
- **Pase de Wallet** — botón en el comprobante de cita para guardarlo en Google Wallet o Apple Wallet.
- **Accesos rápidos** — al mantener presionado el ícono: Agendar, Mi auto y SOS.
- **Live Activity** (iPhone) — etapa del taller en la pantalla bloqueada mientras la orden esté abierta.

## Datos

Sin tablas nuevas: lee `cita` y la orden de servicio abierta (M04).

## API (`/api/v1/app`)

| Método | Ruta | Uso |
| --- | --- | --- |
| GET | `/citas/{id}/pase?plataforma=apple\|google` | Pase firmado por el backend con el QR del comprobante (V2-M02.11). |

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M25.01 | Como cliente quiero un widget con mi próxima cita para verla sin abrir la app | Android (Glance) e iOS (WidgetKit) · fecha, hora y vehículo de la próxima cita confirmada; sin cita invita a agendar · un toque abre la cita · se actualiza al agendar o cancelar | | V2-M02.09, V2-T01.03 |
| V2-M25.02 | Como cliente quiero ver en el widget el estado de mi auto en el taller para seguirlo de un vistazo | Con orden abierta muestra la etapa actual (M04); sin orden, vuelve a la próxima cita | | V2-M04.02, V2-M25.01 |
| V2-M25.03 | Como cliente quiero guardar mi cita en Wallet para presentarla en recepción | Botón en el comprobante · pase firmado por el backend con el QR · si la cita se cancela, el pase queda vencido | ✅ | V2-M02.11 |
| V2-M25.04 | Como cliente quiero accesos rápidos desde el ícono para ir directo a lo que más uso | Mantener presionado el ícono muestra Agendar, Mi auto y SOS · cada uno abre su pantalla | | V2-T01.03 |
| V2-M25.05 | Como cliente de iPhone quiero ver el estado del taller en la pantalla bloqueada para seguir mi servicio | Live Activity con la etapa actual mientras la orden esté abierta · termina al entregar el auto · se actualiza por push desde el backend | ✅ | V2-M04.03 |

## Fuera de alcance / notas

- Firmar pases de Apple y Google pide certificados de las cuentas de desarrollador; van fuera del repositorio (R8) y se tramitan junto con T04.
