---
name: sql-optimization
description: Optimize SQL queries for performance and best practices
user-invocable: true
categories: [data, sql, performance, database]
version: 1.0.0
---

# SQL Query Optimization

Optimize SQL queries following best practices for performance, readability, and maintainability.

## Usage

```
/sql-optimization <query-description>
```

### Examples

```
/sql-optimization "optimize slow join query on users and orders"
/sql-optimization "add indexes for analytics queries"
/sql-optimization "rewrite subquery as CTE for better performance"
```

## Query Optimization Techniques

### 1. Use Indexes Strategically

```sql
-- Bad: No index
SELECT * FROM orders WHERE user_id = 123;

-- Good: Create index on frequently queried columns
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Composite index for multiple columns
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

### 2. SELECT Only Required Columns

```sql
-- Bad: SELECT *
SELECT * FROM users WHERE id = 123;

-- Good: Specify columns
SELECT id, email, name FROM users WHERE id = 123;
```

### 3. Use EXISTS Instead of IN for Large Datasets

```sql
-- Bad: IN with subquery
SELECT * FROM users
WHERE id IN (SELECT user_id FROM orders WHERE total > 1000);

-- Good: EXISTS
SELECT * FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.user_id = u.id AND o.total > 1000
);
```

### 4. Use CTEs for Readability

```sql
-- Bad: Nested subqueries
SELECT *
FROM (
    SELECT user_id, SUM(total) as total_spent
    FROM orders
    WHERE status = 'completed'
    GROUP BY user_id
) AS user_totals
WHERE total_spent > 1000;

-- Good: CTE
WITH user_totals AS (
    SELECT user_id, SUM(total) as total_spent
    FROM orders
    WHERE status = 'completed'
    GROUP BY user_id
)
SELECT * FROM user_totals WHERE total_spent > 1000;
```

### 5. Avoid N+1 Queries

```sql
-- Bad: Separate queries for each user
SELECT * FROM users;
-- Then for each user:
SELECT * FROM orders WHERE user_id = ?;

-- Good: JOIN
SELECT
    u.*,
    o.id as order_id,
    o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```

### 6. Use Window Functions

```sql
-- Calculate running total
SELECT
    date,
    amount,
    SUM(amount) OVER (ORDER BY date) as running_total
FROM transactions;

-- Rank rows
SELECT
    product_id,
    sales,
    RANK() OVER (ORDER BY sales DESC) as rank
FROM product_sales;
```

### 7. Optimize JOINs

```sql
-- Use appropriate JOIN types
SELECT
    u.id,
    u.email,
    COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email;

-- Filter before joining
SELECT u.*, o.*
FROM users u
INNER JOIN (
    SELECT * FROM orders WHERE status = 'completed'
) o ON u.id = o.user_id;
```

### 8. Pagination Best Practices

```sql
-- Bad: OFFSET for large datasets
SELECT * FROM products
ORDER BY id
LIMIT 20 OFFSET 10000;  -- Slow for large offsets

-- Good: Keyset pagination
SELECT * FROM products
WHERE id > 10020
ORDER BY id
LIMIT 20;
```

### 9. Use EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT u.email, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.email;
```

## Best Practices

1. **Use appropriate data types**
2. **Normalize data properly**
3. **Create indexes on foreign keys**
4. **Use database constraints**
5. **Regular VACUUM and ANALYZE**
6. **Monitor slow queries**
7. **Use connection pooling**
8. **Avoid SELECT DISTINCT when possible**
9. **Use batch operations**
10. **Consider partitioning for large tables**
