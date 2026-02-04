---
name: test-suite
description: Create comprehensive test suites following testing best practices
user-invocable: true
categories: [testing, quality-assurance]
version: 1.0.0
---

# Test Suite Creation Skill

Create comprehensive test suites following modern testing best practices, patterns, and principles for different testing levels.

## Usage

```
/test-suite <component-or-feature> <test-type>
```

### Examples

```
/test-suite UserService unit
/test-suite LoginFlow integration
/test-suite CheckoutProcess e2e
/test-suite PaymentAPI contract
```

## Testing Pyramid

```
        /\
       /  \  E2E Tests (Few)
      /____\
     /      \
    / Integ. \ Integration Tests (Some)
   /__________\
  /            \
 /   Unit Tests \ Unit Tests (Many)
/________________\
```

Focus: Many unit tests, some integration tests, few E2E tests.

## Unit Testing

### Principles

- **Fast**: Run in milliseconds
- **Isolated**: No external dependencies
- **Repeatable**: Same result every time
- **Self-validating**: Pass or fail clearly
- **Timely**: Written before or with code (TDD)

### Structure (Arrange-Act-Assert)

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid data', () => {
      // Arrange
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      };
      const service = new UserService();

      // Act
      const result = service.createUser(userData);

      // Assert
      expect(result).toBeDefined();
      expect(result.name).toBe('John Doe');
      expect(result.email).toBe('john@example.com');
      expect(result.id).toBeDefined();
    });

    it('should throw error with invalid email', () => {
      // Arrange
      const userData = {
        name: 'John Doe',
        email: 'invalid-email'
      };
      const service = new UserService();

      // Act & Assert
      expect(() => service.createUser(userData))
        .toThrow('Invalid email format');
    });
  });
});
```

### Test Naming Convention

Pattern: `should [expected behavior] when [condition]`

```typescript
it('should return user when valid ID is provided', () => {});
it('should throw NotFoundException when user does not exist', () => {});
it('should hash password when creating user', () => {});
```

### Mocking and Stubbing

**Jest example:**
```typescript
import { UserService } from './user.service';
import { UserRepository } from './user.repository';

jest.mock('./user.repository');

describe('UserService', () => {
  let service: UserService;
  let repository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    repository = new UserRepository() as jest.Mocked<UserRepository>;
    service = new UserService(repository);
  });

  it('should fetch user from repository', async () => {
    // Arrange
    const mockUser = { id: 1, name: 'John' };
    repository.findById.mockResolvedValue(mockUser);

    // Act
    const result = await service.getUser(1);

    // Assert
    expect(repository.findById).toHaveBeenCalledWith(1);
    expect(result).toEqual(mockUser);
  });
});
```

### Test Coverage Goals

- **Statements**: > 80%
- **Branches**: > 80%
- **Functions**: > 80%
- **Lines**: > 80%

Focus on critical paths, not 100% coverage.

## Integration Testing

### Purpose

Test interaction between components, modules, or external systems.

### Database Integration Tests

```typescript
describe('UserRepository Integration', () => {
  let repository: UserRepository;
  let connection: Connection;

  beforeAll(async () => {
    // Setup test database
    connection = await createTestConnection();
    repository = new UserRepository(connection);
  });

  afterAll(async () => {
    // Cleanup
    await connection.close();
  });

  beforeEach(async () => {
    // Clean database before each test
    await connection.query('DELETE FROM users');
  });

  it('should save and retrieve user from database', async () => {
    // Arrange
    const user = { name: 'John', email: 'john@example.com' };

    // Act
    const saved = await repository.save(user);
    const retrieved = await repository.findById(saved.id);

    // Assert
    expect(retrieved).toBeDefined();
    expect(retrieved.name).toBe(user.name);
    expect(retrieved.email).toBe(user.email);
  });
});
```

### API Integration Tests

```typescript
import request from 'supertest';
import { app } from './app';

