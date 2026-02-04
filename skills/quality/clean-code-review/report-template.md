# Code Review: [Título Descriptivo]

**Fecha**: YYYY-MM-DD
**Revisor**: Claude Opus 4.5
**Archivos**: `path/to/file.py`, `path/to/another.py`
**Proyecto**: [Nombre del proyecto]

## Resumen Ejecutivo

[1-2 párrafos describiendo principales hallazgos, contexto del review, y recomendación general]

## Issues Encontrados

### 🔴 Críticos (0)

#### 1. [Título del Issue Crítico]

**Ubicación**: `file.py:línea-inicio-fin`
**Principio violado**: [SRP | OCP | LSP | ISP | DIP | DRY | YAGNI]

**Problema**:
[Descripción detallada del problema]

**Código actual**:
```python
# Código problemático
```

**Impacto**: [Alto | Medio | Bajo] - [Descripción del impacto]

**Recomendación**:
```python
# Código mejorado
```

**Status**: ⏳ Pendiente | ✅ Resuelto | 🔄 En progreso
**Prioridad**: Alta
**Estimación**: [X horas/días]

**Referencias**:
- memory/coding-standards/clean-code.md - [Sección]
- [Link a documentación externa]

---

### 🟡 Importantes (0)

#### 2. [Título del Issue Importante]

**Ubicación**: `file.py:línea`
**Problema**: [Descripción]

**Recomendación**:
```python
# Solución sugerida
```

**Status**: ⏳ Pendiente
**Prioridad**: Media
**Estimación**: [X horas]

---

### 🟢 Menores (0)

#### 3. [Título del Issue Menor]

**Ubicación**: `file.py:línea`
**Problema**: [Descripción breve]
**Recomendación**: [Solución breve]
**Status**: ⏳ Pendiente

---

## Code Smells Detectados

- [ ] God Class
- [ ] Long Method
- [ ] Long Parameter List
- [ ] Duplicate Code
- [ ] Magic Numbers
- [ ] Feature Envy
- [ ] Data Clumps
- [ ] Shotgun Surgery
- [ ] Inappropriate Intimacy
- [ ] Refused Bequest

## Métricas de Calidad

| Métrica | Actual | Objetivo | Status | Notas |
|---------|--------|----------|--------|-------|
| Complejidad Ciclomática | X | < 10 | ❌ ✅ | Por función |
| Líneas por función (promedio) | X | < 20 | ❌ ✅ | |
| Parámetros por función (max) | X | ≤ 3 | ❌ ✅ | |
| Cobertura de tests | X% | > 80% | ❌ ✅ | |
| Violaciones SOLID | X | 0 | ❌ ✅ | |
| Nivel de anidación (max) | X | ≤ 3 | ❌ ✅ | |
| Duplicación de código | X% | < 5% | ❌ ✅ | |

## Violaciones SOLID

| Principio | Violaciones | Descripción |
|-----------|-------------|-------------|
| **S**RP (Single Responsibility) | X | [Clases/funciones afectadas] |
| **O**CP (Open/Closed) | X | [Clases que requieren modificación frecuente] |
| **L**SP (Liskov Substitution) | X | [Herencias problemáticas] |
| **I**SP (Interface Segregation) | X | [Interfaces gordas] |
| **D**IP (Dependency Inversion) | X | [Dependencias concretas] |

## Recomendaciones Prioritarias

### 1. [Recomendación Principal] (Crítico)
- **Descripción**: [Qué hacer]
- **Tiempo estimado**: [X horas/días]
- **Beneficio**: [Qué se gana]
- **Issues relacionados**: #1, #2

### 2. [Segunda Recomendación] (Importante)
- **Descripción**: [Qué hacer]
- **Tiempo estimado**: [X horas/días]
- **Beneficio**: [Qué se gana]
- **Issues relacionados**: #3, #4

### 3. [Tercera Recomendación] (Menor)
- **Descripción**: [Qué hacer]
- **Tiempo estimado**: [X minutos/horas]
- **Beneficio**: [Qué se gana]

