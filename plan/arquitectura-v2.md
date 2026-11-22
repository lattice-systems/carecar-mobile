# Arquitectura objetivo de la app v2

Estado: **Aceptada**. T01.01 aceptó las decisiones 0001 a 0005, así que ya se puede migrar código por este documento.

## Forma

```
lib/
├── main_desarrollo.dart · main_pruebas.dart · main_produccion.dart   # flavors (T01.04)
├── app.dart                         # MaterialApp.router + tema v2 + localización
├── nucleo/                          # compartido por todos los módulos; no conoce módulos
│   ├── api/                         # ApiCliente (http + tokens + refresco), errores, idempotencia
│   ├── sesion/                      # sesión, biometría, almacén seguro
│   ├── datos_locales/               # base local cifrada y cola sin conexión (M21)
│   ├── navegacion/                  # rutas, deep links, guardias de sesión
│   ├── diseno/                      # tokens, tema, componentes v2 (T02)
│   ├── l10n/                        # ARB es/en (M20)
│   ├── notificaciones/              # FCM + locales (M06)
│   └── observabilidad/              # errores y eventos (M23)
└── modulos/
    └── <modulo>/                    # acceso, vehiculos, citas, catalogo, taller, …
        ├── datos/                   # repositorio + DTO ↔ modelo, fuente remota y local
        ├── dominio/                 # modelos inmutables y reglas puras (sin Flutter)
        └── presentacion/            # pantallas, controladores de estado, widgets propios
```

## Reglas

1. `modulos/a` **no importa** `modulos/b/datos` ni `modulos/b/presentacion`. Si dos módulos se necesitan, se comunican por rutas (navegación) o por un contrato publicado en `modulos/b/b.dart`. Lo verifica T01.06.
2. `dominio/` es Dart puro: se prueba sin Flutter.
3. Toda llamada de red pasa por `nucleo/api`; ningún módulo crea su propio `http.Client`.
4. Toda pantalla usa componentes de `nucleo/diseno`. Prohibido `Color(0x…)`, tamaños de letra o `EdgeInsets` mágicos fuera de los tokens.
5. Cada pantalla resuelve cinco estados: cargando (esqueleto), con datos, vacío, error con reintento, sin conexión.
6. Cadenas visibles solo en ARB.

## Inyección de dependencias (V2-T01.02)

Riverpod sin generación de código. `lib/nucleo/api` y `lib/nucleo/sesion` exponen proveedores (`carecarApiProvider`, `apiClienteProvider`, `controladorSesionProvider`, `estadoSesionProvider`) que `main.dart` inyecta con `overrides`; en pruebas se sustituyen por fakes. Guía de módulo: [`lib/modulos/README.md`](../lib/modulos/README.md).

## Migración desde v1

- La v1 vive en `lib/api`, `lib/sesion`, `lib/pantallas`, `lib/widgets`, `lib/tema`. Se migra **módulo por módulo** (M01 → M02 → M03) detrás de un interruptor de rutas (T01.05).
- `lib/api/carecar_api.dart` y `cliente_api.dart` se reutilizan como base de `nucleo/api` (ya manejan tokens y refresco). Hoy `nucleo/api` los **envuelve** (`ApiCliente` = `ClienteApi`); el código físico se mueve en V2-T01.05.
- Al cerrar H2 se elimina el código v1 (T01.07) y `shadcn_ui` (T02.08).

## Backend

Contrato compartido en `agencia-360-backend/docs/api/`. La app v2 consume `agencia360-api-app-v2.yaml` (T05.02), compatible con v1.
