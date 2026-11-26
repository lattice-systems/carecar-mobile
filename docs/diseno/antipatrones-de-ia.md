# Diseño genérico («AI slop»): qué se rechaza y cómo se revisa

Complementa el [sistema de diseño v2](sistema-de-diseno-v2.md). Nace de una petición de Daniel (2026-11-25): que la app «no se vea mucha IA, con buen diseño, consistente y reutilizable».

## La idea

Un elemento es genérico no por su color, su tipo de letra o su forma, sino porque **se eligió por reflejo y no para este producto**. Se sospecha de un elemento cuando varias de estas cosas son ciertas:

- se podría pegar tal cual en otra app;
- repite un patrón que las herramientas generan por omisión;
- choca con el sistema local o con la pantalla de al lado;
- no dice nada útil (estado, acción, jerarquía, marca);
- compite con el contenido.

No se adivina si algo lo hizo una IA: se juzga lo que se ve.

**Prueba de eliminación.** Nombra el elemento, di qué trabajo hace y quítalo mentalmente. Si el significado, el estado o la acción sobreviven y la pantalla se aclara, se borra. Se añade algo nuevo solo si borrar dejó un hueco real, y siempre con el lenguaje que la app ya tiene.

## Qué se rechaza

Cada fila dice qué se rechaza, el caso real de CareCar donde apareció y la regla que queda.

| Antipatrón | Caso en CareCar | Regla |
| --- | --- | --- |
| **Navegación repetida**: el cuerpo ofrece los mismos destinos que la barra | El inicio traía tres accesos redondos (Vehículos, Citas, Catálogo) con los destinos de la barra, y el botón flotante casi tapaba el último | Un destino vive en un solo lugar. El cuerpo muestra datos (V2-T02.22) |
| **Cuadrícula de tarjetas iguales** de icono y título | El detalle del auto presentaba su navegación (Ficha técnica, Historial, Mantenimiento, Bitácora) como cuatro tarjetas iguales en 2×2 | Ir a pantallas hijas es una lista con chevron: `GrupoLista` |
| **Dos estilos de tarjeta en una pantalla** | El inicio dibujaba la tarjeta del taller (borde y medallón redondo) junto a la de citas (sombra y cuadro lleno) | Una familia: `TarjetaResumen` para resúmenes, `GrupoLista` para listas |
| **Héroes decorativos**: degradados, resplandores, círculos de icono con brillo | Se retiraron en V2-T02.21 | Lleva color pleno solo lo que la pantalla trata: el auto, el QR, el avance |
| **Etiquetas en MAYÚSCULAS sobre el contenido** («eyebrows») | Ajustes (todavía v1) abre con `MI PERFIL` y separa con `CUENTA`, `AYUDA` | `micro` es para metadatos. Los encabezados de sección van en minúsculas con la inicial en mayúscula |
| **Un tono con el significado equivocado** | «Sin próximo servicio estimado» llevaba una palomita verde, pero lo que falta es el kilometraje: no es una buena noticia | Tono = significado (tabla de abajo) |
| **El estado solo en color** | Falla con daltonismo y con lector de pantalla | Texto siempre; icono de tono en las insignias que piden una acción (`estadoConIcono`) |
| **Lo vacío por encima de lo que hay** | La invitación a agendar iba antes que el próximo servicio | Lo vacío va al final |
| **Ritmo irregular**: huecos que cambian según qué tarjetas se vean | Entre la tarjeta del taller y la de citas había 44 px; entre las demás, 16 | Cada tarjeta lleva su propia separación inferior (16); quien las junta no suma huecos |
| **El mismo dato escrito distinto** | `18.450 km` en el inicio y `18,450 km` en el resto | En español, formato de México: `formatearMiles` |
| **Pantallas sin salida visible**, o con el botón de otro color | Historial, Tu orden, Inspección, Adicionales y Ficha técnica abrían sin botón de regreso; «Pedir ayuda» cerraba con una X azul | Toda pantalla de detalle abre con `MarcoPantalla` o `BarraPantalla`, con `BotonRegresar` o `BotonCerrar`. Una prueba de arquitectura falla si un módulo arma `EncabezadoGrande` a mano |
| **Vidrio y desenfoque como adorno** | Cuesta rendimiento y legibilidad sin decir nada | Solo donde hay capas reales: la barra flotante y el encabezado que se recoge |
| **Movimiento sin propósito** (entradas en cascada, rebotes en todo) | Distrae y cansa | Un momento orquestado por pantalla; el que responde a un toque (abrir, confirmar) sí |
| **Datos o pruebas inventados** que parecen reales | Engaña | Cada cifra sale del servidor o de un estado vacío honesto |