describe('POST /api/users', () => {
  it('should create user and return 201', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com'
    };

    const response = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body.data).toMatchObject({
      name: userData.name,
      email: userData.email
    });
    expect(response.body.data.id).toBeDefined();
  });

  it('should return 400 with invalid data', async () => {
    const invalidData = {
      name: '',
      email: 'invalid'
    };

    const response = await request(app)
      .post('/api/users')
      .send(invalidData)
      .expect(400);

    expect(response.body.error).toBeDefined();
  });
});
```

## E2E Testing

### Purpose

Test complete user flows from end to end.

### Playwright/Cypress Example

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Authentication Flow', () => {
  test('should allow user to login with valid credentials', async ({ page }) => {
    // Navigate to login page
    await page.goto('/login');

    // Fill form
    await page.fill('[data-testid="email-input"]', 'john@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');

    // Submit
    await page.click('[data-testid="login-button"]');

    // Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');

    // Verify user is logged in
    await expect(page.locator('[data-testid="user-menu"]'))
      .toContainText('John Doe');
  });

  test('should show error with invalid credentials', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[data-testid="email-input"]', 'wrong@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpass');
    await page.click('[data-testid="login-button"]');

    // Verify error message
    await expect(page.locator('[data-testid="error-message"]'))
      .toContainText('Invalid credentials');

    // Verify still on login page
    await expect(page).toHaveURL('/login');
  });
});
```

## Test Fixtures and Factories

### Factory Pattern

```typescript
// user.factory.ts
export class UserFactory {
  static create(overrides?: Partial<User>): User {
    return {
      id: faker.datatype.uuid(),
      name: faker.name.fullName(),
      email: faker.internet.email(),
      createdAt: new Date(),
      ...overrides
    };
  }

  static createMany(count: number, overrides?: Partial<User>): User[] {
    return Array.from({ length: count }, () => this.create(overrides));
  }
}

// Usage
const user = UserFactory.create({ email: 'specific@example.com' });
const users = UserFactory.createMany(10);
```

### Fixtures

```typescript
// fixtures/users.ts
export const testUsers = {
  admin: {
    id: 1,
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin'
  },
  regular: {
    id: 2,
    name: 'Regular User',
    email: 'user@example.com',
    role: 'user'
  }
};
```

## Test Data Management

### Database Seeding

```typescript
export class TestDataSeeder {
  async seed(connection: Connection) {
    // Clear existing data
    await this.clear(connection);

    // Seed users
    const users = await this.seedUsers(connection);

    // Seed posts (dependent on users)
    await this.seedPosts(connection, users);

    return { users };
  }

  async clear(connection: Connection) {
    await connection.query('DELETE FROM posts');
    await connection.query('DELETE FROM users');
  }

  private async seedUsers(connection: Connection) {
    const users = UserFactory.createMany(5);
    return await connection.getRepository(User).save(users);
  }
}
```

## Snapshot Testing

```typescript
import { render } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  it('should match snapshot', () => {
    const user = {
      name: 'John Doe',
      email: 'john@example.com',
      avatar: '/avatar.jpg'
    };

    const { container } = render(<UserCard user={user} />);

    expect(container.firstChild).toMatchSnapshot();
  });
});
```

## Performance Testing

```typescript
describe('Performance', () => {
  it('should process 1000 users within 100ms', () => {
    const users = UserFactory.createMany(1000);
    const start = performance.now();

    const result = processUsers(users);

    const duration = performance.now() - start;
    expect(duration).toBeLessThan(100);
  });
});
```

## Testing Async Code

### Promises

```typescript
it('should fetch user data', async () => {
  const userId = 1;
  const user = await userService.getUser(userId);

  expect(user).toBeDefined();
  expect(user.id).toBe(userId);
});
```

### Callbacks

```typescript
it('should call callback with user data', (done) => {
  userService.getUser(1, (error, user) => {
    expect(error).toBeNull();
    expect(user).toBeDefined();
    done();
  });
});
```

### Timeouts

```typescript
it('should timeout after 5 seconds', async () => {
  await expect(
    longRunningOperation()
  ).rejects.toThrow('Timeout');
}, 10000); // 10 second timeout for test
```

## Testing Error Scenarios

```typescript
describe('Error Handling', () => {
  it('should handle network errors', async () => {
    // Mock network failure
    mockAxios.get.mockRejectedValue(new Error('Network error'));

    await expect(userService.getUser(1))
      .rejects
      .toThrow('Failed to fetch user');
  });

  it('should handle validation errors', () => {
    const invalidData = { name: '', email: 'invalid' };

    expect(() => validateUser(invalidData))
      .toThrow(ValidationError);
  });

  it('should handle not found errors', async () => {
    mockRepository.findById.mockResolvedValue(null);

    await expect(userService.getUser(999))
      .rejects
      .toThrow(NotFoundException);
  });
});
```

