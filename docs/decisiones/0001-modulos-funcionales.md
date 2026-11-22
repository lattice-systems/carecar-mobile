# 0001 · Organizar la app por módulos funcionales

**Estado:** Aceptada

## Contexto

La v1 organiza por tipo de archivo (`pantallas/`, `widgets/`, `api/`). Con 27 módulos y 6 personas trabajando en paralelo, ese orden mezcla trabajo de todos en las mismas carpetas, provoca conflictos y esconde qué pertenece a qué módulo.

## Opciones

1. Mantener la organización por tipo.
2. Por módulo funcional (`lib/modulos/<modulo>/{datos,dominio,presentacion}`) + núcleo compartido.
3. Paquetes Dart separados por módulo (monorepo con `melos`).

## Decisión

Opción 2. Da propiedad clara por módulo sin el costo de mantener decenas de paquetes. Si un módulo crece mucho, puede extraerse a paquete después.

## Consecuencias

- Cada dueño de módulo trabaja casi siempre en su carpeta: menos conflictos.
- Hace falta una regla verificada de dependencias entre módulos (T01.06).
- Migración gradual desde v1 (T01.05).
