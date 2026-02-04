# TypeScript Coding Standards

## General Principles

1. **Type Safety**: Leverage TypeScript's type system fully
2. **Explicit over Implicit**: Be explicit about types when it helps readability
3. **Avoid `any`**: Use `unknown` or proper types instead
4. **Strictness**: Enable strict mode in tsconfig.json

## Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## Type Declarations

### Interfaces vs Types

**Use `interface` for**:
- Object shapes that might be extended
- Public API definitions
- React component props

```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

interface Admin extends User {
  permissions: string[];
}
```

**Use `type` for**:
- Unions and intersections
- Mapped types
- Utility types
- Primitives and tuples

```typescript
type Status = 'idle' | 'loading' | 'success' | 'error';
type Nullable<T> = T | null;
type ReadonlyUser = Readonly<User>;
```

### Naming Conventions

```typescript
// Interfaces: PascalCase, prefixed with I if needed for clarity
interface UserProfile { }

// Types: PascalCase
type UserRole = 'admin' | 'user' | 'guest';

// Enums: PascalCase, members UPPER_CASE
enum HttpStatus {
  OK = 200,
  NOT_FOUND = 404,
  SERVER_ERROR = 500
}

// Generics: Single capital letter or PascalCase
function identity<T>(value: T): T { }
function mapValues<TValue, TResult>(/* ... */) { }
```

## Functions

### Type Annotations

```typescript
// Explicit return type (recommended for public functions)
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Implicit return type (ok for simple, internal functions)
function double(n: number) {
  return n * 2;
}

// Async functions
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

### Function Overloads

```typescript
function format(value: string): string;
function format(value: number): string;
function format(value: boolean): string;
function format(value: string | number | boolean): string {
  return String(value);
}
```

## Classes

```typescript
class UserService {
  // Private fields use # prefix
  #apiClient: ApiClient;

  // Readonly properties
  readonly baseUrl: string;

  // Constructor with parameter properties
  constructor(
    private readonly config: ServiceConfig,
    apiClient: ApiClient
  ) {
    this.#apiClient = apiClient;
    this.baseUrl = config.baseUrl;
  }

  // Public methods with explicit return types
  async getUser(id: string): Promise<User> {
    return this.#apiClient.get<User>(`/users/${id}`);
  }

  // Private methods
  private validateId(id: string): boolean {
    return id.length > 0;
  }
}
```

## Generics

```typescript
// Generic function
function firstElement<T>(arr: T[]): T | undefined {
  return arr[0];
}

// Generic interface
interface Response<T> {
  data: T;
  status: number;
  message: string;
}

// Generic constraints
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Default generic parameters
interface ApiResponse<T = unknown> {
  data: T;
  error?: string;
}
```

## Utility Types

```typescript
// Partial - all properties optional
type PartialUser = Partial<User>;

// Required - all properties required
type RequiredUser = Required<PartialUser>;

// Pick - select specific properties
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - exclude specific properties
type UserWithoutPassword = Omit<User, 'password'>;

// Record - create object type with specific keys
type UserMap = Record<string, User>;

// ReturnType - extract return type from function
type UserResult = ReturnType<typeof fetchUser>;

// Parameters - extract parameter types
type FetchUserParams = Parameters<typeof fetchUser>;
```

## Type Guards

```typescript
// Type predicate
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  );
}

// Using type guards
function processValue(value: string | number) {
  if (typeof value === 'string') {
    // value is string here
    return value.toUpperCase();
  }
  // value is number here
  return value.toFixed(2);
}
```

## Discriminated Unions

```typescript
interface SuccessResult {
  type: 'success';
  data: User;
}

interface ErrorResult {
  type: 'error';
  error: string;
}

type Result = SuccessResult | ErrorResult;

function handleResult(result: Result) {
  switch (result.type) {
    case 'success':
      console.log(result.data); // TypeScript knows result.data exists
      break;
    case 'error':
      console.error(result.error); // TypeScript knows result.error exists
      break;
  }
}
```

## Null Safety

```typescript
// Use optional chaining
const userName = user?.profile?.name;

// Nullish coalescing
const displayName = userName ?? 'Anonymous';

// Non-null assertion (use sparingly)
const element = document.getElementById('app')!;

