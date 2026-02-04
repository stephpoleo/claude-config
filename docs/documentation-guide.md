# Guía de Documentación: CLAUDE.md vs README.md

Esta guía explica cómo balancear la documentación entre CLAUDE.md y README.md para maximizar la eficiencia de Claude Code.

## Filosofía

### CLAUDE.md = Mapa de Navegación
**Para Claude Code**: Optimizado para consumo de LLM

### README.md = Documentación Humana
**Para Desarrolladores**: Optimizado para lectura humana

### Otros .md = Documentación Específica
**Para Profundidad**: Documentación detallada de módulos/features

## CLAUDE.md

### Propósito

Guiar a Claude Code a través del proyecto de la manera más eficiente posible.

### Contenido

#### 1. Resumen Ultra-Conciso
```markdown
# Proyecto: [Nombre]

**Stack**: Django + Angular + PostgreSQL
**Deploy**: AWS (EC2 + S3 + RDS)
```

#### 2. Estructura del Proyecto
```markdown
## Estructura

```
proyecto/
├── backend/        # Django REST API
├── frontend/       # Angular 16
├── scripts/        # ETL pipelines
└── ml/            # ML models
```
```

#### 3. Rutas por Tarea
```markdown
## Navegación por Tarea

### Backend Development
- Models: `backend/apps/*/models.py`
- APIs: `backend/apps/*/views.py`
- Tests: `backend/apps/*/tests/`

### Frontend Development
- Components: `frontend/src/app/components/`
- Services: `frontend/src/app/services/`
- Routing: `frontend/src/app/app-routing.module.ts`

### Data Science
- Notebooks: `ml/notebooks/`
- Models: `ml/models/`
- Pipelines: `scripts/pipelines/`
```

#### 4. Comandos Comunes
```markdown
## Comandos Esenciales

```bash
# Development
npm start          # Frontend
python manage.py runserver  # Backend

# Testing
npm test
pytest

# Build
docker-compose up
```
```

#### 5. Decisiones Arquitectónicas Clave
```markdown
## Decisiones Clave

- **State Management**: NgRx para estado global
- **API Authentication**: JWT con refresh tokens
- **Data Pipeline**: Airflow scheduled daily
- **Deployment**: Blue-green strategy on AWS
```

### Ejemplo Completo CLAUDE.md

```markdown
# Sistema de Analytics - E-commerce

**Stack**: Django 4.2 + Angular 16 + PostgreSQL 15
**Deploy**: AWS (ECS + S3 + RDS)
**CI/CD**: GitHub Actions

## Estructura

```
project/
├── backend/        # Django REST API
│   ├── api/       # API endpoints
│   ├── core/      # Business logic
│   └── ml/        # ML integration
├── frontend/       # Angular SPA
├── data/          # Data pipelines
└── infrastructure/ # Terraform
```

## Navegación por Tarea

### API Development
- **Endpoints**: `backend/api/views.py`
- **Serializers**: `backend/api/serializers.py`
- **Models**: `backend/core/models.py`
- **Tests**: `backend/api/tests/`

### Frontend
- **Components**: `frontend/src/app/components/`
- **Services**: `frontend/src/app/services/`
- **State**: `frontend/src/app/store/`

### Data Science
- **Notebooks**: `data/notebooks/`
- **Pipelines**: `data/pipelines/`
- **Models**: `ml/models/`

## Stack Details

### Backend (Django)
- Django REST Framework para APIs
- Celery para async tasks
- PostgreSQL con TimescaleDB
- Redis para caching

### Frontend (Angular)
- Angular 16 con standalone components
- NgRx para state management
- RxJS para reactive programming
- TailwindCSS para styling

### Infrastructure
- AWS ECS para containers
- RDS PostgreSQL
- S3 para assets
- CloudFront CDN

## Comandos

```bash
# Development
docker-compose up          # Start all services
python manage.py migrate   # Run migrations
npm start                  # Frontend dev server

# Testing
pytest                     # Backend tests
npm test                   # Frontend tests

# Deployment
./deploy.sh staging        # Deploy to staging
./deploy.sh production     # Deploy to production
```

## Decisiones Arquitectónicas

- **Service Layer**: Business logic separado de views
- **API Versioning**: URL-based (/api/v1/)
- **Caching Strategy**: Redis para queries frecuentes
- **CI/CD**: GitHub Actions con tests automáticos
- **Monitoring**: CloudWatch + Sentry

## Documentación Adicional

- [API Documentation](docs/api.md)
- [Deployment Guide](docs/deployment.md)
- [Data Pipeline](docs/data-pipeline.md)
```

## README.md

### Propósito

Documentación completa para desarrolladores humanos.

### Contenido

#### 1. Descripción del Proyecto
```markdown
# Sistema de Analytics E-commerce

Plataforma de analytics en tiempo real para e-commerce con visualizaciones interactivas y predicciones ML.

## Características

- Dashboard en tiempo real
- Predicción de ventas con ML
- Segmentación de clientes
- Reportes automatizados
- API RESTful
```

#### 2. Setup Completo
```markdown
## Instalación

### Requisitos
- Python 3.11+
- Node.js 18+
- PostgreSQL 15+
- Redis 7+

### Backend Setup
\`\`\`bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup database
createdb analytics_db
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run server
python manage.py runserver
\`\`\`

### Frontend Setup
\`\`\`bash
cd frontend
npm install
npm start
\`\`\`
```

#### 3. Arquitectura Detallada
```markdown
## Arquitectura

### Backend
Django REST Framework proporciona las APIs. Usamos:
- **ViewSets** para CRUD operations
- **Service Layer** para business logic
- **Celery** para tasks asíncronos
- **Redis** para caching

[Incluir diagrama si es útil]

### Frontend
Angular SPA con:
- **Standalone Components** (Angular 16+)
- **NgRx** para state management
- **RxJS** para reactive programming

### Base de Datos
PostgreSQL con:
- **TimescaleDB** para time-series data
- **Indexes** en campos frecuentes
- **Partitioning** para tablas grandes
```

#### 4. Desarrollo
```markdown
## Guía de Desarrollo

### Estructura de Código

```
backend/
├── api/           # API endpoints
├── core/          # Business logic
├── services/      # Service layer
└── tests/         # Tests
```

### Agregar Nuevo Endpoint

1. Crear modelo en `core/models.py`
2. Crear serializer en `api/serializers.py`
3. Crear viewset en `api/views.py`
4. Agregar ruta en `api/urls.py`
5. Escribir tests en `tests/`

### Estándares de Código

- Seguir PEP 8 para Python
- Usar Black para formateo
- Pylint para linting
- Coverage > 80%
```

#### 5. Deployment
```markdown
## Deployment

### Staging
\`\`\`bash
./deploy.sh staging
\`\`\`

### Production
\`\`\`bash
./deploy.sh production
\`\`\`

### Rollback
\`\`\`bash
./rollback.sh <version>
\`\`\`

### Monitoring
- CloudWatch: https://console.aws.amazon.com/...
- Sentry: https://sentry.io/...
```

## Otros Archivos .md

### docs/api.md - Documentación de API

```markdown
# API Documentation

## Authentication

All endpoints require JWT token:
\`\`\`
Authorization: Bearer <token>
\`\`\`

## Endpoints

### GET /api/v1/analytics/sales
Returns sales data with aggregations.

**Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD
- `granularity` (optional): day|week|month

**Response:**
\`\`\`json
{
  "data": [...],
  "total": 12345,
  "period": "2024-01-01 to 2024-01-31"
}
\`\`\`
```

### docs/deployment.md - Guía de Deployment

```markdown
# Deployment Guide

## Infrastructure

- AWS ECS for containers
- RDS for database
- S3 for static files
- CloudFront for CDN

## Process

1. Tests run automatically on push
2. Build Docker image
3. Push to ECR
4. Update ECS service
5. Health checks
6. Rollback if fails

## Monitoring

### Key Metrics
- Response time < 200ms
- Error rate < 0.1%
- CPU usage < 70%
- Memory usage < 80%
```

### docs/data-pipeline.md - Data Pipeline

```markdown
# Data Pipeline Documentation

## ETL Process

### Extract
- Source: PostgreSQL production DB
- Frequency: Daily at 2 AM
- Tool: Python scripts

### Transform
- Aggregations
- Data cleaning
- Feature engineering

### Load
- Destination: Data Warehouse (BigQuery)
- Format: Parquet
```

## Guía Rápida de Decisión

### ¿Dónde Documentar?

| Contenido | CLAUDE.md | README.md | Otro .md |
|-----------|-----------|-----------|----------|
| Estructura del proyecto | ✓ | ✓ | |
| Rutas a archivos clave | ✓ | | |
| Comandos comunes | ✓ | ✓ | |
| Setup completo | | ✓ | |
| Arquitectura | Resumen | Detalle | Diagramas |
| Decisiones arquitectónicas | ✓ | ✓ | |
| API documentation | | | ✓ (api.md) |
| Deployment steps | | Resumen | ✓ (deployment.md) |
| Troubleshooting | | | ✓ (troubleshooting.md) |

## Principios de Escritura

### Para CLAUDE.md
1. **Conciso**: Cada palabra cuenta
2. **Directo**: Sin introducciones innecesarias
3. **Navegable**: Paths absolutos a archivos
4. **Actualizado**: Refleja estado actual del proyecto

### Para README.md
1. **Completo**: Toda la información para nuevos devs
2. **Explicativo**: El "por qué" de las decisiones
3. **Tutorial**: Paso a paso para setup
4. **Mantenible**: Fácil de actualizar

### Para Otros .md
1. **Específico**: Un tema por archivo
2. **Profundo**: Detalles técnicos completos
3. **Ejemplos**: Código y comandos reales
4. **Referenciado**: Enlaces desde CLAUDE.md y README.md

## Ejemplo de Flujo

1. **Nuevo Feature**: Agregar sistema de notificaciones

2. **Actualizar CLAUDE.md**:
```markdown
### Notifications
- Service: `backend/core/services/notification_service.py`
- Models: `backend/core/models/notification.py`
- Frontend: `frontend/src/app/components/notifications/`
```

3. **Actualizar README.md** (si afecta setup):
```markdown
## Environment Variables
- `SMTP_HOST`: Email server for notifications
- `SMTP_PORT`: Email server port
```

4. **Crear docs/notifications.md** si es complejo:
```markdown
# Notification System

## Architecture
[Explicación detallada]

## Email Templates
[Detalles de templates]

## Testing
[Cómo testear notificaciones]
```

## Conclusión

**CLAUDE.md**: Mínimo viable para que Claude navegue eficientemente
**README.md**: Completo para que humanos entiendan y contribuyan
**Otros .md**: Profundidad donde se necesite sin saturar CLAUDE.md
