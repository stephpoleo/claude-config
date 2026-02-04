# Git Submodule Workflow

Esta guía explica cómo trabajar con claude-config como git submodule.

## ¿Qué es un Git Submodule?

Un submodule es un repositorio git dentro de otro repositorio. Permite incluir código de un repo externo manteniendo su propio historial de versiones.

### Ventajas

- **Versionado**: Cada proyecto puede usar versiones diferentes de claude-config
- **Sincronización**: Actualizaciones centralizadas benefician a todos los proyectos
- **Aislamiento**: Cambios en un proyecto no afectan a otros

## Anatomía de un Submodule

```
mi-proyecto/
├── .git/               # Git del proyecto
├── .gitmodules         # Configuración de submodules
└── .claude-config/     # Submodule (otro repo git)
    ├── .git            # Git del submodule
    ├── skills/
    ├── agents/
    └── ...
```

### Archivo .gitmodules

```ini
[submodule ".claude-config"]
    path = .claude-config
    url = https://github.com/tu-usuario/claude-config
    branch = main
```

## Comandos Básicos

### Agregar Submodule

```bash
# Agregar por primera vez
git submodule add <repo-url> .claude-config

# Esto crea:
# 1. .gitmodules (config)
# 2. .claude-config/ (directorio)
# 3. Entry en .git/config
```

### Inicializar Submodules

Cuando clonas un repo que tiene submodules:

```bash
# Método 1: En dos pasos
git clone <proyecto-url>
cd proyecto
git submodule init
git submodule update

# Método 2: Todo a la vez
git clone --recurse-submodules <proyecto-url>

# Método 3: Después de clonar
git submodule update --init --recursive
```

### Actualizar Submodule

```bash
# Opción 1: Usando el script
./.claude-config/scripts/update.ps1  # Windows
./.claude-config/scripts/update.sh   # Linux/Mac

# Opción 2: Manual
cd .claude-config
git pull origin main
cd ..
git add .claude-config
git commit -m "Update claude-config submodule"
```

### Ver Estado del Submodule

```bash
# Ver commit actual del submodule
git submodule status

# Ver cambios en submodule
git diff .claude-config

# Ver log del submodule
cd .claude-config
git log --oneline
cd ..
```

## Workflows Comunes

### Workflow 1: Usar Versión Específica

```bash
# Navegar al submodule
cd .claude-config

# Ver versiones disponibles
git tag

# Checkout versión específica
git checkout v1.2.0

# Volver al proyecto
cd ..

# Guardar la versión en el proyecto
git add .claude-config
git commit -m "Pin claude-config to v1.2.0"
```

### Workflow 2: Actualizar a Última Versión

```bash
# Navegar al submodule
cd .claude-config

# Pull última versión
git pull origin main

# Volver al proyecto
cd ..

# Commit el cambio
git add .claude-config
git commit -m "Update claude-config to latest"

# Push
git push
```

### Workflow 3: Cambiar de Branch

```bash
cd .claude-config

# Cambiar a development branch
git checkout development
git pull origin development

cd ..

git add .claude-config
git commit -m "Switch to claude-config development branch"
```

### Workflow 4: Ver Cambios Disponibles

```bash
cd .claude-config

# Fetch cambios sin aplicar
git fetch origin

# Ver diferencias
git log HEAD..origin/main --oneline

# Ver archivos que cambiarían
git diff --stat HEAD origin/main

cd ..
```

### Workflow 5: Trabajar en Múltiples Proyectos

```
proyecto-a/
└── .claude-config/  → v1.0.0

proyecto-b/
└── .claude-config/  → v1.2.0 (latest)

proyecto-c/
└── .claude-config/  → development branch
```

Cada proyecto puede estar en diferente versión independientemente.

## Contribuir al Submodule

Si quieres contribuir cambios a claude-config:

### Fork y Clone

