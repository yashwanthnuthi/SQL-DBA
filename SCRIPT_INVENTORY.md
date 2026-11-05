# Master SQL Server DBA Script Inventory

Status legend: **Planned** = not yet implemented; **Draft** = under development; **Validated** = tested in a stated environment.

| ID | Domain | Proposed item | Status | File |
|---|---|---|---|---|
| DBA-001 | Administration | Database inventory | Planned | TBD |
| DBA-002 | Performance | Wait statistics analysis | Planned | TBD |
| DBA-003 | Performance | Blocking chain detection | Planned | TBD |
| DBA-004 | Performance | Deadlock investigation | Planned | TBD |
| DBA-005 | High Availability | Always On AG health monitoring | Planned | TBD |
| DBA-006 | High Availability | Replica synchronization troubleshooting | Planned | TBD |
| DBA-007 | Replication | Transactional replication monitoring | Planned | TBD |
| DBA-008 | Automation | PowerShell SQL Server health checks | Planned | TBD |
| DBA-009 | Engineering | SQL performance monitoring agent | Planned | TBD |
| DBA-010 | Engineering | Delphix monitoring and reporting | Planned | TBD |

Inventory entries are planning placeholders, not claims of completed work.

## Template for new entries

- **ID:** DBA-XXX
- **Title:**
- **Domain:**
- **Problem solved:**
- **Script path:**
- **Engine/version:**
- **Prerequisites and permissions:**
- **Execution instructions:**
- **Expected output:**
- **Operational risks:**
- **Testing evidence:**
- **Status:** Planned / Draft / Validated

## Query Tuning DMV Workflow (Draft; not SQL Server tested)

| ID | Domain | Item | Status | File |
|---|---|---|---|---|
| DBA-011 | Performance | Top 10 expensive cached statements | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/01-top-expensive-queries.sql) |
| DBA-012 | Performance | Wait statistics ordered by total wait | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/02-wait-statistics.sql) |
| DBA-013 | Performance | Current blocking and locking | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/03-current-blocking.sql) |
| DBA-014 | Performance | Per-database file I/O latency | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/04-file-io-latency.sql) |
| DBA-015 | Performance | Example index optimization | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/05-example-index-optimization.sql) |
| DBA-016 | Performance | Baseline and verification template | Draft | [SQL](02-Performance-Tuning/Query-Tuning-DMV-Workflow/06-baseline-and-verify.sql) |

[Workflow guide and execution-plan checklist](02-Performance-Tuning/Query-Tuning-DMV-Workflow/README.md).

Note: DBA-002 and DBA-003 remain earlier planned placeholders. DBA-012 and DBA-013 are newly authored drafts, not validated scripts.

## System Catalog FAQ (Beginner-Friendly Drafts)

| ID | Domain | Item | Status | File |
|---|---|---|---|---|
| DBA-017 | Administration | Tables and columns | Draft | [SQL](01-Administration/System-Catalog-FAQ/01-tables-and-columns.sql) |
| DBA-018 | Administration | Indexes, keys and statistics | Draft | [SQL](01-Administration/System-Catalog-FAQ/02-indexes-keys-statistics.sql) |
| DBA-019 | Administration | Views, procedures and functions | Draft | [SQL](01-Administration/System-Catalog-FAQ/03-views-procedures-functions.sql) |
| DBA-020 | Administration | Constraints and dependencies | Draft | [SQL](01-Administration/System-Catalog-FAQ/04-constraints-dependencies.sql) |
| DBA-021 | Administration | Security and custom types | Draft | [SQL](01-Administration/System-Catalog-FAQ/05-security-and-types.sql) |

[Easy-to-follow guide](01-Administration/System-Catalog-FAQ/README.md). Inspired by the Microsoft Learn System Catalog FAQ. Not yet executed against SQL Server.
