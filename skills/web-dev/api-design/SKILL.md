---
name: api-design
description: Design RESTful APIs following industry best practices
user-invocable: true
categories: [web-dev, backend, api]
version: 1.0.0
---

# API Design Skill

Design and implement RESTful APIs following industry standards, best practices, and modern conventions.

## Usage

```
/api-design <resource-name> <description>
```

### Examples

```
/api-design users "CRUD operations for user management"
/api-design posts "Blog posts with comments and likes"
/api-design orders "E-commerce order processing"
```

## RESTful Principles

### 1. Resource Naming

**Use nouns, not verbs:**
- ✓ `GET /users`
- ✗ `GET /getUsers`

**Use plural nouns for collections:**
- ✓ `GET /users`
- ✗ `GET /user`

**Use hierarchical structure for relationships:**
- ✓ `GET /users/123/posts`
- ✗ `GET /users/123/getUserPosts`

**Use kebab-case for multi-word resources:**
- ✓ `GET /order-items`
- ✗ `GET /orderItems` or `/order_items`

### 2. HTTP Methods

**GET** - Retrieve resources
```
GET /users          # List all users
GET /users/123      # Get specific user
GET /users/123/posts # Get user's posts
```

**POST** - Create new resource
```
POST /users         # Create new user
Body: { "name": "John", "email": "john@example.com" }
```

**PUT** - Update entire resource (replace)
```
PUT /users/123      # Replace user completely
Body: { "name": "John", "email": "john@example.com", "role": "admin" }
```

**PATCH** - Update partial resource
```
PATCH /users/123    # Update specific fields
Body: { "email": "newemail@example.com" }
```

**DELETE** - Remove resource
```
DELETE /users/123   # Delete user
```

### 3. Status Codes

**Success:**
- `200 OK` - Successful GET, PUT, PATCH, DELETE
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE with no response body

**Client Errors:**
- `400 Bad Request` - Invalid request format
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `422 Unprocessable Entity` - Validation errors

**Server Errors:**
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Temporary unavailability

### 4. Request/Response Format

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer <token>
Accept: application/json
```

**Successful Response:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address"
      }
    ]
  }
}
```

### 5. Pagination

**Query parameters:**
```
GET /users?page=2&limit=20
GET /users?offset=40&limit=20
```

**Response with pagination:**
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": true
  }
}
```

### 6. Filtering & Sorting

**Filtering:**
```
GET /users?role=admin
GET /users?status=active&role=admin
GET /posts?author=123&published=true
```

**Sorting:**
```
GET /users?sort=name          # Ascending
GET /users?sort=-createdAt    # Descending (- prefix)
GET /users?sort=name,-createdAt # Multiple fields
```

**Field selection:**
```
GET /users?fields=id,name,email
```

### 7. Versioning

**URI versioning (recommended):**
```
GET /api/v1/users
GET /api/v2/users
```

**Header versioning:**
```
GET /api/users
Accept: application/vnd.api+json; version=1
```

### 8. Authentication & Authorization

**Bearer Token:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**API Key:**
```
X-API-Key: your-api-key-here
```

**Auth Endpoints:**
```
POST /auth/login
POST /auth/register
POST /auth/logout
POST /auth/refresh
GET /auth/me
```

## API Endpoint Design Template

For each resource, implement these standard endpoints:

```typescript
// List all resources (with pagination, filtering, sorting)
GET /api/v1/{resource}
Query: page, limit, sort, filters
Response: 200 OK with array of resources

// Get single resource
GET /api/v1/{resource}/:id
Response: 200 OK with resource or 404 Not Found

// Create new resource
POST /api/v1/{resource}
Body: resource data
Response: 201 Created with created resource

// Update resource (full)
PUT /api/v1/{resource}/:id
Body: complete resource data
Response: 200 OK with updated resource

// Update resource (partial)
PATCH /api/v1/{resource}/:id
Body: partial resource data
Response: 200 OK with updated resource

// Delete resource
DELETE /api/v1/{resource}/:id
Response: 204 No Content or 200 OK with confirmation
```

## Advanced Patterns

### 1. Batch Operations

```
POST /api/v1/users/batch
Body: {
  "operations": [
    { "method": "POST", "data": {...} },
    { "method": "PUT", "id": 123, "data": {...} }
  ]
}
```

### 2. Search Endpoint

```
POST /api/v1/users/search
Body: {
  "query": "john",
  "filters": { "role": "admin" },
  "sort": "-createdAt",
  "pagination": { "page": 1, "limit": 20 }
}
```

### 3. Nested Resources

```
GET /api/v1/users/:userId/posts
POST /api/v1/users/:userId/posts
GET /api/v1/users/:userId/posts/:postId
```

### 4. Rate Limiting

**Response headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

**When exceeded:**
```
Status: 429 Too Many Requests
Body: {
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

## Validation Rules

### Input Validation

```typescript
// Example validation schema
interface CreateUserRequest {
  name: string;        // Required, 2-100 chars
  email: string;       // Required, valid email
  password: string;    // Required, min 8 chars
  role?: string;       // Optional, enum: [user, admin]
}
```

### Response Validation

Always validate and sanitize:
- Remove sensitive fields (passwords, tokens)
- Ensure consistent field types
- Handle null/undefined properly
- Format dates consistently (ISO 8601)

## Documentation Standards

Document each endpoint with:

```markdown
### GET /api/v1/users/:id

Get a specific user by ID.

**Parameters:**
- `id` (path, required): User ID

**Query Parameters:**
- `fields` (optional): Comma-separated list of fields to return

**Response:**
- `200 OK`: User found
- `404 Not Found`: User doesn't exist
- `401 Unauthorized`: Not authenticated

**Example Request:**
\`\`\`bash
curl -X GET "https://api.example.com/api/v1/users/123" \
  -H "Authorization: Bearer <token>"
\`\`\`

**Example Response:**
\`\`\`json
{
  "success": true,
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
\`\`\`
```

## Testing Recommendations

Test for:
- ✓ All status codes (success and error cases)
- ✓ Input validation
- ✓ Authentication/authorization
- ✓ Pagination edge cases
- ✓ Rate limiting
- ✓ Concurrent requests
- ✓ Large payloads

## Security Considerations

1. **Always validate input** - Never trust client data
2. **Use HTTPS** - Encrypt all traffic
3. **Implement rate limiting** - Prevent abuse
4. **Sanitize output** - Prevent XSS
5. **Use parameterized queries** - Prevent SQL injection
6. **Implement CORS properly** - Control access
7. **Log security events** - Monitor for attacks
8. **Keep dependencies updated** - Patch vulnerabilities

## Common Mistakes to Avoid

1. ✗ Using verbs in URLs: `/getUser`
2. ✗ Not using HTTP methods correctly
3. ✗ Inconsistent status codes
4. ✗ Exposing internal IDs or structure
5. ✗ Not versioning the API
6. ✗ Poor error messages
7. ✗ Missing pagination on large datasets
8. ✗ Not implementing rate limiting
9. ✗ Inconsistent naming conventions
10. ✗ Not documenting the API

## Tools & Standards

- **OpenAPI/Swagger** - API specification
- **Postman** - API testing
- **JSON Schema** - Validation
- **JWT** - Authentication tokens
- **OAuth 2.0** - Authorization framework

## Example Complete Resource Implementation

See the template for a complete user resource API implementation in the documentation.
