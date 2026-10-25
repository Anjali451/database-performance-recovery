# MySQL Database Performance and Recovery Lab

Hands-on MySQL experiments focused on query optimization, transaction concurrency, backup validation, and binary-log analysis.

## Environment

- MySQL 8.0.37
- InnoDB storage engine
- Windows with Ubuntu WSL2
- MySQL client, `mysqldump`, `mysqlbinlog`, and `EXPLAIN ANALYZE`

## Experiments

### 1. Composite Index Optimization
Compared query execution plans before and after adding a composite index on `order_status` and `order_date`.

- Compared full table scans with index range scans.
- Observed query completion time decrease from 83.8 ms to 52.4 ms in one test run.
- Examined optimizer cost and sorting operations.

### 2. Row-Level Locking and Transaction Concurrency
Investigated concurrent updates to the same InnoDB row using two MySQL sessions.

- Observed a blocked transaction using `SHOW FULL PROCESSLIST`.
- Tested transaction commits and lock release.
- Verified the final `order_total` after both updates.

### 3. Backup Validation and PITR Investigation
Validated a logical backup and restored the baseline into a verification database.

- Inspected the table definition and saved records.
- Generated a SHA-256 checksum.
- Investigated row-based binary-log events with `mysqlbinlog`.
- Identified the transaction associated with an accidental update.

**Status:** Backup restoration and validation are complete. Full point-in-time recovery through binary-log replay remains pending.

## Key Skills

- MySQL query optimization
- Composite indexes and execution plans
- InnoDB transactions and locking
- Logical backup and restore validation
- Binary-log analysis
- SQL troubleshooting and recovery documentation

## Detailed Documentation

See [`experiments/mysql-database-performance-and-recovery-labs.md`](experiments/mysql-database-performance-and-recovery-labs.md) for the detailed procedures, observations, and conclusions.

## Disclaimer

This repository contains personal learning experiments performed in a test environment. Performance measurements are from individual test runs and may vary across environments.
