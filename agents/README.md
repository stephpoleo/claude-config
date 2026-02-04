# Agents Catalog

Catálogo de agentes especializados disponibles en claude-config. Los agents son contextos pre-configurados que dan a Claude conocimiento especializado para tareas específicas.

## Qué son los Agents

Los agents son archivos markdown que definen un contexto especializado para Claude Code. Cuando invocas un agent, Claude adopta el rol, expertise y directrices definidas en el archivo, permitiendo respuestas más enfocadas y expertas en áreas específicas.

## Cómo Usar Agents

1. **Instalación**: Los agents se vinculan a tu proyecto usando symlinks
2. **Invocación**: Invoca agents desde Claude Code según necesidad
3. **Personalización**: Copia y modifica agents para necesidades específicas

## Agents Disponibles

### Web Development

#### Angular Specialist
**Expertise**: Angular 14+, TypeScript, RxJS, SCSS, Web Performance
**Model**: Sonnet
**File**: `agents/web-dev/angular-specialist.md`

**Capacidades**:
- Standalone components y Signals (Angular 16+)
- Arquitectura de aplicaciones Angular
- RxJS y programación reactiva
- OnPush change detection
- State management con Signals
- Lazy loading y performance
- Testing con Jasmine/Karma

**Cuándo usar**:
- Desarrollar componentes Angular
- Implementar reactive patterns
- Optimizar performance Angular
- Diseñar arquitectura de aplicación
- Migrar a standalone components

---

### Backend

#### Python Django Specialist
**Expertise**: Django, Django REST Framework, PostgreSQL, Clean Architecture
**Model**: Sonnet
**File**: `agents/backend/python-django-specialist.md`

**Capacidades**:
- Django REST Framework APIs
- Clean Architecture con Service/Selector pattern
- Optimización de QuerySets
- Celery para tareas asíncronas
- SOLID principles en Python
- PostgreSQL optimization
- Testing con pytest

**Cuándo usar**:
- Diseñar APIs REST
- Implementar Clean Architecture
- Optimizar queries de base de datos
- Estructurar business logic
- Implementar autenticación/autorización

---

### Data Science

#### Data Scientist Specialist
**Expertise**: Python, ML (supervised/unsupervised), pandas, scikit-learn, SQL
**Model**: Sonnet
**File**: `agents/data/data-scientist-specialist.md`

**Capacidades**:
- Machine Learning (supervisado y no supervisado)
- Feature engineering
- Data pipelines ETL/ELT
- Análisis exploratorio (EDA)
- SQL optimization
- Visualización de datos
- Model evaluation y tuning

**Cuándo usar**:
- Diseñar modelos ML
- Crear pipelines de datos
- Análisis de datos complejos
- Feature engineering
- Optimizar queries SQL
- Implementar data validation

---

### DevOps

#### CI/CD Specialist
**Expertise**: GitHub Actions, Docker, AWS, GCP, CI/CD Pipelines
**Model**: Sonnet
**File**: `agents/devops/cicd-specialist.md`

**Capacidades**:
- GitHub Actions workflows
- Docker containerization
- AWS y GCP deployment
- Pipeline design (lint, test, build, deploy)
- Secrets management
- Monitoring y observability
- Deployment strategies (blue-green, canary)

**Cuándo usar**:
- Configurar CI/CD pipelines
- Automatizar deployments
- Implementar testing automation
- Configurar cloud infrastructure
- Optimizar build times

#### Docker Specialist
**Expertise**: Docker, Docker Compose, Containerization
**Model**: Sonnet
**File**: `agents/devops/docker-specialist.md`

**Capacidades**:
- Dockerfiles optimizados
- Multi-stage builds
- Docker Compose para desarrollo
- Optimización de imágenes
- Seguridad de containers
- Health checks y logging

**Cuándo usar**:
- Containerizar aplicaciones
- Optimizar imágenes Docker
- Configurar entornos multi-container
- Implementar best practices de seguridad

---

### Design

