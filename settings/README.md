# Settings Presets

Configuraciones pre-definidas para diferentes tipos de proyectos con Claude Code.

## Jerarquía de Configuración

Las configuraciones se aplican en capas:

```
1. base.json                    # Configuración base (foundation)
        ↓
2. [preset].json               # Preset específico (web-dev, devops, etc)
        ↓
3. settings.local.json         # Configuración del proyecto (gitignored)
```

Cada capa puede extender y sobrescribir la anterior.

## Presets Disponibles

### base.json

Configuración base fundamental para todos los proyectos.

**Características**:
- Permisos conservadores (pide confirmación)
- Sin skills habilitados por defecto
- Sin hooks configurados
- Modelo Sonnet por defecto

**Cuándo usar**: Como base para crear nuevos presets

---

### web-dev.json

Preset para proyectos de desarrollo web.

**Características**:
- Permisos para npm y bash siempre permitidos
- Skills de React y API design habilitados
- Hooks para linting
- Memoria de estándares TypeScript/JavaScript
- Herramientas: npm, eslint, prettier, vite

**Cuándo usar**:
- Aplicaciones web frontend
- APIs backend
- Full-stack applications
- Proyectos Node.js

**Skills incluidos**: `react-component`, `api-design`

---

### devops.json

Preset para proyectos de DevOps e infraestructura.

**Características**:
- Permisos para Docker, kubectl (con confirmación)
- Skills de Docker habilitados
- Hooks para validación YAML y security scan
- Memoria de patrones de microservicios
- Herramientas: docker, docker-compose, prometheus
- Modo verbose activado

**Cuándo usar**:
- Configuración de infraestructura
- Containerización
- CI/CD pipelines
- Deployment automation

**Skills incluidos**: `docker-setup`

---

### testing.json

Preset para proyectos enfocados en testing.

**Características**:
- Tests automáticos en save y commit
- Skills de testing habilitados
- Configuración de coverage thresholds
- Herramientas: jest, playwright, istanbul
- Watch mode habilitado

**Cuándo usar**:
- Proyectos con énfasis en QA
- TDD/BDD workflows
- Test automation projects

**Skills incluidos**: `test-suite`

---

## Uso

### 1. En Nuevo Proyecto

Durante la instalación, el script te preguntará qué preset usar:

```powershell
.\.claude-config\scripts\install.ps1
```

Esto copiará el preset seleccionado a `.claude/settings.local.json`

### 2. Personalizar Configuración Local

Edita `.claude/settings.local.json` en tu proyecto:

```json
{
  "extends": "../.claude-config/settings/web-dev.json",
  "model": "opus",
  "permissions": {
    "git": "always-allow"
  },
  "enabledSkills": [
    "react-component",
    "api-design",
    "docker-setup"
  ],
  "customSettings": {
    "projectName": "my-app",
    "lintOnSave": false
  }
}
```

### 3. Cambiar de Preset

Simplemente cambia el valor de `extends`:

```json
{
  "extends": "../.claude-config/settings/devops.json"
}
```

## Estructura de Configuración

### Campos Principales

#### model
```json
{
  "model": "sonnet"  // o "opus", "haiku"
}
```

Modelo de Claude a usar:
- `sonnet`: Balance de velocidad y capacidad (recomendado)
- `opus`: Mayor capacidad, más lento
- `haiku`: Más rápido, menor capacidad

#### permissions
```json
{
  "permissions": {
    "bash": "always-allow",  // o "ask", "deny"
    "read": "always-allow",
    "write": "ask",
    "edit": "ask",
    "npm": "always-allow",
    "docker": "ask",
    "git": "ask"
  }
}
```

Controla qué operaciones Claude puede hacer:
- `always-allow`: Ejecutar sin preguntar
- `ask`: Pedir confirmación (default)
- `deny`: Bloquear operación

#### hooks
```json
{
  "hooks": {
    "pre-bash": "echo 'Running command...'",
    "post-bash": null,
    "pre-write": "npm run lint",
    "post-write": "npm test -- --changed"
  }
}
```

Comandos a ejecutar antes/después de operaciones.

#### memory
```json
{
  "memory": [
    "../.claude-config/memory/coding-standards/typescript.md",
    "./project-context.md"
  ]
}
```

Archivos de contexto que Claude debe leer.

#### enabledSkills
```json
{
  "enabledSkills": [
    "react-component",
    "api-design",
    "docker-setup"
  ]
}
```

Skills disponibles en el proyecto.

#### customSettings
```json
{
  "customSettings": {
    "autoSave": true,
    "verbose": false,
    "lintOnSave": true,
    "testOnCommit": true
  }
}
```

Configuraciones personalizadas del proyecto.

## Crear Preset Personalizado

### 1. Crear Archivo

```bash
touch settings/my-preset.json
```

### 2. Definir Configuración

```json
{
  "$schema": "https://json-schema.org/draft-07/schema#",
  "description": "Custom preset for my specific needs",
  "extends": "./base.json",
  "model": "sonnet",
  "permissions": {
    "bash": "always-allow"
  },
  "enabledSkills": [
    "custom-skill"
  ]
}
```

