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
> **Estado:** estructura inicial del proyecto. `lib/main.dart` todavía es la app de ejemplo de Flutter (el contador); no hay pantallas de CareCar implementadas.

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
- [Pendientes por definir](#-pendientes-por-definir)
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

En el **Sprint 1** se trabaja `APP-2.1 · Acceso exclusivo gestionado por la agencia`, contra una API simulada mientras el backend implementa el contrato.

---

## 🧰 Stack tecnológico

| Tecnología      | Uso                                                   |
| --------------- | ----------------------------------------------------- |
| Flutter + Dart  | Framework de UI multiplataforma y lenguaje            |
| Material Design | Componentes visuales base                             |
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

# 3. Correr la app en un emulador o dispositivo conectado
flutter run
```

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
| `flutter build ios`         | Compila para iOS (solo en macOS con Xcode)                |
| `flutter pub outdated`      | Muestra qué dependencias tienen versiones más nuevas      |

---

## 📁 Estructura del proyecto

```
carecar-mobile/
├── .github/workflows/     # CI (formato, análisis, pruebas, build), CodeQL y Dependency Review
├── docs/                  # Convenciones de ramas, commits y PR
├── lib/
│   └── main.dart          # Punto de entrada (todavía la app de ejemplo de Flutter)
├── test/
│   └── widget_test.dart   # Prueba del widget principal
├── android/               # Proyecto nativo de Android
├── ios/                   # Proyecto nativo de iOS
├── web/ windows/ macos/ linux/   # Plataformas de la plantilla, fuera del alcance
├── analysis_options.yaml  # Reglas de análisis estático
└── pubspec.yaml           # Dependencias y versión de la app
```

La organización de carpetas dentro de `lib/` se definirá conforme avance el desarrollo.

**Identificadores**

| Dato                       | Valor                        |
| -------------------------- | ---------------------------- |
| Paquete de Dart            | `carecar_mobile`             |
| Application id / bundle id | `com.carecar.carecar_mobile` |

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
| Simulación de la API   | Por definir en TEC-5                           | ⏳ Por configurar |
| De integración         | `integration_test` (en emulador o dispositivo) | ⏳ Por configurar |

Las pruebas viven en `test/` con el sufijo `_test.dart`. `test/widget_test.dart` muestra cómo construir un widget, simular un toque y revisar el resultado:

```bash
flutter test                          # todas las pruebas
flutter test test/widget_test.dart    # un solo archivo
```

---

## ✅ CI y checks del PR

Todo vive en `.github/workflows/` y corre en GitHub Actions. La rama `main` está protegida: solo se integra por PR, con una aprobación y **todos estos checks en verde**:

| Check                                       | Workflow          | Cuándo corre                          |
| ------------------------------------------- | ----------------- | ------------------------------------- |
| `Formato (dart format)`                     | CI                | Cada push a cualquier rama y cada PR  |
| `Análisis estático (flutter analyze)`       | CI                | Cada push a cualquier rama y cada PR  |
| `Pruebas (flutter test)`                    | CI                | Cada push a cualquier rama y cada PR  |
| `Build Android (APK)`                       | CI                | Cada push a cualquier rama y cada PR  |
| `Análisis de CodeQL (GitHub Actions)`       | CodeQL            | PR y push a `main`, y todos los lunes |
| `Revisión de dependencias nuevas/cambiadas` | Dependency Review | Solo en PR                            |

Los cuatro jobs de CI corren en paralelo. El más lento es el build de Android, que tarda unos 5 minutos; los demás, alrededor de minuto y medio.

Antes de hacer push, corre lo mismo en local para no enterarte del error hasta abrir el PR:

```bash
dart format lib test && flutter analyze && flutter test
```

El detalle de cada check (y por qué CodeQL revisa los workflows y no el código Dart) está en [`docs/convenciones-commits.md`](docs/convenciones-commits.md).

---

## 🤝 Forma de trabajo

- Metodología **Scrumban + XP**, en parejas de desarrollador + Claude.
- Límite WIP: 1 historia activa por desarrollador.
- Tablero, iteraciones y wiki en **Azure DevOps**; código en **GitHub**; CI/CD con **GitHub Actions**.
- Ramas, commits y PR siguen [`docs/convenciones-commits.md`](docs/convenciones-commits.md): rama corta por tarea, commits `tipo(alcance): verbo + cambio`, PR con una aprobación y se integra con **merge commit**.

<details>
<summary><strong>Definition of Ready y Definition of Done</strong> (propuesta del backlog V2, pendiente de aprobación)</summary>

- **Definition of Ready:** la historia tiene formato _Como / quiero / para_, criterios comprobables, dependencias resueltas o simuladas, y cabe en un sprint.
- **Definition of Done:** criterios validados por el PO, pruebas unitarias (TDD) y CI en verde, revisión de la otra pareja, integración a la rama principal y requisitos no funcionales generales cumplidos (contraseñas con hash y HTTPS, bitácora de acciones sensibles y datos personales tratados según el aviso de privacidad).

</details>

---

## ✅ Decisiones ya tomadas

Estaban en «Pendientes por definir» y se cerraron en los Sprints 1 y 2.

| Tema                 | Cómo quedó                                                                      |
| -------------------- | ------------------------------------------------------------------------------- |
| Tecnología de la app | **Flutter**, confirmado con el equipo y el PO (decisión D5)                      |
| Pantallas            | **Hechas**: acceso, cambio de la contraseña inicial y recuperación por código    |
| API simulada         | **json-server 0.17.4** sobre Express, en `mock_api/`                             |
| Cliente de la API    | **Escrito a mano** sobre `http`, no generado desde el contrato                   |

---

## 📌 Pendientes por definir

| Tema                 | Qué falta                                                                       |
| -------------------- | ------------------------------------------------------------------------------- |
| Librerías            | Navegación y manejo de estado. Hoy `ChangeNotifier` y un `setState` en la raíz, en su versión mínima y a la espera del documento de stack y arquitectura |
| Estructura de `lib/` | Convenciones de nombres y de carpetas. Hoy `api/`, `sesion/`, `pantallas/`, `tema/` y `widgets/` |
| Tipografía y logo    | Faltan los `.ttf` de Inter y JetBrains Mono y el SVG del logo. Hoy la app usa la fuente del sistema y un PNG derivado del JPEG |
| Notificaciones push  | Integración con Firebase Cloud Messaging                                         |
| Build de iOS en CI   | Requiere un runner de macOS; hoy CI solo compila Android, y **la app nunca se ha compilado para iOS** |
| Publicación          | Firma de release y publicación en Google Play y App Store                        |

---

## 📚 Documentación relacionada

- **Wiki del proyecto (Azure DevOps):** [Agente360 Wiki](https://dev.azure.com/latticesystems/Agente360/_wiki/wikis/Agente360.wiki), sección _Arquitectura y Tecnologías_.
- **Convenciones de ramas, commits y PR:** [`docs/convenciones-commits.md`](docs/convenciones-commits.md)
- **Backend:** [`agencia-360-backend`](https://github.com/lattice-systems/agencia-360-backend)
- **CRM frontend:** [`agencia-360-crm-frontend`](https://github.com/lattice-systems/agencia-360-crm-frontend)
- **ERP frontend:** [`agencia-360-erp-frontend`](https://github.com/lattice-systems/agencia-360-erp-frontend)
- **Documentación de Flutter:** [docs.flutter.dev](https://docs.flutter.dev)
