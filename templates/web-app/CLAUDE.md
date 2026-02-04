# Web Application - Project Context

## Project Overview

**Name**: [App Name]
**Type**: Web Application
**Purpose**: [What problem does this solve?]

## Tech Stack

### Frontend
- **Framework**: React / Vue / Angular
- **Language**: TypeScript
- **State Management**: Redux / Zustand / Context API
- **Styling**: CSS Modules / Tailwind / Styled Components
- **Build Tool**: Vite / Webpack

### Backend (if applicable)
- **Runtime**: Node.js
- **Framework**: Express / Fastify
- **Database**: PostgreSQL / MongoDB / MySQL
- **ORM**: Prisma / TypeORM / Mongoose

### DevOps
- **Package Manager**: npm / yarn / pnpm
- **Testing**: Jest / Vitest / Playwright
- **Linting**: ESLint + Prettier
- **CI/CD**: GitHub Actions / GitLab CI

## Project Structure

```
web-app/
├── src/
│   ├── components/      # Reusable UI components
│   ├── features/        # Feature-specific components
│   ├── hooks/           # Custom React hooks
│   ├── services/        # API services
│   ├── utils/           # Utility functions
│   ├── types/           # TypeScript types
│   └── App.tsx          # Root component
├── public/              # Static assets
├── tests/               # Test files
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── docs/                # Documentation
```

## Development Workflow

1. **Setup**:
   ```bash
   npm install
   ```

2. **Development**:
   ```bash
   npm run dev
   ```

3. **Testing**:
   ```bash
   npm test
   npm run test:e2e
   ```

4. **Build**:
   ```bash
   npm run build
   ```

5. **Deploy**:
   ```bash
   npm run deploy
   ```

## Coding Standards

### TypeScript
- Use strict mode
- Define interfaces for all props
- Avoid `any` type
- Use type inference when obvious

### Components
- One component per file
- PascalCase for component names
- Functional components with hooks
- Props destructuring

### State Management
- Minimize global state
- Use local state when possible
- Lift state only when necessary

### Styling
- Follow BEM naming for CSS classes
- Use CSS modules for component styles
- Mobile-first responsive design

### Testing
- Unit tests for utility functions
- Integration tests for features
- E2E tests for critical paths
- Aim for 80%+ code coverage

## API Integration

**Base URL**: `https://api.example.com`

### Authentication
- Bearer token in Authorization header
- Token stored in httpOnly cookie

### Endpoints
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

## Environment Variables

```env
VITE_API_URL=https://api.example.com
VITE_API_KEY=your-api-key
VITE_ENVIRONMENT=development
```

## Important Notes

- Always test on mobile devices
- Check accessibility (a11y) compliance
- Optimize images before committing
- Keep bundle size < 200KB (initial load)
- Use lazy loading for routes

## Common Tasks

### Add New Component
```bash
# Use skill
/react-component ComponentName "props description"
```

### Add New API Endpoint
```bash
# Use skill
/api-design resource-name "description"
```

### Run Tests
```bash
npm test
npm run test:coverage
```

## Troubleshooting

### Port Already in Use
```bash
# Kill process on port 3000
npx kill-port 3000
```

### Module Not Found
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Build Fails
```bash
# Type check
npm run type-check

# Lint
npm run lint
```

## Current Focus

[Describe what you're currently working on]

## Roadmap

- [ ] Feature A
- [ ] Feature B
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] E2E test coverage

## Resources

- [Design System](https://design.example.com)
- [API Documentation](https://api.example.com/docs)
- [Figma Designs](https://figma.com/...)
