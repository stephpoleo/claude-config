---
name: docs-generator
description: Generate and update project documentation in Spanish or English
user-invocable: true
categories: [utilities, documentation, productivity]
version: 1.0.0
---

# Documentation Generator

Genera y actualiza documentación del proyecto automáticamente en **español** o **inglés**. Se integra con el **Documentation Writer** agent para producir documentación de alta calidad.

## Usage

```
/docs-generator <action> <lang> [target]
```

### Actions

```
/docs-generator generate es           # Genera toda la documentación en español
/docs-generator generate en           # Genera toda la documentación en inglés
/docs-generator update claude es      # Actualiza CLAUDE.md en español
/docs-generator update readme en      # Actualiza README.md en inglés
/docs-generator api es "backend/api"  # Documenta APIs en español
/docs-generator components en "src/app/components"  # Documenta componentes en inglés
/docs-generator schema es             # Documenta schema de BD en español
```

## Parameters

- **action**: `generate`, `update`, `api`, `components`, `schema`
- **lang**: `es` (español) o `en` (inglés)
- **target**: Path opcional al código a documentar

## Actions Detalladas

### 1. generate - Documentación Completa

Genera toda la documentación del proyecto desde cero.

```
/docs-generator generate es
/docs-generator generate en
```

**Genera**:
- `.claude/CLAUDE.md` - Mapa de navegación para Claude Code
- `README.md` - Documentación arquitectónica
- `docs/api.md` - Documentación de APIs (si aplica)
- `docs/architecture.md` - Decisiones arquitectónicas
- `docs/setup.md` - Guía de instalación y setup

**Proceso**:
1. Analiza estructura del proyecto
2. Detecta stack tecnológico
3. Identifica patrones arquitectónicos
4. Invoca Documentation Writer agent
5. Genera todos los archivos

**Ejemplo output**:
```
Generando documentación del proyecto...

✓ Analizando estructura de proyecto
  - Backend: Django REST Framework
  - Frontend: Angular 16
  - Database: PostgreSQL + Supabase

✓ Generando CLAUDE.md (español)
✓ Generando README.md (español)
✓ Generando docs/api.md
✓ Generando docs/architecture.md

Documentación generada en: .claude/ y docs/
```

---

### 2. update - Actualizar Documentación Existente

Actualiza archivos de documentación existentes.

```
/docs-generator update claude es
/docs-generator update readme en
/docs-generator update api es
```

**Targets disponibles**:
- `claude` - Actualiza CLAUDE.md
- `readme` - Actualiza README.md
- `api` - Actualiza docs/api.md
- `architecture` - Actualiza docs/architecture.md
- `all` - Actualiza todos

**Proceso**:
1. Lee documentación existente
2. Analiza cambios en el código
3. Identifica secciones desactualizadas
4. Actualiza solo lo necesario
5. Preserva contenido manual

**Ejemplo**:
```
/docs-generator update claude es

Actualizando CLAUDE.md...

✓ Leyendo CLAUDE.md existente
✓ Detectando cambios en código
  - Nuevos: 3 componentes, 2 APIs
  - Modificados: 1 servicio
  - Eliminados: 1 componente deprecated

✓ Actualizando secciones:
  - Estructura de proyecto
  - Navegación por tarea (Backend)
  - Comandos esenciales

CLAUDE.md actualizado.
```

---

### 3. api - Documentar APIs

Genera documentación de APIs específicas.

```
/docs-generator api es "backend/api/views.py"
/docs-generator api en "backend/api"
```

**Genera**:
- Documentación de endpoints
- Request/response schemas
- Códigos de estado HTTP
- Ejemplos de uso
- Autenticación requerida
- Permisos

**Formato de salida**:

**Español**:
```markdown
## POST /api/orders/

Crea una nueva orden para el usuario autenticado.

**Autenticación**: Bearer Token (requerido)

**Request Body**:
```json
{
  "items": [
    { "product_id": "uuid", "quantity": 2 }
  ],
  "shipping_address": "..."
}
```

**Response 201 Created**:
```json
{
  "id": "uuid",
  "status": "pending",
  "total": 150.00,
  "created_at": "2026-02-05T10:30:00Z"
}
```

**Errores**:
- `400` - Datos inválidos
- `401` - No autenticado
- `404` - Producto no encontrado
```

**Inglés**:
```markdown
## POST /api/orders/

Creates a new order for the authenticated user.

**Authentication**: Bearer Token (required)

**Request Body**:
...
```

**Ubicación**: `docs/api.md` o `docs/api-reference.md`

---

### 4. components - Documentar Componentes

Genera documentación de componentes frontend.

```
/docs-generator components es "src/app/components/order-list"
/docs-generator components en "src/app/components"
```

