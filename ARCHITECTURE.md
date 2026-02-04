# Arquitectura - Claude Config

## Visión General

Claude Config es un sistema modular basado en git submodules que permite compartir y reutilizar configuraciones de Claude Code entre múltiples proyectos. El diseño prioriza la modularidad, versionado, y personalización a nivel de proyecto.

## Principios de Diseño

1. **Separación de Configuraciones**: Configuraciones compartidas (submodule) vs configuraciones específicas del proyecto
2. **Symlinks para Modularidad**: Cada proyecto selecciona solo los componentes que necesita
3. **Versionado con Git Submodules**: Control preciso de versiones de configuraciones
4. **Configuración en Capas**: Base -> Preset -> Local
5. **Automatización**: Scripts para reducir fricción en la adopción

## Componentes del Sistema

### 1. Skills (`skills/`)

**Propósito**: Comandos slash reutilizables que extienden las capacidades de Claude Code.

**Estructura**:
```
skills/
├── web-dev/
│   ├── react-component/
│   │   └── SKILL.md
│   └── api-design/
│       └── SKILL.md
├── devops/
├── testing/
└── utilities/
```

**Formato de SKILL.md**:
```markdown
---
name: skill-name
description: Brief description
user-invocable: true
categories: [web-dev, frontend]
---

# Skill Documentation

Instructions for Claude on how to execute this skill.
```

**Flujo de Uso**:
1. Usuario ejecuta `/skill-name` en Claude Code
2. Claude lee `.claude/skills/skill-name/SKILL.md` (symlink)
3. Claude ejecuta instrucciones del skill
4. Usuario obtiene resultado consistente

### 2. Agents (`agents/`)

**Propósito**: Agentes especializados pre-configurados con contexto específico.

**Estructura**:
```
agents/
├── web-dev/
│   ├── frontend-specialist.md
│   └── react-expert.md
├── devops/
│   └── docker-specialist.md
├── testing/
│   └── test-engineer.md
└── utilities/
```

**Formato de Agent**:
```markdown
---
name: Frontend Specialist
expertise: [React, TypeScript, CSS]
model: sonnet
---

# Agent Context

You are a frontend specialist focused on...
[Detailed instructions and context]
```

**Flujo de Uso**:
1. Usuario invoca agent desde Claude Code
2. Agent carga contexto desde archivo
3. Agent opera con conocimiento especializado

### 3. Settings (`settings/`)

**Propósito**: Presets de configuración para diferentes tipos de proyectos.

**Jerarquía de Configuración**:
```
base.json (foundational)
    ↓
web-dev.json (extends base)
    ↓
settings.local.json (project-specific, gitignored)
```

**base.json** - Configuración base universal:
```json
{
  "model": "sonnet",
  "permissions": {
    "bash": "ask",
    "read": "always-allow",
    "write": "ask"
  },
  "hooks": {},
  "memory": []
}
```

**web-dev.json** - Preset para desarrollo web:
```json
{
  "extends": "./base.json",
  "model": "sonnet",
  "permissions": {
    "bash": "always-allow",
    "npm": "always-allow"
  },
  "enabledSkills": [
    "react-component",
    "api-design",
    "frontend-debug"
  ]
}
```

**settings.local.json** - Configuración del proyecto (gitignored):
```json
{
  "extends": "../.claude-config/settings/web-dev.json",
  "model": "opus",
  "apiKey": "sk-...",
  "projectSpecificSettings": {}
}
```

### 4. Memory (`memory/`)

**Propósito**: Contextos y conocimiento compartido entre proyectos.

**Estructura**:
```
memory/
└── coding-standards/
    ├── typescript.md
    ├── python.md
    └── clean-code.md
```

**Uso**: Referencias en CLAUDE.md del proyecto para mantener consistencia de estándares.

### 5. Scripts (`scripts/`)

**Propósito**: Automatización de instalación y mantenimiento.

#### install.ps1 (Windows)

**Funcionalidad**:
1. Valida entorno (verifica `.claude/` existe)
2. Presenta lista de skills disponibles
3. Usuario selecciona skills interactivamente
4. Crea symlinks usando `New-Item -ItemType SymbolicLink`
5. Copia template base de configuración
6. Muestra resumen de instalación

**Pseudocódigo**:
```powershell
# Validar
if (-not (Test-Path ".claude")) {
    New-Item -ItemType Directory -Path ".claude"
}

# Listar skills
$skills = Get-ChildItem ".claude-config/skills" -Recurse -Filter "SKILL.md"

# Selección interactiva
$selected = Show-SelectionMenu $skills

# Crear symlinks
foreach ($skill in $selected) {
    New-Item -ItemType SymbolicLink `
        -Path ".claude/skills/$skill" `
        -Target "../.claude-config/skills/$skill"
}

# Copiar template
Copy-Item ".claude-config/templates/minimal/*" ".claude/"
```

#### install.sh (Linux/Mac)

**Funcionalidad**: Equivalente a install.ps1 pero usando bash.

#### update.ps1 / update.sh

**Funcionalidad**:
1. Navega al directorio del submodule
2. Ejecuta `git pull origin main`
3. Actualiza symlinks si hay nuevos skills
4. Notifica cambios al usuario

### 6. Templates (`templates/`)

**Propósito**: Estructuras iniciales para nuevos proyectos.

**Templates Disponibles**:

