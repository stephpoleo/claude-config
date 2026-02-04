# Full-Stack Application - Project Context

## Project Overview

**Name**: [App Name]
**Type**: Full-Stack Web Application
**Purpose**: [What problem does this solve?]
**Architecture**: Monorepo / Multi-repo

## Tech Stack

### Frontend
- **Framework**: React 18+ with TypeScript
- **State Management**: Redux Toolkit / Zustand
- **Styling**: Tailwind CSS / CSS Modules
- **Build Tool**: Vite
- **Testing**: Vitest + React Testing Library + Playwright

### Backend
- **Runtime**: Node.js 18+
- **Framework**: Express / Fastify / NestJS
- **Language**: TypeScript
- **API**: RESTful / GraphQL
- **Authentication**: JWT / Passport
- **Validation**: Zod / Joi

### Database
- **Primary**: PostgreSQL 15+
- **ORM**: Prisma / TypeORM
- **Caching**: Redis
- **Search**: Elasticsearch (if applicable)

### DevOps & Infrastructure
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions / GitLab CI
- **Hosting**: AWS / GCP / Vercel + Railway
- **Monitoring**: Sentry + LogRocket
- **Analytics**: PostHog / Mixpanel

## Project Structure

```
fullstack-app/
├── frontend/                # Frontend application
│   ├── src/
│   │   ├── components/
│   │   ├── features/
│   │   ├── hooks/
│   │   ├── services/       # API client
│   │   ├── types/
│   │   └── App.tsx
│   ├── tests/
│   └── package.json
│
├── backend/                 # Backend application
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   ├── middleware/
│   │   ├── routes/
│   │   ├── utils/
│   │   └── server.ts
│   ├── tests/
│   ├── prisma/             # Database schema
│   └── package.json
│
├── shared/                  # Shared types and utilities
│   ├── types/
│   └── utils/
│
├── docker-compose.yml       # Local development
├── docker-compose.prod.yml  # Production
└── docs/                    # Documentation
```

## Development Workflow

### Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd fullstack-app

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env

# Start database with Docker
docker-compose up -d db redis

# Run database migrations
cd backend
npm run db:migrate
npm run db:seed

# Start development servers
npm run dev  # Runs both frontend and backend
```

### Development

```bash
# Frontend only
npm run dev:frontend

# Backend only
npm run dev:backend

# Full stack with Docker
docker-compose up
```

### Testing

```bash
# Run all tests
npm test

# Frontend tests
npm run test:frontend

# Backend tests
npm run test:backend

# E2E tests
npm run test:e2e

# Coverage
npm run test:coverage
```

### Building

```bash
# Build all
npm run build

# Frontend only
npm run build:frontend

# Backend only
npm run build:backend
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255),
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Migrations
```bash
# Create migration
npm run db:migrate:create

# Run migrations
npm run db:migrate

# Rollback
npm run db:migrate:rollback

# Reset database
npm run db:reset
```

## API Documentation

### Base URL
- **Development**: `http://localhost:3000/api`
- **Production**: `https://api.example.com`

### Authentication

All authenticated endpoints require:
```
Authorization: Bearer <jwt-token>
```

### Endpoints

#### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user
- `POST /api/auth/refresh` - Refresh token

#### Users
- `GET /api/users` - List users (admin)
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user (admin)

#### [Add more resources here]

## Environment Variables

### Frontend (.env)
```env
VITE_API_URL=http://localhost:3000
VITE_ENVIRONMENT=development
```

### Backend (.env)
```env
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# External APIs
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-password
```

## Coding Standards

### General
- Use TypeScript strict mode
- Follow ESLint + Prettier configuration
- Write self-documenting code
- Add comments for complex logic
- Keep functions small and focused

### Frontend
- Functional components with hooks
- Props interfaces for all components
- Use custom hooks for reusable logic
- Memoize expensive computations
- Lazy load routes and components

### Backend
- Controller -> Service -> Repository pattern
- Input validation on all endpoints
- Error handling middleware
- Request logging
- Rate limiting on public endpoints

### Database
- Use transactions for multi-step operations
- Index frequently queried columns
- Avoid N+1 queries
- Use prepared statements (ORM handles this)

### Testing
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Mock external dependencies
- Aim for 80%+ coverage

## Security Best Practices

- [ ] Sanitize all user inputs
- [ ] Use parameterized queries (ORM)
- [ ] Hash passwords with bcrypt
- [ ] Implement rate limiting
- [ ] Use HTTPS in production
- [ ] Set secure HTTP headers
- [ ] Validate JWTs properly
- [ ] Don't expose error details in production
- [ ] Keep dependencies updated
- [ ] Use environment variables for secrets

## Performance Optimization

### Frontend
- Code splitting by route
- Lazy load images
- Optimize bundle size
- Use CDN for static assets
- Implement service worker (PWA)

### Backend
- Database query optimization
- Implement caching (Redis)
- Use database indexes
- Pagination for large datasets
- Connection pooling

## Docker Configuration

### Development
```bash
docker-compose up
```

### Production
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Services
- `frontend` - React application (port 3001)
- `backend` - Express API (port 3000)
- `db` - PostgreSQL database (port 5432)
- `redis` - Redis cache (port 6379)

## Deployment

### Frontend (Vercel)
```bash
vercel --prod
```

### Backend (Railway/Render)
```bash
git push railway main
```

### Database Migrations
```bash
# Run on production
npm run db:migrate:prod
```

## Monitoring & Logging

### Error Tracking
- Sentry for error monitoring
- LogRocket for session replay

### Analytics
- PostHog for product analytics
- Google Analytics for web analytics

### Logs
```bash
# View logs
docker-compose logs -f backend

# View specific service
docker-compose logs -f db
```

## Common Tasks

### Add New Feature
1. Create branch: `git checkout -b feature/feature-name`
2. Frontend: Create components in `frontend/src/features/`
3. Backend: Create controller, service, routes
4. Database: Create migration if needed
5. Tests: Add unit + integration tests
6. PR: Create pull request

### Add New API Endpoint

Use the API design skill:
```
/api-design resource-name "description"
```

### Add New Component

Use the React component skill:
```
/react-component ComponentName "props description"
```

## Troubleshooting

### Database Connection Issues
```bash
# Check if DB is running
docker-compose ps

# Restart database
docker-compose restart db

# Check logs
docker-compose logs db
```

### Port Already in Use
```bash
# Kill process
npx kill-port 3000
npx kill-port 3001
```

### Docker Issues
```bash
# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up
```

## Current Focus

[What you're currently working on]

## Roadmap

### MVP (Phase 1)
- [ ] User authentication
- [ ] Basic CRUD operations
- [ ] Frontend UI components
- [ ] Database setup

### Phase 2
- [ ] Advanced features
- [ ] Real-time updates (WebSocket)
- [ ] Email notifications
- [ ] File uploads

### Phase 3
- [ ] Admin dashboard
- [ ] Analytics
- [ ] Performance optimization
- [ ] Mobile app (React Native)

## Team

- **Frontend Lead**: [Name]
- **Backend Lead**: [Name]
- **DevOps**: [Name]

## Resources

- [API Documentation](https://api.example.com/docs)
- [Design System](https://design.example.com)
- [Database Schema](./docs/schema.md)
- [Architecture Diagrams](./docs/architecture.md)
