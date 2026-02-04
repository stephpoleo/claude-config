# Clean Code Principles & SOLID

## Clean Code Fundamentals

### Meaningful Names

```python
# Bad
def calc(x, y, z):
    return x * y * z

# Good
def calculate_total_price(unit_price: float, quantity: int, tax_rate: float) -> float:
    return unit_price * quantity * tax_rate
```

### Functions Should Do One Thing

```python
# Bad
def process_user(data):
    # Validates
    # Saves to database
    # Sends email
    # Logs activity
    pass

# Good
def validate_user_data(data): pass
def save_user(data): pass
def send_welcome_email(user): pass
def log_user_creation(user): pass

def process_user(data):
    validate_user_data(data)
    user = save_user(data)
    send_welcome_email(user)
    log_user_creation(user)
    return user
```

### DRY (Don't Repeat Yourself)

```python
# Bad
def calculate_discount_for_vip(price):
    return price * 0.8

def calculate_discount_for_regular(price):
    return price * 0.9

# Good
def calculate_discount(price: float, discount_rate: float) -> float:
    return price * (1 - discount_rate)

VIP_DISCOUNT = 0.2
REGULAR_DISCOUNT = 0.1
```

## SOLID Principles

### S - Single Responsibility Principle

One class should have one reason to change.

```python
# Bad
class User:
    def save(self): pass
    def send_email(self): pass
    def generate_report(self): pass

# Good
class User:
    def __init__(self, data): pass

class UserRepository:
    def save(self, user): pass

class EmailService:
    def send_welcome(self, user): pass

class ReportGenerator:
    def generate_user_report(self, user): pass
```

### O - Open/Closed Principle

Open for extension, closed for modification.

```python
# Bad
class PaymentProcessor:
    def process(self, payment_type, amount):
        if payment_type == 'credit_card':
            # Process credit card
            pass
        elif payment_type == 'paypal':
            # Process PayPal
            pass

# Good
from abc import ABC, abstractmethod

class PaymentMethod(ABC):
    @abstractmethod
    def process(self, amount: float) -> bool:
        pass

class CreditCardPayment(PaymentMethod):
    def process(self, amount: float) -> bool:
        # Implementation
        pass

class PayPalPayment(PaymentMethod):
    def process(self, amount: float) -> bool:
        # Implementation
        pass

class PaymentProcessor:
    def process(self, payment: PaymentMethod, amount: float):
        return payment.process(amount)
```

### L - Liskov Substitution Principle

Subtypes must be substitutable for their base types.

```python
# Bad
class Rectangle:
    def set_width(self, width): self.width = width
    def set_height(self, height): self.height = height

class Square(Rectangle):
    def set_width(self, width):
        self.width = width
        self.height = width  # Violates LSP

# Good
class Shape:
    def area(self): pass

class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height

class Square(Shape):
    def __init__(self, side):
        self.side = side

    def area(self):
        return self.side ** 2
```

### I - Interface Segregation Principle

Clients shouldn't depend on interfaces they don't use.

```python
# Bad
class Worker:
    def work(self): pass
    def eat(self): pass
    def sleep(self): pass

class Robot(Worker):
    def eat(self):
        raise NotImplementedError("Robots don't eat")

# Good
class Workable:
    def work(self): pass

class Eatable:
    def eat(self): pass

class Human(Workable, Eatable):
    def work(self): pass
    def eat(self): pass

class Robot(Workable):
    def work(self): pass
```

### D - Dependency Inversion Principle

Depend on abstractions, not concretions.

```python
# Bad
class EmailSender:
    def send(self, message): pass

class NotificationService:
    def __init__(self):
        self.sender = EmailSender()

# Good
from abc import ABC, abstractmethod

class MessageSender(ABC):
    @abstractmethod
    def send(self, message): pass

class EmailSender(MessageSender):
    def send(self, message): pass

class SMSSender(MessageSender):
    def send(self, message): pass

class NotificationService:
    def __init__(self, sender: MessageSender):
        self.sender = sender
```

## Code Smells

### Magic Numbers
```python
# Bad
if age > 18: pass

# Good
LEGAL_AGE = 18
if age > LEGAL_AGE: pass
```

### Long Functions
```python
# Keep functions under 20 lines
# Extract complex logic into helper functions
```

### Deep Nesting
```python
# Bad
if a:
    if b:
        if c:
            if d:
                do_something()

# Good: Early returns
if not a: return
if not b: return
if not c: return
if not d: return
do_something()
```

### God Classes
```python
# Split large classes into focused ones
# Follow Single Responsibility Principle
```

## Best Practices

1. **Meaningful Names**: Clear, descriptive
2. **Small Functions**: < 20 lines
3. **Few Arguments**: ≤ 3 parameters
4. **No Side Effects**: Functions do what they say
5. **Error Handling**: Don't ignore errors
6. **Tests**: Write tests first (TDD)
7. **Comments**: Explain "why", not "what"
8. **Formatting**: Consistent style
9. **Refactor**: Continuously improve
10. **YAGNI**: You Ain't Gonna Need It