**Genera**:
- Propósito del componente
- Inputs y Outputs
- Servicios utilizados
- Estado interno (Signals)
- Eventos emitidos
- Ejemplos de uso

**Formato de salida**:

**Español**:
```markdown
## OrderListComponent

Lista de órdenes del usuario con paginación y filtrado.

**Selector**: `app-order-list`

**Inputs**:
- `userId: string` - ID del usuario (opcional, usa usuario actual por defecto)
- `status: OrderStatus` - Filtro de estado (opcional)

**Outputs**:
- `orderSelected: EventEmitter<Order>` - Emite cuando se selecciona una orden

**Estado**:
- `orders: Signal<Order[]>` - Lista de órdenes
- `isLoading: Signal<boolean>` - Estado de carga
- `hasMore: Signal<boolean>` - Indica si hay más órdenes

**Dependencias**:
- `OrderService` - Para obtener órdenes
- `AuthService` - Para obtener usuario actual

**Uso**:
```html
<app-order-list
  [status]="'pending'"
  (orderSelected)="onOrderSelected($event)">
</app-order-list>
```
```

**Ubicación**: `docs/components.md` o inline en código

---

### 5. schema - Documentar Schema de BD

Genera documentación del schema de base de datos.

```
/docs-generator schema es
/docs-generator schema en
```

**Genera**:
- Diagrama ER en texto/Mermaid
- Descripción de tablas
- Relaciones entre tablas
- Índices importantes
- Constraints
- Triggers y funciones

**Formato de salida**:

**Español**:
```markdown
# Schema de Base de Datos

## Diagrama ER

```
[users]                [orders]
-------                --------
PK: id (UUID)      1:N PK: id (UUID)
    email              FK: user_id → users.id
    name                   total
    created_at             status
                           created_at
```

## Tablas

### users
Usuarios de la aplicación con autenticación via Supabase Auth.

**Columnas**:
- `id` (UUID, PK) - Identificador único
- `email` (TEXT, UNIQUE) - Email del usuario
- `name` (TEXT) - Nombre completo
- `created_at` (TIMESTAMPTZ) - Fecha de creación

**Relaciones**:
- 1:N con `orders` (un usuario tiene muchas órdenes)
- 1:1 con `profiles` (perfil extendido opcional)

**Índices**:
- `idx_users_email` en `email` (búsqueda por email)

**RLS Policies**:
- Users can view own data: `auth.uid() = id`
```

**Ubicación**: `docs/database.md`

---

## Idiomas Soportados

### Español (es)

**Características**:
- Términos técnicos en inglés cuando es estándar
- Explicaciones en español neutro
- Nombres de variables/funciones en inglés (convención)

**Ejemplo**:
```markdown
## Arquitectura

El proyecto usa **Clean Architecture** con separación en capas:

- **Controllers**: Manejo de HTTP requests
- **Services**: Lógica de negocio
- **Repositories**: Acceso a datos
```

### Inglés (en)

**Características**:
- Documentación completamente en inglés
- Terminología técnica estándar
- Formato profesional

**Ejemplo**:
```markdown
## Architecture

The project uses **Clean Architecture** with layered separation:

- **Controllers**: HTTP request handling
- **Services**: Business logic
- **Repositories**: Data access
```

---

## Integración con Documentation Writer Agent

Este skill trabaja en conjunto con el **Documentation Writer** agent:

**Workflow**:
```
1. Skill analiza el código
   ↓
2. Skill invoca Documentation Writer agent
   ↓
3. Agent aplica expertise y estándares
   ↓
4. Skill recibe documentación generada
   ↓
5. Skill escribe archivos
```

**Para invocar el agent desde el skill**:
```markdown
@docs-writer-es - Genera documentación en español
(El agent tiene acceso a Context7 para sintaxis específica)
```

---

## Análisis Automático del Proyecto

El skill detecta automáticamente:

### Stack Tecnológico
```python
# Detecta por archivos presentes
- requirements.txt → Python
- manage.py → Django
- package.json + angular.json → Angular
- docker-compose.yml → Docker
- .github/workflows/ → GitHub Actions
```

### Estructura
```python
# Identifica patrones
backend/
  api/ → APIs REST
  services/ → Service Layer
  models.py → Django Models

frontend/
  src/app/
    components/ → Angular Components
    services/ → Angular Services
```

### Decisiones Arquitectónicas
```python
# Detecta patrones de código
- Service/Selector pattern → Clean Architecture
- ViewSets → Django REST Framework
- Signals → Angular 16+
- RLS policies → Supabase
```

---

## Templates por Stack

### Django + Angular (Full Stack)

