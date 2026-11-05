/*
DBA-015 | Example only: create a covering index after plan/workload review.
DO NOT run against production without validating schema, write overhead,
existing indexes, storage impact, and change approval.
Replace sample table/columns with actual reviewed objects.
*/
-- Example workload:
-- SELECT OrderID, OrderDate, TotalAmount
-- FROM dbo.Orders
-- WHERE CustomerID = @CustomerID AND OrderDate >= @StartDate;

-- Hypothetical index (uncomment only after adapting to your schema):
-- CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_OrderDate
-- ON dbo.Orders (CustomerID, OrderDate)
-- INCLUDE (TotalAmount);

-- Before creation, compare existing index keys/includes, selectivity,
-- execution plans, reads, CPU, duration, and insert/update costs.
-- Test in nonproduction and capture baseline/after metrics.
