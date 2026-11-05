/* DBA-017 | TABLES AND COLUMNS | Run in the database you want to inspect.
   A catalog is like a library's list of books: it describes what exists.
   All queries below only READ metadata. Results depend on your permissions. */
SET NOCOUNT ON;
-- 1. List ordinary user tables. A schema is like a folder for tables.
SELECT SCHEMA_NAME(schema_id) AS schema_name, name AS table_name
FROM sys.tables WHERE is_ms_shipped = 0 ORDER BY 1,2;

-- 2. Tables without a clustered index (often called heaps).
-- A heap is not automatically bad: investigate how it is used.
SELECT SCHEMA_NAME(t.schema_id) AS schema_name, t.name AS table_name
FROM sys.tables AS t
WHERE NOT EXISTS (SELECT 1 FROM sys.indexes AS i
                  WHERE i.object_id=t.object_id AND i.type=1)
ORDER BY 1,2;

-- 3. Tables without any rowstore/columnstore indexes (heap only).
SELECT SCHEMA_NAME(t.schema_id) AS schema_name, t.name AS table_name
FROM sys.tables AS t
WHERE NOT EXISTS (SELECT 1 FROM sys.indexes AS i
                  WHERE i.object_id=t.object_id AND i.index_id>0)
ORDER BY 1,2;

-- 4. Tables missing a primary key (a unique identifier for each row).
SELECT SCHEMA_NAME(t.schema_id) AS schema_name, t.name AS table_name
FROM sys.tables AS t
WHERE NOT EXISTS (SELECT 1 FROM sys.key_constraints AS k
                  WHERE k.parent_object_id=t.object_id AND k.type='PK')
ORDER BY 1,2;

-- 5. Identity columns: SQL Server can automatically generate numbers.
SELECT SCHEMA_NAME(t.schema_id) AS schema_name, t.name AS table_name,
       c.name AS identity_column
FROM sys.tables AS t JOIN sys.identity_columns AS c ON c.object_id=t.object_id
ORDER BY 1,2;

-- 6. Change this variable to inspect another table.
DECLARE @TableName nvarchar(517)=N'dbo.Orders';
SELECT c.column_id, c.name AS column_name, ty.name AS data_type,
       c.max_length AS max_length_bytes, c.precision, c.scale,
       c.is_nullable, c.is_computed
FROM sys.columns AS c JOIN sys.types AS ty ON c.user_type_id=ty.user_type_id
WHERE c.object_id=OBJECT_ID(@TableName,'U') ORDER BY c.column_id;

-- 7. Large object columns: can store big text, XML or binary data.
SELECT OBJECT_SCHEMA_NAME(c.object_id) AS schema_name,
       OBJECT_NAME(c.object_id) AS table_name, c.name AS column_name,
       TYPE_NAME(c.user_type_id) AS data_type
FROM sys.columns AS c JOIN sys.tables AS t ON t.object_id=c.object_id
WHERE TYPE_NAME(c.user_type_id) IN ('text','ntext','image','xml')
   OR (c.max_length=-1 AND TYPE_NAME(c.user_type_id) IN
       ('varchar','nvarchar','varbinary'))
ORDER BY 1,2,3;

-- 8. Find a column name across tables. Change this search value.
DECLARE @ColumnName sysname=N'CustomerID';
SELECT OBJECT_SCHEMA_NAME(c.object_id) AS schema_name,
       OBJECT_NAME(c.object_id) AS table_name, c.name AS column_name
FROM sys.columns AS c JOIN sys.tables AS t ON t.object_id=c.object_id
WHERE c.name=@ColumnName ORDER BY 1,2;
