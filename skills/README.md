# Skills Catalog

Catálogo completo de skills disponibles en claude-config. Los skills son comandos especializados que extienden las capacidades de Claude Code.

## Cómo Usar Skills

1. **Instalación**: Los skills se vinculan a tu proyecto usando symlinks durante la instalación
2. **Invocación**: Usa `/skill-name` en Claude Code para invocar un skill
3. **Personalización**: Copia y modifica skills para necesidades específicas del proyecto

## Skills Disponibles (13)

### Web Development

#### angular-component
**Categorías**: web-dev, frontend, angular, typescript
**Archivo**: `skills/web-dev/angular-component/SKILL.md`

```
/angular-component UserProfile "user info, avatar, edit button"
```

**Características**:
- Standalone components (Angular 14+)
- Signals para state management (Angular 16+)
- OnPush change detection
- TypeScript strict mode
- RxJS reactive patterns
- SCSS styling

---

#### api-design
**Categorías**: web-dev, backend, api
**Archivo**: `skills/web-dev/api-design/SKILL.md`

```
/api-design users "CRUD operations for user management"
```

**Características**:
- Principios RESTful
- Métodos HTTP correctos
- Códigos de estado apropiados
- Paginación y filtrado
- Versionado de APIs
- Documentación OpenAPI

---

### Backend

#### django-api
**Categorías**: backend, django, api, python
**Archivo**: `skills/backend/django-api/SKILL.md`

```
/django-api orders "CRUD operations with business logic"
```

**Características**:
- Django REST Framework ViewSets
- Clean Architecture (Service/Selector pattern)
- SOLID principles
- Serializers con validaciones
- Permissions y authentication
- Optimización de QuerySets

---

### Data Engineering & Science

#### data-pipeline
**Categorías**: data, etl, data-engineering
**Archivo**: `skills/data/data-pipeline/SKILL.md`

```
/data-pipeline sales-aggregation "daily sales ETL from PostgreSQL to BigQuery"
```

**Características**:
- Patrón ETL/ELT
- BaseExtractor, BaseTransformer, BaseLoader
- Data validation
- Error handling y retry logic
- Logging y monitoring
- Scheduling con Airflow

---

#### sql-optimization
**Categorías**: data, sql, performance
**Archivo**: `skills/data/sql-optimization/SKILL.md`

```
/sql-optimization "SELECT query for user orders with items"
```

**Características**:
- Query analysis con EXPLAIN
- Index optimization
- Join optimization
- Query rewriting
- N+1 problem solving
- Partitioning strategies

---

#### data-visualization
**Categorías**: data, visualization, python
**Archivo**: `skills/data/data-visualization/SKILL.md`

```
/data-visualization sales-trends "monthly revenue with forecast"
```

**Características**:
- matplotlib, seaborn, plotly
- Time series, distributions, correlations
- Professional styling
- Interactive dashboards
- Export para presentaciones

---

### Machine Learning

#### model-design
**Categorías**: ml, machine-learning, data-science
**Archivo**: `skills/ml/model-design/SKILL.md`

```
/model-design churn-prediction "supervised classification model"
```

**Características**:
- Supervised learning (classification, regression)
- Unsupervised learning (clustering, dimensionality reduction)
- Feature engineering
- Cross-validation
- Hyperparameter tuning
- Model evaluation metrics

---

### DevOps & Cloud

#### docker-setup
**Categorías**: devops, docker, containerization
**Archivo**: `skills/devops/docker-setup/SKILL.md`

```
/docker-setup django-app "python, postgres, redis"
```

**Características**:
- Multi-stage Dockerfiles
- Docker Compose configurations
- Security best practices
- Health checks
- Resource limits
- Environment-specific configs

---

#### github-actions
**Categorías**: devops, ci-cd, github
**Archivo**: `skills/devops/github-actions/SKILL.md`

```
/github-actions django-app "test, lint, build, deploy"
```

**Características**:
- CI/CD pipelines completos
- Matrix testing (multiple versions)
- Caching para performance
- Secrets management
- Multi-environment deployments
- Rollback strategies

---

#### aws-setup
**Categorías**: cloud, aws, infrastructure
**Archivo**: `skills/cloud/aws-setup/SKILL.md`

```
/aws-setup "S3 bucket for data lake with lifecycle policies"
```

**Características**:
- S3, EC2, RDS, Lambda
- boto3 Python SDK
- Infrastructure as Code (Terraform)
- Security best practices
- Cost optimization
- Monitoring con CloudWatch

---

#### gcp-setup
**Categorías**: cloud, gcp, infrastructure
**Archivo**: `skills/cloud/gcp-setup/SKILL.md`

```
/gcp-setup "BigQuery dataset for analytics"
```

**Características**:
- Cloud Storage, Compute Engine, BigQuery
- Python client libraries
- Infrastructure as Code (Terraform)
- Security best practices
- Cost optimization
- Monitoring con Cloud Monitoring

---

### Quality & Testing