## Test Hooks and Setup

```typescript
describe('UserService', () => {
  let service: UserService;
  let repository: MockRepository;

  // Runs once before all tests
  beforeAll(() => {
    // Setup expensive resources
  });

  // Runs before each test
  beforeEach(() => {
    repository = new MockRepository();
    service = new UserService(repository);
  });

  // Runs after each test
  afterEach(() => {
    jest.clearAllMocks();
  });

  // Runs once after all tests
  afterAll(() => {
    // Cleanup expensive resources
  });

  // Tests...
});
```

## Best Practices

### 1. Test Independence

Each test should be independent and not rely on other tests.

```typescript
// BAD - Tests depend on order
let user;
it('should create user', () => {
  user = userService.create({ name: 'John' });
});
it('should update user', () => {
  user.name = 'Jane';
  userService.update(user);
});

// GOOD - Tests are independent
it('should create user', () => {
  const user = userService.create({ name: 'John' });
  expect(user).toBeDefined();
});
it('should update user', () => {
  const user = userService.create({ name: 'John' });
  user.name = 'Jane';
  const updated = userService.update(user);
  expect(updated.name).toBe('Jane');
});
```

### 2. One Assertion Per Test (guideline)

Focus each test on one specific behavior.

```typescript
// Instead of this
it('should create and validate user', () => {
  const user = createUser(data);
  expect(user.id).toBeDefined();
  expect(user.email).toBe(data.email);
  expect(validateUser(user)).toBe(true);
});

// Split into multiple tests
it('should assign ID to created user', () => {
  const user = createUser(data);
  expect(user.id).toBeDefined();
});

it('should preserve email in created user', () => {
  const user = createUser(data);
  expect(user.email).toBe(data.email);
});

it('should create valid user', () => {
  const user = createUser(data);
  expect(validateUser(user)).toBe(true);
});
```

### 3. Descriptive Test Names

```typescript
// BAD
it('test user', () => {});
it('works', () => {});

// GOOD
it('should create user with valid data', () => {});
it('should throw ValidationError when email is invalid', () => {});
```

### 4. Test What, Not How

Test behavior, not implementation details.

```typescript
// BAD - Testing implementation
it('should call repository.save', () => {
  userService.createUser(data);
  expect(mockRepository.save).toHaveBeenCalled();
});

// GOOD - Testing behavior
it('should persist user to database', () => {
  const user = userService.createUser(data);
  const saved = repository.findById(user.id);
  expect(saved).toEqual(user);
});
```

### 5. Avoid Test Duplication

Use test utilities and helpers.

```typescript
// Helper function
function createTestUser(overrides = {}) {
  return userService.createUser({
    name: 'Test User',
    email: 'test@example.com',
    ...overrides
  });
}

// Use in multiple tests
it('should update user name', () => {
  const user = createTestUser();
  // test logic
});
```

## Testing Checklist

- [ ] Unit tests for all business logic
- [ ] Integration tests for external dependencies
- [ ] E2E tests for critical user flows
- [ ] Edge cases and error scenarios covered
- [ ] Tests are fast and independent
- [ ] Mocks used appropriately
- [ ] Test data is realistic
- [ ] Tests are maintainable and readable
- [ ] Coverage meets project standards
- [ ] CI/CD pipeline runs all tests

## Testing Anti-Patterns to Avoid

1. **Flaky tests** - Tests that sometimes pass, sometimes fail
2. **Slow tests** - Tests that take too long to run
3. **Testing implementation details** - Tests that break when refactoring
4. **No assertions** - Tests that don't verify anything
5. **Testing everything** - Over-testing trivial code
6. **Unclear test names** - Can't understand what failed
7. **Large test files** - Difficult to navigate and maintain
8. **Tight coupling** - Tests depend on specific implementation

## Tools and Frameworks

### JavaScript/TypeScript
- **Jest** - Testing framework
- **Vitest** - Fast unit test runner
- **Mocha + Chai** - Flexible testing
- **Playwright** - E2E testing
- **Cypress** - E2E testing
- **Testing Library** - React/Vue/Angular testing

### Python
- **pytest** - Testing framework
- **unittest** - Standard library
- **pytest-mock** - Mocking
- **Selenium** - E2E testing

### General
- **Faker** - Generate test data
- **MSW** - Mock service worker for API mocking
- **Testcontainers** - Docker containers for testing
