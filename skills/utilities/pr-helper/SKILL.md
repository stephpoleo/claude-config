---
name: pr-helper
description: Generate commits and PR descriptions from code changes
user-invocable: true
categories: [utilities, git, workflow, pull-request]
version: 1.0.0
---

# PR Helper

Analiza cambios en el código y genera commits estructurados y descripciones de Pull Request completas.

## Usage

```
/pr-helper <action> [options]
```

**Actions disponibles**:
- `commit` - Genera mensaje de commit estructurado
- `pr` - Genera descripción completa de Pull Request
- `both` - Genera ambos (commit + PR)

### Examples

```
/pr-helper commit
/pr-helper pr
/pr-helper both
/pr-helper commit --scope=backend
```

## Proceso

### 1. Análisis de Cambios

El skill analiza automáticamente:

```bash
# Ver cambios staged
git diff --cached --stat
git diff --cached

# Ver commits desde branch base
git log origin/main..HEAD --oneline
git diff origin/main...HEAD --stat

# Detectar tipo de proyecto
# - Buscar package.json, requirements.txt, etc.
# - Identificar framework (Django, Angular, etc.)
```

### 2. Generación de Commit

**Formato**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat` / `add` - Nueva funcionalidad
- `fix` - Corrección de bug
- `refactor` - Reestructuración sin cambio funcional
- `perf` - Mejora de performance
- `docs` - Documentación
- `test` - Tests
- `chore` - Mantenimiento
- `style` - Formato, no cambia lógica
- `build` - Build system o dependencias
- `ci` - Cambios en CI/CD

**Scopes comunes**:
- `backend`, `frontend`, `api`, `ui`
- `data`, `ml`, `pipeline`
- `docker`, `ci`, `deploy`
- `tests`, `docs`

**Ejemplo generado**:
```
feat(backend): add order validation service

Implementa servicio de validación de órdenes con Clean Architecture:
- OrderValidator con reglas de negocio
- Validaciones de stock, precios, y datos de usuario
- Tests unitarios con 95% coverage
- Integración con OrderService existente

Resuelve casos donde órdenes inválidas llegaban a procesamiento.

Archivos modificados:
- backend/services/order_validator.py (nuevo)
- backend/services/order_service.py (refactor)
- tests/services/test_order_validator.py (nuevo)

```

### 3. Generación de PR

**Template personalizado** según tipo de proyecto:

#### Template Web Dev (Angular/Django)

```markdown
## Descripción

[Descripción clara de qué hace este PR]

## Tipo de Cambio

- [ ] 🐛 Bug fix (cambio que corrige un issue)
- [ ] ✨ Nueva feature (cambio que agrega funcionalidad)
- [ ] 💥 Breaking change (fix o feature que causa cambio en funcionalidad existente)
- [ ] 📝 Documentación
- [ ] ♻️ Refactor (sin cambios funcionales)
- [ ] ⚡ Performance
- [ ] ✅ Tests

## Cambios Realizados

### Backend (Django)
- [x] Implementado `OrderValidator` service
- [x] Refactorizado `OrderService` para usar validación
- [x] Agregadas validaciones de stock y precios

### Frontend (Angular)
- [ ] [Si aplica]

### Database
- [ ] Migraciones agregadas
- [ ] Seeds/fixtures actualizados

## Archivos Modificados

<details>
<summary>Ver archivos (X archivos cambiados, +Y/-Z líneas)</summary>

### Nuevos archivos
- `backend/services/order_validator.py` (+150 líneas)
- `tests/services/test_order_validator.py` (+200 líneas)

### Archivos modificados
- `backend/services/order_service.py` (+50/-30 líneas)
- `backend/models/order.py` (+10 líneas)

### Archivos eliminados
- Ninguno

</details>

## Test Plan

### Tests Unitarios
- [x] `test_order_validator.py` - 15 tests, 95% coverage
- [x] `test_order_service.py` - Actualizados 8 tests

### Tests de Integración
- [x] Validación end-to-end con API
- [ ] Tests de UI (si aplica)

### Manual Testing
1. Crear orden con datos válidos → ✅ Pasa validación
2. Crear orden sin stock → ✅ Rechaza con mensaje claro
3. Crear orden con precio inválido → ✅ Rechaza apropiadamente

## Screenshots / Videos

[Si aplica - cambios de UI]

## Checklist

### Código
- [x] Código sigue guías de estilo del proyecto
- [x] Realicé self-review del código
- [x] Comenté código en áreas complejas
- [x] Actualicé documentación relevante

### Testing
- [x] Tests agregados/actualizados
- [x] Todos los tests pasan localmente
- [x] Coverage > 80%

### Clean Code
- [x] Sin violaciones SOLID
- [x] Funciones siguen Single Responsibility
- [x] Sin code smells detectados

