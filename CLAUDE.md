# Claude Config - Sistema de Configuración Reutilizable

**Tipo**: Git submodule para compartir configuraciones de Claude Code
**Stack**: Markdown, PowerShell, Bash, JSON
**Propósito**: Sistema modular de skills, agents, y configuraciones reutilizables entre proyectos

## Stack Objetivo

Este sistema está diseñado para proyectos con:

**Backend**: Python, Django, Django REST Framework, PostgreSQL
**Frontend**: Angular 14+, TypeScript, RxJS, SCSS
**Data**: pandas, scikit-learn, numpy, SQL, BigQuery
**ML**: Supervised & unsupervised learning
**DevOps**: Docker, GitHub Actions
**Cloud**: AWS (S3, EC2, RDS, Lambda), GCP (Cloud Storage, Compute, BigQuery)
**Principios**: Clean Code, SOLID, Clean Architecture

## Estructura

```
claude-config/
├── skills/              # 17 skills especializados
│   ├── web-dev/        # angular-component, api-design
│   ├── backend/        # django-api
│   ├── data/           # data-pipeline, sql-optimization, data-visualization, database-schema
│   ├── ml/             # model-design
│   ├── cloud/          # aws-setup, gcp-setup
│   ├── devops/         # docker-setup, github-actions
│   ├── quality/        # clean-code-review, frontend-supervisor
│   ├── testing/        # test-suite
│   └── utilities/      # pr-helper, docs-generator
├── agents/              # 9 agents expertos
│   ├── web-dev/        # angular-specialist.md
│   ├── backend/        # python-django-specialist.md
│   ├── data/           # data-scientist-specialist.md, database-architect.md
│   ├── design/         # ux-ui-designer.md
│   ├── security/       # security-auditor.md
│   ├── devops/         # cicd-specialist.md, docker-specialist.md
│   └── documentation/  # docs-writer-es.md
├── settings/            # 5 presets de configuración
│   ├── base.json
│   ├── web-dev.json
│   ├── data-science.json
│   ├── devops.json
│   └── testing.json
├── docs/                # Guías de uso
│   ├── getting-started.md
│   ├── submodule-workflow.md
│   ├── documentation-guide.md  # CLAUDE.md vs README.md
│   ├── using-context7.md       # Integración con Context7 MCP
│   └── troubleshooting.md
├── scripts/             # Instalación automatizada
│   ├── install.ps1     # Windows PowerShell
│   ├── install.sh      # Linux/Mac Bash
│   └── update.ps1      # Actualización
├── memory/              # Estándares de código
│   └── coding-standards/
│       ├── python.md
│       ├── typescript.md
│       └── clean-code.md
└── templates/           # Templates de proyecto
    ├── minimal/
    ├── web-app/
    └── fullstack/
```

## Navegación por Tarea

### Agregar/Modificar Skill

**Ubicación**: `skills/<categoría>/<skill-name>/SKILL.md`

**Estructura requerida**:
```markdown
---
name: skill-name
description: Brief description
user-invocable: true
categories: [category1, category2]
version: 1.0.0
---

# Skill Title
[Contenido del skill]
```

**Actualizar también**:
- `skills/README.md` - Agregar a catálogo
- `scripts/install.ps1` - Agregar a $PresetSkills si aplica
- `scripts/install.sh` - Agregar a PRESET_SKILLS si aplica

**Skills con reportes**:
Algunos skills generan reportes markdown (ej: `clean-code-review`):
- Reportes se guardan en `docs/code-reviews/` del proyecto
- Formato estandarizado con template
- Sistema de tracking (pendiente, en progreso, resuelto)
- Ver `skills/quality/clean-code-review/report-template.md` para formato

### Agregar/Modificar Agent

**Ubicación**: `agents/<categoría>/<agent-name>.md`

**Estructura requerida**:
```markdown
---
name: Agent Name
expertise: [skill1, skill2]
model: sonnet
version: 1.0.0
---

# Agent Title
[Expertise y responsabilidades]
```

**Actualizar también**:
- `agents/README.md` - Agregar a catálogo
- `scripts/install.ps1` - Agregar a $PresetAgents si aplica
- `scripts/install.sh` - Agregar a PRESET_AGENTS si aplica

### Agregar Preset de Configuración

**Ubicación**: `settings/<preset-name>.json`

**Estructura**:
```json
{
  "$schema": "https://json-schema.org/draft/07/schema#",
  "description": "Description",
  "extends": "./base.json",
  "model": "sonnet",
  "permissions": {},
  "enabledSkills": []
}
```

**Actualizar también**:
- `settings/README.md` - Documentar preset
- `scripts/install.ps1` - Agregar a $AvailablePresets
- `scripts/install.sh` - Agregar a PRESETS array

