# CLAUDE.md

@AGENTS.md

## Específico de Claude Code

- Subagentes del equipo en `.claude/agents/`: `sincronizador` (Haiku), `planificador` (Opus), `orquestador` (Sonnet), `implementador` (Sonnet). Úsalos según la sección 3 de `AGENTS.md`.
- Subagentes de apoyo: `explorer` (Haiku, solo lectura: Read/Grep/Glob) para investigar el código antes de implementar, e `implementer` (Sonnet) para cambios de código acotados con un plan claro. Para una historia completa con rama, tablero y PR sigue usándose `implementador`.
- Implementadores en paralelo: cada uno en su propio worktree (`isolation: worktree`) y su propia rama.
- `.claude/settings.json` desactiva la atribución (`attribution` vacío): no agregues `Co-Authored-By` ni "Generated with" a mano.
- Config local personal: `.claude/settings.local.json` y `CLAUDE.local.md` (ignorados por git).
