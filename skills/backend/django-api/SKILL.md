---
name: django-api
description: Create Django REST APIs following best practices and clean architecture
user-invocable: true
categories: [backend, django, api, python]
version: 1.0.0
---

# Django REST API Creation

Create RESTful APIs with Django and Django REST Framework following best practices, clean code principles, and SOLID design.

## Usage

```
/django-api <resource-name> <description>
```

### Examples

```
/django-api users "CRUD operations for user management"
/django-api orders "E-commerce order processing with status tracking"
/django-api analytics "Data analytics endpoints with aggregations"
```

## Project Structure

```
project/
├── manage.py
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   └── users/
│       ├── __init__.py
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       ├── services.py
│       ├── selectors.py
│       ├── tests/
│       └── migrations/
└── requirements/
    ├── base.txt
    ├── development.txt
    └── production.txt
```

## 1. Models (models.py)

### Clean Model Definition

```python
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils.translation import gettext_lazy as _


class TimestampedModel(models.Model):
    """Abstract base model with creation and update timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class User(AbstractUser, TimestampedModel):
    """Custom user model."""
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    is_verified = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']

    def __str__(self):
        return self.email


class Order(TimestampedModel):
    """Order model with status tracking."""

    class Status(models.TextChoices):
        PENDING = 'pending', _('Pending')
        PROCESSING = 'processing', _('Processing')
        COMPLETED = 'completed', _('Completed')
        CANCELLED = 'cancelled', _('Cancelled')

    user = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name='orders'
    )
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING
    )
    total = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0)]
    )
    notes = models.TextField(blank=True)

    class Meta:
        db_table = 'orders'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"Order #{self.id} - {self.user.email}"

    @property
    def is_modifiable(self):
        """Check if order can be modified."""
        return self.status in [self.Status.PENDING, self.Status.PROCESSING]
```

## 2. Serializers (serializers.py)

### DRF Serializers

```python
from rest_framework import serializers
from .models import User, Order


class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model."""
    full_name = serializers.SerializerMethodField()
    orders_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username',
            'full_name',
            'phone',
            'is_verified',
            'orders_count',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at', 'is_verified']

    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}".strip()


class UserCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating users."""
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'password_confirm', 'first_name', 'last_name']

    def validate(self, data):
        if data['password'] != data['password_confirm']:
            raise serializers.ValidationError(
                {"password": "Passwords do not match"}
            )
        return data

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        return user


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for Order model."""
    user_email = serializers.EmailField(source='user.email', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id',
            'user',
            'user_email',
            'status',
            'status_display',
            'total',
            'notes',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def validate_total(self, value):
        if value <= 0:
            raise serializers.ValidationError("Total must be greater than 0")
        return value


class OrderListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list view."""
    user_email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'user_email', 'status', 'total', 'created_at']
```

## 3. Views (views.py)

### Class-Based Views with ViewSets

```python
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Count, Q

from .models import User, Order
from .serializers import (
    UserSerializer,
    UserCreateSerializer,
    OrderSerializer,
    OrderListSerializer
)
from .services import OrderService
from .selectors import OrderSelector


class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for User CRUD operations.

    list: Get all users (admin only)
    retrieve: Get user by ID
    create: Register new user
    update: Update user
    destroy: Delete user (admin only)
    """
    queryset = User.objects.all()
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['email', 'username', 'first_name', 'last_name']
    ordering_fields = ['created_at', 'email']
    ordering = ['-created_at']

    def get_queryset(self):
        """Filter queryset based on user permissions."""
        queryset = super().get_queryset()

        if not self.request.user.is_staff:
            # Regular users can only see themselves
            queryset = queryset.filter(id=self.request.user.id)

        # Annotate with orders count
        queryset = queryset.annotate(orders_count=Count('orders'))

        return queryset

    def get_serializer_class(self):
        """Return appropriate serializer class."""
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer

    def get_permissions(self):
        """Set permissions based on action."""
        if self.action in ['list', 'destroy']:
            permission_classes = [IsAdminUser]
        elif self.action == 'create':
            permission_classes = []  # Allow registration
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]

    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get current user profile."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def verify(self, request, pk=None):
        """Verify user (admin only)."""
        user = self.get_object()
        user.is_verified = True
        user.save()
        return Response({'status': 'user verified'})


class OrderViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Order CRUD operations.
    """
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'user']
    ordering_fields = ['created_at', 'total']
    ordering = ['-created_at']

    def get_queryset(self):
        """Filter queryset based on user permissions."""
        if self.request.user.is_staff:
            return Order.objects.select_related('user').all()
        return Order.objects.filter(user=self.request.user).select_related('user')

    def get_serializer_class(self):
        """Return appropriate serializer class."""
        if self.action == 'list':
            return OrderListSerializer
        return OrderSerializer

    def perform_create(self, serializer):
        """Create order with current user."""
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel order."""
        order = self.get_object()

        try:
            OrderService.cancel_order(order)
            return Response({'status': 'order cancelled'})
        except ValueError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get order statistics."""
        stats = OrderSelector.get_user_statistics(request.user)
        return Response(stats)
```

## 4. Services (services.py)

Business logic layer following Clean Architecture:

```python
from django.db import transaction
from django.utils import timezone
from .models import Order


class OrderService:
    """Service layer for Order business logic."""

    @staticmethod
    @transaction.atomic
    def create_order(user, items, notes=''):
        """
        Create new order with items.

        Args:
            user: User instance
            items: List of items
            notes: Optional notes

        Returns:
            Order instance

        Raises:
            ValueError: If validation fails
        """
        # Validate items
        if not items:
            raise ValueError("Order must have at least one item")

        # Calculate total
        total = sum(item['price'] * item['quantity'] for item in items)

        # Create order
        order = Order.objects.create(
            user=user,
            total=total,
            notes=notes
        )

        # Create order items (assuming OrderItem model exists)
        # OrderItem.objects.bulk_create([...])

        return order

    @staticmethod
    @transaction.atomic
    def cancel_order(order):
        """
        Cancel an order.

        Args:
            order: Order instance

        Raises:
            ValueError: If order cannot be cancelled
        """
        if not order.is_modifiable:
            raise ValueError("Order cannot be cancelled in current status")

        order.status = Order.Status.CANCELLED
        order.save(update_fields=['status', 'updated_at'])

    @staticmethod
    @transaction.atomic
    def update_order_status(order, new_status):
        """Update order status with validation."""
        valid_transitions = {
            Order.Status.PENDING: [Order.Status.PROCESSING, Order.Status.CANCELLED],
            Order.Status.PROCESSING: [Order.Status.COMPLETED, Order.Status.CANCELLED],
        }

        if new_status not in valid_transitions.get(order.status, []):
            raise ValueError(f"Invalid status transition from {order.status} to {new_status}")

        order.status = new_status
        order.save(update_fields=['status', 'updated_at'])
```

## 5. Selectors (selectors.py)

Query layer for complex data retrieval:

```python
from django.db.models import Sum, Count, Avg, Q
from django.utils import timezone
from datetime import timedelta
from .models import Order


class OrderSelector:
    """Selector layer for Order queries."""

    @staticmethod
    def get_user_orders(user, status=None):
        """Get user orders with optional status filter."""
        queryset = Order.objects.filter(user=user).select_related('user')

        if status:
            queryset = queryset.filter(status=status)

        return queryset.order_by('-created_at')

    @staticmethod
    def get_user_statistics(user):
        """Get order statistics for user."""
        stats = Order.objects.filter(user=user).aggregate(
            total_orders=Count('id'),
            total_spent=Sum('total'),
            average_order=Avg('total'),
            pending_orders=Count('id', filter=Q(status=Order.Status.PENDING))
        )
        return stats

    @staticmethod
    def get_recent_orders(days=30):
        """Get orders from last N days."""
        cutoff_date = timezone.now() - timedelta(days=days)
        return Order.objects.filter(
            created_at__gte=cutoff_date
        ).select_related('user').order_by('-created_at')

    @staticmethod
    def get_orders_by_date_range(start_date, end_date):
        """Get orders within date range."""
        return Order.objects.filter(
            created_at__date__range=[start_date, end_date]
        ).select_related('user')
```

## 6. URLs (urls.py)

```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, OrderViewSet

app_name = 'users'

router = DefaultRouter()
router.register('users', UserViewSet, basename='user')
router.register('orders', OrderViewSet, basename='order')

urlpatterns = [
    path('', include(router.urls)),
]
```

## 7. Permissions

```python
from rest_framework import permissions


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to only allow owners or admins to edit.
    """

    def has_object_permission(self, request, view, obj):
        # Read permissions for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True

        # Write permissions for owner or admin
        return obj.user == request.user or request.user.is_staff


class IsVerifiedUser(permissions.BasePermission):
    """Only allow verified users."""

    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated and request.user.is_verified
```

## 8. Testing

```python
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from django.urls import reverse
from .models import User, Order


class UserAPITest(APITestCase):
    """Test User API endpoints."""

    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='testpass123'
        )

    def test_create_user(self):
        """Test user creation."""
        url = reverse('users:user-list')
        data = {
            'email': 'newuser@example.com',
            'username': 'newuser',
            'password': 'newpass123',
            'password_confirm': 'newpass123'
        }
        response = self.client.post(url, data)

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 2)

    def test_list_users_requires_auth(self):
        """Test that listing users requires authentication."""
        url = reverse('users:user-list')
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_get_current_user(self):
        """Test getting current user profile."""
        self.client.force_authenticate(user=self.user)
        url = reverse('users:user-me')
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['email'], self.user.email)
```

## Best Practices

### 1. Use Django REST Framework

```bash
pip install djangorestframework django-filter
```

### 2. Separate Business Logic

- **Models**: Data structure only
- **Serializers**: Data validation and transformation
- **Services**: Business logic
- **Selectors**: Complex queries
- **Views**: HTTP handling

### 3. Use Transactions

```python
from django.db import transaction

@transaction.atomic
def create_order_with_items(data):
    order = Order.objects.create(...)
    OrderItem.objects.bulk_create([...])
    return order
```

### 4. Optimize Queries

```python
# Use select_related for ForeignKey
Order.objects.select_related('user')

# Use prefetch_related for Many-to-Many
Order.objects.prefetch_related('items')

# Annotate for aggregations
User.objects.annotate(order_count=Count('orders'))
```

### 5. Pagination

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20
}
```

### 6. API Versioning

```python
# urls.py
urlpatterns = [
    path('api/v1/', include('apps.users.urls')),
    path('api/v2/', include('apps.users.v2.urls')),
]
```

### 7. Error Handling

```python
from rest_framework.views import exception_handler
from rest_framework.response import Response

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        response.data = {
            'error': {
                'status_code': response.status_code,
                'message': response.data
            }
        }

    return response
```

## Documentation

Use drf-spectacular for OpenAPI documentation:

```python
# settings.py
INSTALLED_APPS = [
    ...
    'drf_spectacular',
]

REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# urls.py
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]
```

## Notes

- Follow Django coding style and PEP 8
- Use type hints for better code quality
- Write comprehensive tests
- Document API endpoints
- Use environment variables for secrets
- Implement proper error handling
- Log important operations
- Use database indexes for frequently queried fields