#### UX/UI Designer
**Expertise**: UX Design, UI Design, Accessibility, Design Systems, Angular
**Model**: Sonnet
**File**: `agents/design/ux-ui-designer.md`

**Capacidades**:
- User Experience (UX) design
- User Interface (UI) design
- Accessibility (a11y) - WCAG 2.1 compliance
- Responsive design (mobile-first)
- Design systems y component libraries
- Micro-interactions y animations
- Angular Material, Tailwind CSS
- Figma, prototyping
- User research y testing

**Cuándo usar**:
- Diseñar nuevas features o componentes
- Mejorar UX de funcionalidad existente
- Implementar accessibility
- Crear design system
- Revisar diseños visuales
- Optimizar responsive design
- Definir interacciones y transitions

---

### Documentation

#### Documentation Writer (ES)
**Expertise**: Technical Writing, CLAUDE.md, README.md, API Docs
**Model**: Sonnet
**File**: `agents/documentation/docs-writer-es.md`

**Capacidades**:
- Documentación optimizada para LLMs (CLAUDE.md)
- Documentación para desarrolladores (README.md)
- API documentation
- Code comments inline
- Integración con Context7 para docs oficiales
- Español técnico directo y conciso

**Cuándo usar**:
- Crear/actualizar CLAUDE.md
- Escribir README completo
- Documentar APIs
- Crear guías técnicas
- Balancear documentación LLM vs humana

---

## Estructura de un Agent

```markdown
---
name: Agent Name
expertise: [skill1, skill2, skill3]
model: sonnet
version: 1.0.0
---

# Agent Title

You are a [role] specialist with deep expertise in [areas].

## Core Expertise
[List of technologies and skills]

## Responsibilities
[What this agent is responsible for]

## Best Practices
[Guidelines and standards to follow]

## Common Patterns
[Reusable patterns and solutions]

## Communication Style
[How to interact with users]
```

## Crear Tus Propios Agents

### 1. Definir el Rol

Especifica claramente:
- Área de especialización
- Tecnologías y herramientas
- Nivel de expertise esperado
- Modelo recomendado (sonnet/opus)

### 2. Documentar Expertise

Detalla:
- Conocimientos core
- Frameworks y librerías
- Herramientas relacionadas
- Best practices específicas

### 3. Establecer Responsabilidades

Define qué debe hacer el agent:
- Tareas principales
- Decisiones que puede tomar
- Cuándo escalar a otros especialistas

### 4. Incluir Ejemplos

Proporciona:
- Patrones de código
- Configuraciones comunes
- Soluciones a problemas frecuentes
- Anti-patterns a evitar

### 5. Definir Comunicación

Especifica:
- Cómo explicar conceptos
- Nivel de detalle en respuestas
- Cuándo pedir clarificación
- Formato de respuestas

## Agents vs Skills

### Agents
- Contexto persistente durante sesión
- Conocimiento especializado amplio
- Para tareas complejas o exploratorias
- Define comportamiento general

### Skills
- Invocación puntual
- Tarea específica y acotada
- Para acciones concretas y repetibles
- Define proceso específico

### Cuándo Usar Cada Uno

**Usa Agent cuando**:
- Necesitas expertise especializado
- La tarea requiere decisiones arquitectónicas
- Hay múltiples sub-tareas relacionadas
- Necesitas contexto de dominio específico

**Usa Skill cuando**:
- La tarea es específica y bien definida
- Quieres resultado consistente
- Es una operación repetible
- No requiere decisiones complejas

## Combinando Agents y Skills

Agents pueden usar skills para tareas específicas:

```
Agent: Frontend Specialist
  ↓ usa
Skill: /react-component Button
```

El agent proporciona contexto y expertise, el skill proporciona el proceso específico.

## Roadmap de Agents

### Próximos Agents Planeados

#### Web Development
- [ ] Backend Architect
- [ ] API Specialist
- [ ] Database Expert
- [ ] GraphQL Specialist
- [ ] Security Expert