**minimal/** - Setup básico:
```
minimal/
├── settings.local.json
└── CLAUDE.md
```

**web-app/** - Aplicación web:
```
web-app/
├── settings.local.json (web-dev preset)
├── CLAUDE.md (contexto frontend)
└── skills/ (symlinks pre-configurados)
```

**fullstack/** - Aplicación full-stack:
```
fullstack/
├── settings.local.json (múltiples presets)
├── CLAUDE.md (contexto completo)
├── skills/ (frontend + backend)
└── agents/ (frontend + backend specialists)
```

## Flujo de Trabajo con Git Submodules

### Agregar a Nuevo Proyecto

```bash
# 1. Agregar submodule
git submodule add <repo-url> .claude-config

# 2. Instalar
./.claude-config/scripts/install.ps1

# 3. Personalizar
edit .claude/settings.local.json
```

### Actualizar Configuraciones Compartidas

```bash
# En el repositorio claude-config
git pull origin main
git commit -m "Update: new skills"
git push

# En proyectos que usan el submodule
cd .claude-config
git pull origin main
cd ..
git add .claude-config
git commit -m "Update claude-config submodule"
```

### Pinear Versión Específica

```bash
cd .claude-config
git checkout v1.2.0
cd ..
git add .claude-config
git commit -m "Pin claude-config to v1.2.0"
```

## Estructura Resultante en Proyectos

```
mi-proyecto/
├── .git/
├── .gitignore
├── .gitmodules           # Define submodule
├── .claude/              # Configuración específica del proyecto
│   ├── settings.local.json    # No versionado (gitignored)
│   ├── CLAUDE.md              # Contexto del proyecto
│   ├── skills/                # Symlinks a skills seleccionados
│   │   ├── react-component -> ../../.claude-config/skills/web-dev/react-component
│   │   └── api-design -> ../../.claude-config/skills/web-dev/api-design
│   └── agents/                # Symlinks a agents seleccionados
│       └── frontend-specialist.md -> ../../.claude-config/agents/web-dev/frontend-specialist.md
├── .claude-config/       # Submodule (versionado, compartido)
│   ├── skills/
│   ├── agents/
│   ├── settings/
│   ├── memory/
│   ├── scripts/
│   ├── templates/
│   └── docs/
└── src/                  # Código del proyecto
```

## Consideraciones de Symlinks en Windows

### Requisitos
- **Developer Mode habilitado** (Windows 10+), o
- **Ejecutar PowerShell como Administrador**

### Alternativas si Symlinks Fallan
1. **Junctions** (solo directorios): `New-Item -ItemType Junction`
2. **Hard Links** (solo archivos): `New-Item -ItemType HardLink`
3. **Copiar archivos** (menos ideal, requiere actualización manual)

### Detección Automática en Scripts
```powershell
try {
    New-Item -ItemType SymbolicLink -Path "test" -Target "test"
    Remove-Item "test"
    $useSymlinks = $true
} catch {
    Write-Warning "Symlinks not available, using junctions/copies"
    $useSymlinks = $false
}
```

## Ventajas del Diseño

1. **Modularidad Total**: Proyectos eligen exactamente lo que necesitan
2. **Versionado Granular**: Control fino con git submodules
3. **Actualización Segura**: Cambios en claude-config no afectan automáticamente
4. **Personalización sin Conflictos**: settings.local.json es gitignored
5. **Colaboración Facilitada**: Equipos comparten skills/agents sin imponer configuraciones
6. **Escalabilidad**: Agregar nuevos skills/agents no requiere cambios en proyectos existentes

## Desventajas y Mitigaciones

### Complejidad de Submodules
- **Mitigación**: Scripts automatizados + documentación clara
- **Guías**: docs/submodule-workflow.md

### Permisos en Windows
- **Mitigación**: Detección automática + alternativas (junctions/copies)
- **Documentación**: docs/troubleshooting.md

### Sincronización Manual
- **Mitigación**: update.ps1 script + recordatorios en documentación
- **Futuro**: Hook de git para notificar actualizaciones disponibles

## Extensibilidad

### Agregar Nuevo Skill
1. Crear directorio en categoría apropiada
2. Crear SKILL.md con formato estándar
3. Documentar en skills/README.md
4. Commit y push a claude-config

### Agregar Nuevo Preset
1. Crear archivo en settings/
2. Extender base.json o otro preset
3. Documentar en ARCHITECTURE.md
4. Agregar opción en install.ps1

### Agregar Nueva Categoría
1. Crear directorio en skills/ y agents/
2. Actualizar scripts de instalación
3. Documentar en README.md

## Testing del Sistema

### Test de Instalación
```bash
# Crear proyecto de prueba
mkdir test-project && cd test-project
git init
git submodule add ../claude-config .claude-config

# Ejecutar instalación
./.claude-config/scripts/install.ps1

# Verificar
ls -la .claude/skills  # Debe mostrar symlinks
cat .claude/settings.local.json  # Debe existir
```

### Test de Skills
```bash
# En Claude Code
/react-component Button "onClick handler"

# Verificar que Claude ejecuta el skill correctamente
```

### Test de Actualización
```bash
# Hacer cambio en claude-config
cd .claude-config
echo "test" >> skills/web-dev/test-skill/SKILL.md
git commit -am "Test change"
cd ..

# Actualizar en proyecto
./.claude-config/scripts/update.ps1

# Verificar cambio se refleja
cat .claude/skills/test-skill/SKILL.md
```

## Roadmap Futuro

1. **Auto-update hooks**: Git hooks para notificar actualizaciones
2. **Registry de skills**: Búsqueda y descubrimiento de skills
3. **Validación de skills**: CI/CD para validar formato de skills
4. **Templates adicionales**: Mobile, data science, ML/AI
5. **CLI tool**: Herramienta dedicada para gestionar claude-config
6. **Marketplace**: Compartir skills públicamente

## Referencias

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [PowerShell Symlinks](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
