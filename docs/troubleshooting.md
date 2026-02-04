# Troubleshooting Guide

Soluciones a problemas comunes con claude-config.

## Tabla de Contenidos

- [Instalación](#instalación)
- [Symlinks](#symlinks)
- [Git Submodules](#git-submodules)
- [Configuración](#configuración)
- [Skills y Agents](#skills-y-agents)
- [Scripts](#scripts)
- [Windows Específico](#windows-específico)

## Instalación

### Error: .claude Directory Already Exists

**Síntoma**:
```
Error: .claude directory already exists
```

**Causa**: Ya existe una instalación previa.

**Solución**:
```bash
# Opción 1: Hacer backup y reinstalar
mv .claude .claude.backup
./.claude-config/scripts/install.sh

# Opción 2: Ejecutar instalación sin sobrescribir
# El script preguntará qué hacer con archivos existentes
```

---

### Error: Permission Denied

**Síntoma**:
```
Permission denied: .claude/settings.local.json
```

**Causa**: Permisos incorrectos del archivo o directorio.

**Solución**:

**Windows**:
```powershell
# Verificar propietario
Get-Acl .\.claude

# Cambiar permisos
icacls .\.claude /grant ${env:USERNAME}:F /T
```

**Linux/Mac**:
```bash
# Cambiar propietario
sudo chown -R $USER:$USER .claude

# Dar permisos
chmod -R 755 .claude
```

---

### Error: Git Not Found

**Síntoma**:
```
git: command not found
```

**Causa**: Git no está instalado o no está en PATH.

**Solución**:
1. Instalar Git: https://git-scm.com/downloads
2. Reiniciar terminal
3. Verificar: `git --version`

---

## Symlinks

### Error: Symlinks Not Supported (Windows)

**Síntoma**:
```
New-Item: Administrator privilege required
```

**Causa**: Windows requiere Developer Mode o privilegios de admin para symlinks.

**Solución 1: Habilitar Developer Mode** (Recomendado):
1. `Settings` → `Update & Security` → `For developers`
2. Activar `Developer Mode`
3. Reiniciar
4. Re-ejecutar instalación

**Solución 2: Ejecutar como Admin**:
```powershell
# Ejecutar PowerShell como Administrador
Start-Process powershell -Verb runAs

# Navegar al proyecto y ejecutar instalación
cd C:\ruta\a\proyecto
.\.claude-config\scripts\install.ps1
```

**Solución 3: Usar Copias**:
El script automáticamente copiará archivos si symlinks fallan.

---

### Symlinks Rotos

**Síntoma**:
```bash
ls .claude/skills/react-component
# No such file or directory
```

**Causa**: Symlink apunta a ubicación incorrecta.

**Solución**:

**Windows**:
```powershell
# Verificar symlinks
Get-ChildItem .\.claude\skills | Select-Object Name, Target

# Recrear symlinks
Remove-Item .\.claude\skills -Recurse -Force
.\.claude-config\scripts\install.ps1
```

**Linux/Mac**:
```bash
# Verificar symlinks
ls -la .claude/skills

# Recrear symlinks
rm -rf .claude/skills
./.claude-config/scripts/install.sh
```

---

## Git Submodules

### Submodule Directory Empty

**Síntoma**:
`.claude-config/` existe pero está vacío.

**Causa**: Submodule no inicializado.

**Solución**:
```bash
# Inicializar y actualizar
git submodule update --init --recursive

# Verificar
ls -la .claude-config/
```

---

### Submodule Detached HEAD

**Síntoma**:
```
HEAD detached at abc1234
```

**Causa**: Submodule en commit específico, no en branch.

**Solución**:
```bash
cd .claude-config

# Volver a branch main
git checkout main
git pull origin main

cd ..

# Actualizar referencia
git add .claude-config
git commit -m "Update submodule to main branch"
```

---

### Submodule Merge Conflict

**Síntoma**:
```
CONFLICT (submodule): Merge conflict in .claude-config
```

**Solución**:
```bash
# Opción 1: Usar versión local
git checkout --ours .claude-config
git add .claude-config

# Opción 2: Usar versión remota
git checkout --theirs .claude-config
git add .claude-config

# Opción 3: Actualizar a latest
cd .claude-config
git checkout main
git pull origin main
cd ..
git add .claude-config

# Finalizar merge
git commit
```

---

### Cannot Update Submodule

**Síntoma**:
```
error: Your local changes would be overwritten
```

**Causa**: Cambios no commiteados en submodule.

**Solución**:
```bash
cd .claude-config

# Ver cambios
git status

# Opción 1: Descartar cambios
git reset --hard HEAD

# Opción 2: Stash cambios
git stash

# Opción 3: Commit cambios
git add .
git commit -m "Local changes"

cd ..
```

---

## Configuración

### Settings Not Applied

**Síntoma**: Claude Code no usa la configuración en `settings.local.json`.

**Solución**:

1. **Verificar sintaxis JSON**:
```bash
# Usar JSONLint
cat .claude/settings.local.json | jq .

# O en Windows
Get-Content .\.claude\settings.local.json | ConvertFrom-Json
```

2. **Verificar path de extends**:
```json
{
  "extends": "../.claude-config/settings/web-dev.json"  // ✓
  // No: ".claude-config/settings/web-dev.json"  // ✗
}
```

3. **Reiniciar Claude Code**:
Settings solo se cargan al inicio.

---

### Invalid JSON Syntax

**Síntoma**:
```
SyntaxError: Unexpected token } in JSON
```

**Causa**: Error de sintaxis en JSON.

**Solución**:
```json
// ✗ MAL - trailing comma
{
  "model": "sonnet",
  "permissions": {},  // ← Error aquí
}

// ✓ BIEN
{
  "model": "sonnet",
  "permissions": {}
}
```

Herramientas para validar:
- https://jsonlint.com/
- `jq` command line tool
- VS Code JSON validation

---

### Hooks Failing

**Síntoma**: Hooks no se ejecutan o fallan silenciosamente.

**Solución**:

1. **Verificar comando existe**:
```bash
# Verificar que npm existe
which npm  # Linux/Mac
where npm  # Windows
```

2. **Verificar paths**:
```json
{
  "hooks": {
    "pre-write": "npm run lint"  // Asegúrate que 'npm run lint' funciona manualmente
  }
}
```

3. **Ver logs**:
Claude Code debería mostrar output de hooks en consola.

---

## Skills y Agents

### Skill Not Found

**Síntoma**:
```
Error: Skill 'react-component' not found
```

**Causa**: Skill no instalado o no habilitado.

**Solución**:

1. **Verificar instalación**:
```bash
ls .claude/skills/
# Debería aparecer react-component/
```

2. **Verificar enabledSkills**:
```json
{
  "enabledSkills": [
    "react-component"  // Debe estar listado
  ]
}
```

3. **Re-instalar skill**:
```bash
./.claude-config/scripts/install.sh
# Seleccionar el skill nuevamente
```

---

### Skill Broken After Update

**Síntoma**: Skill funcionaba antes pero ahora falla.

**Causa**: Cambio en formato del skill en nueva versión.

**Solución**:

1. **Ver changelog**:
```bash
cd .claude-config
git log --oneline skills/
```

2. **Revertir a versión anterior**:
```bash
cd .claude-config
git checkout v1.0.0  # Versión que funcionaba
cd ..
git add .claude-config
git commit -m "Revert to claude-config v1.0.0"
```

3. **Reportar issue**: Abrir issue en repositorio.

---

### Agent Not Loading

**Síntoma**: Agent no se carga correctamente.

**Solución**:

1. **Verificar archivo existe**:
```bash
cat .claude/agents/frontend-specialist.md
```

2. **Verificar sintaxis frontmatter**:
```markdown
---
name: Frontend Specialist
expertise: [JavaScript, TypeScript]
model: sonnet
---

# Agent content...
```

3. **Verificar symlink**:
```bash
ls -la .claude/agents/
```

---

## Scripts

### install.ps1 Execution Policy Error

**Síntoma**:
```
File cannot be loaded because running scripts is disabled
```

**Causa**: PowerShell execution policy bloqueada.

**Solución**:
```powershell
# Opción 1: Permitir script actual
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Opción 2: Cambiar policy permanente (como admin)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Ejecutar script
.\.claude-config\scripts\install.ps1
```

---

### install.sh Permission Denied

**Síntoma**:
```
Permission denied: ./install.sh
```

**Causa**: Script no tiene permisos de ejecución.

**Solución**:
```bash
# Dar permisos de ejecución
chmod +x ./.claude-config/scripts/install.sh

# Ejecutar
./.claude-config/scripts/install.sh
```

---

### update.ps1 No Updates Found

**Síntoma**: Script dice "Already up to date" pero sabes que hay cambios.

**Solución**:
```bash
cd .claude-config

# Fetch explícito
git fetch origin --tags

# Ver si hay cambios
git log HEAD..origin/main --oneline

# Pull si hay cambios
git pull origin main

cd ..
git add .claude-config
git commit -m "Update submodule"
```

---

## Windows Específico

### Path Too Long Error

**Síntoma**:
```
The filename or extension is too long
```

**Causa**: Windows tiene límite de 260 caracteres en paths.

**Solución**:

**Opción 1: Habilitar long paths**:
```powershell
# Como administrador
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
  -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

# Reiniciar
```

**Opción 2: Mover proyecto más cerca de raíz**:
```powershell
# En lugar de
C:\Users\Username\Very\Long\Path\To\Project

# Usar
C:\Projects\MyProject
```

---

### Line Ending Issues

**Síntoma**: Scripts bash no funcionan en Windows.

**Causa**: Line endings CRLF vs LF.

**Solución**:

```bash
# Configurar git para auto-conversion
git config --global core.autocrlf true

# Re-checkout archivos
cd .claude-config
git checkout main --force
```

O usar `.gitattributes`:
```
*.sh text eol=lf
*.ps1 text eol=crlf
```

---

### WSL vs PowerShell

**Síntoma**: Scripts se comportan diferente en WSL vs PowerShell.

**Solución**:

- Usa PowerShell scripts (`.ps1`) en Windows
- Usa Bash scripts (`.sh`) en WSL/Linux
- No mezcles

---

## General Debugging

### Ver Logs de Claude Code

```bash
# Ver logs en tiempo real
tail -f ~/.claude/logs/claude-code.log

# En Windows
Get-Content $env:USERPROFILE\.claude\logs\claude-code.log -Wait
```

### Verificar Estructura Completa

```bash
# Ver todo el árbol
tree -L 3 .claude/

# En Windows
tree /F .claude
```

### Reset Completo

Si nada funciona, reset completo:

```bash
# 1. Backup
mv .claude .claude.backup

# 2. Remover submodule
git submodule deinit -f .claude-config
git rm -f .claude-config
rm -rf .git/modules/.claude-config

# 3. Re-agregar
git submodule add <repo-url> .claude-config
git submodule update --init --recursive

# 4. Re-instalar
./.claude-config/scripts/install.sh
```

## Obtener Ayuda

### Antes de Reportar Issue

1. **Verificar versión**:
```bash
cd .claude-config
git describe --tags
```

2. **Revisar este troubleshooting**

3. **Buscar issues existentes**: GitHub Issues

### Reportar Issue

Incluir:
- OS y versión (Windows 10, macOS 12, Ubuntu 22.04)
- Versión de claude-config
- Comando ejecutado
- Error completo
- Steps to reproduce

### Template de Issue

```markdown
**Entorno:**
- OS: Windows 11
- Shell: PowerShell 7.2
- Claude Config Version: v1.0.0

**Problema:**
[Descripción clara del problema]

**Steps to Reproduce:**
1. ...
2. ...
3. ...

**Expected Behavior:**
[Qué esperabas que pasara]

**Actual Behavior:**
[Qué pasó realmente]

**Error Message:**
\`\`\`
[Error completo]
\`\`\`

**Additional Context:**
[Cualquier información adicional]
```

## Recursos Adicionales

- [Getting Started](./getting-started.md)
- [Submodule Workflow](./submodule-workflow.md)
- [GitHub Issues](https://github.com/tu-usuario/claude-config/issues)
- [Git Documentation](https://git-scm.com/docs)
