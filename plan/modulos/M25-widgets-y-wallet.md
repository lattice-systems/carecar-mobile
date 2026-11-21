# M25 · Widgets, Wallet y accesos rápidos

| Campo | Valor |
| --- | --- |
| Hito | H6 |
| Dueño | Jael |
| Revisa | Cristian |
| Ficha técnica | No |
| Estado | Borrador |

## Propósito

CareCar fuera de la app: widget de inicio con próxima cita y estado del taller, pase de cita en Google Wallet / Apple Wallet, accesos rápidos desde el ícono. Mueve O2 y O3.

## Historias

| ID | Historia | Criterios de aceptación | B | Depende de |
| --- | --- | --- | --- | --- |
| V2-M25.01 | Como cliente quiero un widget con mi próxima cita | Android (Glance) e iOS (WidgetKit) · toque abre la cita | | V2-M02.09 |
| V2-M25.02 | Como cliente quiero ver en el widget el estado de mi auto en el taller | Etapa actual de M04 | | V2-M04.02 |
| V2-M25.03 | Como cliente quiero guardar mi cita en Wallet | Pase firmado por el backend con QR del comprobante | ✅ | V2-M02.11 |
| V2-M25.04 | Como cliente quiero accesos rápidos desde el ícono | Agendar, Mi auto, SOS | | V2-T01.03 |
| V2-M25.05 | Como cliente de iPhone quiero ver el estado del taller en la pantalla bloqueada | Live Activity durante la orden abierta | ✅ | V2-M04.03 |
