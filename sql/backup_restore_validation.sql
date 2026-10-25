-- MySQL Backup and Restore Validation
-- Database: database_performance_and_recovery
-- Restored verification database: recovery_test
-- Objective: Validate restored tables, row counts, and indexes.
--
-- Note: The backup and restore operations use shell commands.
-- This SQL file contains post-restore validation queries.

-- 1. Check the restored database's tables.
SHOW TABLES FROM recovery_test;

-- 2. Validate the customers row count.
SELECT COUNT(*) AS customer_count
FROM recovery_test.customers;

-- 3. Validate the orders row count.
SELECT COUNT(*) AS order_count
FROM recovery_test.orders;

-- 4. Confirm the order_items table exists and inspect its row count.
SELECT COUNT(*) AS order_item_count
FROM recovery_test.order_items;

-- 5. Verify the restored orders table definition.
SHOW CREATE TABLE recovery_test.orders;

-- 6. Verify the composite index was restored.
SHOW INDEX FROM recovery_test.orders
WHERE Key_name = 'idx_orders_status_date';

-- Recorded validation results:
-- customers: 1,000 rows
-- orders: 50,000 rows
-- order_items: 0 rows
-- idx_orders_status_date: restored
--
-- These checks validate the restored copy against the recorded
-- lab expectations. Row counts alone do not prove full data integrity.
--
-- Point-in-time recovery (PITR) through binary-log replay
-- has NOT been completed in this lab.
