# Getting Started with Claude Config

Esta guía te ayudará a configurar claude-config en tu proyecto paso a paso.

## Requisitos Previos

- **Claude Code CLI** instalado
- **Git** (para submodules)
- **PowerShell 5.1+** (Windows) o **Bash** (Linux/Mac)
- **Developer Mode habilitado** (Windows, para symlinks) o ejecutar como administrador

### Verificar Developer Mode en Windows

1. Abre `Settings` → `Update & Security` → `For developers`
2. Activa `Developer Mode`
3. Reinicia si es necesario

## Opción 1: Nuevo Proyecto

Si estás creando un proyecto desde cero:

### Paso 1: Crear Proyecto

```bash
# Crear directorio
mkdir mi-proyecto
cd mi-proyecto

# Inicializar git
git init
```

### Paso 2: Agregar Claude Config como Submodule

```bash
git submodule add https://github.com/tu-usuario/claude-config .claude-config
```

### Paso 3: Ejecutar Instalación

**Windows (PowerShell)**:
```powershell
.\.claude-config\scripts\install.ps1
```

**Linux/Mac**:
```bash
chmod +x ./.claude-config/scripts/install.sh
./.claude-config/scripts/install.sh
```

### Paso 4: Seguir el Asistente Interactivo

El script te preguntará:

1. **Preset**: Elige el tipo de proyecto
   - `minimal`: Setup básico
   - `web-dev`: Desarrollo web
   - `devops`: DevOps e infraestructura
   - `testing`: Enfocado en testing

2. **Skills**: Selecciona skills adicionales
   - El preset incluye algunos por defecto
   - Puedes agregar más o saltar este paso

3. **Agents**: Selecciona agents especializados
   - Similar a skills, algunos vienen con el preset

### Paso 5: Personalizar Configuración

Edita `.claude/settings.local.json`:

```json
{
  "extends": "../.claude-config/settings/web-dev.json",
  "model": "sonnet",
  "permissions": {
    "bash": "always-allow",
    "npm": "always-allow"
  },
  "customSettings": {
    "projectName": "mi-proyecto",
    "apiUrl": "https://api.example.com"
  }
}
```

### Paso 6: Editar Contexto del Proyecto

Edita `.claude/CLAUDE.md` con información sobre tu proyecto:

```markdown
# Mi Proyecto

## Overview
Aplicación web para...

## Tech Stack
- Frontend: React + TypeScript
- Backend: Node.js + Express
- Database: PostgreSQL

## Development
\`\`\`bash
npm install
npm run dev
\`\`\`
```

## Opción 2: Proyecto Existente

Si ya tienes un proyecto:

### Paso 1: Navegar al Proyecto

```bash
cd mi-proyecto-existente
```

### Paso 2: Agregar Submodule

```bash
git submodule add https://github.com/tu-usuario/claude-config .claude-config
git submodule update --init --recursive
```

### Paso 3: Ejecutar Instalación

Mismo que en "Nuevo Proyecto", paso 3 en adelante.

## Verificar Instalación

### 1. Estructura de Directorios

Tu proyecto debería verse así:

```
mi-proyecto/
├── .git/
├── .gitignore
├── .gitmodules          # Configuración del submodule
├── .claude/
│   ├── settings.local.json
│   ├── CLAUDE.md
│   ├── skills/          # Symlinks a skills
│   └── agents/          # Symlinks a agents
├── .claude-config/      # Submodule
└── [tus archivos de proyecto]
```

### 2. Verificar Symlinks

**Windows (PowerShell)**:
```powershell
Get-ChildItem .\.claude\skills -Recurse
```

**Linux/Mac**:
```bash
ls -la .claude/skills
```

Deberías ver symlinks apuntando a `.claude-config/skills/...`

### 3. Verificar Configuración

```bash
cat .claude/settings.local.json
```

Debe mostrar tu configuración extendiend de un preset.

## Usar Skills

Una vez instalado, puedes usar skills en Claude Code:

```
/react-component Button "onClick, disabled, loading"
/api-design users "CRUD operations"
/docker-setup web-app "node, postgres"
/test-suite UserService unit
```

## Actualizar Claude Config

Cuando haya actualizaciones disponibles:

**Windows**:
```powershell
.\.claude-config\scripts\update.ps1
```

**Linux/Mac**:
```bash
./.claude-config/scripts/update.sh
```

## Troubleshooting

### Error: Symlinks No Soportados

**Síntoma**: Error al crear symlinks en Windows

**Solución**:
1. Habilita Developer Mode (ver arriba)
2. O ejecuta PowerShell como Administrador
3. O el script copiará archivos en lugar de symlinks

### Error: Submodule No Inicializado

**Síntoma**: `.claude-config/` está vacío

**Solución**:
```bash
git submodule update --init --recursive
```

### Error: Settings No Se Aplican

**Síntoma**: Claude no usa la configuración

**Solución**:
1. Verifica que `settings.local.json` existe
2. Verifica sintaxis JSON
3. Reinicia Claude Code

### Error: Skill No Encontrado

**Síntoma**: `/skill-name` no funciona

**Solución**:
1. Verifica que el skill está en `.claude/skills/`
2. Verifica que está en `enabledSkills` en settings
3. Re-ejecuta instalación si es necesario

## Próximos Pasos

1. **Explorar Skills**: Ver [skills/README.md](../skills/README.md) - Incluye guía de creación
2. **Explorar Agents**: Ver [agents/README.md](../agents/README.md) - Incluye guía de creación
3. **Personalizar Settings**: Ver [settings/README.md](../settings/README.md)
4. **Workflow con Submodules**: Ver [submodule-workflow.md](./submodule-workflow.md)
5. **Crear Skills/Agents**: Copia y modifica los existentes según necesites

## Ejemplos de Proyectos

Ver la carpeta `templates/` para ejemplos completos de diferentes tipos de proyectos:

- `templates/minimal/` - Setup mínimo
- `templates/web-app/` - Aplicación web
- `templates/fullstack/` - Aplicación full-stack

## Soporte

- **Issues**: [GitHub Issues](https://github.com/tu-usuario/claude-config/issues)
- **Discusiones**: [GitHub Discussions](https://github.com/tu-usuario/claude-config/discussions)
- **Documentación**: [docs/](../docs/)

## Resumen de Comandos

```bash
# Setup inicial
git submodule add <repo-url> .claude-config
./.claude-config/scripts/install.sh

# Actualizar
./.claude-config/scripts/update.sh

# Agregar más skills
./.claude-config/scripts/install.sh

# Verificar estructura
ls -la .claude/

# Editar configuración
nano .claude/settings.local.json

# Editar contexto
nano .claude/CLAUDE.md
```

¡Listo! Ahora tienes claude-config configurado y puedes empezar a usar skills y agents en tu proyecto.