**CLAUDE.md**:
```markdown
# [Nombre del Proyecto]

**Stack**: Django REST Framework + Angular 16 + PostgreSQL
**Deploy**: Render (backend) + Vercel (frontend)

## Estructura

```
proyecto/
├── backend/         # Django REST API
│   ├── api/        # ViewSets y serializers
│   ├── services/   # Lógica de negocio
│   └── models.py   # Modelos Django
├── frontend/        # Angular app
│   └── src/app/
│       ├── components/
│       └── services/
└── docs/           # Documentación
```

## Navegación por Tarea

### Backend API
- Models: `backend/models.py`
- ViewSets: `backend/api/views.py`
- Services: `backend/services/`
- Tests: `backend/tests/`

### Frontend
- Components: `frontend/src/app/components/`
- Services: `frontend/src/app/services/`
- State: Signals en components

## Comandos

```bash
# Development
cd backend && python manage.py runserver
cd frontend && ng serve

# Testing
cd backend && pytest
cd frontend && ng test

# Database
python manage.py makemigrations
python manage.py migrate
```

## Decisiones Clave

- **Architecture**: Clean Architecture con Service Layer
- **API**: Django REST Framework con ViewSets
- **State**: Angular Signals (no NgRx)
- **Auth**: JWT tokens via Django REST Auth
```

### Data Science

**CLAUDE.md**:
```markdown
# [Nombre del Proyecto]

**Stack**: Python + pandas + scikit-learn + Jupyter
**Deploy**: N/A (local analysis)

## Estructura

```
proyecto/
├── data/
│   ├── raw/        # Datos originales
│   ├── processed/  # Datos procesados
│   └── final/      # Datos finales
├── notebooks/      # Jupyter notebooks
├── src/
│   ├── features/   # Feature engineering
│   ├── models/     # Modelos ML
│   └── pipelines/  # Pipelines ETL
└── reports/        # Reportes y visualizaciones
```

## Navegación por Tarea

### Data Processing
- ETL: `src/pipelines/`
- Features: `src/features/`
- Validation: `src/data/validation.py`

### Modeling
- Models: `src/models/`
- Training: `notebooks/training/`
- Evaluation: `notebooks/evaluation/`

### Analysis
- EDA: `notebooks/exploratory/`
- Reports: `reports/`

## Comandos

```bash
# Setup
python -m venv venv
pip install -r requirements.txt

# Run pipeline
python -m src.pipelines.main

# Jupyter
jupyter notebook
```

## Decisiones Clave

- **Data**: pandas para manipulación
- **ML**: scikit-learn (supervisado y no supervisado)
- **Validation**: train_test_split con stratification
- **Features**: StandardScaler + feature selection
```

### DevOps

**CLAUDE.md**:
```markdown
# [Nombre del Proyecto]

**Stack**: Docker + GitHub Actions + AWS
**Deploy**: ECS (containers) + RDS (database)

## Estructura

```
proyecto/
├── .github/
│   └── workflows/      # CI/CD pipelines
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── infrastructure/
│   └── terraform/      # IaC
└── scripts/            # Deployment scripts
```

## Navegación por Tarea

### Docker
- Dockerfile: `docker/Dockerfile`
- Compose: `docker/docker-compose.yml`

### CI/CD
- Build: `.github/workflows/build.yml`
- Deploy: `.github/workflows/deploy.yml`
- Tests: `.github/workflows/test.yml`

### Infrastructure
- Terraform: `infrastructure/terraform/`
- Scripts: `scripts/`

## Comandos

```bash
# Local
docker-compose up -d
docker-compose logs -f

# Deploy
./scripts/deploy.sh production

# Infrastructure
cd infrastructure/terraform
terraform plan
terraform apply
```

## Decisiones Clave

- **Containers**: Multi-stage Docker builds
- **CI/CD**: GitHub Actions con matrix testing
- **IaC**: Terraform para AWS resources
- **Secrets**: AWS Secrets Manager
```

---

## Output Files

El skill genera/actualiza estos archivos:

```
proyecto/
├── .claude/
│   └── CLAUDE.md           # Mapa de navegación (SIEMPRE)
├── README.md                # Documentación principal (SIEMPRE)
└── docs/
    ├── api.md              # Documentación de API (si aplica)
    ├── components.md       # Documentación de componentes (si aplica)
    ├── database.md         # Schema de BD (si aplica)
    ├── architecture.md     # Decisiones arquitectónicas
    ├── setup.md            # Guía de instalación
    └── deployment.md       # Guía de deployment
```

---

## Opciones Avanzadas

### Generar solo CLAUDE.md

```
/docs-generator update claude es
```

### Generar documentación API específica

```
/docs-generator api es "backend/api/orders.py"
```

