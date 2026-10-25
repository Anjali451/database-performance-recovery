# MySQL Database Performance and Recovery

A hands-on lab exploring query optimization, transaction concurrency, logical backup and restore validation, and binary-log investigation using MySQL.

## Environment

- Database: MySQL 8.0.37
- Operating system: Windows with Ubuntu WSL2
- Storage engine: InnoDB
- Database: `database_performance_and_recovery`
- Tools: MySQL client, `mysqldump`, `mysqlbinlog`, `EXPLAIN ANALYZE`

---

## Composite Index Optimization

### Objective

Investigate a query filtering orders by status and date, then compare execution plans before and after creating a composite index.

### Test Environment

- Table: `orders`
- Total rows: 50,000
- Query filters: `order_status = 'COMPLETED'` and `order_date >= '2026-01-01'`
- Index: `idx_orders_status_date (order_status, order_date)`

### Before Indexing

- Access method: Full table scan
- Rows scanned: 50,000
- Rows returned: 3,350
- Final operator completion time: 83.8 ms
- Separate sorting operation: Present

### After Indexing

- Access method: Index range scan
- Rows returned: 3,350
- Final operator completion time: 52.4 ms
- Separate sorting operation: Not shown in the reported plan
- Optimizer estimated cost: Reduced from 5,075 to 1,508

### Observed Result

The reported completion time decreased by approximately 37.5% in this test run. The indexed plan accessed the matching range through the composite index and avoided a separate sorting operator.

### Conclusion

A composite index aligned with the query's equality and range predicates improved the observed execution plan. Additional repeated tests are needed to quantify performance consistently. Index maintenance overhead should also be considered.

**Skills practiced:** Composite indexing, query optimization, execution plan analysis, `EXPLAIN ANALYZE`, and performance comparison.

---

## MySQL Row-Level Locking and Transaction Concurrency

### Objective

Observe how InnoDB handles concurrent updates to the same row and investigate transaction lock waits.

### Test Environment

- Table: `orders`
- Test row: `order_id = 100`
- Storage engine: InnoDB
- Sessions: Two concurrent MySQL sessions

### Procedure

1. Started a transaction in Session A and increased `order_total` by 10.
2. Left Session A uncommitted, retaining its row lock.
3. Started a transaction in Session B and attempted to increase the same row's `order_total` by 20.
4. Observed Session B waiting in `SHOW FULL PROCESSLIST`.
5. Committed Session A, allowing Session B's update to proceed.
6. Committed Session B and verified the final value.

### Observed Result

| Measurement | Value |
|---|---:|
| Initial `order_total` | 509.00 |
| Session A update | +10.00 |
| Session B update | +20.00 |
| Final `order_total` | 539.00 |
| Total increase | 30.00 |

### Conclusion

InnoDB row-level locking prevented the conflicting updates from proceeding concurrently. Session B waited until Session A committed and released its lock. Both updates then completed, resulting in a final value of 539.00.

**Skills practiced:** InnoDB transactions, concurrent updates, lock-wait investigation, and transaction commit behavior.

---

## MySQL Backup Validation and PITR Investigation

### Objective

Validate a logical backup, restore it into a verification database, and inspect binary logs to identify an accidental update and its transaction boundary.

### Test Environment

- MySQL: 8.0.37
- Storage engine: InnoDB
- Binary logging: Enabled
- Binary log format: `ROW`
- Binary log: `ANJALI_SINHA-bin.000170`
- Recovery target: `pitr_recovery_verify`
- Baseline backup: `pitr_recovery_baseline.sql`

### Backup Validation

Inspected the SQL dump to confirm that the `pitr_demo` table definition and expected data were present. Checked the dump completion marker and generated a SHA-256 checksum.

```text
02129aceeada9fa898fd5a0c8e3767a539c403966e6493e48243da7c31e88cb1
```

A checksum can help detect file changes when compared with a later checksum; it does not independently prove restorability.

### Restore and Validation

Restored the baseline SQL file into `pitr_recovery_verify` and validated the table:

```sql
SHOW CREATE TABLE pitr_recovery_verify.pitr_demo;

SELECT COUNT(*) AS total_rows
FROM pitr_recovery_verify.pitr_demo;

SELECT *
FROM pitr_recovery_verify.pitr_demo
ORDER BY id;
```

**Observed results:**

- Table schema verified.
- Storage engine: InnoDB.
- Primary key: `id`.
- Total rows: 3.
- All expected records were present.
- Row 3 retained its original value: `Row to simulate accidental change`.

### Binary Log Investigation

Used `mysqlbinlog` with row-event decoding to investigate an accidental update to `pitr_recovery.pitr_demo`.

| Field | Before | After |
|---|---|---|
| `id` | 3 | 3 |
| `note` | `Row to simulate accidental change` | `PITR lab: accidental update` |

Identified transaction boundaries:

| Event | Binary log position |
|---|---:|
| Transaction start | 5008872 |
| Table-map event end | 5009116 |
| Update-rows event end | 5009226 |
| Transaction commit | 5009257 |

The decoded event identified the affected record, its old and new values, and the transaction's commit position.

### Conclusion

The baseline backup was inspected and restored successfully, and the relevant binary-log transaction was identified. However, **a complete point-in-time recovery using binary-log replay has not yet been performed**.

This experiment demonstrates logical backup restoration and validation, plus binary-log investigation. It should not yet be described as a completed end-to-end PITR operation.

**Skills practiced:** Logical backup validation, restore testing, checksum generation, schema verification, `mysqlbinlog`, row-based event decoding, transaction boundary identification, and recovery-point analysis.

---

## Overall Learning Outcomes

- **Performance tuning:** Analyzed query execution plans and evaluated composite indexes.
- **Transaction management:** Investigated row-level locks, concurrency, and blocked updates.
- **Backup and recovery:** Validated logical backups and restored data into a verification database.
- **Binary-log analysis:** Identified row changes and transaction boundaries with `mysqlbinlog`.
- **Recovery validation:** Verified restored schemas, row counts, and expected values.
- **Documentation:** Recorded test conditions, observations, results, and limitations.

## Future Improvements

- Repeat performance tests to assess consistency.
- Investigate deadlocks and lock timeouts.
- Complete an end-to-end PITR exercise using a verified backup position and carefully selected binary-log replay boundary.
- Document recovery time and data-loss objectives.

## Disclaimer

These experiments were performed in a personal test environment. Performance measurements represent individual test runs and may vary across environments.
