---
name: clean-code-review
description: Review code for clean code principles and SOLID design
user-invocable: true
categories: [quality, clean-code, solid, best-practices]
version: 1.0.0
---

# Clean Code Review

Review and improve code following Clean Code principles, SOLID design, and best practices.

## Usage

```
/clean-code-review <code-description>
```

### Examples

```
/clean-code-review "refactor this function to follow single responsibility"
/clean-code-review "check this class for SOLID violations"
/clean-code-review "improve naming and reduce complexity"
```

## Clean Code Principles

### 1. Meaningful Names

```python
# Bad
def calc(x, y):
    return x * y * 0.21

# Good
def calculate_tax_amount(price: float, quantity: int) -> float:
    TAX_RATE = 0.21
    subtotal = price * quantity
    return subtotal * TAX_RATE
```

### 2. Functions Should Do One Thing

```python
# Bad: Multiple responsibilities
def process_user(data):
    # Validate
    if not data.get('email'):
        raise ValueError("Email required")

    # Save to database
    user = User.objects.create(**data)

    # Send email
    send_welcome_email(user.email)

    # Log
    logger.info(f"User created: {user.id}")

    return user

# Good: Single responsibility
def validate_user_data(data: dict) -> None:
    if not data.get('email'):
        raise ValueError("Email required")

def create_user(data: dict) -> User:
    return User.objects.create(**data)

def notify_new_user(user: User) -> None:
    send_welcome_email(user.email)
    logger.info(f"User created: {user.id}")

def process_user(data: dict) -> User:
    validate_user_data(data)
    user = create_user(data)
    notify_new_user(user)
    return user
```

### 3. Don't Repeat Yourself (DRY)

```python
# Bad: Repetition
def format_user_name(user):
    return f"{user.first_name} {user.last_name}".strip()

def format_admin_name(admin):
    return f"{admin.first_name} {admin.last_name}".strip()

# Good: Reuse
def format_full_name(person) -> str:
    return f"{person.first_name} {person.last_name}".strip()
```

### 4. Small Functions

```python
# Bad: Too long
def process_order(order_data):
    # 100+ lines of code

# Good: Decomposed
def process_order(order_data):
    validate_order(order_data)
    order = create_order(order_data)
    reserve_inventory(order)
    process_payment(order)
    send_confirmation(order)
    return order
```

### 5. Minimize Function Arguments

```python
# Bad: Too many parameters
def create_user(name, email, age, address, phone, city, country):
    pass

# Good: Use dataclass or dict
from dataclasses import dataclass

@dataclass
class UserData:
    name: str
    email: str
    age: int
    address: str
    phone: str
    city: str
    country: str

def create_user(user_data: UserData):
    pass
```

## SOLID Principles

### S - Single Responsibility Principle

```python
# Bad: Multiple responsibilities
class UserManager:
    def create_user(self, data):
        pass

    def send_email(self, user):
        pass

    def log_activity(self, message):
        pass

# Good: Separate responsibilities
class UserRepository:
    def create(self, data):
        pass

class EmailService:
    def send_welcome_email(self, user):
        pass

class ActivityLogger:
    def log(self, message):
        pass
```

### O - Open/Closed Principle

```python
# Bad: Modified for new payment types
class PaymentProcessor:
    def process(self, payment_type, amount):
        if payment_type == 'credit_card':
            # Process credit card
            pass
        elif payment_type == 'paypal':
            # Process PayPal
            pass

# Good: Open for extension, closed for modification
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def process(self, amount: float) -> bool:
        pass

class CreditCardPayment(PaymentMethod):
    def process(self, amount: float) -> bool:
        # Process credit card
        pass

class PayPalPayment(PaymentMethod):
    def process(self, amount: float) -> bool:
        # Process PayPal
        pass

class PaymentProcessor:
    def process(self, payment_method: PaymentMethod, amount: float):
        return payment_method.process(amount)
```

### L - Liskov Substitution Principle

```python
# Bad: Violates LSP
class Bird:
    def fly(self):
        pass

class Penguin(Bird):
    def fly(self):
        raise Exception("Penguins can't fly!")

# Good: Proper abstraction
class Bird:
    def move(self):
        pass

class FlyingBird(Bird):
    def fly(self):
        pass

class Penguin(Bird):
    def move(self):
        # Swim or walk
        pass
```

### I - Interface Segregation Principle

```python
# Bad: Fat interface
class Worker:
    def work(self):
        pass

    def eat(self):
        pass

    def sleep(self):
        pass

class Robot(Worker):
    def eat(self):
        raise NotImplementedError("Robots don't eat")

# Good: Segregated interfaces
class Workable(ABC):
    @abstractmethod
    def work(self):
        pass

class Eatable(ABC):
    @abstractmethod
    def eat(self):
        pass

class Human(Workable, Eatable):
    def work(self):
        pass

    def eat(self):
        pass

class Robot(Workable):
    def work(self):
        pass
```