### Modificar Scripts de Instalación

**PowerShell**: `scripts/install.ps1`
**Bash**: `scripts/install.sh`

**Áreas críticas**:
- `$AvailablePresets` / `PRESETS` - Lista de presets
- `$PresetSkills` / `PRESET_SKILLS` - Skills por preset
- `$PresetAgents` / `PRESET_AGENTS` - Agents por preset

**Importante**:
- Usar `[PSCustomObject]@{}` en PowerShell (no `@{}`)
- Mantener sincronizados ambos scripts
- Probar en ambas plataformas

### Actualizar Documentación

**CLAUDE.md**: Mapa de navegación (este archivo)
**README.md**: Documentación para usuarios
**docs/**: Guías específicas

Ver `docs/documentation-guide.md` para balance CLAUDE.md vs README.md

### Agregar Estándares de Código

**Ubicación**: `memory/coding-standards/<lenguaje>.md`

Documentar:
- Convenciones de naming
- Patrones preferidos
- Anti-patterns a evitar
- Herramientas (linters, formatters)

## Comandos Esenciales

### Desarrollo Local

```bash
# Probar scripts de instalación
.\scripts\install.ps1         # Windows
./scripts/install.sh          # Linux/Mac

# Ver estructura de skills/agents
find skills -name "SKILL.md"
find agents -name "*.md" ! -name "README.md"

# Validar JSON
Get-Content settings/*.json | ConvertFrom-Json  # PowerShell
jq '.' settings/*.json                          # Linux/Mac
```

### Git Workflow

```bash
# Desarrollo
git add <archivos>
git commit -m "tipo: mensaje descriptivo"
git push origin main

# En proyectos que usan este submodule
cd .claude-config
git pull origin main
cd ..
```

### Testing en Proyecto Real

```bash
# En otro proyecto
git submodule add https://github.com/stephpoleo/claude-config .claude-config
git submodule update --init --recursive

# Instalar (preguntará si agregar a .gitignore)
./claude-config/scripts/install.ps1  # Windows
# o
./claude-config/scripts/install.sh   # Linux/Mac

# Opción interactiva:
# Add .claude-config/ to .gitignore? (y/n) [Recommended: y]: y
```

## Decisiones Arquitectónicas

### Git Submodule vs Otras Opciones

**Decisión**: Git submodule
**Razón**:
- Versionado independiente
- Reutilización en múltiples proyectos
- Actualizaciones controladas (no automáticas)
- Estándar de la industria

### Symlinks vs Copiar Archivos

**Decisión**: Symlinks con fallback a copia
**Razón**:
- Symlinks: Cambios en submodule se reflejan inmediatamente
- Fallback: Compatibilidad en Windows sin Developer Mode
- Scripts detectan capacidad y eligen método apropiado

### PowerShell + Bash

**Decisión**: Mantener ambos scripts sincronizados
**Razón**:
- PowerShell: Nativo en Windows
- Bash: Nativo en Linux/Mac
- Maximiza compatibilidad sin dependencias

### Opción de .gitignore Interactiva

**Decisión**: Preguntar si agregar `.claude-config/` a `.gitignore`
**Razón**:
- Flexibilidad: Configuración personal vs compartida por equipo
- Default recomendado: No subir (cada dev configura independientemente)
- Casos de uso válidos para ambas opciones:
  - Personal: No compartir configuración (recomendado)
  - Equipo: Estandarizar configuración del proyecto
- Script valida si es repo git antes de preguntar

### Estructura de Skills

**Decisión**: `skills/<categoría>/<skill-name>/SKILL.md`
**Razón**:
- Organización por dominio (web-dev, data, devops, etc.)
- Escalable (agregar categorías fácilmente)
- Descriptivo en exploradores de archivos
- Permite múltiples archivos por skill si necesario

### Presets como JSON

**Decisión**: Archivos JSON separados con herencia
**Razón**:
- Fácil de parsear programáticamente
- Schema validation disponible
- Herencia reduce duplicación (extends base.json)
- Standard para configuraciones

### Context7 Integration

**Decisión**: Documentar uso pero no hardcodear en skills
**Razón**:
- Context7 es opcional (MCP server)
- Skills deben funcionar sin Context7
- Documentación en `docs/using-context7.md`
- Agent docs-writer-es usa Context7 cuando disponible

### Asignación de Modelos a Agents

**Decisión**: Modelo específico por agent según complejidad de tareas
**Distribución**:
- **Opus (1 agent)**: Security Auditor
  - Razón: Análisis de seguridad crítico, requiere razonamiento profundo
  - Minimizar falsos positivos/negativos es crucial
  - Cadenas de ataque complejas requieren pensamiento multi-step
  - Costo justificado por criticidad de seguridad

- **Sonnet (6 agents)**: Angular, Django, Data Science, Database, UX/UI, Documentation
  - Razón: Balance perfecto velocidad/capacidad
  - Decisiones arquitectónicas pero patrones conocidos
  - Razonamiento necesario pero no extremo
  - Uso más frecuente - costo moderado

- **Haiku (2 agents)**: CI/CD, Docker
  - Razón: Tareas mecánicas, patrones establecidos
  - Configuración más que diseño
  - 80% más económico, 3x más rápido
  - Suficiente para YAML/Dockerfiles

**Impacto en costos**: ~6-10% ahorro con mejor velocidad en DevOps
**Filosofía**: Right model for the right task

## Fixes Aplicados

### Fix 1: Presets Incorrectos (Commit 4ba00e5)

**Problema**: Scripts tenían "minimal" hardcoded, faltaba "data-science"
**Solución**: Actualizar a "base", agregar todos los 5 presets
**Archivos**: `scripts/install.ps1`, `scripts/install.sh`

### Fix 2: PowerShell Presets Vacíos (Commit 7193c4a)

**Problema**: Presets mostraban solo guiones: `[1]  -`
**Causa**: PowerShell no accedía propiedades de `@{}` en arrays
**Solución**: Cambiar a `[PSCustomObject]@{}`
**Archivo**: `scripts/install.ps1`

## Patrones de Desarrollo

### Agregar Nuevo Skill - Checklist

1. Crear `skills/<categoría>/<nombre>/SKILL.md`
2. Seguir formato con frontmatter
3. Documentar en `skills/README.md`
4. Si es común, agregar a preset en scripts
5. Probar instalación
6. Commit descriptivo
7. Push a main

### Agregar Nuevo Agent - Checklist

1. Crear `agents/<categoría>/<nombre>.md`
2. Seguir formato con frontmatter
3. Documentar en `agents/README.md`
4. Si es común, agregar a preset en scripts
5. Probar instalación
6. Commit descriptivo
7. Push a main

### Modificar Scripts - Checklist

1. Modificar ambos (install.ps1 y install.sh)
2. Mantener sincronizados
3. Probar en Windows (PowerShell)
4. Probar en Linux/Mac (Bash) si posible
5. Usar `[PSCustomObject]@{}` en PowerShell
6. Commit descriptivo
7. Push a main

## Testing

### Probar Localmente

```bash
# En un directorio de prueba
mkdir test-project
cd test-project
git init
git submodule add ../claude-config .claude-config
cd .claude-config
./scripts/install.ps1
```

### Validar Skills/Agents

```bash
# Skills deben tener frontmatter válido
# Agents deben tener frontmatter válido
# JSONs deben parsear correctamente
```

## Notas Importantes

### NO Incluir en Repo

- `.claude/` - Específico de cada proyecto
- `settings.local.json` - Configuración local
- Archivos temporales o de testing

### Mantener Actualizado

- Skills cuando frameworks cambien
- Agents cuando best practices evolucionen
- Scripts cuando agreguemos funcionalidad
- Docs cuando estructura cambie

### Convenciones de Commits

```
Add: nuevo skill/agent/preset
Fix: corrección de bug
Update: mejora de existente
Docs: cambios en documentación
Refactor: reestructuración sin cambio funcional
```

## Referencias Rápidas

- **Getting Started**: `docs/getting-started.md`
- **Submodule Workflow**: `docs/submodule-workflow.md`
- **Documentation Guide**: `docs/documentation-guide.md`
- **Context7 Usage**: `docs/using-context7.md`
- **Skills Catalog**: `skills/README.md`
- **Agents Catalog**: `agents/README.md`
- **Settings Guide**: `settings/README.md`
- **Architecture**: `ARCHITECTURE.md`

## Contexto del Proyecto

Este sistema fue creado para estandarizar configuraciones de Claude Code en proyectos full-stack con enfoque en:

- Web development (Angular + Django)
- Data engineering & science
- Machine learning
- DevOps y cloud (AWS, GCP)
- Clean Code y SOLID principles

Diseñado para ser:
- **Modular**: Cada proyecto usa solo lo necesario
- **Reutilizable**: Una vez creado, disponible en todos los proyectos
- **Versionado**: Control total sobre actualizaciones
- **Extensible**: Fácil agregar nuevos skills/agents
- **Multiplataforma**: Windows, Linux, Mac

El sistema permite que equipos compartan conocimiento (skills, agents, estándares) mientras mantienen flexibilidad por proyecto (settings.local.json).
