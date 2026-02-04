---
name: angular-component
description: Create Angular components following best practices with TypeScript
user-invocable: true
categories: [web-dev, frontend, angular]
version: 1.0.0
---

# Angular Component Creation

Create Angular components following modern best practices, TypeScript conventions, and Angular style guide.

## Usage

```
/angular-component <ComponentName> [description]
```

### Examples

```
/angular-component UserCard "displays user information with avatar and actions"
/angular-component DataTable "paginated table with sorting and filtering"
/angular-component Modal "reusable modal dialog with custom content"
```

## Guidelines

### 1. Component Structure

Use Angular CLI for consistency:

```bash
ng generate component components/user-card
```

Creates:
```
user-card/
├── user-card.component.ts       # Component logic
├── user-card.component.html     # Template
├── user-card.component.scss     # Styles
├── user-card.component.spec.ts  # Tests
└── index.ts                     # Barrel export (optional)
```

### 2. Component Class

```typescript
import { Component, Input, Output, EventEmitter, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './user-card.component.html',
  styleUrls: ['./user-card.component.scss']
})
export class UserCardComponent implements OnInit, OnDestroy {
  // Inputs con decorador
  @Input() user!: User;
  @Input() showActions: boolean = true;

  // Outputs con EventEmitter
  @Output() userClick = new EventEmitter<User>();
  @Output() deleteClick = new EventEmitter<string>();

  // Properties
  isLoading = false;
  errorMessage: string | null = null;

  // Lifecycle hooks
  ngOnInit(): void {
    this.loadUserData();
  }

  ngOnDestroy(): void {
    // Cleanup subscriptions
  }

  // Public methods
  onUserClick(): void {
    this.userClick.emit(this.user);
  }

  onDeleteClick(): void {
    this.deleteClick.emit(this.user.id);
  }

  // Private methods
  private loadUserData(): void {
    // Implementation
  }
}
```

### 3. Template (HTML)

```html
<div class="user-card" [class.loading]="isLoading">
  <!-- Avatar -->
  <img
    [src]="user.avatar"
    [alt]="user.name"
    class="user-card__avatar"
  >

  <!-- Info -->
  <div class="user-card__info">
    <h3 class="user-card__name">{{ user.name }}</h3>
    <p class="user-card__email">{{ user.email }}</p>
  </div>

  <!-- Actions -->
  <div class="user-card__actions" *ngIf="showActions">
    <button
      type="button"
      class="btn btn-primary"
      (click)="onUserClick()"
    >
      Ver Perfil
    </button>
    <button
      type="button"
      class="btn btn-danger"
      (click)="onDeleteClick()"
    >
      Eliminar
    </button>
  </div>

  <!-- Error -->
  <div class="user-card__error" *ngIf="errorMessage">
    {{ errorMessage }}
  </div>
</div>
```

### 4. Styles (SCSS)

Use BEM naming convention:

```scss
.user-card {
  display: flex;
  gap: 1rem;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;

  &.loading {
    opacity: 0.5;
    pointer-events: none;
  }

  &__avatar {
    width: 64px;
    height: 64px;
    border-radius: 50%;
    object-fit: cover;
  }

  &__info {
    flex: 1;
  }

  &__name {
    margin: 0;
    font-size: 1.2rem;
    font-weight: 600;
  }

  &__email {
    margin: 0.25rem 0 0;
    color: #666;
  }

  &__actions {
    display: flex;
    gap: 0.5rem;
    align-items: center;
  }

  &__error {
    color: #d32f2f;
    font-size: 0.875rem;
  }
}
```

### 5. Component Types

#### Smart (Container) Components
- Connect to services
- Manage state
- Handle business logic
- Pass data to dumb components

```typescript
@Component({
  selector: 'app-user-list-container',
  template: `
    <app-user-list
      [users]="users$ | async"
      [loading]="loading$ | async"
      (userSelected)="onUserSelected($event)"
    ></app-user-list>
  `
})
export class UserListContainerComponent {
  users$ = this.userService.getUsers();
  loading$ = this.userService.loading$;

  constructor(private userService: UserService) {}

  onUserSelected(user: User): void {
    this.router.navigate(['/users', user.id]);
  }
}
```