### Tono = significado

| Tono | Úsalo para |
| --- | --- |
| `exito` | Hecho, vigente, listo |
| `advertencia` | Por vencer o a la espera de que el cliente haga algo |
| `peligro` | Vencido, error, acción que no se deshace |
| `informacion` | Dato neutro, o que falta un dato |
| `neutro` | Sin carga emocional |

## Es una app móvil, no una web portada

La pregunta es: ¿un usuario de Android o de iPhone confiaría en esto o dudaría de los controles?

- Objetivos táctiles de **48** como mínimo; separación entre ellos.
- El texto escala hasta **200 %** sin cortarse ni tapar acciones (el botón flotante se esconde a más de 150 %).
- Áreas seguras respetadas; el gesto de regreso del sistema siempre funciona.
- Oscuro como apariencia de primera clase, probado, no invertido.
- **Una** acción principal por pantalla.
- Controles del sistema de diseño, no inventados por pantalla.

## Cómo se revisa

Antes de abrir un PR con interfaz, contesta:

- [ ] ¿Algún destino de la barra aparece también en el cuerpo?
- [ ] ¿Cada pantalla usa una sola familia de tarjetas y filas (`TarjetaResumen`, `GrupoLista`)?
- [ ] ¿Cada elemento pasa la prueba de eliminación?
- [ ] ¿El color de cada insignia y cada icono dice lo que significa?
- [ ] ¿Lo vacío va después de lo que hay?
- [ ] ¿Los números y fechas se escriben igual que en el resto de la app?
- [ ] ¿Hay una salida visible y el botón es el estándar?
- [ ] ¿Se probó en claro, oscuro y letra al 200 %?
- [ ] ¿La captura se tomó de la app corriendo (no de un maquetado)?

## Herramientas

Tres skills de agente (2026-11-25): se leyó su contenido completo antes de instalarlas, pero no se ejecutaron sus scripts. Sirven a quien trabaje con Claude Code; las reglas de arriba valen igual para personas y para otros agentes.

| Skill | Para qué | Origen |
| --- | --- | --- |
| `audit-ai-design-slop` | Auditoría con evidencia, sin editar: hallazgos priorizados y qué quitar primero | [`mengto/skills`](https://github.com/mengto/skills) (MIT) |
| `no-ai-design-slop` | Filtro pasivo mientras se construye y la prueba de eliminación | [`mengto/skills`](https://github.com/mengto/skills) (MIT) |
| `impeccable` | Diseño, crítica, auditoría y pulido, con guías nativas de iOS y Android | [`pbakaus/impeccable`](https://github.com/pbakaus/impeccable) (Apache-2.0) |

```bash
npx skills add pbakaus/impeccable -g -a claude-code -s impeccable -y
npx skills add mengto/skills -g -a claude-code -s no-ai-design-slop -s audit-ai-design-slop -y
```

Cuidado con `impeccable`: su lanzador (`scripts/impeccable`) descarga un binario desde las *releases* de su repositorio y lo verifica contra un SHA-256 incluido en la skill. Para este proyecto basta leer sus guías (`reference/*.md`); no hace falta ejecutarlo, y menos instalar sus ganchos (`/impeccable hooks`) sin revisarlos.

Una skill es texto que el agente obedece con los permisos del usuario: se lee antes de instalar.
