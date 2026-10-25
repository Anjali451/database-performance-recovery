-- InnoDB Row-Level Locking
-- Database: database_performance_and_recovery
-- Objective: Observe how concurrent transactions updating the
-- same row behave when one transaction holds a lock.

USE database_performance_and_recovery;

-- 1. Confirm the table uses InnoDB.
SHOW TABLE STATUS LIKE 'orders';

-- 2. Record the initial value for the test row.
SELECT order_id, order_total
FROM orders
WHERE order_id = 100;

-- SESSION A: Run these statements in MySQL Session A.
START TRANSACTION;

UPDATE orders
SET order_total = order_total + 10
WHERE order_id = 100;

-- Leave this transaction uncommitted while testing Session B.
-- Do not run COMMIT yet.

-- SESSION B: Open a second MySQL session and run:
-- START TRANSACTION;
-- UPDATE database_performance_and_recovery.orders
-- SET order_total = order_total + 20
-- WHERE order_id = 100;
--
-- This UPDATE should wait while Session A holds the row lock.
--
-- OBSERVER SESSION: In a third session, run:
-- SHOW FULL PROCESSLIST;
--
-- Return to Session A and run:
-- COMMIT;
--
-- Session B should then proceed. In Session B, run:
-- COMMIT;
--
-- FINAL VERIFICATION: Run in either session after both commits:
SELECT order_id, order_total
FROM orders
WHERE order_id = 100;

-- Recorded lab result:
-- Initial order_total: 509.00
-- Final order_total:   539.00
-- Both updates were applied, for a total increase of 30.00.
--
-- WARNING: These UPDATE statements modify data.
-- Run only in a disposable test environment.