#### DevOps
- [ ] Kubernetes Specialist
- [ ] CI/CD Engineer
- [ ] Infrastructure as Code Expert
- [ ] Monitoring Specialist
- [ ] Cloud Architect (AWS/Azure/GCP)

#### Testing
- [ ] Test Engineer
- [ ] QA Specialist
- [ ] Performance Tester
- [ ] Security Tester

#### Data
- [ ] Data Engineer
- [ ] Data Scientist
- [ ] Analytics Expert

#### General
- [ ] Code Reviewer
- [ ] Documentation Writer
- [ ] Refactoring Specialist
- [ ] Debugger

## Best Practices para Agents

### 1. Enfoque Específico

Agents deben tener un área de especialización clara, no intentar ser generalistas.

**Bien**:
- Frontend Specialist (específico)
- Docker Specialist (específico)

**Mal**:
- Full Stack Everything (demasiado amplio)
- Programming Expert (muy genérico)

### 2. Contexto Rico

Proporciona suficiente contexto para que el agent pueda:
- Tomar decisiones informadas
- Recomendar best practices
- Identificar anti-patterns
- Sugerir alternativas

### 3. Límites Claros

Define claramente:
- Qué está dentro del scope del agent
- Qué debe escalarse a otros especialistas
- Cuándo pedir ayuda del usuario

### 4. Actualización Regular

Mantén agents actualizados con:
- Nuevas tecnologías
- Best practices emergentes
- Cambios en herramientas
- Feedback de uso

### 5. Ejemplos Prácticos

Incluye ejemplos concretos de:
- Código
- Configuraciones
- Comandos
- Soluciones a problemas comunes

## Testing de Agents

### Verificar Comportamiento

1. **Consistencia**: Respuestas consistentes para mismas preguntas
2. **Expertise**: Demuestra conocimiento especializado
3. **Límites**: Reconoce cuando está fuera de scope
4. **Prácticas**: Recomienda best practices apropiadas
5. **Comunicación**: Explica claramente conceptos técnicos

### Casos de Prueba

Para cada agent, probar:
- Tarea simple en su dominio
- Tarea compleja multi-paso
- Tarea fuera de su expertise
- Optimización de código existente
- Debugging de problemas
- Explicación de conceptos

## FAQ

### ¿Puedo combinar múltiples agents?

No simultáneamente en una sesión, pero puedes cambiar entre agents según la tarea.

### ¿Agents reemplazan a skills?

No, son complementarios. Agents dan contexto, skills dan procesos específicos.

### ¿Cómo actualizo agents?

Ejecuta el script de actualización del submodule: `.claude-config/scripts/update.ps1`

### ¿Puedo tener agents privados?

Sí, créalos directamente en `.claude/agents/` de tu proyecto.

### ¿Qué modelo debo usar?

- **Sonnet**: Balance de velocidad y capacidad (recomendado)
- **Opus**: Tareas muy complejas, mejor razonamiento
- **Haiku**: Tareas simples, muy rápido

### ¿Agents pueden usar herramientas?

Sí, agents tienen acceso a todas las herramientas de Claude Code (bash, file operations, etc).

## Contribuir Agents

1. Fork el repositorio
2. Crear nuevo agent en categoría apropiada
3. Seguir formato estándar
4. Incluir ejemplos y best practices
5. Probar exhaustivamente
6. Actualizar este README
7. Submit pull request

### Checklist de Contribución

- [ ] Frontmatter completo
- [ ] Expertise claramente definida
- [ ] Responsabilidades documentadas
- [ ] Best practices incluidas
- [ ] Ejemplos prácticos
- [ ] Límites establecidos
- [ ] Estilo de comunicación definido
- [ ] Probado con casos reales
- [ ] Documentado en README
- [ ] Versionado apropiadamente

## Recursos

- [Documentación de Claude Code](https://github.com/anthropics/claude-code)
- [Guía de Desarrollo de Agents](../docs/agent-development.md)
- [Ejemplos de Agents](./examples/)
- [Template de Agent](./template/)

## Licencia

Todos los agents están bajo licencia MIT. Ver [LICENSE](../LICENSE) para detalles.
