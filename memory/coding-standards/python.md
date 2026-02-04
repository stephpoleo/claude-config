# Python Coding Standards

## PEP 8 Style Guide

### Import Order

```python
# Standard library
import os
import sys
from datetime import datetime

# Third-party
import pandas as pd
import numpy as np
from django.db import models

# Local
from .models import User
from .services import UserService
```

### Naming Conventions

```python
# Classes: PascalCase
class UserService:
    pass

# Functions and variables: snake_case
def calculate_total(items):
    user_count = len(items)
    return user_count

# Constants: UPPER_SNAKE_CASE
MAX_RETRIES = 3
API_BASE_URL = "https://api.example.com"

# Private: prefix with underscore
def _internal_helper():
    pass
```

### Type Hints

```python
from typing import List, Optional, Dict, Any

def get_user(user_id: int) -> Optional[User]:
    return User.objects.filter(id=user_id).first()

def calculate_total(items: List[Dict[str, Any]]) -> float:
    return sum(item['price'] * item['quantity'] for item in items)
```

### Docstrings

```python
def calculate_discount(price: float, discount_rate: float) -> float:
    """
    Calculate discounted price.

    Args:
        price: Original price in USD
        discount_rate: Discount rate between 0.0 and 1.0

    Returns:
        Discounted price

    Raises:
        ValueError: If discount_rate is not between 0 and 1

    Examples:
        >>> calculate_discount(100, 0.2)
        80.0
    """
    if not 0 <= discount_rate <= 1:
        raise ValueError("Discount rate must be between 0 and 1")
    return price * (1 - discount_rate)
```

### List Comprehensions

```python
# Good: Simple and readable
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Bad: Too complex
result = [process(x) for x in data if validate(x) and transform(x) > threshold]

# Better: Use regular loop for complex logic
result = []
for x in data:
    if validate(x):
        transformed = transform(x)
        if transformed > threshold:
            result.append(process(x))
```

### Context Managers

```python
# File operations
with open('data.txt') as f:
    data = f.read()

# Database transactions
with transaction.atomic():
    user.save()
    profile.save()

# Custom context manager
from contextlib import contextmanager

@contextmanager
def timer(name):
    start = time.time()
    yield
    print(f"{name} took {time.time() - start:.2f}s")

with timer("Data processing"):
    process_data()
```

### Exception Handling

```python
# Be specific
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    raise
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    return None

# Use finally for cleanup
try:
    file = open('data.txt')
    process(file)
finally:
    file.close()
```

### F-strings

```python
name = "John"
age = 30

# Good
message = f"Hello, {name}. You are {age} years old."

# With expressions
print(f"Total: ${price * quantity:.2f}")

# Multiline
query = f"""
SELECT *
FROM users
WHERE age > {age}
AND name = '{name}'
"""
```

### Dataclasses

```python
from dataclasses import dataclass
from typing import List

@dataclass
class User:
    id: int
    name: str
    email: str
    is_active: bool = True

@dataclass
class Order:
    user: User
    items: List[str]
    total: float

    def __post_init__(self):
        if self.total < 0:
            raise ValueError("Total cannot be negative")
```

## Django Best Practices

### Models

```python
from django.db import models

class User(models.Model):
    email = models.EmailField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email']),
        ]

    def __str__(self):
        return self.email
```

### QuerySets

```python
# Use select_related for ForeignKey
users = User.objects.select_related('profile').all()

# Use prefetch_related for ManyToMany
users = User.objects.prefetch_related('orders').all()

# Annotate for aggregations
from django.db.models import Count
users = User.objects.annotate(order_count=Count('orders'))
```

## Testing

```python
import pytest
from django.test import TestCase

class UserServiceTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            email='test@example.com',
            username='testuser'
        )

    def test_create_user(self):
        """Test user creation."""
        user = UserService.create_user({
            'email': 'new@example.com',
            'username': 'newuser'
        })

        assert user.email == 'new@example.com'
        assert User.objects.count() == 2

    def test_invalid_email(self):
        """Test creation with invalid email."""
        with pytest.raises(ValueError):
            UserService.create_user({
                'email': 'invalid',
                'username': 'test'
            })
```

## Best Practices

1. Follow PEP 8
2. Use type hints
3. Write docstrings
4. Handle exceptions properly
5. Use context managers
6. Prefer f-strings
7. Use dataclasses for data
8. Keep functions small
9. Write tests
10. Use linters (pylint, flake8, black, mypy)
