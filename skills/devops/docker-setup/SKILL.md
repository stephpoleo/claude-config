---
name: docker-setup
description: Configure Docker and Docker Compose for projects
user-invocable: true
categories: [devops, docker, containerization]
version: 1.0.0
---

# Docker Setup Skill

Configure Docker and Docker Compose for projects following best practices for containerization, security, and optimization.

## Usage

```
/docker-setup <project-type> [services]
```

### Examples

```
/docker-setup web-app "node, postgres, redis"
/docker-setup api "python, mongodb"
/docker-setup fullstack "frontend, backend, database"
```

## Core Docker Files

### Dockerfile Best Practices

**Multi-stage builds:**
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**General principles:**
1. Use specific version tags (not `latest`)
2. Use alpine images when possible (smaller)
3. Leverage build cache (order matters)
4. Minimize layers (combine RUN commands)
5. Use .dockerignore
6. Don't run as root user
7. Use COPY instead of ADD
8. Clean up in same layer

### .dockerignore

```
# Dependencies
node_modules/
bower_components/

# Build outputs
dist/
build/
*.log

# Development
.git/
.gitignore
.env
.env.local
*.md
docker-compose*.yml

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Tests
coverage/
.nyc_output/
```

## Docker Compose Configuration

### Basic Structure

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: app
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://user:pass@db:5432/dbname
    depends_on:
      - db
      - redis
    networks:
      - app-network
    volumes:
      - ./logs:/app/logs

  db:
    image: postgres:15-alpine
    container_name: db
    restart: unless-stopped
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: dbname
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    networks:
      - app-network

volumes:
  postgres-data:

networks:
  app-network:
    driver: bridge
```

### Development Override

**docker-compose.override.yml:**
```yaml
version: '3.8'

services:
  app:
    build:
      target: development
    environment:
      NODE_ENV: development
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev
```

### Environment-specific Compose Files

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Testing
docker-compose -f docker-compose.yml -f docker-compose.test.yml up
```

## Common Service Configurations

### Node.js Application

```dockerfile
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM base AS development
ENV NODE_ENV=development
COPY . .
CMD ["npm", "run", "dev"]

FROM base AS production
ENV NODE_ENV=production
RUN npm ci --only=production
COPY . .
RUN npm run build
USER node
CMD ["node", "dist/index.js"]
```

### Python Application

```dockerfile
FROM python:3.11-slim AS base
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM base AS production
COPY . .
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
```

### Frontend (React/Vue/Angular)

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage with nginx
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Health Checks

### In Dockerfile

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### In Docker Compose

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
```

## Security Best Practices

### 1. Non-root User

```dockerfile
# Create user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set ownership
COPY --chown=nodejs:nodejs . .

# Switch to user
USER nodejs
```

### 2. Read-only File System

```yaml
services:
  app:
    read_only: true
    tmpfs:
      - /tmp
      - /app/.cache
```

### 3. Resource Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### 4. Secrets Management

```yaml
services:
  app:
    secrets:
      - db_password
    environment:
      DB_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

## Networking

### Internal Network (no external access)

```yaml
networks:
  internal:
    driver: bridge
    internal: true

services:
  db:
    networks:
      - internal
```

### Custom IP Addresses

```yaml
networks:
  app-network:
    ipam:
      config:
        - subnet: 172.20.0.0/16

services:
  app:
    networks:
      app-network:
        ipv4_address: 172.20.0.2
```

## Volumes and Data Persistence

### Named Volumes (recommended)

```yaml
volumes:
  postgres-data:
    driver: local

services:
  db:
    volumes:
      - postgres-data:/var/lib/postgresql/data
```

### Bind Mounts (development)

```yaml
services:
  app:
    volumes:
      - ./src:/app/src:ro  # Read-only
      - ./logs:/app/logs   # Read-write
```

### Volume Backup

```bash
# Backup
docker run --rm -v postgres-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz /data

# Restore
docker run --rm -v postgres-data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /
```

## Common Commands

### Build and Run

```bash
# Build image
docker build -t myapp:latest .

# Run container
docker run -d -p 3000:3000 --name myapp myapp:latest

# Compose up
docker-compose up -d

# Compose with specific file
docker-compose -f docker-compose.prod.yml up -d
```

### Logs and Debugging

```bash
# View logs
docker logs myapp
docker-compose logs -f app

# Execute command in container
docker exec -it myapp sh
docker-compose exec app sh

# Inspect container
docker inspect myapp
```

### Cleanup

```bash
# Stop and remove
docker-compose down

# Remove volumes too
docker-compose down -v

# Prune system
docker system prune -a
docker volume prune
```

## Production Optimization

### 1. Layer Caching

```dockerfile
# Copy dependencies first (changes less frequently)
COPY package*.json ./
RUN npm ci

# Copy source code last (changes frequently)
COPY . .
```

### 2. Minimize Image Size

```dockerfile
# Use alpine
FROM node:18-alpine

# Remove unnecessary files
RUN apk add --no-cache python3 make g++ && \
    npm ci --only=production && \
    apk del python3 make g++

# Multi-stage build
COPY --from=builder /app/dist ./dist
```

### 3. Build Arguments

```dockerfile
ARG NODE_ENV=production
ARG API_URL

ENV NODE_ENV=$NODE_ENV
ENV API_URL=$API_URL
```

```bash
docker build --build-arg NODE_ENV=production --build-arg API_URL=https://api.example.com .
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Docker Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Run tests
        run: docker run myapp:${{ github.sha }} npm test

      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
```

## Monitoring and Logging

### Logging Driver

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Integration with Monitoring Tools

```yaml
services:
  app:
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=3000"
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change port mapping
2. **Permission denied**: Check file permissions and user
3. **Cannot connect to service**: Check network configuration
4. **Out of disk space**: Run `docker system prune`
5. **Slow builds**: Optimize layer caching

### Debugging Tools

```bash
# Check container status
docker ps -a

# Check resource usage
docker stats

# Check networks
docker network ls
docker network inspect <network-name>

# Check volumes
docker volume ls
docker volume inspect <volume-name>
```

## Templates

Provide templates for:
- Dockerfile (Node.js, Python, Go, Java)
- docker-compose.yml (web app, microservices, fullstack)
- docker-compose.dev.yml
- docker-compose.prod.yml
- .dockerignore
- nginx.conf (for frontend apps)

## Checklist

Before deploying:
- [ ] Multi-stage build implemented
- [ ] Using specific image versions
- [ ] .dockerignore configured
- [ ] Running as non-root user
- [ ] Health checks configured
- [ ] Resource limits set
- [ ] Secrets not in environment variables
- [ ] Volumes for persistent data
- [ ] Logging configured
- [ ] Tested in production-like environment