**Output**: `docs/api/orders.md`

### Documentar componente específico

```
/docs-generator components en "src/app/components/user-card"
```

**Output**: Docstring inline + entrada en `docs/components.md`

### Actualizar solo arquitectura

```
/docs-generator update architecture es
```

**Output**: `docs/architecture.md` actualizado

---

## Best Practices

### Cuándo Usar

✅ **Usar cuando**:
- Inicias un nuevo proyecto
- Estructura del proyecto cambió significativamente
- Agregaste muchos componentes/APIs nuevos
- Necesitas documentación para nuevo team member
- Quieres generar docs para Claude Code

❌ **No usar cuando**:
- Cambios menores en código
- Solo actualizaste docstrings inline
- Documentación manual específica está OK

### Mantener Actualizado

```bash
# Después de cambios mayores
/docs-generator update all es

# Después de agregar APIs
/docs-generator api es "backend/api"

# Después de agregar componentes
/docs-generator components es "frontend/src/app/components"
```

### Idioma por Proyecto

**Regla general**:
- **Español**: Proyectos locales, equipos hispanohablantes
- **Inglés**: Proyectos open source, equipos internacionales

**Cambiar idioma**:
```bash
# De español a inglés
/docs-generator generate en

# Regenera toda la documentación en inglés
```

---

## Integración con Otros Skills

### Con pr-helper

```bash
# 1. Actualiza documentación
/docs-generator update all es

# 2. Genera PR con docs actualizados
/pr-helper both
```

### Con database-schema

```bash
# 1. Genera schema
/database-schema design "blog system"

# 2. Documenta schema
/docs-generator schema es
```

### Con clean-code-review

```bash
# 1. Review de código
/clean-code-review "backend/services/"

# 2. Actualiza arquitectura con fixes
/docs-generator update architecture es
```

---

## Troubleshooting

### "No se detectó stack tecnológico"

**Problema**: El skill no puede determinar las tecnologías usadas

**Solución**:
1. Asegúrate de tener archivos identificadores:
   - `requirements.txt` (Python)
   - `package.json` (Node/Angular)
   - `Gemfile` (Ruby)
2. Especifica manualmente en CLAUDE.md existente

### "Documentación muy genérica"

**Problema**: La documentación generada es poco específica

**Solución**:
1. Agrega más código primero
2. Usa actions específicos (`api`, `components`) en lugar de `generate`
3. Edita manualmente para agregar contexto único del proyecto

### "Idioma mezclado"

**Problema**: Algunas secciones en español, otras en inglés

**Solución**:
```bash
# Regenera completamente en un idioma
/docs-generator generate es  # Todo en español
```

---

## Referencias

### Internos
- `agents/documentation/docs-writer-es.md` - Documentation Writer agent
- `docs/documentation-guide.md` - Guía de documentación
- `memory/coding-standards/` - Estándares de código

### Externos
- [CommonMark](https://commonmark.org/) - Sintaxis Markdown
- [JSDoc](https://jsdoc.app/) - Comentarios JavaScript/TypeScript
- [Sphinx](https://www.sphinx-doc.org/) - Documentación Python

---

## Ejemplo Completo de Uso

### Proyecto Nuevo

```bash
# 1. Inicializar proyecto
git init
django-admin startproject backend
ng new frontend

# 2. Generar documentación inicial
/docs-generator generate es

# Output:
# ✓ CLAUDE.md creado
# ✓ README.md creado
# ✓ docs/setup.md creado
# ✓ docs/architecture.md creado
```

### Proyecto Existente

```bash
# 1. Analizar código existente
/docs-generator generate es

# 2. Revisar documentación generada
# 3. Ajustar manualmente si es necesario

# 4. Mantener actualizado
/docs-generator update all es
```

### Documentar Feature Nuevo

```bash
# 1. Desarrollas nuevo feature (ej: orders API)
# ...código...

# 2. Documentar API
/docs-generator api es "backend/api/orders.py"

# 3. Actualizar CLAUDE.md
/docs-generator update claude es

# 4. Commit con docs
/pr-helper both
```

---

## Notas Finales

- El skill es inteligente: detecta cambios y actualiza solo lo necesario
- Se integra con Documentation Writer agent para calidad profesional
- Soporta español e inglés nativamente
- Respeta contenido manual (no sobrescribe sin avisar)
- Genera documentación optimizada para Claude Code (CLAUDE.md)
- Genera documentación arquitectónica para humanos (README.md)

**Próximas mejoras planeadas**:
- Soporte para más idiomas (PT, FR)
- Generación de diagramas automáticos (Mermaid)
- Integración con OpenAPI/Swagger
- Detección de código sin documentar