#### Dumb (Presentational) Components
- Only @Input and @Output
- No services injected
- Pure presentation logic
- Highly reusable

```typescript
@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent {
  @Input() users: User[] = [];
  @Input() loading: boolean = false;
  @Output() userSelected = new EventEmitter<User>();

  onUserClick(user: User): void {
    this.userSelected.emit(user);
  }
}
```

### 6. Standalone Components (Angular 14+)

```typescript
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UserService } from '@services/user.service';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  providers: [UserService],
  templateUrl: './user-form.component.html'
})
export class UserFormComponent {
  // Component logic
}
```

### 7. Reactive Forms

```typescript
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './user-form.component.html'
})
export class UserFormComponent implements OnInit {
  userForm!: FormGroup;

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.userForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      age: ['', [Validators.required, Validators.min(18)]]
    });
  }

  onSubmit(): void {
    if (this.userForm.valid) {
      console.log(this.userForm.value);
    } else {
      this.userForm.markAllAsTouched();
    }
  }

  get name() { return this.userForm.get('name'); }
  get email() { return this.userForm.get('email'); }
}
```

Template:
```html
<form [formGroup]="userForm" (ngSubmit)="onSubmit()">
  <div class="form-group">
    <label for="name">Nombre</label>
    <input
      id="name"
      type="text"
      formControlName="name"
      [class.invalid]="name?.invalid && name?.touched"
    >
    <div class="error" *ngIf="name?.invalid && name?.touched">
      <span *ngIf="name?.errors?.['required']">El nombre es requerido</span>
      <span *ngIf="name?.errors?.['minlength']">Mínimo 3 caracteres</span>
    </div>
  </div>

  <button type="submit" [disabled]="userForm.invalid">
    Guardar
  </button>
</form>
```

### 8. Change Detection

```typescript
import { Component, ChangeDetectionStrategy } from '@angular/core';

@Component({
  selector: 'app-user-card',
  changeDetection: ChangeDetectionStrategy.OnPush, // Performance optimization
  templateUrl: './user-card.component.html'
})
export class UserCardComponent {
  // Component uses OnPush strategy
  // Only updates when:
  // - @Input reference changes
  // - Event handler fires
  // - Observable emits (with async pipe)
}
```

### 9. Lifecycle Hooks

```typescript
export class ComponentLifecycle implements
  OnInit,
  OnChanges,
  OnDestroy {

  ngOnChanges(changes: SimpleChanges): void {
    // Called when @Input values change
    if (changes['user']) {
      console.log('User changed:', changes['user'].currentValue);
    }
  }

  ngOnInit(): void {
    // Initialize component
    // Called once after first ngOnChanges
  }

  ngOnDestroy(): void {
    // Cleanup
    // Unsubscribe from observables
    this.subscription.unsubscribe();
  }
}
```

### 10. Services Injection

```typescript
import { Component, inject } from '@angular/core';
import { UserService } from '@services/user.service';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent {
  // Modern inject function (Angular 14+)
  private userService = inject(UserService);

  // Or traditional constructor injection
  constructor(
    private router: Router,
    private activatedRoute: ActivatedRoute
  ) {}
}
```

## Best Practices

### 1. Naming Conventions

- **Components**: PascalCase suffix with "Component"
  - `UserCardComponent`
  - `DataTableComponent`

- **Selectors**: kebab-case with prefix
  - `app-user-card`
  - `app-data-table`

- **Files**: kebab-case with suffix
  - `user-card.component.ts`
  - `user-card.component.html`

### 2. Template Syntax

```html
<!-- Property binding -->
<img [src]="imageUrl">

<!-- Event binding -->
<button (click)="onClick()">Click</button>

<!-- Two-way binding -->
<input [(ngModel)]="name">

<!-- Attribute binding -->
<button [attr.aria-label]="buttonLabel">

<!-- Class binding -->
<div [class.active]="isActive">
<div [ngClass]="{ 'active': isActive, 'disabled': isDisabled }">

<!-- Style binding -->
<div [style.color]="textColor">
<div [ngStyle]="{ 'color': textColor, 'font-size': fontSize }">
```

