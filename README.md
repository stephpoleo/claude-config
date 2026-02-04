# Claude Config - Sistema de Configuración Reutilizable

Sistema modular de configuración para Claude Code que permite compartir skills, agents, y configuraciones entre proyectos usando git submodules.

## Características

- **Skills Personalizados**: Catálogo de comandos especializados reutilizables
- **Agents Especializados**: Agentes pre-configurados para tareas específicas
- **Configuraciones Base**: Presets de configuración para diferentes tipos de proyectos
- **Memory Compartida**: Contextos y estándares de código reutilizables
- **Templates de Proyecto**: Estructuras iniciales para nuevos proyectos
- **Instalación Automatizada**: Scripts para configurar rápidamente cualquier proyecto

## Quick Start

### 1. Agregar a un Proyecto Existente

```bash
# Agregar como submodule
git submodule add https://github.com/tu-usuario/claude-config .claude-config

# Inicializar el submodule
git submodule update --init --recursive

# Ejecutar instalación (Windows)
.\.claude-config\scripts\install.ps1

# Ejecutar instalación (Linux/Mac)
./.claude-config/scripts/install.sh
```

### 2. Seleccionar Skills y Agents

El script de instalación te guiará interactivamente para:
- Seleccionar skills necesarios para tu proyecto
- Elegir agents especializados
- Configurar settings base
- Crear symlinks automáticamente

### 3. Personalizar Configuración

Edita `.claude/settings.local.json` para ajustar la configuración específica de tu proyecto:

```json
{
  "model": "sonnet",
  "enabledSkills": ["react-component", "api-design"],
  "permissions": {
    "bash": "always-allow"
  }
}
```

## Estructura del Repositorio

```
claude-config/
├── skills/           # Skills organizados por categoría
├── agents/           # Agents especializados
├── settings/         # Presets de configuración
├── memory/           # Contextos compartidos
├── scripts/          # Scripts de instalación
├── templates/        # Templates de proyecto
└── docs/            # Documentación completa
```

## Uso en Proyectos

Una vez instalado, tu proyecto tendrá:

```
mi-proyecto/
├── .claude/
│   ├── settings.local.json    # Tu configuración
│   ├── CLAUDE.md              # Contexto del proyecto
│   ├── skills/                # Symlinks a skills
│   └── agents/                # Symlinks a agents
└── .claude-config/            # Submodule (compartido)
```

## Skills Disponibles (10)

### Web Development
- `angular-component` - Crear componentes Angular con TypeScript, Signals
- `api-design` - Diseñar APIs RESTful (genérico)
- `django-api` - APIs Django REST Framework con Clean Architecture

### Data Engineering & Science
- `data-pipeline` - Pipelines ETL/ELT para procesar datos
- `sql-optimization` - Optimizar queries SQL para performance
- `model-design` - Diseñar modelos ML (supervisados y no supervisados)
- `data-visualization` - Crear visualizaciones con matplotlib, seaborn, plotly

### DevOps & Cloud
- `docker-setup` - Configurar Docker y Docker Compose
- `github-actions` - Pipelines CI/CD con GitHub Actions
- `aws-setup` - Configurar servicios AWS (S3, EC2, RDS, Lambda)
- `gcp-setup` - Configurar servicios GCP (Cloud Storage, Compute, BigQuery)

### Quality & Testing
- `test-suite` - Crear test suites completos
- `clean-code-review` - Review de código con SOLID y Clean Code

Ver catálogo completo en [skills/README.md](skills/README.md)

## Agents Disponibles (6)

### Web & Backend
- **Angular Specialist** - Experto en Angular 14+, TypeScript, RxJS, Signals
- **Python Django Specialist** - Backend con Django, DRF, Clean Architecture, SOLID

### Data Science
- **Data Scientist Specialist** - ML (supervisado/no supervisado), análisis, feature engineering

### DevOps
- **CI/CD Specialist** - GitHub Actions, pipelines, Docker, AWS, GCP deployment
- **Docker Specialist** - Containerización, Docker Compose, optimización

### Documentation
- **Documentation Writer (ES)** - Documentación técnica, CLAUDE.md, README.md, Context7

Ver catálogo completo en [agents/README.md](agents/README.md)

## Actualización

```bash
# Actualizar configuraciones compartidas
cd .claude-config
git pull origin main
cd ..

# O usar el script
.\.claude-config\scripts\update.ps1
```

## Ventajas

1. **Modularidad**: Cada proyecto usa solo lo que necesita
2. **Versionado**: Control de versiones con git submodules
3. **Actualización Centralizada**: Mejoras disponibles para todos los proyectos
4. **Flexibilidad**: Configuración local independiente
5. **Reutilización**: Skills y agents disponibles inmediatamente
6. **Colaboración**: Equipos comparten conocimiento y configuraciones

## Documentación

### Guías de Uso
- [Getting Started Guide](docs/getting-started.md) - Inicio rápido
- [Submodule Workflow](docs/submodule-workflow.md) - Trabajo con git submodules
- [Documentation Guide](docs/documentation-guide.md) - Balance CLAUDE.md vs README.md
- [Using Context7](docs/using-context7.md) - Consultar documentación oficial de frameworks
- [Troubleshooting](docs/troubleshooting.md) - Solución de problemas

### Guías de Desarrollo
- [Skills Catalog](skills/README.md) - Catálogo y guía para crear skills
- [Agents Catalog](agents/README.md) - Catálogo y guía para crear agents
- [Architecture Details](ARCHITECTURE.md) - Detalles arquitectónicos

## Requisitos

- Claude Code CLI instalado
- Git (para submodules)
- PowerShell 5.1+ (Windows) o Bash (Linux/Mac)
- Permisos para crear symlinks (Windows: Developer Mode o admin)

## Licencia

MIT License - Ver [LICENSE](LICENSE) para detalles.

## Soporte

- Issues: [GitHub Issues](https://github.com/tu-usuario/claude-config/issues)
- Documentación: [docs/](docs/)
- Ejemplos: [templates/](templates/)
