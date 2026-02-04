# Usando Context7 MCP

Context7 es un servidor MCP (Model Context Protocol) que proporciona acceso a documentación actualizada de frameworks y librerías directamente desde Claude.

## ¿Qué es Context7?

Context7 permite a Claude consultar documentación oficial y actualizada de:
- **Frameworks web**: Django, Angular, FastAPI, etc.
- **Librerías Python**: pandas, scikit-learn, numpy, etc.
- **Librerías JavaScript/TypeScript**: RxJS, TypeScript, etc.
- **Cloud providers**: AWS SDK, Google Cloud SDK
- **Herramientas**: Docker, Kubernetes, Terraform

## Cuándo Usar Context7

### ✅ Usa Context7 cuando:
- Necesitas la sintaxis exacta de una API
- Quieres verificar la versión actual de un método
- Buscas ejemplos oficiales
- Necesitas información de una versión específica
- Quieres entender nuevas features de un framework

### ❌ No uses Context7 cuando:
- Tienes una pregunta genérica sobre programación
- El conocimiento base de Claude es suficiente
- Necesitas debugging de tu código específico
- Buscas opiniones o comparaciones

## Cómo Usar Context7

### 1. Identificar la Librería

Primero, necesitas el ID de la librería. Usa el tool `resolve-library-id`:

```
Necesito consultar la documentación de Django REST Framework para ver
cómo implementar ViewSets personalizados.
```

Claude usará:
```
mcp__context7__resolve-library-id(
  libraryName="django-rest-framework",
  query="how to implement custom ViewSets"
)
```

### 2. Consultar Documentación

Una vez tengas el library ID, consulta:

```
mcp__context7__query-docs(
  libraryId="/encode/django-rest-framework",
  query="custom ViewSets with mixins examples"
)
```

## Ejemplos Prácticos

### Django

```markdown
Usuario: ¿Cómo implemento select_related en Django para optimizar queries?

Claude usa Context7:
1. resolve-library-id("django", "select_related optimization")
2. query-docs("/django/django", "select_related usage examples")

Resultado: Obtiene documentación oficial con ejemplos actualizados.
```

### Angular

```markdown
Usuario: ¿Cómo usar Signals en Angular 16+?

Claude usa Context7:
1. resolve-library-id("angular", "signals reactive state")
2. query-docs("/angular/angular", "signals API usage")

Resultado: Documentación de la versión específica de Angular.
```

### scikit-learn

```markdown
Usuario: ¿Cuál es la sintaxis correcta para RandomForestClassifier?

Claude usa Context7:
1. resolve-library-id("scikit-learn", "RandomForestClassifier")
2. query-docs("/scikit-learn/scikit-learn", "RandomForestClassifier parameters")

Resultado: API reference actualizado con todos los parámetros.
```

### pandas

```markdown
Usuario: ¿Cómo hacer merge de DataFrames con multiple keys?

Claude usa Context7:
1. resolve-library-id("pandas", "merge multiple keys")
2. query-docs("/pandas-dev/pandas", "merge on multiple columns")

Resultado: Ejemplos oficiales de merge operations.
```

## Tips para Mejores Resultados

### 1. Sé Específico en tu Query

```
❌ Malo: "cómo usar Django"
✅ Bueno: "Django QuerySet select_related and prefetch_related examples"
```

### 2. Incluye Versión si es Crítico

```
"Angular 16 standalone components migration guide"
"Django 4.2 async views implementation"
```

### 3. Usa Términos Técnicos Correctos

```
❌ Malo: "hacer join en pandas"
✅ Bueno: "pandas merge, join, and concat operations"
```

### 4. Especifica lo que Buscas

```
"TypeScript generics with constraints examples"
"Django REST Framework nested serializers validation"
"scikit-learn pipeline with custom transformers"
```

## Librerías Comunes Disponibles

### Python
- `/python/cpython` - Python standard library
- `/django/django` - Django framework
- `/encode/django-rest-framework` - Django REST Framework
- `/pandas-dev/pandas` - pandas
- `/scikit-learn/scikit-learn` - scikit-learn
- `/numpy/numpy` - NumPy
- `/psf/requests` - requests
- `/boto/boto3` - AWS SDK (boto3)

### JavaScript/TypeScript
- `/angular/angular` - Angular
- `/microsoft/TypeScript` - TypeScript
- `/ReactiveX/rxjs` - RxJS
- `/nestjs/nest` - NestJS

### DevOps
- `/docker/docs` - Docker
- `/hashicorp/terraform` - Terraform

## Integración con Skills

Los skills pueden usar Context7 internamente. Por ejemplo:

### En django-api skill

Cuando usas `/django-api users "CRUD operations"`, el skill puede:
1. Consultar Context7 para la sintaxis exacta de ViewSets
2. Verificar métodos actuales de DRF
3. Obtener ejemplos oficiales

### En angular-component skill

Cuando usas `/angular-component UserCard "user info"`, el skill puede:
1. Consultar sintaxis de decoradores en Angular 16+
2. Verificar API de Signals
3. Obtener ejemplos de change detection

## Troubleshooting

### "Library not found"

Intenta variaciones del nombre:
- `django-rest-framework`
- `djangorestframework`
- `drf`

O especifica el path completo si lo conoces:
- `/encode/django-rest-framework`

### "No results found"

- Simplifica tu query
- Usa términos más genéricos
- Divide en múltiples consultas más específicas

### "Too many results"

- Sé más específico
- Agrega contexto adicional
- Menciona la versión específica

## Mejores Prácticas

1. **Consulta Primero, Implementa Después**
   - Verifica la sintaxis con Context7
   - Luego implementa basado en docs oficiales

2. **Usa para Features Nuevas**
   - Cuando una librería actualiza
   - Para features recién agregadas
   - Para cambios de API

3. **Combina con Knowledge Base**
   - Context7 para sintaxis específica
   - Claude base para patrones generales
   - Tu experiencia para decisiones arquitectónicas

4. **Versiona tu Código**
   - Anota qué versión de librería usas
   - Consulta docs de esa versión específica
   - Facilita mantenimiento futuro

## Recursos

- Context7 está configurado automáticamente en claude-config
- No requiere configuración adicional
- Funciona con todos los agents y skills
- Disponible en cualquier momento

## Ejemplo Completo

```markdown
Usuario: Quiero implementar un ViewSet custom en Django REST Framework
que filtre por usuario actual y tenga paginación.

Claude:
1. Usa Context7 para consultar DRF ViewSets
2. Obtiene documentación de filtrado
3. Verifica paginación options
4. Combina con knowledge base para generar implementación
5. Entrega código con sintaxis correcta y actualizada

Resultado: Código funcional basado en docs oficiales actualizadas.
```

## Comandos Útiles

Para invocar manualmente (no necesario, Claude lo hace automáticamente):

```python
# Resolver library ID
resolve-library-id(
    libraryName="django",
    query="tu consulta aquí"
)

# Consultar docs
query-docs(
    libraryId="/django/django",
    query="tu consulta específica"
)
```

## Límites

- **No más de 3 consultas por pregunta**: Evita uso excesivo
- **Consultas específicas**: No consultas demasiado amplias
- **Cache automático**: Resultados se cachean temporalmente

## Conclusión

Context7 es una herramienta poderosa para mantener tu código actualizado con las últimas versiones de frameworks y librerías. Úsala estratégicamente para complementar el conocimiento base de Claude.
