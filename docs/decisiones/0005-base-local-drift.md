# 0005 · Base local con drift (SQLite) cifrada

**Estado:** Aceptada

## Contexto

La v1 guarda respuestas en archivos de caché. La v2 necesita consultar datos sin red (vehículos, historial, citas, documentos, bitácora), cola de operaciones pendientes y migraciones de esquema.

## Opciones

1. Seguir con caché en archivos/JSON.
2. `drift` (SQLite tipado) con cifrado (SQLCipher).
3. Base NoSQL embebida (Isar/Hive/ObjectBox).

## Decisión

Opción 2. SQL tipado con migraciones versionadas y consultas reactivas; mismo modelo mental que el backend (PostgreSQL); cifrado para datos personales.

## Consecuencias

- Generación de código y migraciones locales que mantener (M21.01).
- La base se borra al cerrar sesión.
