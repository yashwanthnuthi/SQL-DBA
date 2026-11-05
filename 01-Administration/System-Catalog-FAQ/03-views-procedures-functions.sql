/* DBA-019 | PROGRAMMABLE OBJECTS | Read-only, current database.
   Views are saved SELECT definitions; procedures are reusable commands.
   Definitions may be hidden without VIEW DEFINITION permission. */
SET NOCOUNT ON;
-- 1. All views.
SELECT SCHEMA_NAME(schema_id) AS schema_name,name AS view_name,
       create_date,modify_date FROM sys.views ORDER BY 1,2;

-- 2. Stored procedures.
SELECT SCHEMA_NAME(schema_id) AS schema_name,name AS procedure_name,
       create_date,modify_date FROM sys.procedures WHERE is_ms_shipped=0
ORDER BY 1,2;

-- 3. Functions (scalar, table-valued and CLR).
SELECT SCHEMA_NAME(schema_id) AS schema_name,name AS function_name,type_desc
FROM sys.objects WHERE type IN ('FN','IF','TF','FS','FT')
ORDER BY 1,2;

-- 4. Parameters of one procedure or function.
DECLARE @ObjectName nvarchar(517)=N'dbo.usp_GetOrders';
SELECT p.parameter_id,p.name AS parameter_name,
       TYPE_NAME(p.user_type_id) AS data_type,p.max_length,p.is_output
FROM sys.parameters AS p WHERE p.object_id=OBJECT_ID(@ObjectName)
ORDER BY p.parameter_id;

-- 5. Definition of a view, procedure, function or DML trigger.
SELECT OBJECT_DEFINITION(OBJECT_ID(@ObjectName)) AS object_definition;

-- 6. Recently changed object definitions. This is metadata change time,
-- not the last time someone inserted or updated rows in a table.
DECLARE @DaysBack int=30;
SELECT SCHEMA_NAME(schema_id) AS schema_name,name AS object_name,
       type_desc,modify_date FROM sys.objects
WHERE modify_date>=DATEADD(DAY,-@DaysBack,GETDATE())
ORDER BY modify_date DESC;

-- 7. Server-level trigger definitions (requires appropriate permissions).
SELECT st.name AS trigger_name, sm.definition
FROM sys.server_triggers AS st
LEFT JOIN sys.server_sql_modules AS sm ON sm.object_id=st.object_id;
