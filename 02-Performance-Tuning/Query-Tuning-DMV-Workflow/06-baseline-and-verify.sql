/*
DBA-016 | Query tuning measurement template.
Run in SSMS with Include Actual Execution Plan enabled.
Replace example statement with your actual query. Repeat with identical
parameters, data, isolation level, and cache conditions before and after.
STATISTICS IO outputs per-table logical/physical reads in Messages;
STATISTICS TIME outputs CPU and elapsed time.
*/
SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DECLARE @CustomerID int = 1001;
DECLARE @StartDate date = '2026-01-01';

-- Example only: requires a dbo.Orders table in the selected database.
-- SELECT OrderID, OrderDate, TotalAmount
-- FROM dbo.Orders
-- WHERE CustomerID = @CustomerID AND OrderDate >= @StartDate;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

-- Record each run in a results table/document:
-- variant | parameters | execution_plan | elapsed_ms | cpu_ms
--         | table_name | logical_reads | physical_reads | row_count
-- STATISTICS IO is per table accessed by the executed statement, not a
-- persistent aggregate of all queries touching a table.
-- Run multiple trials and compare median values; note warm/cold cache.
