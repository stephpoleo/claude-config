---
name: github-actions
description: Create CI/CD pipelines with GitHub Actions
user-invocable: true
categories: [devops, ci-cd, github, automation]
version: 1.0.0
---

# GitHub Actions CI/CD

Create complete CI/CD pipelines using GitHub Actions for automated testing, building, and deployment.

## Usage

```
/github-actions <workflow-type> <description>
```

### Examples

```
/github-actions "python django app with tests and deployment"
/github-actions "docker build and push to registry"
/github-actions "data pipeline scheduled daily"
```

## Basic Workflow Structure

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

env:
  PYTHON_VERSION: '3.11'
  NODE_VERSION: '18'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Run tests
        run: |
          pip install -r requirements.txt
          pytest
```

## Python/Django Pipeline

```yaml
name: Django CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pylint black flake8 mypy

      - name: Run Black
        run: black --check .

      - name: Run Flake8
        run: flake8 .

      - name: Run Pylint
        run: pylint **/*.py

      - name: Run MyPy
        run: mypy .

  test:
    runs-on: ubuntu-latest
    needs: lint

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    env:
      DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
      REDIS_URL: redis://localhost:6379

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov pytest-django

      - name: Run migrations
        run: python manage.py migrate

      - name: Run tests with coverage
        run: |
          pytest --cov=. --cov-report=xml --cov-report=html

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

  build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to DockerHub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/myapp:latest
            ${{ secrets.DOCKERHUB_USERNAME }}/myapp:${{ github.sha }}
          cache-from: type=registry,ref=${{ secrets.DOCKERHUB_USERNAME }}/myapp:buildcache
          cache-to: type=registry,ref=${{ secrets.DOCKERHUB_USERNAME }}/myapp:buildcache,mode=max

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Deploy to production
        run: |
          # Add deployment commands
          echo "Deploying to production..."
```

## Angular Pipeline

```yaml
name: Angular CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm run test -- --watch=false --code-coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    runs-on: ubuntu-latest
    needs: lint-and-test

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build production
        run: npm run build -- --configuration production

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: dist

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

## Data Pipeline / ML Workflow

```yaml
name: Data Pipeline

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:  # Manual trigger

jobs:
  run-pipeline:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt

      - name: Run ETL pipeline
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          python scripts/etl_pipeline.py

      - name: Validate data quality
        run: |
          python scripts/validate_data.py

      - name: Send notification
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'Pipeline execution completed'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  train-model:
    runs-on: ubuntu-latest
    needs: run-pipeline

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install ML dependencies
        run: |
          pip install -r requirements.txt
          pip install mlflow

      - name: Train model
        env:
          MLFLOW_TRACKING_URI: ${{ secrets.MLFLOW_TRACKING_URI }}
        run: |
          python scripts/train_model.py

      - name: Evaluate model
        run: |
          python scripts/evaluate_model.py

      - name: Upload model artifacts
        uses: actions/upload-artifact@v3
        with:
          name: model
          path: models/
```

## Docker Multi-Stage Build

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]
    tags:
      - 'v*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Matrix Strategy (Multiple Versions)

```yaml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ['3.9', '3.10', '3.11']
        exclude:
          - os: macos-latest
            python-version: '3.9'

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          pip install -r requirements.txt

      - name: Run tests
        run: |
          pytest
```

## Deployment Patterns

### Deploy to AWS

```yaml
deploy-aws:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Deploy to ECS
      run: |
        aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment
```

### Deploy to GCP

```yaml
deploy-gcp:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3

    - name: Authenticate to GCP
      uses: google-github-actions/auth@v1
      with:
        credentials_json: ${{ secrets.GCP_SA_KEY }}

    - name: Deploy to Cloud Run
      uses: google-github-actions/deploy-cloudrun@v1
      with:
        service: my-service
        image: gcr.io/${{ secrets.GCP_PROJECT_ID }}/my-image:latest
```

## Reusable Workflows

**`.github/workflows/reusable-test.yml`:**
```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: true
        type: string
    secrets:
      codecov-token:
        required: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ inputs.python-version }}
      - run: pytest
```

**Usage:**
```yaml
jobs:
  test-python-311:
    uses: ./.github/workflows/reusable-test.yml
    with:
      python-version: '3.11'
    secrets:
      codecov-token: ${{ secrets.CODECOV_TOKEN }}
```

## Secrets Management

### GitHub Secrets

Add in: `Settings` → `Secrets and variables` → `Actions`

Common secrets:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `GCP_SA_KEY`
- `DATABASE_URL`
- `SLACK_WEBHOOK`

### Environment Variables

```yaml
env:
  # Workflow level
  PYTHON_VERSION: '3.11'

jobs:
  test:
    env:
      # Job level
      DATABASE_URL: postgresql://localhost/test

    steps:
      - name: Test
        env:
          # Step level
          DEBUG: 'true'
        run: pytest
```

## Conditional Execution

```yaml
steps:
  - name: Run only on main
    if: github.ref == 'refs/heads/main'
    run: echo "Main branch"

  - name: Run on PR
    if: github.event_name == 'pull_request'
    run: echo "Pull request"

  - name: Run on success
    if: success()
    run: echo "Previous steps succeeded"

  - name: Always run
    if: always()
    run: echo "Runs regardless"
```

## Notifications

### Slack

```yaml
- name: Slack Notification
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment completed'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    fields: repo,message,commit,author
```

### Email

```yaml
- name: Send email
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Build failed
    to: team@example.com
    from: GitHub Actions
```

## Best Practices

1. **Use caching** to speed up workflows
2. **Fail fast** with matrix strategies
3. **Separate workflows** for different concerns
4. **Use reusable workflows** for common tasks
5. **Secure secrets** properly
6. **Add status badges** to README
7. **Use concurrency** to cancel outdated runs
8. **Monitor costs** for self-hosted runners
9. **Test workflows** in branches first
10. **Document workflows** in comments

## Status Badge

Add to README.md:
```markdown
![CI/CD](https://github.com/username/repo/actions/workflows/main.yml/badge.svg)
```

## Troubleshooting

- Check workflow logs in Actions tab
- Use `act` for local testing
- Enable debug logging: Set `ACTIONS_STEP_DEBUG` secret to `true`
- Verify secrets are set correctly
- Check permissions for GITHUB_TOKEN
