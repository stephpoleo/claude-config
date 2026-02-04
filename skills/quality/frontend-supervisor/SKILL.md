---
name: frontend-supervisor
description: Review frontend code for UX/UI issues, accessibility, and design consistency
user-invocable: true
categories: [quality, frontend, ux, ui, accessibility]
version: 1.0.0
---

# Frontend Supervisor

Supervisa y revisa código frontend para identificar problemas de UX/UI, accesibilidad, diseño y experiencia de usuario.

## Usage

```
/frontend-supervisor <file-or-component>
```

### Examples

```
/frontend-supervisor "src/app/components/user-card"
/frontend-supervisor "review header navigation for accessibility"
/frontend-supervisor "check form validation UX"
```

## Reports System

Similar a `clean-code-review`, genera reportes markdown en `docs/frontend-reviews/`

### Formato del Reporte

```markdown
# Frontend Review: [Component/Feature Name]

**Fecha**: YYYY-MM-DD
**Revisor**: Frontend Supervisor
**Archivos**: `path/to/component`
**Tipo**: [UX | UI | Accessibility | Performance | All]

## Resumen Ejecutivo

[Resumen de hallazgos principales]

## Issues Encontrados

### 🔴 Críticos - Accesibilidad (X)

#### 1. Contraste insuficiente en botones primarios

**Ubicación**: `button.component.scss:15`
**Estándar**: WCAG 2.1 Level AA

**Problema**:
El contraste entre texto blanco (#FFFFFF) y fondo azul (#42A5F5) es 3.2:1,
por debajo del mínimo requerido de 4.5:1 para texto normal.

**Código actual**:
\`\`\`scss
.button-primary {
  background-color: #42A5F5;  // Light Blue 400
  color: #FFFFFF;
  // Ratio: 3.2:1 ❌
}
\`\`\`

**Impacto**: Alto - Usuarios con problemas visuales no pueden leer el texto

**Recomendación**:
\`\`\`scss
.button-primary {
  background-color: #1976D2;  // Blue 700
  color: #FFFFFF;
  // Ratio: 8.5:1 ✅ (AAA compliant)
}
\`\`\`

**Status**: ⏳ Pendiente
**Prioridad**: Alta (Legal - WCAG requirement)

---

#### 2. Falta keyboard navigation en modal

**Ubicación**: `modal.component.ts:45`
**Estándar**: WCAG 2.1 Level A

**Problema**:
El modal no atrapa el foco (focus trap), permitiendo que usuarios
con teclado naveguen fuera del modal sin cerrarlo.

**Impacto**: Alto - Bloquea usuarios de solo-teclado

**Recomendación**:
\`\`\`typescript
import { FocusTrap, FocusTrapFactory } from '@angular/cdk/a11y';

export class ModalComponent implements OnInit, OnDestroy {
  private focusTrap: FocusTrap;

  constructor(
    private focusTrapFactory: FocusTrapFactory,
    private elementRef: ElementRef
  ) {}

  ngOnInit(): void {
    this.focusTrap = this.focusTrapFactory.create(
      this.elementRef.nativeElement
    );
    this.focusTrap.focusInitialElementWhenReady();
  }

  ngOnDestroy(): void {
    this.focusTrap.destroy();
  }

  @HostListener('document:keydown.escape')
  closeOnEscape(): void {
    this.close();
  }
}
\`\`\`

**Status**: ⏳ Pendiente
**Prioridad**: Alta

---

### 🟡 Importantes - UX (X)

#### 3. Sin loading state durante fetch

**Ubicación**: `user-list.component.ts:30`

**Problema**:
Al cargar usuarios, no hay feedback visual. Pantalla vacía por 2-3 segundos.

**Impacto**: Medio - Usuarios piensan que la app no responde

**Recomendación**:
\`\`\`typescript
// user-list.component.ts
isLoading = signal(false);

async loadUsers(): Promise<void> {
  this.isLoading.set(true);

  try {
    this.users.set(await this.userService.getUsers());
  } finally {
    this.isLoading.set(false);
  }
}
\`\`\`

\`\`\`html
<!-- user-list.component.html -->
<div class="user-list">
  <!-- Skeleton loading -->
  <app-user-skeleton *ngIf="isLoading()" [count]="5" />

  <!-- Contenido real -->
  <app-user-card
    *ngFor="let user of users()"
    [user]="user" />

  <!-- Empty state -->
  <app-empty-state
    *ngIf="!isLoading() && users().length === 0"
    message="No hay usuarios"
    (action)="addUser()" />
</div>
\`\`\`

**Status**: ⏳ Pendiente
**Prioridad**: Media

---

### 🟢 Menores - UI (X)

#### 4. Inconsistencia en spacing

**Ubicación**: Múltiples componentes

**Problema**:
Uso inconsistente de spacing (12px, 15px, 18px, 20px).
Design system define múltiplos de 8px.

**Recomendación**:
\`\`\`scss
// Usar clases de utilidad o mixins
.mb-1 { margin-bottom: 8px; }   // $spacing-sm
.mb-2 { margin-bottom: 16px; }  // $spacing-md
.mb-3 { margin-bottom: 24px; }  // $spacing-lg
.mb-4 { margin-bottom: 32px; }  // $spacing-xl
\`\`\`

**Status**: ⏳ Pendiente

---

## Métricas UX/UI

| Métrica | Actual | Objetivo | Status |
|---------|--------|----------|--------|
| **Accesibilidad** |
| Contraste WCAG AA | 75% | 100% | ❌ |
| Keyboard navigation | 60% | 100% | ❌ |
| ARIA labels | 40% | 100% | ❌ |
| Semantic HTML | 70% | 100% | ❌ |
| **UX** |
| Loading states | 30% | 100% | ❌ |
| Error handling | 50% | 100% | ❌ |
| Empty states | 20% | 100% | ❌ |
| Form validation | 80% | 100% | 🟡 |
| **UI** |
| Design consistency | 65% | 95% | ❌ |
| Responsive breakpoints | 100% | 100% | ✅ |
| Touch targets ≥ 48px | 85% | 100% | 🟡 |
| **Performance** |
| First Contentful Paint | 2.1s | < 1.8s | 🟡 |
| Largest Contentful Paint | 3.5s | < 2.5s | ❌ |

## Checklist de Revisión

### Accesibilidad (a11y)
- [ ] Contraste de colores WCAG AA (4.5:1 mínimo)
- [ ] Navegación con teclado funcional
- [ ] Focus states visibles
- [ ] ARIA labels en elementos interactivos
- [ ] Semantic HTML (<header>, <nav>, <main>, <footer>)
- [ ] Alt text en imágenes
- [ ] Form labels asociados correctamente
- [ ] Headings en orden jerárquico (h1 → h2 → h3)
- [ ] Skip links para navegación
- [ ] Error messages anunciados a screen readers

### UX Design
- [ ] Loading states implementados
- [ ] Error states manejados
- [ ] Empty states diseñados
- [ ] Success feedback visible
- [ ] Confirmaciones en acciones destructivas
- [ ] Formularios con validación inline
- [ ] Mensajes de error user-friendly
- [ ] Undo/redo cuando sea posible
- [ ] Progreso guardado automáticamente
- [ ] Tooltips en iconos ambiguos

### UI Design
- [ ] Jerarquía visual clara
- [ ] Consistencia con design system
- [ ] Spacing uniforme (múltiplos de 8px)
- [ ] Tipografía consistente
- [ ] Colores del design system
- [ ] Iconografía coherente
- [ ] Botones con min-width/height apropiados
- [ ] Estados hover/active/disabled definidos
- [ ] Transiciones suaves (< 300ms)
- [ ] Sombras según elevación

### Responsive Design
- [ ] Mobile first approach
- [ ] Breakpoints apropiados (sm, md, lg, xl)
- [ ] Touch targets ≥ 48x48px en mobile
- [ ] Texto legible en mobile (≥ 16px)
- [ ] Navegación adaptada a mobile
- [ ] Formularios optimizados para mobile
- [ ] Imágenes responsive
- [ ] Grid/Flexbox layouts

### Performance
- [ ] Lazy loading de imágenes
- [ ] Code splitting en rutas
- [ ] OnPush change detection
- [ ] Virtual scrolling en listas largas
- [ ] Debounce en búsquedas/inputs
- [ ] Memoización de cálculos pesados
- [ ] Unsubscribe de observables
- [ ] TrackBy en *ngFor

## Herramientas de Detección

El skill usa estas herramientas para análisis automático:

### Accesibilidad
- **axe-core**: Auditoría automática a11y
- **WAVE**: Visualizar issues de accesibilidad
- **Lighthouse**: Score y recomendaciones
- **Contrast Checker**: Ratios de contraste

### UX/UI
- **Angular DevTools**: Inspeccionar componentes
- **Chrome DevTools**: Layout, responsive
- **Figma/Design Tool**: Comparar con diseños

### Performance
- **Lighthouse**: Métricas de performance
- **Chrome DevTools**: Profiling, network
- **Angular Profiler**: Change detection

## Categorías de Review

### 1. Accessibility Review (a11y)

Focus en cumplimiento WCAG:
- Contraste de colores
- Keyboard navigation
- Screen reader support
- ARIA attributes
- Semantic HTML

### 2. UX Review

Focus en experiencia de usuario:
- Loading states
- Error handling
- Empty states
- Form validation
- User feedback
- Navigation flow

### 3. UI Review

Focus en diseño visual:
- Design system compliance
- Visual consistency
- Spacing and typography
- Color usage
- Component states
- Responsive design

### 4. Performance Review

Focus en rendimiento frontend:
- Loading times
- Bundle size
- Change detection
- Memory leaks
- Network requests

### 5. Full Review

Todos los aspectos anteriores

## Ejemplo de Uso

```typescript
// Antes del review
@Component({
  template: `
    <button (click)="save()">
      <i class="icon-save"></i>
    </button>
  `
})
export class SaveButton {
  save() {
    this.api.save().subscribe();
  }
}
```

Issues detectados:
1. ❌ Sin ARIA label (accesibilidad)
2. ❌ Sin loading state (UX)
3. ❌ Sin error handling (UX)
4. ❌ Sin unsubscribe (performance)
5. ❌ Touch target pequeño (UI)

```typescript
// Después del review
@Component({
  template: `
    <button
      class="save-button"
      [attr.aria-label]="isLoading() ? 'Guardando...' : 'Guardar cambios'"
      [disabled]="isLoading()"
      (click)="save()">

      <mat-icon *ngIf="!isLoading()">save</mat-icon>
      <mat-spinner
        *ngIf="isLoading()"
        diameter="20"
        aria-label="Guardando...">
      </mat-spinner>

      <span class="button-text">
        {{ isLoading() ? 'Guardando...' : 'Guardar' }}
      </span>
    </button>
  `,
  styles: [`
    .save-button {
      min-width: 48px;
      min-height: 48px;
      padding: 12px 24px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
  `]
})
export class SaveButton implements OnDestroy {
  private destroy$ = new Subject<void>();
  isLoading = signal(false);