### 3. Usar en Proyecto

```json
{
  "extends": "../.claude-config/settings/my-preset.json"
}
```

## Best Practices

### 1. Extender, No Copiar

Siempre usa `extends` en lugar de copiar toda la configuración:

```json
// ✓ BIEN
{
  "extends": "../.claude-config/settings/web-dev.json",
  "model": "opus"
}

// ✗ MAL - Copiar todo manualmente
{
  "model": "opus",
  "permissions": { /* ... todo copiado ... */ }
}
```

### 2. Settings Local Gitignored

`.claude/settings.local.json` debe estar en `.gitignore` para no compartir:
- API keys
- Configuraciones personales
- Paths locales

### 3. Permisos Mínimos

Usa el principio de privilegio mínimo:

```json
// Solo permite lo necesario
{
  "permissions": {
    "bash": "ask",        // Pedir confirmación por seguridad
    "read": "always-allow", // Safe, permite siempre
    "write": "ask"        // Pedir confirmación
  }
}
```

### 4. Documentar Custom Settings

```json
{
  "customSettings": {
    // Explain what this does
    "autoDeployOnCommit": true,
    // Path to deployment script
    "deployScript": "./scripts/deploy.sh"
  }
}
```

### 5. Usar Hooks con Cuidado

Hooks pueden ralentizar el workflow:

```json
{
  "hooks": {
    // Rápido: solo archivos cambiados
    "post-write": "npm test -- --changed",

    // Lento: todos los tests
    // "post-write": "npm test"
  }
}
```

## Ejemplos de Configuración

### Proyecto Full-Stack

```json
{
  "extends": "../.claude-config/settings/web-dev.json",
  "model": "sonnet",
  "enabledSkills": [
    "angular-component",
    "django-api",
    "docker-setup",
    "test-suite"
  ],
  "memory": [
    "../.claude-config/memory/coding-standards/typescript.md",
    "../.claude-config/memory/coding-standards/python.md",
    "../.claude-config/memory/coding-standards/clean-code.md",
    "./CLAUDE.md"
  ],
  "customSettings": {
    "frontend": {
      "framework": "angular",
      "packageManager": "npm"
    },
    "backend": {
      "framework": "django",
      "database": "postgresql"
    }
  }
}
```

### Proyecto DevOps

```json
{
  "extends": "../.claude-config/settings/devops.json",
  "model": "opus",
  "permissions": {
    "docker": "always-allow",
    "kubectl": "ask"
  },
  "enabledSkills": [
    "docker-setup"
  ],
  "customSettings": {
    "environment": "production",
    "cluster": "k8s-prod",
    "securityScanOnBuild": true
  }
}
```

### Proyecto Testing

```json
{
  "extends": "../.claude-config/settings/testing.json",
  "model": "sonnet",
  "hooks": {
    "post-write": "npm test -- --coverage --changed"
  },
  "customSettings": {
    "coverageThreshold": 90,
    "e2eBrowsers": ["chromium"],
    "ciMode": false
  }
}
```

## Troubleshooting

### Settings No se Aplican

1. Verificar que `extends` apunta al path correcto
2. Verificar sintaxis JSON (usar JSONLint)
3. Revisar logs de Claude Code

### Hooks Fallan

1. Verificar que comandos existen (npm, etc)
2. Probar comandos manualmente
3. Revisar paths relativos
4. Verificar permisos de ejecución

### Skills No Disponibles

1. Verificar que skills están en `enabledSkills`
2. Verificar que symlinks existen en `.claude/skills/`
3. Re-ejecutar instalación si es necesario

## FAQ

### ¿Puedo tener múltiples presets en un proyecto?

No directamente, pero puedes crear un preset custom que combine otros:

```json
{
  "extends": "../.claude-config/settings/web-dev.json",
  "enabledSkills": [
    // Skills de web-dev
    "react-component",
    // Skills de devops
    "docker-setup",
    // Skills de testing
    "test-suite"
  ]
}
```

### ¿Cómo comparto settings entre equipo?

Crea un preset en el submodule y todos lo pueden extender. Cada miembro mantiene su `settings.local.json` gitignored.

### ¿Puedo cambiar settings durante sesión?

No, settings se cargan al inicio. Necesitas reiniciar Claude Code.

### ¿Qué pasa si no uso extends?

Tendrás que definir todo manualmente, pero pierdes los beneficios de actualizaciones del submodule.

## Recursos

- [Documentación de Claude Code](https://github.com/anthropics/claude-code)
- [JSON Schema](https://json-schema.org/)
- [Guía de Configuración](../docs/configuration.md)

## Contribuir

Para agregar nuevos presets:

1. Crear archivo en `settings/`
2. Extender `base.json`
3. Documentar en este README
4. Agregar ejemplos de uso
5. Submit PR

## Licencia

MIT License - Ver [LICENSE](../LICENSE)