### D - Dependency Inversion Principle

```python
# Bad: High-level depends on low-level
class EmailSender:
    def send(self, message):
        # Send email
        pass

class NotificationService:
    def __init__(self):
        self.email_sender = EmailSender()

    def notify(self, message):
        self.email_sender.send(message)

# Good: Depend on abstractions
from abc import ABC, abstractmethod

class MessageSender(ABC):
    @abstractmethod
    def send(self, message: str) -> None:
        pass

class EmailSender(MessageSender):
    def send(self, message: str) -> None:
        # Send email
        pass

class SMSSender(MessageSender):
    def send(self, message: str) -> None:
        # Send SMS
        pass

class NotificationService:
    def __init__(self, sender: MessageSender):
        self.sender = sender

    def notify(self, message: str) -> None:
        self.sender.send(message)
```

## Code Smells to Avoid

### 1. Magic Numbers

```python
# Bad
if age > 18:
    pass

# Good
LEGAL_AGE = 18
if age > LEGAL_AGE:
    pass
```

### 2. Long Parameter Lists

```python
# Bad
def create_order(user_id, product_id, quantity, price, tax, shipping, discount):
    pass

# Good
@dataclass
class OrderData:
    user_id: int
    product_id: int
    quantity: int
    price: float
    tax: float
    shipping: float
    discount: float

def create_order(order_data: OrderData):
    pass
```

### 3. Deep Nesting

```python
# Bad
def process(data):
    if data:
        if data.is_valid():
            if data.has_permission():
                if data.can_process():
                    return data.process()

# Good: Early returns
def process(data):
    if not data:
        return None

    if not data.is_valid():
        return None

    if not data.has_permission():
        return None

    if not data.can_process():
        return None

    return data.process()
```

### 4. God Classes

```python
# Bad: Does everything
class UserManager:
    def create_user(self):
        pass

    def delete_user(self):
        pass

    def send_email(self):
        pass

    def generate_report(self):
        pass

    def process_payment(self):
        pass

# Good: Separate concerns
class UserRepository:
    def create(self):
        pass

    def delete(self):
        pass

class EmailService:
    def send(self):
        pass

class ReportGenerator:
    def generate(self):
        pass

class PaymentProcessor:
    def process(self):
        pass
```

## Best Practices

### 1. Use Type Hints

```python
from typing import List, Optional, Dict

def get_user_by_id(user_id: int) -> Optional[User]:
    pass

def calculate_total(items: List[Dict[str, float]]) -> float:
    pass
```

### 2. Write Docstrings

```python
def calculate_discount(price: float, discount_rate: float) -> float:
    """
    Calculate discounted price.

    Args:
        price: Original price
        discount_rate: Discount rate (0.0 to 1.0)

    Returns:
        Discounted price

    Raises:
        ValueError: If discount_rate is invalid
    """
    if not 0 <= discount_rate <= 1:
        raise ValueError("Discount rate must be between 0 and 1")

    return price * (1 - discount_rate)
```

### 3. Handle Errors Properly

```python
# Bad
try:
    result = risky_operation()
except:
    pass

# Good
try:
    result = risky_operation()
except SpecificException as e:
    logger.error(f"Operation failed: {e}")
    raise
```

### 4. Use Context Managers

```python
# Bad
file = open('data.txt')
data = file.read()
file.close()

# Good
with open('data.txt') as file:
    data = file.read()
```

### 5. List Comprehensions (When Appropriate)

```python
# Bad
squares = []
for i in range(10):
    squares.append(i ** 2)

# Good
squares = [i ** 2 for i in range(10)]

# But don't overdo it - complex logic stays in loops
```

## Code Review Checklist

- [ ] Functions have single responsibility
- [ ] Names are meaningful and descriptive
- [ ] No magic numbers or strings
- [ ] DRY principle followed
- [ ] Functions are small (< 20 lines ideally)
- [ ] Maximum 3 parameters per function
- [ ] Type hints used
- [ ] Docstrings for public functions
- [ ] Error handling implemented
- [ ] No code duplication
- [ ] SOLID principles followed
- [ ] No deep nesting (max 3 levels)
- [ ] Constants are uppercase
- [ ] Classes have single responsibility
- [ ] Comments explain "why", not "what"
- [ ] Tests written for new code
- [ ] Code is readable without comments

## Tools

- **pylint**: Static code analysis
- **black**: Code formatter
- **mypy**: Static type checker
- **flake8**: Style guide enforcement
- **bandit**: Security linter
- **isort**: Import sorting
- **radon**: Complexity analysis