  save(): void {
    this.isLoading.set(true);

    this.api.save()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: () => {
          this.isLoading.set(false);
          this.snackBar.open('Guardado exitosamente', 'OK');
        },
        error: (error) => {
          this.isLoading.set(false);
          this.snackBar.open(
            'Error al guardar. Por favor intenta de nuevo.',
            'Reintentar',
            { action: () => this.save() }
          );
        }
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

## Recomendaciones Prioritarias

### Alta Prioridad (Legales/Bloqueantes)
1. Cumplir WCAG 2.1 Level AA mínimo
2. Keyboard navigation completo
3. Screen reader compatibility

### Media Prioridad (UX crítico)
1. Loading states en todas las operaciones async
2. Error handling user-friendly
3. Form validation inline

### Baja Prioridad (Mejoras)
1. Micro-interactions
2. Skeleton screens
3. Optimistic updates

## Integración con Design System

El skill verifica cumplimiento del design system:

```typescript
// Verificar uso de design tokens
const issues: Issue[] = [];

// Verificar colores
if (usesHardcodedColors(component)) {
  issues.push({
    severity: 'warning',
    message: 'Usar design tokens en lugar de colores hardcoded',
    example: `
      // ❌ Mal
      color: #1976D2;

      // ✅ Bien
      color: var(--color-primary);
    `
  });
}

// Verificar spacing
if (usesNonStandardSpacing(component)) {
  issues.push({
    severity: 'info',
    message: 'Usar múltiplos de 8px para spacing',
    example: `
      // ❌ Mal
      margin: 15px;

      // ✅ Bien
      margin: 16px; // $spacing-md
    `
  });
}
```

## Referencias

### Estándares
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Guidelines](https://material.io/design)
- [Angular Accessibility](https://angular.io/guide/accessibility)

### Herramientas
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [Lighthouse](https://developers.google.com/web/tools/lighthouse)
- [WAVE](https://wave.webaim.org/)

### Recursos Internos
- `memory/coding-standards/typescript.md` - Estándares Angular/TypeScript
- `agents/design/ux-ui-designer.md` - UX/UI Designer agent
- `agents/web-dev/angular-specialist.md` - Angular Specialist agent

## Notas

- El skill es complementario al `clean-code-review` (se enfocan en aspectos diferentes)
- Usar junto con UX/UI Designer agent para diseño de nuevas features
- Siempre priorizar accesibilidad (no es opcional, es requerimiento legal)
- Feedback con el usuario final es crucial - tests de usabilidad recomendados
