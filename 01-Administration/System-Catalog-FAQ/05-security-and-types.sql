/* DBA-021 | USERS, PERMISSIONS AND CUSTOM TYPES | Read-only.
   Users/roles are like school ID cards and groups; permissions decide access.
   Explicit permissions are not the same as effective access: roles, ownership,
   DENY, server privileges and other rules also matter. */
SET NOCOUNT ON;
-- 1. Users and database roles.
SELECT name,type_desc,authentication_type_desc
FROM sys.database_principals WHERE type IN ('S','U','G','R','E','X')
ORDER BY type_desc,name;

-- 2. Role memberships.
SELECT USER_NAME(rm.role_principal_id) AS role_name,
       USER_NAME(rm.member_principal_id) AS member_name
FROM sys.database_role_members AS rm ORDER BY 1,2;

-- 3. Explicit database permissions for a named user/role.
DECLARE @Principal sysname=N'public';
SELECT USER_NAME(p.grantee_principal_id) AS principal_name,
       p.state_desc,p.permission_name,p.class_desc,
       CASE WHEN p.class=1 THEN
         QUOTENAME(OBJECT_SCHEMA_NAME(p.major_id))+'.'+QUOTENAME(OBJECT_NAME(p.major_id))
         WHEN p.class=3 THEN SCHEMA_NAME(p.major_id)
         WHEN p.class=0 THEN DB_NAME()
         ELSE CONVERT(nvarchar(30),p.major_id) END AS securable
FROM sys.database_permissions AS p
WHERE p.grantee_principal_id=DATABASE_PRINCIPAL_ID(@Principal)
ORDER BY p.class_desc,p.permission_name;

-- 4. Explicit server permissions for a named login or server role.
DECLARE @Login sysname=N'public';
SELECT SUSER_NAME(grantee_principal_id) AS principal_name,
       state_desc,permission_name,class_desc,major_id
FROM sys.server_permissions
WHERE grantee_principal_id=SUSER_ID(@Login)
ORDER BY class_desc,permission_name;

-- 5. Columns using a custom alias or CLR type.
SELECT OBJECT_SCHEMA_NAME(c.object_id) AS schema_name,
       OBJECT_NAME(c.object_id) AS object_name,c.name AS column_name,
       SCHEMA_NAME(t.schema_id) AS type_schema,t.name AS custom_type
FROM sys.columns AS c JOIN sys.types AS t ON c.user_type_id=t.user_type_id
JOIN sys.tables AS tb ON tb.object_id=c.object_id
WHERE t.is_user_defined=1 ORDER BY 1,2,3;

-- 6. Parameters using custom types.
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS schema_name,
       OBJECT_NAME(p.object_id) AS object_name,p.name AS parameter_name,
       t.name AS custom_type
FROM sys.parameters AS p JOIN sys.types AS t ON p.user_type_id=t.user_type_id
WHERE t.is_user_defined=1 ORDER BY 1,2,3;