// Better: check explicitly
const element = document.getElementById('app');
if (!element) {
  throw new Error('Element not found');
}
```

## Unknown vs Any

```typescript
// ❌ Avoid any
function processData(data: any) {
  return data.value; // No type checking
}

// ✅ Use unknown and narrow the type
function processData(data: unknown) {
  if (isValidData(data)) {
    return data.value; // Type-safe after validation
  }
  throw new Error('Invalid data');
}
```

## Const Assertions

```typescript
// Without const assertion
const colors = ['red', 'green', 'blue']; // string[]

// With const assertion
const colors = ['red', 'green', 'blue'] as const; // readonly ['red', 'green', 'blue']

// Object with const assertion
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} as const;
```

## Mapped Types

```typescript
// Make all properties optional and nullable
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

// Make all properties readonly and required
type Immutable<T> = {
  readonly [K in keyof T]-?: T[K];
};

// Transform all properties to functions
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};
```

## Template Literal Types

```typescript
type EmailEvent = 'email-sent' | 'email-failed';
type SMSEvent = 'sms-sent' | 'sms-failed';
type Event = EmailEvent | SMSEvent;

type EventHandler<T extends string> = `on${Capitalize<T>}`;
type EmailHandler = EventHandler<EmailEvent>; // 'onEmail-sent' | 'onEmail-failed'
```

## Best Practices

### 1. Prefer Union Types over Enums

```typescript
// ❌ Enum
enum Color {
  Red,
  Green,
  Blue
}

// ✅ Union type
type Color = 'red' | 'green' | 'blue';
```

### 2. Use `readonly` for Immutable Data

```typescript
interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
}

function processArray(arr: readonly number[]) {
  // arr.push(1); // Error: readonly
  return arr.map(n => n * 2); // OK
}
```

### 3. Avoid Function Overload Overuse

```typescript
// ❌ Too many overloads
function format(value: string): string;
function format(value: number): string;
function format(value: boolean): string;
function format(value: Date): string;

// ✅ Use union type
function format(value: string | number | boolean | Date): string {
  return String(value);
}
```

### 4. Use Type Inference

```typescript
// ❌ Redundant type annotation
const users: User[] = getUsers();

// ✅ Let TypeScript infer
const users = getUsers(); // Type is inferred as User[]
```

### 5. Destructure with Types

```typescript
interface Options {
  timeout: number;
  retries: number;
}

// ✅ Type entire parameter
function request({ timeout, retries }: Options) {
  // ...
}
```

### 6. Avoid Type Assertions

```typescript
// ❌ Type assertion
const user = data as User;

// ✅ Type guard
if (isUser(data)) {
  const user = data; // TypeScript knows it's User
}
```

## Common Patterns

### Result Type

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function divide(a: number, b: number): Result<number> {
  if (b === 0) {
    return { ok: false, error: new Error('Division by zero') };
  }
  return { ok: true, value: a / b };
}
```

### Builder Pattern

```typescript
class QueryBuilder {
  private query = '';

  select(fields: string[]): this {
    this.query += `SELECT ${fields.join(', ')} `;
    return this;
  }

  from(table: string): this {
    this.query += `FROM ${table} `;
    return this;
  }

  where(condition: string): this {
    this.query += `WHERE ${condition} `;
    return this;
  }

  build(): string {
    return this.query.trim();
  }
}
```

### Branded Types

```typescript
type UserId = string & { readonly __brand: 'UserId' };
type Email = string & { readonly __brand: 'Email' };

function createUserId(id: string): UserId {
  return id as UserId;
}

function sendEmail(userId: UserId, email: Email) {
  // Type-safe: can't accidentally swap parameters
}
```

## Testing

```typescript
// Type-safe test helpers
function expectType<T>(value: T): void {
  // Runtime no-op, compile-time type check
}

// Usage in tests
expectType<User>(getUserById('123'));
```

## Documentation

```typescript
/**
 * Fetches user data from the API
 * @param id - The user ID
 * @returns Promise resolving to User object
 * @throws {NotFoundError} When user doesn't exist
 */
async function fetchUser(id: string): Promise<User> {
  // ...
}
```

## Migration from JavaScript

1. Start with `allowJs: true` in tsconfig
2. Rename files gradually: `.js` → `.ts`
3. Add `// @ts-check` to JS files for partial checking
4. Use JSDoc for type hints in JS files
5. Enable strict mode incrementally
