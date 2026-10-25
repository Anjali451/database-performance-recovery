Composite Index Optimization
-- Database: database_performance_and_recovery
-- Table: orders
-- Objective: Compare query execution plans before and after indexing.

USE database_performance_and_recovery;

-- 1. Check the table row count.
SELECT COUNT(*) AS total_orders
FROM orders;

-- 2. Inspect existing indexes.
SHOW INDEX FROM orders;

-- 3. Analyze the query plan before indexing.
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_status = 'COMPLETED'
  AND order_date >= '2026-01-01'
ORDER BY order_date;

-- 4. Create a composite index.
CREATE INDEX idx_orders_status_date
ON orders (order_status, order_date);

-- 5. Refresh table statistics.
ANALYZE TABLE orders;

-- 6. Analyze the query plan after indexing.
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_status = 'COMPLETED'
  AND order_date >= '2026-01-01'
ORDER BY order_date;

-- 7. Verify the index exists.
SHOW INDEX FROM orders;

-- Recorded observation from the lab:
-- Before: 50,000 rows scanned; 3,350 rows returned;
--         final operator completion time 83.8 ms.
-- After:  index range scan; 3,350 rows returned;
--         final operator completion time 52.4 ms.
-- One-run observed reduction: approximately 37.5%.
--
-- Note: EXPLAIN ANALYZE timings vary between runs.
-- Run CREATE INDEX only if the index does not already exist.