```bash
# 1. Fork claude-config en GitHub

# 2. Cambiar URL del submodule a tu fork
cd .claude-config
git remote set-url origin https://github.com/tu-usuario/claude-config
git remote add upstream https://github.com/original/claude-config

# 3. Crear branch
git checkout -b feature/nueva-funcionalidad

# 4. Hacer cambios
# ... editar archivos ...

# 5. Commit y push
git add .
git commit -m "Add nueva funcionalidad"
git push origin feature/nueva-funcionalidad

# 6. Crear Pull Request en GitHub
```

### Sincronizar Fork

```bash
cd .claude-config

# Fetch cambios del upstream
git fetch upstream

# Merge cambios a tu main
git checkout main
git merge upstream/main

# Push a tu fork
git push origin main

cd ..
```

## Sincronizar entre Equipo

### Escenario: Compañero Actualizó Submodule

```bash
# Tu compañero hizo:
# git submodule update
# git add .claude-config
# git commit -m "Update claude-config"
# git push

# Tú haces:
git pull

# Git te avisa que .claude-config cambió
# Actualizar submodule
git submodule update --remote
```

### Automatizar Actualización

Agregar hook de git:

**.git/hooks/post-merge**:
```bash
#!/bin/bash
# Auto-update submodules after merge
git submodule update --init --recursive
```

```bash
chmod +x .git/hooks/post-merge
```

## Resolver Conflictos

### Conflicto en .gitmodules

```bash
# Si hay conflicto en .gitmodules
git checkout --ours .gitmodules   # Usar tu versión
# o
git checkout --theirs .gitmodules # Usar su versión

# Luego
git add .gitmodules
git commit
```

### Submodule en Estado Detached HEAD

```bash
cd .claude-config

# Ver en qué commit estás
git status

# Volver a branch
git checkout main
git pull origin main

cd ..
git add .claude-config
git commit -m "Fix detached HEAD in submodule"
```

## Eliminar Submodule

Si necesitas remover claude-config:

```bash
# 1. Deinicializar
git submodule deinit -f .claude-config

# 2. Remover del índice
git rm -f .claude-config

# 3. Remover directorio .git del submodule
rm -rf .git/modules/.claude-config

# 4. Commit
git commit -m "Remove claude-config submodule"
```

## Best Practices

### 1. Siempre Commit el Submodule

```bash
# Después de actualizar submodule
git add .claude-config
git commit -m "Update claude-config to vX.Y.Z"
```

### 2. Documentar Versión en README

```markdown
## Dependencies

- claude-config: v1.2.0
```

### 3. CI/CD: Inicializar Submodules

```yaml
# GitHub Actions
- name: Checkout code
  uses: actions/checkout@v2
  with:
    submodules: recursive

# GitLab CI
variables:
  GIT_SUBMODULE_STRATEGY: recursive
```

### 4. No Modificar Submodule Directamente

Trabaja en el repo de claude-config, no en el submodule.

### 5. Pinear Versiones en Producción

```bash
# En producción, usa tags específicos
cd .claude-config
git checkout v1.2.0
```

## Troubleshooting

### Submodule Vacío

```bash
git submodule update --init --recursive
```

### Submodule en Commit Viejo

```bash
cd .claude-config
git checkout main
git pull
cd ..
git add .claude-config
git commit -m "Update submodule"
```

### Error: "Already exists in the index"

```bash
git rm --cached .claude-config
git submodule add <url> .claude-config
```

### Cambios No Commiteados en Submodule

```bash
cd .claude-config
git status
git stash  # o commit/revert
cd ..
```

## Referencias

- [Git Submodules Official](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Submodules](https://github.blog/2016-02-01-working-with-submodules/)

## Comandos de Referencia Rápida

```bash
# Agregar
git submodule add <url> <path>

# Inicializar
git submodule update --init --recursive

# Actualizar a latest
git submodule update --remote

# Status
git submodule status

# Foreach (ejecutar comando en todos los submodules)
git submodule foreach 'git pull origin main'

# Eliminar
git submodule deinit -f <path>
git rm -f <path>

# Ver diferencias
git diff --submodule

# Clonar con submodules
git clone --recurse-submodules <url>
```
