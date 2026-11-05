/* DBA-020 | RULES AND DEPENDENCIES | Read-only, current database.
   A constraint is a rule that helps keep data correct. */
SET NOCOUNT ON;
DECLARE @TableName nvarchar(517)=N'dbo.Orders';
-- 1. Check constraints: rules such as TotalAmount >= 0.
SELECT name AS constraint_name,definition,is_disabled,is_not_trusted
FROM sys.check_constraints WHERE parent_object_id=OBJECT_ID(@TableName,'U');

-- 2. Default constraints: values filled in when no value is supplied.
SELECT name AS constraint_name,COL_NAME(parent_object_id,parent_column_id)
 AS column_name,definition
FROM sys.default_constraints WHERE parent_object_id=OBJECT_ID(@TableName,'U');

-- 3. Computed columns: calculated from other columns.
SELECT name AS computed_column,definition,is_persisted
FROM sys.computed_columns WHERE object_id=OBJECT_ID(@TableName,'U');

-- 4. Objects that reference the chosen table in SQL definitions.
-- Dependency metadata is not complete for all dynamic SQL or cross-database cases.
SELECT OBJECT_SCHEMA_NAME(d.referencing_id) AS referencing_schema,
       OBJECT_NAME(d.referencing_id) AS referencing_object,
       d.referenced_schema_name,d.referenced_entity_name
FROM sys.sql_expression_dependencies AS d
WHERE d.referenced_id=OBJECT_ID(@TableName)
ORDER BY 1,2;

-- 5. Columns used by computed columns in this table.
SELECT cc.name AS computed_column, c.name AS referenced_column
FROM sys.computed_columns AS cc
JOIN sys.sql_expression_dependencies AS d
 ON d.referencing_id=cc.object_id AND d.referencing_minor_id=cc.column_id
JOIN sys.columns AS c ON c.object_id=d.referenced_id
 AND c.column_id=d.referenced_minor_id
WHERE cc.object_id=OBJECT_ID(@TableName,'U')
ORDER BY cc.name,c.name;