## Plan de Acción

### Sprint 1 (Semana 1-2)
- [ ] Refactor [Componente principal] (Issue #1)
  - [ ] Crear [nueva clase/módulo]
  - [ ] Migrar funcionalidad
  - [ ] Agregar tests
  - [ ] Actualizar documentación
- [ ] Implementar [mejora] (Issue #2)

### Sprint 2 (Semana 3-4)
- [ ] Mejorar cobertura de tests (objetivo: 80%)
- [ ] Resolver code smells menores (Issues #3-#5)

### Sprint 3 (Semana 5+)
- [ ] Optimizaciones finales
- [ ] Documentación completa
- [ ] Code review final

## Archivos a Crear/Modificar

### Nuevos archivos
```
project/
├── path/to/new_module.py          # [Descripción]
├── path/to/another_module.py      # [Descripción]
├── tests/test_new_module.py       # Tests para nuevo módulo
└── docs/architecture/refactor.md  # Documentación del refactor
```

### Archivos a modificar
- `path/to/existing.py` - [Descripción de cambios]
- `path/to/another.py` - [Descripción de cambios]
- `tests/test_existing.py` - [Actualizar tests]
- `README.md` - [Actualizar documentación si aplica]

### Archivos a eliminar (deprecar)
- `path/to/old_module.py` - [Razón de eliminación]

## Patrones de Diseño Sugeridos

- **[Patrón 1]**: Para [problema específico]
  - Beneficio: [Descripción]
  - Referencia: [Link o documento]

- **[Patrón 2]**: Para [problema específico]
  - Beneficio: [Descripción]
  - Referencia: [Link o documento]

## Testing Strategy

### Tests a Agregar
```python
# test_module.py

def test_[funcionalidad]():
    """Test que valida [comportamiento esperado]"""
    # Arrange
    # Act
    # Assert

def test_[edge_case]():
    """Test para caso límite: [descripción]"""
    pass
```

### Cobertura Actual vs Objetivo

| Módulo | Actual | Objetivo | Gap |
|--------|--------|----------|-----|
| module_a.py | 45% | 80% | 35% |
| module_b.py | 60% | 80% | 20% |

## Notas Adicionales

- [Consideraciones especiales]
- [Contexto de negocio relevante]
- [Dependencias externas]
- [Deuda técnica relacionada]
- [Limitaciones conocidas]

## Referencias

### Documentación Interna
- `memory/coding-standards/python.md` - Estándares de código Python
- `memory/coding-standards/clean-code.md` - Principios Clean Code
- `docs/architecture.md` - Arquitectura del proyecto

### Recursos Externos
- [Clean Code by Robert Martin](https://www.example.com)
- [SOLID Principles](https://www.example.com)
- [Refactoring Catalog](https://refactoring.com)

## Historial de Cambios

| Fecha | Cambio | Responsable | Status |
|-------|--------|-------------|--------|
| YYYY-MM-DD | Review inicial | Claude | ✅ |
| YYYY-MM-DD | Issue #1 resuelto | [Nombre] | ✅ |
| YYYY-MM-DD | Issue #2 resuelto | [Nombre] | 🔄 |

## Próxima Revisión

**Fecha sugerida**: [YYYY-MM-DD] (después de implementar cambios críticos)
**Enfoque**:
- Validar que issues críticos fueron resueltos correctamente
- Revisar nuevos tests agregados
- Medir mejora en métricas de calidad
- Identificar nuevas áreas de mejora

**Criterios de aceptación**:
- [ ] Todos los issues críticos resueltos
- [ ] Cobertura de tests > 80%
- [ ] Complejidad ciclomática < 10
- [ ] Cero violaciones SOLID nuevas

---

**Generado por**: `/clean-code-review` skill
**Versión**: 1.0.0
**Repositorio**: [claude-config](https://github.com/stephpoleo/claude-config)
