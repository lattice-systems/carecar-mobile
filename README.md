<div align="center">

# CareCar · App móvil

**App postventa de CareCar:** para los clientes que ya compraron una unidad en la agencia. Desde el celular consultan sus vehículos, el historial de servicios y tickets, y agendan citas en el taller.

<p>
  <a href="https://github.com/lattice-systems/carecar-mobile/actions/workflows/ci.yml"><img src="https://github.com/lattice-systems/carecar-mobile/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI" /></a>
  <a href="https://github.com/lattice-systems/carecar-mobile/actions/workflows/codeql.yml"><img src="https://github.com/lattice-systems/carecar-mobile/actions/workflows/codeql.yml/badge.svg?branch=main" alt="CodeQL" /></a>
</p>

<p>
  <img src="https://img.shields.io/badge/Flutter-3.47-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.47" />
  <img src="https://img.shields.io/badge/Dart-3.13-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.13" />
  <img src="https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material Design" />
</p>
<p>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
  <img src="https://img.shields.io/badge/GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions" />
</p>

[Cómo empezar](#-cómo-empezar) · [Comandos](#-comandos-útiles) · [Pruebas](#-pruebas) · [CI y checks](#-ci-y-checks-del-pr) · [Convenciones](docs/convenciones-commits.md)

</div>

> [!NOTE]
> **Estado:** el MVP v1 está en `main` (acceso, vehículos, manuales, historial con ticket, citas, catálogo, ajustes). Arranca la **v2**: se construye nueva sobre la [ficha técnica](docs/ficha-tecnica/README.md), con [plan maestro](plan/README.md) de 27 módulos, [sistema de diseño nuevo](docs/diseno/sistema-de-diseno-v2.md) y reglas de trabajo en [`AGENTS.md`](AGENTS.md).

> [!IMPORTANT]
> **Antes de tu primer cambio:** lee [`AGENTS.md`](AGENTS.md) y corre `git config core.hooksPath .githooks`. Vale igual para personas, Claude Code, Codex y Antigravity.

---

## 📑 Contenido

- [Contexto del proyecto](#-contexto-del-proyecto)
- [Alcance de la app](#-alcance-de-la-app)
- [Stack tecnológico](#-stack-tecnológico)
- [Cómo empezar](#-cómo-empezar)
- [Comandos útiles](#-comandos-útiles)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Arquitectura](#-arquitectura)
- [Pruebas](#-pruebas)
- [CI y checks del PR](#-ci-y-checks-del-pr)
- [Forma de trabajo](#-forma-de-trabajo)
- [Pendientes](#-pendientes)
- [Documentación relacionada](#-documentación-relacionada)

---

## 🧭 Contexto del proyecto

El proyecto se compone de cuatro aplicaciones que comparten una misma API:

| Aplicación        | Usuarios                                           | Repositorio                                                                               |
| ----------------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **App CareCar**   | Clientes de la agencia que ya compraron una unidad | Este repositorio                                                                          |
| **CRM web**       | Vendedores, gerente de marketing y administrador   | [`agencia-360-crm-frontend`](https://github.com/lattice-systems/agencia-360-crm-frontend) |
| **ERP web**       | Personal de los departamentos de la agencia        | [`agencia-360-erp-frontend`](https://github.com/lattice-systems/agencia-360-erp-frontend) |
| **API (backend)** | Atiende a la app, al CRM y al ERP                  | [`agencia-360-backend`](https://github.com/lattice-systems/agencia-360-backend)           |

---

## 🎯 Alcance de la app

Alcance del MVP según el documento de stack y arquitectura (v2):

| Funcionalidad     | Descripción                                                                                           |
| ----------------- | ----------------------------------------------------------------------------------------------------- |
| Acceso exclusivo  | Sin registro público: la agencia entrega usuario y contraseña al cliente después de validar la compra |
| Mis vehículos     | Las unidades del cliente, con su historial de servicios y los tickets que genera el taller            |
| Citas de servicio | El cliente agenda una cita y queda registrada en el módulo de Servicio del ERP                        |

Además: manuales del vehículo (PDF de la agencia o incluido en la app) y Ajustes/Perfil (cambiar contraseña, contacto, aviso de privacidad, cerrar sesión).

---

## 🧰 Stack tecnológico

| Tecnología      | Uso                                                   |
| --------------- | ----------------------------------------------------- |
| Flutter + Dart  | Framework de UI multiplataforma y lenguaje            |
| Material Design + `shadcn_ui` | Componentes visuales (`ShadApp` con la paleta de marca) |
| `http`          | Cliente de la API escrito a mano                      |
| `flutter_secure_storage` | Guarda la sesión (tokens) cifrada            |
| `flutter_animate`, `skeletonizer` | Animaciones y esqueletos de carga   |
| `google_fonts`  | Inter y JetBrains Mono (hoy se descargan en runtime)  |
| `pdfx`          | Visor de manuales y tickets en PDF                    |
| `flutter_lints` | Reglas de análisis estático (`analysis_options.yaml`) |
| `flutter_test`  | Pruebas unitarias y de widgets                        |
| GitHub Actions  | CI, CodeQL y Dependency Review                        |

Las plataformas objetivo son **Android** e **iOS**. Las carpetas `web/`, `windows/`, `macos/` y `linux/` vienen de la plantilla de Flutter y no son parte del alcance.

---

## 🚀 Cómo empezar

**Requisitos**

| Herramienta    | Versión                      | Para qué                            |
| -------------- | ---------------------------- | ----------------------------------- |
| Flutter SDK    | 3.47.5 o superior (`stable`) | Compilar y correr la app            |
| Dart SDK       | 3.13.4 o superior            | Viene incluido con Flutter          |
| Android Studio | Reciente, con el Android SDK | Emulador y compilación para Android |
| Xcode          | Reciente (solo en macOS)     | Simulador y compilación para iOS    |

Revisa que tu entorno esté completo (Flutter marca lo que falta):

```bash
flutter doctor
```

**Instalación**

```bash
# 1. Clonar el repositorio
git clone https://github.com/lattice-systems/carecar-mobile.git
cd carecar-mobile

# 2. Instalar dependencias
flutter pub get

# 3. Correr la app (API_BASE_URL es obligatorio, no hay valor por omisión)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/app   # emulador Android
```

| Dónde corre la app | `API_BASE_URL` |
| --- | --- |
| **Backend en la nube** (Azure + Neon, con datos de ejemplo) | `https://ca-agencia360-api.calmcliff-d0e7fc3b.eastus2.azurecontainerapps.io/api/v1/app` |
| Emulador Android | `http://10.0.2.2:8080/api/v1/app` |
| Celular por USB (con `adb reverse tcp:8080 tcp:8080`) | `http://localhost:8080/api/v1/app` |
| API simulada (`mock_api/`) | `http://localhost:3000/api/v1/app` |
| Backend en Docker detrás de nginx (red local) | `http://IP-DE-LA-PC:8089/api/v1/app` |

> [!NOTE]
> **Arranque en frío del backend en la nube.** Azure Container Apps apaga el servidor sin tráfico; la primera petición tras un rato de inactividad (por ejemplo el primer inicio de sesión) tarda ~35 s en despertarlo. La app espera hasta 60 s en lugar de fallar, y tras 8 s muestra «Despertando el servidor…» (V2-M01.12). Si aun así ves «Sin conexión», el servidor tardó más de un minuto o no hay red.

> [!NOTE]
> El proyecto es solo local: la app acepta `http` en debug y en release (IP de la PC con `ip -4 addr`).

> [!TIP]
> Con `flutter devices` ves los emuladores y dispositivos disponibles; con `flutter run -d <id>` eliges uno.

---

## 🔧 Comandos útiles

| Comando                     | Descripción                                               |
| --------------------------- | --------------------------------------------------------- |
| `flutter run`               | Corre la app con recarga en caliente (`r` en la terminal) |
| `dart format lib test`      | Aplica el formato oficial de Dart                         |
| `flutter analyze`           | Análisis estático con las reglas de `flutter_lints`       |
| `flutter test`              | Corre todas las pruebas                                   |
| `flutter build apk --debug` | Compila el APK de Android (lo mismo que revisa CI)        |
| `flutter build ios --no-codesign` | Compila iOS sin firmar (solo macOS; lo mismo que CI) |
| `flutter build apk --release --dart-define=API_BASE_URL=http://IP-DE-LA-PC:8089/api/v1/app` | APK para instalar en el celular |
| `flutter pub outdated`      | Muestra qué dependencias tienen versiones más nuevas      |

---

## 📁 Estructura del proyecto

```
carecar-mobile/
├── AGENTS.md              # Reglas para personas y agentes (CLAUDE.md y GEMINI.md apuntan aquí)
├── .claude/               # Subagentes de Claude Code y configuración sin atribución
├── .githooks/             # Hook commit-msg que quita co-autores de IA
├── .github/workflows/     # CI, Release, Autoría, CodeQL y Dependency Review
├── api/                   # Copia del contrato OpenAPI de la app (fuente de verdad)
├── assets/                # Logo, imágenes y manuales PDF incluidos
├── docs/                  # Ficha técnica, decisiones, diseño v2, convenciones, manuales
├── plan/                  # Plan maestro v2: propósito, hitos, módulos, tablero, reparto
├── mock_api/              # API simulada (json-server) para desarrollo sin backend
├── lib/
│   ├── main.dart          # Arranque: lee API_BASE_URL, crea la sesión y el ShadApp
│   ├── api/               # Cliente HTTP a mano: CarecarApi (interfaz), CarecarApiHttp,
│   │   │                  # ClienteApi (tokens y refresco), ApiConfig, excepciones
│   │   └── modelos/       # Vehiculo, Servicio, Cita, Disponibilidad, Manual, Perfil, ...
│   ├── sesion/            # ControladorSesion (ChangeNotifier) y almacén seguro
│   ├── manuales/          # Manual de la agencia con respaldo al PDF incluido
│   ├── pantallas/         # Login, recuperar/cambiar contraseña, inicio (menú),
│   │   │                  # vehículos, detalle, manual, ajustes, próximamente
│   │   ├── citas/         # Mis citas y Agendar cita
│   │   ├── servicios/     # Historial de servicios y ticket
│   │   └── perfil/        # Perfil
│   ├── tema/              # TemaCareCar: paleta, tipografía, tema Material y Shad
│   └── widgets/           # PaginaCareCar, menú, CargaDatos, campos, avisos, Movimiento
├── test/                  # Pruebas de API, contrato, sesión y pantallas
├── android/ ios/          # Proyectos nativos
├── analysis_options.yaml
└── pubspec.yaml           # Dependencias y versión (version: x.y.z+build)
```

**Identificadores**

| Dato                       | Valor                        |
| -------------------------- | ---------------------------- |
| Paquete de Dart            | `carecar_mobile`             |
| Application id (Android)   | `com.carecar.carecar_mobile` |
| Bundle id (iOS)            | `com.carecar.carecarMobile`  |

El paquete de Dart usa guion bajo porque Dart no admite guiones en los nombres de paquete; el repositorio se llama `carecar-mobile`.

> [!WARNING]
> No subas secretos al repositorio. El `.gitignore` ya excluye archivos `.env` (salvo `.env.example`) y las llaves de firma de Android (`*.jks`, `*.keystore`, `key.properties`). Los archivos de configuración local (`android/local.properties`, `ios/Flutter/Generated.xcconfig`, `.dart_tool/`, `build/`) se generan solos y tampoco se versionan.

---

## 🧱 Arquitectura

La app consume la misma **API REST** que el ERP y el CRM, construida con Spring Boot como **monolito modular**. Lo que usa la app vive en el módulo `carecarapp` del backend.

```
  ERP web             CRM web           App CareCar (este repo)
     │                   │                      │
     └───────────────────┼──────────────────────┘
                         ▼
       API REST · Spring Boot + Spring Modulith
                         │
     PostgreSQL · Redis · Almacenamiento · Firebase (FCM)
```

Lineamientos que afectan a la app:

- La API se documenta con OpenAPI. El contrato vive en `docs/api/` del repositorio del backend y aquí se versiona una copia en `api/`, que es insumo de la API simulada y de la prueba de contrato.
- **El cliente Dart de la app está escrito a mano** sobre `http`, no generado desde el contrato: una dependencia en lugar de tres y unas 150 líneas en lugar de ~40 archivos generados. Si el equipo decide generarlo, la interfaz `CarecarApi` no cambia y solo se reemplaza su implementación.
- **Sin registro público:** el login usa credenciales emitidas por la agencia.
- Los datos que ve el cliente (servicios, tickets, citas) los genera el ERP; la app solo los consulta o crea citas.
- Mientras el backend implementa el contrato, la app trabaja contra una **API simulada** con dirección configurable (TEC-5).

---

## 🧪 Pruebas

| Tipo                   | Herramienta                                    | Estado           |
| ---------------------- | ---------------------------------------------- | ---------------- |
| Unitarias y de widgets | `flutter_test`                                 | ✅ Configurado    |
| Simulación de la API   | `mock_api/` (json-server) + prueba de contrato | ✅ Configurado    |
| De integración         | `integration_test` (en emulador o dispositivo) | ⏳ Por configurar |

Las pruebas viven en `test/` con el sufijo `_test.dart` (API, contrato, sesión y pantallas; `test/ayudas/api_falsa.dart` simula la API). Las animaciones infinitas se apagan en pruebas (`test/flutter_test_config.dart`).

```bash
flutter test                          # todas las pruebas
flutter test test/widget_test.dart    # un solo archivo
```

---

## ✅ CI y checks del PR

Todo vive en `.github/workflows/` y corre en GitHub Actions. La rama `main` está protegida: solo se integra por PR (sin aprobación obligatoria por ahora) y con **todos estos checks en verde**:

| Check                                       | Workflow          | Cuándo corre                          |
| ------------------------------------------- | ----------------- | ------------------------------------- |
| `Formato (dart format)`                     | CI                | Cada PR y cada push a `main`         |
| `Análisis estático (flutter analyze)`       | CI                | Cada PR y cada push a `main`         |
| `Pruebas (flutter test)`                    | CI                | Cada PR y cada push a `main`         |
| `Build Android (APK)`                       | CI                | Cada PR y cada push a `main`         |
| `Build iOS (sin firma)`                     | CI (macOS)        | Cada PR y cada push a `main`         |
| `Análisis de CodeQL (GitHub Actions)`       | CodeQL            | PR y push a `main`, y todos los lunes |
| `Revisión de dependencias nuevas/cambiadas` | Dependency Review | Solo en PR                            |
| `Sin co-autor de IA`                        | Autoría           | Solo en PR                            |

Los cinco jobs de CI corren en paralelo. Los builds de Android e iOS son los más lentos (5-6 y unos 3 minutos); el de iOS corre en un runner de macOS y compila sin firmar. Para no gastar tiempo: el push a una rama no dispara CI (lo cubre su PR; ábrelo temprano, aunque sea en borrador) y si el PR solo cambia documentación (`docs/`, `plan/`, `.claude/`, `.githooks/` o `.md`) los cinco jobs se saltan y cuentan como aprobados.

**Versión y releases.** La versión vive solo en `version:` de `pubspec.yaml`; el número de build lo pone CI (`github.run_number`). Para sacar una versión: sube la versión en `pubspec.yaml` por PR, intégrala a `main` y corre `git tag vX.Y.Z && git push origin vX.Y.Z`. El workflow `Release` verifica que la etiqueta coincida con el pubspec y publica un GitHub Release con el APK, apuntando al servidor de la variable de repositorio `API_BASE_URL` (si falta, el workflow falla; hoy firmado con la llave de debug; detalle en [`plan/modulos/T04-entrega-continua.md`](plan/modulos/T04-entrega-continua.md)).

Antes de hacer push, corre lo mismo en local para no enterarte del error hasta abrir el PR:

```bash
dart format lib test && flutter analyze && flutter test
```

El detalle de cada check (y por qué CodeQL revisa los workflows y no el código Dart) está en [`docs/convenciones-commits.md`](docs/convenciones-commits.md).

---

## 🤝 Forma de trabajo

- Metodología **Scrumban + XP**. Las 6 personas programan, cada una dueña de sus módulos ([reparto](plan/equipo-y-reparto.md)).
- Agentes de código con roles fijos: **sincronizador**, **planificador**, **orquestador** e **implementador** ([`AGENTS.md`](AGENTS.md) §3; en Claude Code viven en `.claude/agents/`).
- Límite WIP: 1 historia activa por persona. Estado de todo en [`plan/tablero.md`](plan/tablero.md).
- Ramas, commits y PR siguen [`docs/convenciones-commits.md`](docs/convenciones-commits.md): rama corta por historia, commits atómicos `tipo(alcance): verbo + cambio`, PR con una aprobación y **merge commit**.
- **Documentación en cada PR, sin excepción**, y **sin IA como autor ni co-autor**.

<details>
<summary><strong>Definition of Ready y Definition of Done</strong> (propuesta del backlog V2, pendiente de aprobación)</summary>

- **Definition of Ready:** la historia tiene formato _Como / quiero / para_, criterios comprobables, dependencias resueltas o simuladas, y cabe en un sprint.
- **Definition of Done:** criterios validados por el PO, pruebas unitarias (TDD) y CI en verde, revisión de la otra pareja, integración a la rama principal y requisitos no funcionales generales cumplidos (contraseñas con hash y HTTPS, bitácora de acciones sensibles y datos personales tratados según el aviso de privacidad).

</details>

---

## ✅ Decisiones ya tomadas

Se cerraron en los Sprints 1 a 3.

| Tema                 | Cómo quedó                                                                      |
| -------------------- | ------------------------------------------------------------------------------- |
| Tecnología de la app | **Flutter**, confirmado con el equipo y el PO (decisión D5)                      |
| Pantallas            | **Hechas**: acceso, vehículos, manuales, historial y ticket, citas, ajustes      |
| API simulada         | **json-server 0.17.4** sobre Express, en `mock_api/`                             |
| Cliente de la API    | **Escrito a mano** sobre `http`, no generado desde el contrato                   |
| Estado               | `ChangeNotifier`; sin Provider/Riverpod/Bloc                                     |
| Componentes          | `shadcn_ui` sobre Material, con la paleta de marca                               |

---

## 📌 Pendientes

Los pendientes ya no viven aquí: todo está en el [plan maestro v2](plan/README.md) y su [tablero](plan/tablero.md). Lo más urgente frente a la ficha técnica (ver [matriz](plan/cumplimiento-ficha.md)):

| Brecha | Historia |
| --- | --- |
| Falta la calculadora de toma a cuenta (APP-4.1) | V2-M03.04 |
| Recuperación por código en vez de enlace de un solo uso | V2-M01.04, V2-T05.04 |
| El cliente no puede editar teléfono y correo | V2-M01.07 |
| Cinco tablas del backend no coinciden con la ficha | V2-T05.03 a V2-T05.07 |

---

## 📚 Documentación relacionada

- **Wiki del proyecto (Azure DevOps):** [Agente360 Wiki](https://dev.azure.com/latticesystems/Agente360/_wiki/wikis/Agente360.wiki), sección _Arquitectura y Tecnologías_.
- **Reglas para personas y agentes:** [`AGENTS.md`](AGENTS.md)
- **Ficha técnica (obligatoria):** [`docs/ficha-tecnica/`](docs/ficha-tecnica/README.md)
- **Plan maestro v2:** [`plan/`](plan/README.md)
- **Sistema de diseño v2:** [`docs/diseno/sistema-de-diseno-v2.md`](docs/diseno/sistema-de-diseno-v2.md)
- **Decisiones de arquitectura:** [`docs/decisiones/`](docs/decisiones/README.md)
- **Convenciones de ramas, commits y PR:** [`docs/convenciones-commits.md`](docs/convenciones-commits.md)
- **Backend:** [`agencia-360-backend`](https://github.com/lattice-systems/agencia-360-backend)
- **CRM frontend:** [`agencia-360-crm-frontend`](https://github.com/lattice-systems/agencia-360-crm-frontend)
- **ERP frontend:** [`agencia-360-erp-frontend`](https://github.com/lattice-systems/agencia-360-erp-frontend)
- **Documentación de Flutter:** [docs.flutter.dev](https://docs.flutter.dev)

## Correr en local con el celular

Todo corre en la laptop; el celular Android se conecta por USB (con depuracion USB activada).

1. Levanta el backend (puerto 8089 detras de nginx):
   `cd ../backend-agencia360-wt-app2 && ADMIN_INICIAL_USUARIO=admin ADMIN_INICIAL_CONTRASENA=Admin12345 GERENTE_INICIAL_USUARIO=gerente GERENTE_INICIAL_CONTRASENA=Gerente12345 docker compose --profile proxy up -d`
2. Datos de ejemplo (opcional): `API=http://localhost:8089 bash ../backend-agencia360-wt-app2/scripts/cargar-datos-de-ejemplo.sh`
3. Instala y abre la app: `bash scripts/instalar_en_celular.sh` (puerto distinto: `API_PUERTO=8090 bash scripts/instalar_en_celular.sh`). Hace `adb reverse`, compila y usa `-r`.
   Si adb dice `unauthorized`: `adb kill-server && adb start-server` y acepta el aviso en el telefono.

Usuario de prueba: `laura.mendez@example.com` / `CareCar2026!`.
Correos de recuperacion de contrasena: Mailpit en http://localhost:8025.
Sin conexion, la app muestra los ultimos datos guardados (cache en disco, se borra al cerrar sesion).