### 3. Pipes

```html
<!-- Built-in pipes -->
{{ date | date:'dd/MM/yyyy' }}
{{ price | currency:'USD':'symbol':'1.2-2' }}
{{ text | uppercase }}
{{ text | lowercase }}
{{ data | json }}
{{ value | async }}

<!-- Custom pipe -->
{{ phoneNumber | phone }}
```

### 4. Directives

```html
<!-- Structural directives -->
<div *ngIf="isVisible">Content</div>
<div *ngFor="let item of items; let i = index">{{ i }}: {{ item }}</div>
<div [ngSwitch]="condition">
  <div *ngSwitchCase="'A'">Case A</div>
  <div *ngSwitchCase="'B'">Case B</div>
  <div *ngSwitchDefault>Default</div>
</div>

<!-- Attribute directives -->
<input [ngModel]="value">
```

### 5. Observables and RxJS

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject, takeUntil } from 'rxjs';

export class UserComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  users: User[] = [];

  ngOnInit(): void {
    this.userService.getUsers()
      .pipe(takeUntil(this.destroy$))
      .subscribe(users => {
        this.users = users;
      });
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}

// Or use async pipe (preferred)
export class UserComponent {
  users$ = this.userService.getUsers();
}
```

```html
<div *ngFor="let user of users$ | async">
  {{ user.name }}
</div>
```

### 6. Testing

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { UserCardComponent } from './user-card.component';

describe('UserCardComponent', () => {
  let component: UserCardComponent;
  let fixture: ComponentFixture<UserCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserCardComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(UserCardComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display user name', () => {
    component.user = { id: '1', name: 'John Doe', email: 'john@example.com' };
    fixture.detectChanges();

    const compiled = fixture.nativeElement;
    expect(compiled.querySelector('.user-card__name').textContent).toContain('John Doe');
  });

  it('should emit userClick on button click', () => {
    spyOn(component.userClick, 'emit');
    component.onUserClick();
    expect(component.userClick.emit).toHaveBeenCalledWith(component.user);
  });
});
```

## Common Patterns

### Loading State

```typescript
export class DataComponent {
  isLoading = false;
  data: any[] = [];
  error: string | null = null;

  loadData(): void {
    this.isLoading = true;
    this.error = null;

    this.dataService.getData()
      .subscribe({
        next: (data) => {
          this.data = data;
          this.isLoading = false;
        },
        error: (error) => {
          this.error = error.message;
          this.isLoading = false;
        }
      });
  }
}
```

### Pagination

```typescript
export class PaginatedListComponent {
  items: any[] = [];
  page = 1;
  pageSize = 10;
  totalItems = 0;

  loadPage(page: number): void {
    this.dataService.getItems(page, this.pageSize)
      .subscribe(response => {
        this.items = response.items;
        this.totalItems = response.total;
      });
  }

  get totalPages(): number {
    return Math.ceil(this.totalItems / this.pageSize);
  }
}
```

## Accessibility

```html
<!-- Use semantic HTML -->
<button type="button" (click)="onClick()">Submit</button>

<!-- Add ARIA labels -->
<button
  type="button"
  [attr.aria-label]="'Delete user ' + user.name"
  (click)="onDelete()"
>
  <i class="icon-delete"></i>
</button>

<!-- Form labels -->
<label for="email">Email</label>
<input id="email" type="email" formControlName="email">

<!-- Focus management -->
<div role="dialog" [attr.aria-hidden]="!isOpen">
  <button autofocus>Close</button>
</div>
```

## Performance Tips

1. **Use OnPush change detection** for components with immutable inputs
2. **Use trackBy with ngFor** to optimize list rendering
3. **Lazy load modules** for better initial load time
4. **Use async pipe** to auto-unsubscribe from observables
5. **Avoid logic in templates** - move to component class
6. **Use pure pipes** for transformations

## Notes

- Follow Angular Style Guide: https://angular.io/guide/styleguide
- Use Angular CLI for scaffolding
- Prefer standalone components (Angular 14+)
- Use TypeScript strict mode
- Write unit tests for components
- Use accessibility best practices