### Deploy
- [ ] Migraciones de DB incluidas (si aplica)
- [ ] Variables de entorno documentadas (si aplica)
- [ ] Cambios backward compatible

## Issues Relacionados

Cierra #123
Relacionado con #124, #125

## Dependencias

- [ ] Requiere merge de PR #XXX primero
- [ ] Depende de deploy de servicio X

## Notas Adicionales

[Información adicional para reviewers]

## Próximos Pasos

- [ ] [Task 1 post-merge]
- [ ] [Task 2 post-merge]

---

🤖 Generado con `/pr-helper` - [claude-config](https://github.com/stephpoleo/claude-config)
```

#### Template Data Science

```markdown
## Descripción

[Descripción del análisis/modelo/pipeline]

## Tipo de Cambio

- [ ] 📊 Nuevo análisis
- [ ] 🤖 Nuevo modelo ML
- [ ] 🔄 Pipeline de datos
- [ ] 📈 Visualización
- [ ] 🐛 Fix en datos/modelo
- [ ] ♻️ Refactor de código

## Cambios Realizados

### Data Pipeline
- [x] [Descripción de cambios]

### Models
- [x] [Modelos agregados/modificados]

### Visualizaciones
- [x] [Gráficos/dashboards]

## Archivos Modificados

<details>
<summary>Ver archivos</summary>

### Notebooks
- `notebooks/analysis_v2.ipynb` (nuevo)

### Scripts
- `scripts/etl_pipeline.py` (modificado)
- `scripts/train_model.py` (nuevo)

### Data
- `data/processed/features_v2.csv` (nuevo)

</details>

## Resultados

### Métricas del Modelo

| Métrica | Anterior | Nuevo | Mejora |
|---------|----------|-------|--------|
| Accuracy | 0.85 | 0.92 | +8.2% |
| Precision | 0.82 | 0.90 | +9.8% |
| Recall | 0.88 | 0.91 | +3.4% |
| F1-Score | 0.85 | 0.91 | +7.1% |

### Visualizaciones

[Incluir gráficos importantes]

## Test Plan

### Data Validation
- [x] Schema validation pasa
- [x] No missing values inesperados
- [x] Rangos de datos correctos

### Model Validation
- [x] Cross-validation: 5-fold
- [x] Train/test split: 80/20
- [x] No data leakage

### Manual Testing
1. Ejecutar pipeline completo → ✅
2. Entrenar modelo → ✅
3. Validar predicciones → ✅

## Checklist

- [x] Código reproducible
- [x] Requirements.txt actualizado
- [x] Documentación de datos agregada
- [x] Notebook ejecuta de principio a fin
- [x] Resultados validados

## Issues Relacionados

Cierra #123

---

🤖 Generado con `/pr-helper` - [claude-config](https://github.com/stephpoleo/claude-config)
```

#### Template DevOps

```markdown
## Descripción

[Descripción de cambios en infra/CI/CD]

## Tipo de Cambio

- [ ] 🐳 Docker/Containerización
- [ ] 🔄 CI/CD pipeline
- [ ] ☁️ Cloud infrastructure
- [ ] 🔒 Security
- [ ] 📦 Dependencies
- [ ] 🐛 Fix

## Cambios Realizados

### Infrastructure
- [x] [Descripción]

### CI/CD
- [x] [Descripción]

### Configuration
- [x] [Descripción]

## Archivos Modificados

<details>
<summary>Ver archivos</summary>

- `.github/workflows/deploy.yml` (modificado)
- `docker-compose.yml` (modificado)
- `Dockerfile` (nuevo)

</details>

## Test Plan

### Local Testing
- [x] Docker build exitoso
- [x] Docker compose up funciona

### CI/CD Testing
- [x] Pipeline ejecuta correctamente
- [x] Tests pasan en CI

### Deploy Testing
- [ ] Deploy a staging exitoso
- [ ] Health checks pasan

## Impacto

**Uptime**: Sin downtime esperado
**Rollback**: [Procedimiento si es necesario]

## Checklist

- [x] Secrets manejados correctamente
- [x] No credentials en código
- [x] Documentación actualizada
- [x] Rollback plan definido

## Issues Relacionados

Cierra #123

---

🤖 Generado con `/pr-helper` - [claude-config](https://github.com/stephpoleo/claude-config)
```

## Detección Automática de Proyecto

El skill detecta el tipo de proyecto analizando:

```python
# Detectar tipo de proyecto
def detect_project_type():
    if exists('package.json'):
        if 'angular' in read('package.json'):
            return 'angular'

    if exists('requirements.txt') or exists('pyproject.toml'):
        if 'django' in dependencies:
            return 'django'
        if 'pandas' in dependencies:
            return 'data-science'

    if exists('.github/workflows/'):
        return 'devops'

    return 'general'
```

## Llenado Automático

El skill llena automáticamente:

1. **Descripción**: Resumen de commits
2. **Tipo de cambio**: Basado en archivos modificados y commits
3. **Archivos modificados**: Lista completa con diff stats
4. **Checklist**: Marcados según análisis de cambios
5. **Issues**: Extrae de commits (ej: "fixes #123")

## Ejemplo de Uso Completo

### Paso 1: Usuario hace cambios

```bash
git add backend/services/order_validator.py
git add tests/services/test_order_validator.py
```

### Paso 2: Invocar skill

```
/pr-helper both
```

### Paso 3: Skill analiza

```bash
# Ejecuta internamente:
git diff --cached --stat
git diff --cached
# Detecta: Django project, nuevo service, tests agregados
```

### Paso 4: Genera commit

```
feat(backend): add order validation service

Implementa servicio de validación de órdenes con Clean Architecture:
- OrderValidator con reglas de negocio
- Validaciones de stock, precios, y datos de usuario
- Tests unitarios con 95% coverage
- Integración con OrderService existente

Archivos:
- backend/services/order_validator.py (nuevo, +150 líneas)
- tests/services/test_order_validator.py (nuevo, +200 líneas)

```

### Paso 5: Genera PR description

```markdown
## Descripción

Implementa servicio de validación de órdenes siguiendo Clean Architecture...

## Tipo de Cambio

- [x] ✨ Nueva feature
- [ ] 🐛 Bug fix
...

[Template completo llenado automáticamente]
```

### Paso 6: Usuario revisa y ajusta

El usuario puede:
- Editar descripción si necesario
- Ajustar checklist
- Agregar screenshots/videos
- Modificar test plan

### Paso 7: Crear commit y PR

```bash
# Opción 1: Crear commit automáticamente
git commit -m "[mensaje generado]"

# Opción 2: Copiar descripción para PR manual
# Usar gh CLI:
gh pr create --title "feat(backend): add order validation service" \
             --body "[descripción generada]"
```

## Configuración por Proyecto

Crear `.pr-helper.json` en la raíz del proyecto:

```json
{
  "type": "web-dev",
  "framework": {
    "backend": "django",
    "frontend": "angular"
  },
  "commitConvention": "conventional",
  "prTemplate": "standard",
  "autoDetect": true,
  "scopes": ["backend", "frontend", "api", "ui", "tests"],
  "requireTests": true,
  "requireDocs": false,
  "customChecklist": [
    "Database migrations created (if needed)",
    "Environment variables documented",
    "Backwards compatible changes"
  ]
}
```

## Integración con GitHub CLI

El skill puede usar `gh` CLI para crear PRs directamente:

```bash
# Después de generar descripción
gh pr create \
  --title "[título del commit]" \
  --body "[descripción generada]" \
  --base main \
  --head feature-branch
```

## Tips de Uso

### Para Commits Limpios

- Hacer commits pequeños y frecuentes
- Un commit por feature/fix
- Stage solo archivos relacionados

### Para PRs Efectivos

- Incluir contexto suficiente
- Explicar el "por qué", no solo el "qué"
- Agregar test plan detallado
- Screenshots para cambios visuales
- Links a issues relacionados

### Workflow Recomendado

```bash
# 1. Hacer cambios
[editar archivos]

# 2. Stage cambios relacionados
git add [archivos]

# 3. Generar y crear commit
/pr-helper commit
git commit -m "[mensaje generado]"

# 4. Más cambios si necesario
[repetir 1-3]

# 5. Al terminar feature, generar PR
/pr-helper pr

# 6. Crear PR con gh CLI
gh pr create --title "[título]" --body "[descripción]"
```

## Personalización

### Custom Templates

Crear templates en `.claude/pr-templates/`:

```markdown
# .claude/pr-templates/feature.md

## Descripción
{{description}}

## Cambios
{{changes}}

[Tu formato personalizado]
```

### Custom Scripts

Para proyectos con necesidades específicas:

```bash
# .claude/scripts/pr-helper-hook.sh
# Se ejecuta después de generar PR
#!/bin/bash
echo "PR generado, ejecutando checks adicionales..."
npm run lint
npm test
```

## Notas

- El skill es una **herramienta de ayuda**, siempre revisa lo generado
- Ajusta según tu estilo y el del equipo
- Los mensajes generados son sugerencias, no mandatorios
- Para PRs complejos, considera agregar contexto manual adicional

## Referencias

- [Conventional Commits](https://www.conventionalcommits.org/)
- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)
- [GitHub PR Best Practices](https://github.com/blog/1943-how-to-write-the-perfect-pull-request)
