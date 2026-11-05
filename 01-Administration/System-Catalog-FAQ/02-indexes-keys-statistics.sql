/* DBA-018 | INDEXES, KEYS AND STATISTICS | Read-only, current database.
   An index is like a book's index: it helps locate information. */
SET NOCOUNT ON;
DECLARE @TableName nvarchar(517)=N'dbo.Orders';
-- 1. Index list for one table.
SELECT i.name AS index_name, i.type_desc, i.is_unique,
       i.is_primary_key, i.is_disabled, i.has_filter, i.filter_definition
FROM sys.indexes AS i WHERE i.object_id=OBJECT_ID(@TableName,'U')
ORDER BY i.index_id;

-- 2. Which columns are in each index? Key columns come before INCLUDE.
SELECT i.name AS index_name, c.name AS column_name,
       ic.key_ordinal, ic.is_included_column, ic.is_descending_key
FROM sys.indexes AS i
JOIN sys.index_columns AS ic ON ic.object_id=i.object_id AND ic.index_id=i.index_id
JOIN sys.columns AS c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE i.object_id=OBJECT_ID(@TableName,'U')
ORDER BY i.name,ic.key_ordinal,ic.index_column_id;

-- 3. Primary key columns, in key order.
SELECT kc.name AS primary_key_name, c.name AS column_name, ic.key_ordinal
FROM sys.key_constraints AS kc
JOIN sys.index_columns AS ic ON ic.object_id=kc.parent_object_id
 AND ic.index_id=kc.unique_index_id AND ic.key_ordinal>0
JOIN sys.columns AS c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
WHERE kc.type='PK' AND kc.parent_object_id=OBJECT_ID(@TableName,'U')
ORDER BY ic.key_ordinal;

-- 4. Foreign keys: links between child and parent tables.
SELECT fk.name AS foreign_key_name,
       COL_NAME(fkc.parent_object_id,fkc.parent_column_id) AS child_column,
       OBJECT_SCHEMA_NAME(fkc.referenced_object_id) AS parent_schema,
       OBJECT_NAME(fkc.referenced_object_id) AS parent_table,
       COL_NAME(fkc.referenced_object_id,fkc.referenced_column_id) AS parent_column,
       fk.is_disabled
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc ON fkc.constraint_object_id=fk.object_id
WHERE fk.parent_object_id=OBJECT_ID(@TableName,'U')
ORDER BY fk.name,fkc.constraint_column_id;

-- 5. Statistics: summaries SQL Server uses to estimate row counts.
SELECT s.name AS statistics_name, s.auto_created, s.user_created,
       STATS_DATE(s.object_id,s.stats_id) AS last_updated
FROM sys.stats AS s WHERE s.object_id=OBJECT_ID(@TableName,'U')
ORDER BY s.name;

-- 6. Statistics columns in order.
SELECT s.name AS statistics_name, sc.stats_column_id,
       c.name AS column_name
FROM sys.stats AS s JOIN sys.stats_columns AS sc
 ON sc.object_id=s.object_id AND sc.stats_id=s.stats_id
JOIN sys.columns AS c ON c.object_id=sc.object_id AND c.column_id=sc.column_id
WHERE s.object_id=OBJECT_ID(@TableName,'U')
ORDER BY s.name,sc.stats_column_id;

-- 7. Partitioned tables and indexes.
SELECT SCHEMA_NAME(t.schema_id) AS schema_name,t.name AS table_name,
       i.name AS index_name, ps.name AS partition_scheme
FROM sys.tables AS t JOIN sys.indexes AS i ON i.object_id=t.object_id
JOIN sys.partition_schemes AS ps ON ps.data_space_id=i.data_space_id
ORDER BY 1,2,3;