#### test-suite
**Categorías**: testing, quality-assurance
**Archivo**: `skills/testing/test-suite/SKILL.md`

```
/test-suite UserService unit
```

**Características**:
- Unit, integration, y E2E tests
- Test structure (AAA pattern)
- Mocking y stubbing
- Test fixtures y factories
- Coverage goals
- Performance testing

---

#### clean-code-review
**Categorías**: quality, code-review, solid
**Archivo**: `skills/quality/clean-code-review/SKILL.md`

```
/clean-code-review "backend/services/order_service.py"
```

**Características**:
- Clean Code principles
- SOLID principles
- Code smells detection
- Refactoring suggestions
- Design patterns
- Best practices del stack
- **Genera reportes markdown** automáticos con issues categorizados
- Sistema de tracking con status (pendiente, en progreso, resuelto)
- Métricas de calidad y plan de acción

**Reportes**:
Genera reportes detallados en `docs/code-reviews/` con:
- Issues categorizados por severidad (🔴 Críticos, 🟡 Importantes, 🟢 Menores)
- Métricas de calidad (complejidad, cobertura, violaciones)
- Plan de acción con estimaciones
- Template incluido en `skills/quality/clean-code-review/report-template.md`

---

## Por Categoría

### Web Development (2)
- `angular-component` - Componentes Angular con TypeScript, Signals
- `api-design` - Diseño de APIs RESTful

### Backend (1)
- `django-api` - APIs Django REST Framework con Clean Architecture

### Data Engineering & Science (3)
- `data-pipeline` - Pipelines ETL/ELT para procesamiento de datos
- `sql-optimization` - Optimización de queries SQL
- `data-visualization` - Visualizaciones con matplotlib, seaborn, plotly

### Machine Learning (1)
- `model-design` - Modelos ML supervisados y no supervisados

### DevOps & Cloud (3)
- `docker-setup` - Configuración Docker y Docker Compose
- `github-actions` - Pipelines CI/CD completos
- `aws-setup` - Configuración de servicios AWS
- `gcp-setup` - Configuración de servicios GCP

### Quality & Testing (2)
- `test-suite` - Test suites completos
- `clean-code-review` - Review con Clean Code y SOLID

### Total: 13 skills

## Stack Tecnológico

Los skills están optimizados para:

**Backend**: Python, Django, Django REST Framework, PostgreSQL
**Frontend**: Angular 14+, TypeScript, RxJS, SCSS
**Data**: pandas, scikit-learn, numpy, SQL, BigQuery
**ML**: scikit-learn (supervised & unsupervised)
**DevOps**: Docker, GitHub Actions
**Cloud**: AWS (S3, EC2, RDS, Lambda), GCP (Cloud Storage, Compute, BigQuery)

## Crear Tus Propios Skills

### 1. Estructura Básica

```markdown
---
name: skill-name
description: Short description
user-invocable: true
categories: [category1, category2]
version: 1.0.0
---

# Skill Title

Description of what this skill does.

## Usage

\`\`\`
/skill-name [param1] [param2]
\`\`\`

## Examples

...
```

### 2. Ubicación

Coloca tu skill en la categoría apropiada:
- `skills/web-dev/` - Frontend y APIs
- `skills/backend/` - Backend específico
- `skills/data/` - Data engineering
- `skills/ml/` - Machine learning
- `skills/devops/` - DevOps y CI/CD
- `skills/cloud/` - Cloud infrastructure
- `skills/quality/` - Quality assurance
- `skills/testing/` - Testing

### 3. Best Practices

- **Nombre claro**: Usa kebab-case descriptivo
- **Descripción concisa**: Explica qué hace en 1-2 líneas
- **Ejemplos prácticos**: Incluye ejemplos de uso reales
- **Categorías apropiadas**: Facilita el descubrimiento
- **Versión semántica**: Usa versionado semántico

### 4. Testing

Prueba tu skill con:
- Casos simples
- Casos complejos
- Edge cases
- Diferentes proyectos

## Actualización de Skills

```bash
# Actualizar desde el repositorio principal
cd .claude-config
git pull origin main

# O usar el script
.\.claude-config\scripts\update.ps1
```

## FAQ

### ¿Cómo invoco un skill?

Usa `/skill-name` en Claude Code. Ejemplo: `/angular-component UserCard`

### ¿Puedo modificar un skill?

Sí, copia el skill a `.claude/skills/` en tu proyecto y modifícalo.

### ¿Cómo desactivo un skill?

Edita `.claude/settings.local.json` y remuévelo de `enabledSkills`.

### ¿Los skills funcionan con cualquier modelo?

Sí, pero algunos skills complejos se benefician de Sonnet u Opus.

### ¿Puedo contribuir skills?

Sí, sigue la guía en `docs/skill-development.md` y envía un PR.

## Recursos

- [Skill Development Guide](../docs/skill-development.md)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Architecture Details](../ARCHITECTURE.md)

## Licencia

MIT - Ver [LICENSE](../LICENSE) para detalles.
