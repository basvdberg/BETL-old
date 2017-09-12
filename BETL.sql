
-- START BETL Release version 3.0.68 , date: 2017-09-12 14:52:54

-- schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'def')
EXEC sys.sp_executesql N'CREATE SCHEMA [def]'

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'util')
EXEC sys.sp_executesql N'CREATE SCHEMA [util]'
GO
-- end schemas

-- user defined table types 
CREATE TYPE [dbo].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_name] [varchar](64) NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

CREATE TYPE [dbo].[MappingTable] AS TABLE(
	[src_id] [int] NOT NULL,
	[trg_id] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[src_id] ASC,
	[trg_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

CREATE TYPE [dbo].[ParamTable] AS TABLE(
	[param_name] [varchar](255) NOT NULL,
	[param_value] [sql_variant] NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](8000) NULL,
	[i] [int] NULL
)
GO
-- end user defined tables

-- create table [dbo].[Version]
GO

CREATE TABLE [dbo].[Version](	  [major_version] INT NOT NULL	, [minor_version] INT NOT NULL	, [build] INT NOT NULL	, [build_dt] DATETIME NULL	, CONSTRAINT [PK_Version] PRIMARY KEY ([major_version] ASC, [minor_version] ASC, [build] ASC))
-- create table [dbo].[Transfer]
GO

CREATE TABLE [dbo].[Transfer](	  [transfer_id] INT NOT NULL IDENTITY(1,1)	, [batch_id] INT NULL	, [start_dt] DATETIME NULL	, [end_dt] DATETIME NULL	, [src_name] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, [dest_name] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, [rec_cnt_src] INT NULL	, [rec_cnt_new] INT NULL	, [rec_cnt_changed] INT NULL	, [rec_cnt_unchanged] INT NULL	, [rec_cnt_deleted] INT NULL	, [status_id] INT NULL	, [last_error_id] INT NULL	, CONSTRAINT [PK_transfer_id] PRIMARY KEY ([transfer_id] DESC))
-- create table [dbo].[Batch]
GO

CREATE TABLE [dbo].[Batch](	  [batch_id] INT NOT NULL IDENTITY(1,1)	, [batch_name] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, [batch_start_dt] DATETIME NULL DEFAULT(getdate())	, [batch_end_dt] DATETIME NULL	, [status_id] INT NULL	, [last_error_id] INT NULL	, CONSTRAINT [PK_run_id] PRIMARY KEY ([batch_id] DESC))
-- create table [dbo].[Transfer_log]
GO

CREATE TABLE [dbo].[Transfer_log](	  [log_id] INT NOT NULL IDENTITY(1,1)	, [log_dt] DATETIME NULL DEFAULT(getdate())	, [msg] VARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	, [transfer_id] INT NULL	, [log_level_id] INT NULL	, [log_type_id] INT NULL	, [exec_sql] BIT NULL	, CONSTRAINT [PK_log_id] PRIMARY KEY ([log_id] DESC))
-- create table [dbo].[Error]
GO

CREATE TABLE [dbo].[Error](	  [error_id] INT NOT NULL IDENTITY(1,1)	, [error_code] INT NULL	, [error_msg] VARCHAR(5000) COLLATE Latin1_General_CI_AS NULL	, [error_line] INT NULL	, [error_procedure] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_procedure_id] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_execution_id] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_event_name] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_severity] INT NULL	, [error_state] INT NULL	, [error_source] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_interactive_mode] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_machine_name] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [error_user_name] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [transfer_id] INT NULL	, [record_dt] DATETIME NULL DEFAULT(getdate())	, [record_user] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_error_id] PRIMARY KEY ([error_id] DESC))
-- create table [dbo].[Status]
GO

CREATE TABLE [dbo].[Status](	  [status_id] INT NOT NULL	, [status_name] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_Status] PRIMARY KEY ([status_id] ASC))
-- create table [def].[Col_hist]
GO

CREATE TABLE [def].[Col_hist](	  [column_id] INT NOT NULL IDENTITY(1,1)	, [eff_dt] DATETIME NOT NULL	, [object_id] INT NOT NULL	, [column_name] VARCHAR(64) COLLATE Latin1_General_CI_AS NOT NULL	, [prefix] VARCHAR(64) COLLATE Latin1_General_CI_AS NULL	, [entity_name] VARCHAR(64) COLLATE Latin1_General_CI_AS NULL	, [foreign_column_id] INT NULL	, [ordinal_position] SMALLINT NULL	, [is_nullable] BIT NULL	, [data_type] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, [max_len] INT NULL	, [numeric_precision] INT NULL	, [numeric_scale] INT NULL	, [column_type_id] INT NULL	, [src_column_id] INT NULL	, [delete_dt] DATETIME NULL	, [record_dt] DATETIME NULL	, [record_user] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [chksum] INT NOT NULL	, [transfer_id] INT NULL	, [part_of_unique_index] BIT NULL DEFAULT((0))	, CONSTRAINT [PK__Hst_column] PRIMARY KEY ([column_id] ASC, [eff_dt] DESC))CREATE UNIQUE NONCLUSTERED INDEX [IX_Unique__Column_obj_col_eff] ON [def].[Col_hist] ([object_id] ASC, [column_name] ASC, [eff_dt] ASC)
-- create table [def].[Column_type]
GO

CREATE TABLE [def].[Column_type](	  [column_type_id] INT NOT NULL	, [column_type_name] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [column_type_description] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [record_dt] DATETIME NULL	, [record_user] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_Column_type] PRIMARY KEY ([column_type_id] ASC))
-- create table [def].[Obj]
GO

CREATE TABLE [def].[Obj](	  [object_id] INT NOT NULL IDENTITY(1,1)	, [object_type_id] INT NOT NULL	, [object_name] VARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL	, [parent_id] INT NULL	, [scope] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [template_id] SMALLINT NULL	, [delete_dt] DATETIME NULL	, [record_dt] DATETIME NULL DEFAULT(getdate())	, [record_user] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT(suser_sname())	, [prefix] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [object_name_no_prefix] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK__Object] PRIMARY KEY ([object_id] DESC))ALTER TABLE [def].[Obj] WITH CHECK ADD CONSTRAINT [FK__Object__Object] FOREIGN KEY([parent_id]) REFERENCES [def].[Obj] ([object_id])ALTER TABLE [def].[Obj] CHECK CONSTRAINT [FK__Object__Object]CREATE UNIQUE NONCLUSTERED INDEX [IX__Object] ON [def].[Obj] ([object_name] ASC, [parent_id] ASC)CREATE UNIQUE NONCLUSTERED INDEX [UIX__Object_id_parent_object_id] ON [def].[Obj] ([object_id] ASC, [parent_id] ASC)
-- create table [def].[Object_type]
GO

CREATE TABLE [def].[Object_type](	  [object_type_id] INT NOT NULL	, [object_type] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_Object_type] PRIMARY KEY ([object_type_id] ASC))
-- create table [def].[Prefix]
GO

CREATE TABLE [def].[Prefix](	  [prefix_name] VARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL	, [default_template_id] INT NULL)
-- create table [def].[Property]
GO

CREATE TABLE [def].[Property](	  [property_id] INT NOT NULL	, [property_name] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [description] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [property_scope] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [default_value] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [apply_table] BIT NULL	, [apply_view] BIT NULL	, [apply_schema] BIT NULL	, [apply_db] BIT NULL	, [apply_srv] BIT NULL	, [apply_user] BIT NULL	, [record_dt] DATETIME NULL DEFAULT(getdate())	, [record_user] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL DEFAULT(suser_sname())	, CONSTRAINT [PK_Property_1] PRIMARY KEY ([property_id] ASC))
-- create table [def].[Property_value]
GO

CREATE TABLE [def].[Property_value](	  [property_id] INT NOT NULL	, [object_id] INT NOT NULL	, [value] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, [record_dt] DATETIME NULL	, [record_user] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_Property_Value] PRIMARY KEY ([property_id] ASC, [object_id] ASC))
-- create table [def].[Template]
GO

CREATE TABLE [def].[Template](	  [template_id] SMALLINT NOT NULL	, [template] VARCHAR(100) COLLATE Latin1_General_CI_AS NULL	, [record_dt] DATETIME NULL DEFAULT(getdate())	, [record_name] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL DEFAULT(suser_sname())	, CONSTRAINT [PK_Template] PRIMARY KEY ([template_id] ASC))
-- create table [util].[Log_level]
GO

CREATE TABLE [util].[Log_level](	  [log_level_id] SMALLINT NOT NULL	, [log_level] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [log_level_description] VARCHAR(255) COLLATE Latin1_General_CI_AS NULL	, CONSTRAINT [PK_Log_level_1] PRIMARY KEY ([log_level_id] ASC))
-- create table [util].[Log_type]
GO

CREATE TABLE [util].[Log_type](	  [log_type_id] SMALLINT NOT NULL	, [log_type] VARCHAR(50) COLLATE Latin1_General_CI_AS NULL	, [min_log_level_id] INT NULL	, CONSTRAINT [PK_Log_type_1] PRIMARY KEY ([log_type_id] ASC))
GO


	INSERT [dbo].[Version] ([major_version], [minor_version], [build], build_dt) VALUES (3,0,68,'2017-09-12 14:52:54')
	GO
	
print '-- 1. ddl_clear'

	  GO
	  
	  
	  
	  

-- exec ddl_clear 1

CREATE procedure [dbo].[ddl_clear] @execute as bit = 0  as
begin 

	declare @sql as varchar(max) =''
	select @sql+= 'DROP '+
	   case 
	   when q.type ='P' then 'PROCEDURE' 
	   when q.type='U' then 'TABLE'
	   when q.type= 'V' then 'VIEW'
	   when q.type= 'TT' then 'TYPE'
	   else 'FUNCTION' end + ' ' + 
	   fullname + '
	;
	'

	from  (
	select so.object_id, so.name , so.type,  quotename(s.name) + '.' + quotename(so.name)  fullname 
	from sys.objects so
	inner join sys.schemas s on so.schema_id = s.schema_id 
	where     so.type in  ( 'U', 'V', 'P', 'IF' , 'FT', 'FS', 'FN', 'TF')
						AND so.is_ms_shipped = 0
     
	union all 
		SELECT null, name , 'TT' type ,name fullname
		FROM sys.types WHERE is_table_type = 1 
    ) q

	
				



--select quotename(s.name) + '.' + quotename(so.name), so.type
--from sys.objects so 
--inner join sys.schemas s on so.schema_id = s.schema_id 
--where   --  so.type in  ( 'U', 'V', 'P', 'IF' , 'FT', 'FS', 'FN')
--						 so.is_ms_shipped = 0
--order by 1
				
	print @sql

	if @execute = 1  
	   exec(@sql) 
end






GO

print '-- 2. get_cols'

	  GO
	  
	  
	  
	  

-- =============================================
-- =============================================
-- returns a table with all column meta data 
-- Unfortunately we have to re-define the columTable type here... 
-- see http://stackoverflow.com/questions/2501324/can-t-sql-function-return-user-defined-table-type
-- select * from def.get_cols(32)
-- exec def.info

CREATE FUNCTION [def].[get_cols]
(
	@object_id int
)
RETURNS @cols TABLE(
	[ordinal_position] [int] NOT NULL PRIMARY KEY,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreignCol_name] [varchar](64) NULL,
	[foreign_sur_pkey] int NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	part_of_unique_index BIT NULL,
	[identity] [bit] NULL

)  as
begin 
	--SET IDENTITY_INSERT @cols ON 
	insert into @cols(
		ordinal_position
		, column_name
		, column_value
		, data_type 
		, max_len
		, [column_type_id] 
		, is_nullable
		, [prefix] 
		, [entity_name]
		, [foreignCol_name] 
		, [foreign_sur_pkey] 
		  ,[numeric_precision]
		  ,[numeric_scale]
		  ,part_of_unique_index 
		  ,[identity]
		) 
		select 
			ordinal_position
			, column_name
			, null column_value
			, data_type 
			, max_len
			, [column_type_id] 
			, is_nullable
			, prefix
			, [entity_name]
			, [foreign_column_name]
			, [foreign_sur_pkey] 
			  ,[numeric_precision]
			  ,[numeric_scale]
			  ,part_of_unique_index 
			  ,null [identity]
		from def.Col_ext
		where [object_id] = @object_id 
	--SET IDENTITY_INSERT @cols OFF
	RETURN
end


--SELECT * from vwCol










GO

print '-- 3. Obj_ext'

	  GO
	  
	  
	  
	  







CREATE VIEW [def].[Obj_ext]AS
WITH q AS (SELECT        o.object_id, ot.object_type, o.object_name, o.scope, o.parent_id, parent_o.object_name AS parent, parent_o.parent_id AS grand_parent_id, grand_parent_o.object_name AS grand_parent, 
                                                   grand_parent_o.parent_id AS great_grand_parent_id, great_grand_parent_o.object_name AS great_grand_parent, o.delete_dt, o.record_dt, o.record_user, isnull(o.template_id, parent_o.template_id) template_id
												   , o.prefix, o.[object_name_no_prefix]
                         FROM            def.Obj AS o INNER JOIN
                                                   def.Object_type AS ot ON o.object_type_id = ot.object_type_id LEFT OUTER JOIN
                                                   def.Obj AS parent_o ON o.parent_id = parent_o.object_id LEFT OUTER JOIN
                                                   def.Obj AS grand_parent_o ON parent_o.parent_id = grand_parent_o.object_id LEFT OUTER JOIN
                                                   def.Obj AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.object_id
												   where o.delete_dt is null 
												   )
, q2 AS
    (SELECT        object_id, object_type , object_name, 
                                CASE WHEN [object_type] = 'server' THEN [object_name] WHEN [object_type] = 'database' THEN parent WHEN [object_type] = 'schema' THEN grand_parent WHEN [object_type] = 'table'
                                 THEN great_grand_parent WHEN [object_type] = 'view' THEN great_grand_parent END AS srv, CASE WHEN [object_type] = 'server' THEN NULL 
                                WHEN [object_type] = 'database' THEN [object_name] WHEN [object_type] = 'schema' THEN parent WHEN [object_type] = 'table' THEN grand_parent WHEN [object_type] = 'view' THEN
                                 grand_parent END AS db, CASE WHEN [object_type] = 'server' THEN NULL WHEN [object_type] = 'database' THEN NULL 
                                WHEN [object_type] = 'schema' THEN [object_name] WHEN [object_type] = 'table' THEN parent WHEN [object_type] = 'view' THEN parent END AS [schema], 
                                CASE WHEN [object_type] = 'server' THEN NULL WHEN [object_type] = 'database' THEN NULL WHEN [object_type] = 'schema' THEN NULL 
                                WHEN [object_type] = 'table' THEN [object_name] WHEN [object_type] = 'view' THEN [object_name] END AS table_or_view, delete_dt, record_dt, record_user, parent_id, grand_parent_id, great_grand_parent_id, scope, q_1.template_id
								, prefix, [object_name_no_prefix]
      FROM            q AS q_1)
SELECT        
object_id
, 
case when object_type in ( 'user', 'server') then [object_name] else 
ISNULL('[' + case when srv<>'LOCALHOST'then srv else null end  + '].', '') -- don't show localhost
+ ISNULL('[' + db + ']', '') 
+ ISNULL('.[' + [schema] + ']', '') 
+ ISNULL('.[' + table_or_view + ']', '') end AS full_object_name




, object_type, object_name, srv, db, [schema], 
table_or_view, scope, template_id, parent_id, grand_parent_id, great_grand_parent_id, delete_dt, record_dt, record_user
, prefix, [object_name_no_prefix]
, p.[default_template_id]
FROM q2 AS q2_1
left join def.Prefix p on q2_1.prefix = p.prefix_name













GO

print '-- 4. prefix_first_underscore'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreignCol_id('par_relatie_id')
-- SELECT [def].[prefix_first_underscore]('relatie_id')
-- DROP FUNCTION [def].[prefix_underscore]

CREATE FUNCTION [util].[prefix_first_underscore]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,		@pos INT 

	SET @pos = CHARINDEX('_', @column_name)

	IF @pos IS NOT NULL and @pos>1
		SET @res = SUBSTRING(@column_name, 1, @pos-1)

	RETURN @res 
	/* 
		declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, 1, @n-@len_suffix) 
	*/
END











GO

print '-- 5. suffix_first_underscore'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreignCol_id('par_relatie_id')
-- SELECT [def].[suffix_first_underscore]('relatie_id')
-- DROP FUNCTION [def].[prefix_underscore]

CREATE FUNCTION [util].[suffix_first_underscore]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,		@pos INT 

	SET @pos = CHARINDEX('_', @column_name)

	IF @pos IS NOT NULL
		SET @res = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)

	RETURN @res 
	/* 
		declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, 1, @n-@len_suffix) 
	*/
END











GO

print '-- 6. prefix'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:                            <Author,,Name>
-- Create date: 2017-01-01
-- Description:    returns true if @s ends with @suffix
-- =============================================
--select def.prefix('gfjhaaaaa_aap', 4) 

CREATE FUNCTION [util].[prefix]
(
                @s as varchar(255)
                , @len_suffix as int
                --, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
                declare @n as int=len(@s) 
                                                --, @n_suffix as int = len(@suffix)

                declare @result as bit = 0 
                return SUBSTRING(@s, 1, @n-@len_suffix) 
END













GO

print '-- 7. trim'

	  GO
	  
	  
	  
	  



-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [util].[trim]
(
	@s varchar(200)
	, @return_null bit = 1 
)
RETURNS varchar(200)
AS
BEGIN
	declare @result as varchar(max)= replace(replace(convert(varchar(200), ltrim(rtrim(@s))), '"', ''), '''' , '')
	if @return_null =0 
		return isnull(@result , '') 
	return @result 
END
















GO

print '-- 8. Col'

	  GO
	  
	  
	  
	  







CREATE VIEW [def].[Col] AS
	SELECT     * 
	FROM  [def].[Col_hist] AS h
	WHERE     (eff_dt =
                      ( SELECT     MAX(eff_dt) max_eff_dt
                        FROM       [def].[Col_hist] h2
                        WHERE      h.column_id = h2.column_id
                       )
              )
		AND delete_dt IS NULL 














GO

print '-- 9. obj_id'

	  GO
	  
	  
	  
	  
-- =============================================
-- 2017-09-06 BvdB Return meta data id for a full object name
-- =============================================

--select def.obj_id('AdventureWorks2014.Person.Person', null) --> points to table 
--select def.obj_id('AdventureWorks2014.Person', null) --> points to schema
--select def.obj_id('AdventureWorks2014', null) --> points to db
--select def.obj_id('BETL', null) --> points to db
--select def.obj_id('def', null) 

CREATE FUNCTION [def].[obj_id]( @fullObj_name varchar(255) , @scope varchar(255) = null ) 
RETURNS int
AS
BEGIN
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	select @object_id= max(o.object_id), @cnt = count(*) 
	from def.[Obj] o
	LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where o.[object_name] = @elem1 
	and ( @elem2 is null or parent_o.[object_name] = @elem2 ) 
	and ( @elem3 is null or grand_parent_o.[object_name] = @elem3) 
	and ( @elem4 is null or great_grand_parent_o.[object_name] = @elem4) 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			or o.object_type_id= 50 -- scope not relevant for servers. 
		)  
	and o.delete_dt is null 

	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@object_id 
	return @res 
END











GO

print '-- 10. schema_id'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema_id of this full object name 
--  e.g. LOCALHOST.AdventureWorks2014.Person.Sales ->LOCALHOST.AdventureWorks2014.Person
-- =============================================

--select def.object('LOCALHOST.AdventureWorks2014.Person.Sales') --> points to table 
--select def.object('LOCALHOST.AdventureWorks2014.Person') --> points to schema
--select def.object('LOCALHOST.AdventureWorks2014') --> points to db
--select def.object('LOCALHOST.BETL') --> points to db
--select def.object('LOCALHOST') --> points to srv
--select def.object('LOCALHOST.def') 
--select def.object('def') 

CREATE FUNCTION [def].[schema_id]( @fullObj_name varchar(255), @scope varchar(255) = null  ) 
RETURNS int
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
--exec def.get_var 'debug', @debug output
--exec def.get_var 'progress', @progress output
--exec progress @progress, '? ?,?', @proc_name , @fullObj_name

-- END standard BETL header code... 

	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

		 
	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	select @object_id= max(o.object_id), @cnt = count(*) 
	from def.[Obj] o
	LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where 	o.[object_name] = @elem2
	and ( @elem3 is null or parent_o.[object_name] = @elem3) 
	and ( @elem4 is null or grand_parent_o.[object_name] = @elem4) 
	and ( @scope is null or 
			@scope = o.scope
			or @scope = parent_o.scope
			or @scope = grand_parent_o.scope
			or @scope = great_grand_parent_o.scope) 

	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@object_id 
	return @res 
END














GO

print '-- 11. content_type_name'

	  GO
	  
	  
	  
	  
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- select def.[content_type_name](300) 
create FUNCTION [def].[content_type_name]
(
	@content_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @content_type_name as varchar(255) 
	select @content_type_name = [content_type_name] from def.Content_type where content_type_id = @content_type_id 
	return @content_type_name + ' (' + convert(varchar(10), @content_type_id ) + ')'

END










GO

print '-- 12. object_name'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema name of this full object name 
--  e.g. C2H_PC.AdventureWorks2014.Person.Sales ->C2H_PC.AdventureWorks2014.Person
-- =============================================

--select def.object_name('C2H_PC.AdventureWorks2014.Person.Sales') --> points to table 

CREATE FUNCTION [util].[object_name]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
--exec def.get_var 'debug', @debug output
--exec def.get_var 'progress', @progress output
--exec progress @progress, '? ?,?', @proc_name , @fullObj_name

-- END standard BETL header code... 

	--declare @fullObj_name varchar(255)= 'Tim_DWH.L2.Location'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @object_id int 
		, @remove_chars varchar(255)
		, @cnt as int 

		 
	set @remove_chars = replace(@fullObj_name, '[','')
	set @remove_chars = replace(@remove_chars , ']','')
	
	insert into @t 
	select * from util.split(@remove_chars , '.') 

	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 

	select @cnt_elems = MAX(i) from @t	

	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3

	--select @object_id= max(o.object_id), @cnt = count(*) 
	--from def.[Obj] o
	--LEFT OUTER JOIN def.[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	--LEFT OUTER JOIN def.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	--LEFT OUTER JOIN def.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	--where 	o.[object_name] = @elem2
	--and ( @elem3 is null or parent_o.[object_name] = @elem3) 
	--and ( @elem4 is null or grand_parent_o.[object_name] = @elem4) 
	declare @res as varchar(255) 
	--if @cnt >1 
	--	set @res =  -@cnt
	--else 
	--	set @res =@object_id 

	set @res = '[' + @elem1 + ']'
	return @res 
END














GO

print '-- 13. ddl_table'

	  GO
	  
	  
	  
	  


-- exec dbo.ddl_table '[dbo].[run]'
CREATE procedure [dbo].[ddl_table] @table_name SYSNAME
as 
begin 

DECLARE 
      @object_name SYSNAME
    , @object_id INT

SELECT 
      @object_name = '[' + s.name + '].[' + o.name + ']'
    , @object_id = o.[object_id]


FROM sys.objects o WITH (NOWAIT)
JOIN sys.schemas s WITH (NOWAIT) ON o.[schema_id] = s.[schema_id]
WHERE quotename(s.name) + '.' + quotename(o.name) = @table_name
    AND o.[type] = 'U'
    AND o.is_ms_shipped = 0

DECLARE @SQL NVARCHAR(MAX) = ''

;WITH index_column AS 
(
    SELECT 
          ic.[object_id]
        , ic.index_id
        , ic.is_descending_key
        , ic.is_included_column
        , c.name
    FROM sys.index_columns ic WITH (NOWAIT)
    JOIN sys.columns c WITH (NOWAIT) ON ic.[object_id] = c.[object_id] AND ic.column_id = c.column_id
    WHERE ic.[object_id] = @object_id
),
fk_columns AS 
(
     SELECT 
          k.constraint_object_id
        , cname = c.name
        , rcname = rc.name
    FROM sys.foreign_key_columns k WITH (NOWAIT)
    JOIN sys.columns rc WITH (NOWAIT) ON rc.[object_id] = k.referenced_object_id AND rc.column_id = k.referenced_column_id 
    JOIN sys.columns c WITH (NOWAIT) ON c.[object_id] = k.parent_object_id AND c.column_id = k.parent_column_id
    WHERE k.parent_object_id = @object_id
)
SELECT @SQL = 'CREATE TABLE ' + @object_name + CHAR(13) + '(' + CHAR(13) + STUFF((
    SELECT CHAR(9) + ', [' + c.name + '] ' + 
        CASE WHEN c.is_computed = 1
            THEN 'AS ' + cc.[definition] 
            ELSE UPPER(tp.name) + 
                CASE WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('nvarchar', 'nchar', 'ntext')
                       THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length / 2 AS VARCHAR(5)) END + ')'
                     WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset') 
                       THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'
                     WHEN tp.name = 'decimal' 
                       THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
                    ELSE ''
                END +
                CASE WHEN c.collation_name IS NOT NULL THEN ' COLLATE ' + c.collation_name ELSE '' END +
                CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
                CASE WHEN dc.[definition] IS NOT NULL THEN ' DEFAULT' + dc.[definition] ELSE '' END + 
                CASE WHEN ic.is_identity = 1 THEN ' IDENTITY(' + CAST(ISNULL(ic.seed_value, '0') AS CHAR(1)) + ',' + CAST(ISNULL(ic.increment_value, '1') AS CHAR(1)) + ')' ELSE '' END 
        END + CHAR(13)
    FROM sys.columns c WITH (NOWAIT)
    JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
    LEFT JOIN sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id



    LEFT JOIN sys.default_constraints dc WITH (NOWAIT) ON c.default_object_id != 0 AND c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
    LEFT JOIN sys.identity_columns ic WITH (NOWAIT) ON c.is_identity = 1 AND c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
    WHERE c.[object_id] = @object_id
    ORDER BY c.column_id
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
    + ISNULL((SELECT CHAR(9) + ', CONSTRAINT [' + k.name + '] PRIMARY KEY (' + 
                    (SELECT STUFF((
                         SELECT ', [' + c.name + '] ' + CASE WHEN ic.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
                         FROM sys.index_columns ic WITH (NOWAIT)
                         JOIN sys.columns c WITH (NOWAIT) ON c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
                         WHERE ic.is_included_column = 0
                             AND ic.[object_id] = k.parent_object_id 
                             AND ic.index_id = k.unique_index_id     
                         FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
            + ')' + CHAR(13)
            FROM sys.key_constraints k WITH (NOWAIT)
            WHERE k.parent_object_id = @object_id 
                AND k.[type] = 'PK'), '') + ')'  + CHAR(13)
    + ISNULL((SELECT (
        SELECT CHAR(13) +
             'ALTER TABLE ' + @object_name + ' WITH' 
            + CASE WHEN fk.is_not_trusted = 1 
                THEN ' NOCHECK' 
                ELSE ' CHECK' 
              END + 
              ' ADD CONSTRAINT [' + fk.name  + '] FOREIGN KEY(' 
              + STUFF((
                SELECT ', [' + k.cname + ']'
                FROM fk_columns k
                WHERE k.constraint_object_id = fk.[object_id]
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
               + ')' +
              ' REFERENCES [' + SCHEMA_NAME(ro.[schema_id]) + '].[' + ro.name + '] ('
              + STUFF((
                SELECT ', [' + k.rcname + ']'
                FROM fk_columns k
                WHERE k.constraint_object_id = fk.[object_id]
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
               + ')'
            + CASE 
                WHEN fk.delete_referential_action = 1 THEN ' ON DELETE CASCADE' 
                WHEN fk.delete_referential_action = 2 THEN ' ON DELETE SET NULL'
                WHEN fk.delete_referential_action = 3 THEN ' ON DELETE SET DEFAULT' 
                ELSE '' 
              END
            + CASE 
                WHEN fk.update_referential_action = 1 THEN ' ON UPDATE CASCADE'
                WHEN fk.update_referential_action = 2 THEN ' ON UPDATE SET NULL'
                WHEN fk.update_referential_action = 3 THEN ' ON UPDATE SET DEFAULT'  
                ELSE '' 
              END 
            + CHAR(13) + 'ALTER TABLE ' + @object_name + ' CHECK CONSTRAINT [' + fk.name  + ']' + CHAR(13)



        FROM sys.foreign_keys fk WITH (NOWAIT)
        JOIN sys.objects ro WITH (NOWAIT) ON ro.[object_id] = fk.referenced_object_id
        WHERE fk.parent_object_id = @object_id
        FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)')), '')
    + ISNULL(((SELECT
         CHAR(13) + 'CREATE' + CASE WHEN i.is_unique = 1 THEN ' UNIQUE' ELSE '' END 
                + ' NONCLUSTERED INDEX [' + i.name + '] ON ' + @object_name + ' (' +
                STUFF((
                SELECT ', [' + c.name + ']' + CASE WHEN c.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
                FROM index_column c
                WHERE c.is_included_column = 0
                    AND c.index_id = i.index_id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ')'  
                + ISNULL(CHAR(13) + 'INCLUDE (' + 
                    STUFF((
                    SELECT ', [' + c.name + ']'
                    FROM index_column c
                    WHERE c.is_included_column = 1
                        AND c.index_id = i.index_id
                    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ')', '')  + CHAR(13)
        FROM sys.indexes i WITH (NOWAIT)
        WHERE i.[object_id] = @object_id
            AND i.is_primary_key = 0
            AND i.[type] = 2
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
    ), '')

PRINT @SQL
--EXEC sys.sp_executesql @SQL
end 





GO

print '-- 14. split'

	  GO
	  
	  
	  
	  


-- --CREATE TYPE SplitListType AS TABLE 	(item VARCHAR(8000), i int)
-- select * from util.split('AAP,NOOT', ',')
CREATE  FUNCTION [util].[split](
    @sInputList VARCHAR(8000) -- List of delimited items
  , @sDelimiter VARCHAR(16) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item VARCHAR(8000), i int)

BEGIN
DECLARE @sItem VARCHAR(8000)
, @i int =1


WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
 BEGIN
 SELECT
  @sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
  @sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
 IF LEN(@sItem) > 0
 begin
  INSERT INTO @List SELECT @sItem, @i
  set @i += 1
 end 
  
 END

IF LEN(@sInputList) > 0
 INSERT INTO @List SELECT @sInputList , @i-- Put the last item in
RETURN
END

















GO

print '-- 15. column_type_name'

	  GO
	  
	  
	  
	  
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- select def.[column_type_name](300) 
CREATE FUNCTION [def].[column_type_name]
(
	@column_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @column_type_name as varchar(255) 
	select @column_type_name = [column_type_name] from def.column_type where column_type_id = @column_type_id 
	return @column_type_name + ' (' + convert(varchar(10), @column_type_id ) + ')'

END










GO

print '-- 16. ddl_content'

	  GO
	  
	  
	  
	  
-- exec ddl_content
CREATE procedure [dbo].[ddl_content] as 
begin 
print '
GO
set nocount on 
GO
insert into def.Obj(object_type_id, object_name)
values ( 50, ''LOCALHOST'')
GO
exec def.setp ''is_localhost'', 1 , ''LOCALHOST''
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (0, N''Unknown'')
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (100, N''Success'')
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (200, N''Error'')
'
print '
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N''Unknown'', N''Unknown,  not relevant'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')


GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N''nat_pkey'', N''Natural primary key (e.g. user_key)'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N''nat_fkey'', N''Natural foreign key (e.g. create_user_key)'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N''sur_pkey'', N''Surrogate primary key (e.g. user_id)'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N''sur_fkey'', N''Surrogate foreign key (e.g. create_user_id)'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N''attribute'', N''low or non repetetive value for containing object. E.g. customer lastname, firstname.'', CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N''meta data'', NULL, CAST(N''2015-10-20T13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (10, N''table'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (20, N''view'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (30, N''schema'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (40, N''database'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (50, N''server'')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (60, N''user'')
GO
'
print'
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgd'', 12)

GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgf'', 13)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgh'', 8)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgl'', 10)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N''target_schema_id'', N''used for deriving target table'', N''db_object'', NULL, 0, 0, 1, 1, NULL, NULL, CAST(N''2015-08-31T13:18:22.073'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (15, N''template_id'', N''which ETL template to use (see def.Template) '', N''db_object'', NULL, 1, 1, 1, 1, NULL, NULL, CAST(N''2017-09-07T09:12:49.160'' AS DateTime), N''C2H_PC\BAS'')


GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N''has_synonym_id'', N''apply syn pattern (see biblog.nl)'', N''db_object'', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N''2015-08-31T13:18:56.070'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N''has_record_dt'', N''add this column (insert date time) to all tables'', N''db_object'', NULL, 0, 0, 0, 0, 1, NULL, CAST(N''2015-08-31T13:19:09.607'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N''has_record_user'', N''add this column (insert username ) to all tables'', N''db_object'', NULL, 0, 0, 1, 0, 1, NULL, CAST(N''2015-08-31T13:19:15.000'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N''use_linked_server'', N''assume that servername = linked_server name. Access server via linked server'', N''db_object'', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-08-31T17:17:37.830'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N''date_datatype_based_on_suffix'', N''if a column ends with the suffix _date then it''''s a date datatype column (instead of e.g. datetime)'', N''db_object'', N''1'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-02T13:16:15.733'' AS DateTime), N''C2H_PC\BAS'')

GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N''is_localhost'', N''This server is localhost. For performance reasons we don''''t want to access localhost via linked server as we would with external sources'', N''db_object'', N''0'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-24T16:22:45.233'' AS DateTime), N''C2H_PC\BAS'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N''recreate_tables'', N''This will drop and create tables (usefull during initial development)'', N''db_object'', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)


GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N''prefix_length'', N''This object name uses a prefix of certain length x. Strip this from target name. '', N''db_object'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N''etl_meta_fields'', N''etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source'', N''db_object'', N''1'', NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [def].

GO

print '-- 17. addQuotes'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [util].[addQuotes]
(
	@s varchar(7900) 
)
RETURNS varchar(8000) 
AS
BEGIN
	RETURN '''' + isnull(@s , '') + '''' 
END














GO

print '-- 18. refresh_views'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec util.refresh_views 'MyDB'
--SELECT * FROM  ##betl_vars
CREATE PROCEDURE [util].[refresh_views]
	@db_name as varchar(255)  
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @sql AS VARCHAR(MAX) 
		, @cur_db as varchar(255) 
    set @cur_db = DB_NAME()

	SET @sql = '
DECLARE @sql AS VARCHAR(MAX) =''use '+@db_name + ';
''
use '+@db_name+ ';
SELECT @sql += ''EXEC sp_refreshview '''''' + schema_name(schema_id)+ ''.''+ name + '''''' ;
''
  FROM sys.views
set @sql+= ''USE '+@Cur_db+ '''
PRINT @sql 
exec(@sql)
use ' +@cur_db+ '
'
--	PRINT @sql 
   EXEC(@sql)

   




/* 
   declare @cur_db as varchar(255) 
			,@sql as varchar(255) 
   select @cur_db = DB_NAME()
   set @sql = 'use '+@db_name
   exec (@sql) 

   select DB_NAME()
	DECLARE @view_name AS NVARCHAR(500);
	DECLARE views_cursor CURSOR FOR 
		SELECT TABLE_SCHEMA + '.' +TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
		WHERE	TABLE_TYPE = 'VIEW' 
		ORDER BY TABLE_SCHEMA,TABLE_NAME 
	
	OPEN views_cursor 

	FETCH NEXT FROM views_cursor 
	INTO @view_name 

	WHILE (@@FETCH_STATUS <> -1) 
	BEGIN
		BEGIN TRY
			EXEC sp_refreshview @view_name;
			PRINT @view_name;
		END TRY
		BEGIN CATCH
			PRINT 'Error during refreshing view "' + @view_name + '".'+ + convert(varchar(255), isnull(ERROR_MESSAGE(),''))	;
		END CATCH;

		FETCH NEXT FROM views_cursor 
		INTO @view_name 
	END 

	CLOSE views_cursor; 
	DEALLOCATE views_cursor;

   set @sql = 'use '+@cur_db
   exec (@sql) 
*/
END






GO

print '-- 19. ddl_other'

	  GO
	  
	  
	  
	  
-- exec ddl_other
CREATE procedure [dbo].[ddl_other] as 
begin
	set nocount on 
	if object_id('tempdb..#dep') is not null 
		drop table tempdb.#dep
		;
		   WITH dep (obj_id, obj_name, dep_id, dep_name, level)
			 AS
			 (
			 SELECT DISTINCT
					sd.referencing_id obj_id,
					OBJECT_NAME(sd.referencing_id) obj_name,
					Referenced_ID dep_id, -- = sd.referenced_major_id,
					Referenced_entity_name dep_name, -- Object = OBJECT_NAME(sd.referenced_major_id),
					1 AS Level
		
			 FROM    
					sys.sql_expression_dependencies sd
					JOIN sys.objects so ON sd.referencing_id = so.object_id
					JOIN sys.objects dep_o ON sd.Referenced_ID = dep_o.object_id
					where     so.type in  ( 'P', 'IF' , 'FT', 'FS', 'FN', 'V')
							AND so.is_ms_shipped = 0
						and dep_o.type in  ( 'P', 'IF' , 'FT', 'FS', 'FN', 'V')
						and dep_o.is_ms_shipped =0 
/*
			 UNION ALL
			 SELECT 
					sd.referencing_id obj_id,
					OBJECT_NAME(sd.referencing_id)  obj_name,
					sd.referencing_id  dep_id, -- = sd.referenced_major_id,
					sd.Referenced_entity_name dep_name, -- Object = OBJECT_NAME(sd.referenced_major_id),
					Level+1
			--select * 
			 FROM  sys.sql_expression_dependencies sd
				join  dep do
					   ON sd.referenced_id = do.obj_id
			 WHERE					sd.Referenced_ID <> sd.referencing_id    		
  */
			 --SELECT
				--	sd.object_id,
				--	OBJECT_NAME(sd.object_id),
				--	OBJECT_NAME(referenced_major_id),
				--	object_id,
				--	Level + 1
			 --FROM    
				--	sys.sql_dependencies sd
				-- JOIN DependentObjectCTE do ON sd.referenced_major_id = do.DependentObjectID       
			
			 )
			 SELECT obj_id, obj_name , dep_id, dep_name--,  max(level) level
			 into #dep
			 FROM  dep	
			-- group by obj_id, obj_name 


--	select * from  #dep

	declare 
		@def as varchar(max) 
		--, @sql as varchar(4000) 
		, @level as int =0 
		, @id int
		, @obj_name varchar(255) 


	declare 
	   @t TABLE 
	( 
	 id int identity(1,1),
	 obj_name varchar(4000) 
	 ,def  varchar(max) 
	) 
	insert into @t
			select o.name, object_definition(o.object_id) def
			from sys.objects o
			left join #dep d on o.object_id =d.obj_id
			where type_desc in ('SQL_SCALAR_FUNCTION',
			'SQL_STORED_PROCEDURE',
			'SQL_TABLE_VALUED_FUNCTION',
			'SQL_TRIGGER',
			'VIEW')
			and d.dep_name is null 


	while @level < 10
	begin --select * from @t
		insert into @t
			select distinct d.obj_name, object_definition(obj_id) def
			from #dep d 
			--where d.level = @level
			where d.dep_name in ( select obj_name from @t) -- dependend object is already added
		         and d.obj_name not in ( select obj_name from @t) -- dont add tw
		set @level+=1
	end 

	--select * from @t order by 1

	declare @i as int = 1
		, @j int
		, @n int
, @nextspace int
, @newline nchar(2)= nchar(13) + nchar(10)
	while @i <= ( select max(id) from @t ) 
	begin
		SELECT @DEF= def , @id = id, @obj_name =obj_name 
		from @t where id = @i


      print 'print ''-- '+ convert(varchar(255), @id) + '. '+ @obj_name + '''

	  GO
	  '
	   set @n = len(@def) 
	   set @j = 1 
	   set @nextspace=0
	   -- print is limited to 4000 chars workaround:
	    while (@j <= @n)
        begin
 --           while Substring(@def,@j+3000+@nextspace,1) <> ' ' Substring(@def,@j+3000+@nextspace,2) <> @newline
            while Substring(@def,@j+3000+@nextspace,2) <> @newline and (@j+@nextspace<= @n) 
                BEGIN
                    set @nextspace = @nextspace + 1
                end
            print Substring(@def,@j,3000+@nextspace)
            set @j = @j+3000+@nextspace
            set @nextspace = 0
         end

	   print '
GO
'

		set @i+=1
	end

end







GO

print '-- 20. const'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2015-08-31
-- Description:	returns int value for const string. 
-- this way we don't have to use ints foreign keys in our code. 
-- Assumption: const is unique across all lookup tables. 
-- Lookup tables: Object_type
-- =============================================
--select def.const('table')
CREATE FUNCTION [def].[const]
(
	@const varchar(255) 
)
RETURNS int 
AS
BEGIN
	declare @res as int 
	SELECT @res = object_type_id from def.object_type 
	where object_type = @const 
	
	RETURN @res

END













GO

print '-- 21. apply_params'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*
Declare @p as ParamTable
,	@sql as varchar(8000) = 'select <aap> from <wiz> where <where>="nice" '
insert into @p values ('aap', 9)
insert into @p values ('wiz', 'woz')

print @sql 
EXEC util.apply_params @sql output , @p
print @sql 


*/
CREATE PROCEDURE [util].[apply_params]
	@sql as varchar(max) output
	, @params as ParamTable readonly
	as
BEGIN
	declare 
		@nl as varchar(2) = CHAR(13) + CHAR(10)
	declare
		@tmp as varchar(max) ='-- [apply_params]'+@nl

	SET NOCOUNT ON;


	--if @progress =1 
	--begin
	--	select @tmp += '-- '+ param_name + ' : '+ replace(isnull(convert(varchar(max), p.param_value), '?'), @nl, @nl+'--')   + @nl  
	--	from @params p

	--	print @tmp 
	--end
		
	-- insert some default params. 
	select @sql = REPLACE(@sql, '<'+ p.param_name+ '>', isnull(convert(varchar(max), p.param_value), '<' + isnull(p.param_name, '?') + ' IS NULL>'))
	from @params  p

	declare @default_params ParamTable
	insert into @default_params  values ('"', '''' ) 
	insert into @default_params  values ('<dt>', ''''+ convert(varchar(50), GETDATE(), 121)  + '''' ) 

	select @sql = REPLACE(@sql, p.param_name, convert(Varchar(255), p.param_value) )
	from @default_params  p
END



















GO

print '-- 22. suffix'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	returns true if @s ends with @suffix
-- =============================================
--select def.suffix('gfjh_aap', '_aap') 
--select def.suffix('gfjh_aap', 4) 
--select def.suffix('gfjh_aap', '_a3p') 

CREATE FUNCTION [util].[suffix]
(
	@s as varchar(255)
	, @len_suffix as int
	--, @suffix as varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	declare @n as int=len(@s) 
			--, @n_suffix as int = len(@suffix)

	declare @result as bit = 0 
	return SUBSTRING(@s, @n+1-@len_suffix, @len_suffix) 
END














GO

print '-- 23. Int2Char'

	  GO
	  
	  
	  
	  
-- select util.int2Char(2)
CREATE FUNCTION [util].[Int2Char] (     @i int)
RETURNS varchar(15) AS
BEGIN
       RETURN isnull(convert(varchar(15), @i), '')
END














GO

print '-- 24. parent'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- returns parent by parsing the string. e.g. localhost.AdventureWorks2014.def = localhost.AdventureWorks2014
-- select util.parent('localhost.AdventureWorks2014.def')
CREATE FUNCTION [util].[parent]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @rev_str as varchar(255) 
			, @i as int
			, @res as varchar(255) 
	set @rev_str = reverse(@fullObj_name ) 
	set @i = charindex('.', @rev_str) 
	
	if @i = 0 
		set @res = null 
	else 
		set @res =  substring( @fullObj_name, 1, len( @fullObj_name) - @i ) 
	return @res 
END














GO

print '-- 25. Col_ext'

	  GO
	  
	  
	  
	  


CREATE VIEW [def].[Col_ext]
AS
SELECT    c.column_id, c.column_name, 
o.[schema], 
o.full_object_name,  c.Column_type_id, ct.Column_type_name, c.prefix, c.[entity_name], c.foreign_column_id , foreign_c.column_name foreign_column_name, lookup_foreign_cols.foreign_sur_pkey  , lookup_foreign_cols.foreign_sur_pkey_name
, c.is_nullable, c.ordinal_position, c.data_type, c.max_len, c.numeric_precision, c.numeric_scale, c.src_column_id,  o.[object_id] , o.[object_name]
, c.chksum
, c.part_of_unique_index
FROM def.Col AS c 
INNER JOIN def.Obj_ext AS o ON c.object_id = o.object_id
LEFT JOIN def.Column_type ct ON c.Column_type_id = ct.Column_type_id
LEFT JOIN def.Col AS foreign_c ON foreign_c.column_id = c.foreign_column_id  AND foreign_c.delete_dt IS NULL 
LEFT JOIN ( 
	SELECT c1.column_id, c1.foreign_column_id, c3.column_id foreign_sur_pkey, c3.column_name foreign_sur_pkey_name
	, ROW_NUMBER() OVER (PARTITION BY c1.column_id ORDER BY c3.ordinal_position ASC) seq_nr 
	FROM def.Col c1
	INNER JOIN def.Col c2 ON c1.[foreign_column_id] = c2.column_id 
	INNER JOIN def.Col c3 ON c3.[object_id] = c2.[object_id] AND c3.Column_type_id=200 -- sur_pkey
	WHERE c1.[foreign_column_id] IS NOT NULL 
) lookup_foreign_cols ON lookup_foreign_cols.column_id = c.column_id AND lookup_foreign_cols.seq_nr = 1 
WHERE        (c.delete_dt IS NULL) 

/*
SELECT * 
FROM vw_column
WHERE column_id IN ( 1140) 
*/














GO

print '-- 26. create_table'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:          Bas van den Berg
-- ============================================
/* 
->don't create primary keys for performance reasons (lock last page clustered index )
unique indexes:
hubs:
on all nat_pkeys 

hub sats:
on all nat_pkeys 
note that etl_load_dt is included

links
on all sur_fkeys 

link sats
on all sur_fkeys 
note that etl_load_dt is included

*/
--drop PROCEDURE [def].[create_table]

CREATE PROCEDURE [dbo].[create_table]
    @full_object_name AS VARCHAR(255) 
    , @scope AS VARCHAR(255) 
	, @cols AS dbo.ColumnTable READONLY
	, @transfer_id AS INT = -1
	, @create_pkey AS BIT =1 

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID)
	exec dbo.log 'header', '? ?, scope ? ?', @proc_name , @full_object_name,  @scope, @transfer_id 
	-- END standard BETL header code... 

	declare @sql as varchar(8000) 
			, @col_str as varchar(8000) =''
			, @nl as varchar(2) = char(13)+char(10)
			, @db as varchar(255) 
			, @obj_name as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int
			, @this_db as varchar(255) = db_name()
			, @prim_key as varchar(1000) =''
			, @prim_key_sql as varchar(8000)=''
			, @p ParamTable
			, @unique_index as varchar(1000)=''
			, @index_sql as varchar(4000) 
			, @refresh_sql as varchar(4000) 
			, @recreate_tables as BIT
            , @obj_id AS INT 

	select @schema_id=def.schema_id(@full_object_name, @scope)  -- 
	select 
		@db = db 
		, @schema = [schema]
		, @obj_name =  util.object_name(@full_object_name) 
	from def.obj_ext 
	where object_id = @schema_id

	select @col_str+= case when @col_str='' then '' else ',' end + 
	'['+ column_name + '] ['+ case when data_type in ('money', 'smallmoney')  then 'decimal' else data_type end + ']'
		+ case when data_type in ( 'varchar', 'nvarchar', 'char', 'nchar', 'varbinary') then  isnull('('+ case when max_len<0 then 'MAX' else convert(varchar(10), max_len ) end + ')', '')
			   when numeric_precision is not null then '('+ convert(varchar(10), numeric_precision) +  
														isnull ( ',' + convert(varchar(10), numeric_scale), '') + ')' 
				else ''
		  end
	   + case when [identity] = 1 then ' IDENTITY(1,1) ' else '' end + 
		case when is_nullable=0 or ( column_type_id in (100,200) )   then ' NOT NULL' else ' NULL' end 
--		case when is_nullable=0   then ' NOT NULL' else ' NULL' end 
		+ case when column_value is null then '' else ' DEFAULT ('+ column_value + ')' end	
		+ ' -- '+ def.column_type_name(column_type_id) +@nl
	from @cols 

	select @prim_key+= case when @prim_key='' then '' else ',' end + 
	'['+ column_name + ']' + @nl
	from @cols 
	where column_type_id = 200 -- sur_pkey
	order by ordinal_position asc

	select @unique_index+= case when @unique_index='' then '' else ',' end + 
	'['+ column_name + ']' + @nl
	from @cols 
	where part_of_unique_index = 1 



	order by ordinal_position asc
	
	-- exec dbo.log 'VAR', '@unique_index ?', @unique_index
	if @prim_key='' 
		set @prim_key = @unique_index 

	if @unique_index is not null and @unique_index <> '' 
		set @index_sql = '
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"IX_<obj_name_striped>_<schema_id>")
ALTER TABLE <schema>.<obj_name> ADD CONSTRAINT
	IX_<obj_name_striped>_<schema_id> UNIQUE NONCLUSTERED 
	(
	<unique_index>
	) 
'

--skip this for performance reasons... 
	if @prim_key is not null and @prim_key<> '' and @create_pkey=1
		set @prim_key_sql = '
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"PK_<obj_name_striped>_<schema_id>")
ALTER TABLE <schema>.<obj_name> ADD CONSTRAINT
	PK_<obj_name_striped>_<schema_id> PRIMARY KEY CLUSTERED 
	(
	<prim_key>
	) 
'

/*
-- create FK to etl_data_source
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N"FK_<obj_name_striped>_<schema_id>_etl_data_source")
begin
	ALTER TABLE <schema>.<obj_name> WITH CHECK ADD  CONSTRAINT 
		FK_<obj_name_striped>_<schema_id>_etl_data_source FOREIGN KEY([etl_data_source])
	REFERENCES [def].[etl_data_source] ([etl_data_source])
	ALTER TABLE <schema>.<obj_name> CHECK CONSTRAINT FK_<obj_name_striped>_<schema_id>_etl_data_source
end
*/
	set @sql ='
-------------------------------------------------
-- Start create table DDL <full_object_name>
-------------------------------------------------	
USE <db> 
'

	select @recreate_tables = def.get_prop_obj_id('recreate_tables', @schema_id ) 
	if @recreate_tables =1 
	begin
		exec dbo.log 'step', '@recreate_tables =1->drop table ?', @full_object_name
		SET @sql += '
-- recreate table =1 

if object_id(''<schema>.<obj_name>'') is not null 
	drop table <schema>.<obj_name>
;
'


	END


	SET @sql += '
if object_id(''<schema>.<obj_name>'') is null 
begin 
	CREATE Table <schema>.<obj_name> (
		<col_str>
	) ON [PRIMARY]

	<prim_key_sql>
	<index_sql>
	<refresh_sql>
end

	
USE <this_db> 
-------------------------------------------------
-- End create table DDL <full_object_name>
-------------------------------------------------	
'
SET @refresh_sql = '
	exec betl.def.refresh ''<schema>.<obj_name>'' -- make sure that betl meta data is up to date
'
-- not needed because we do a get_object_id after this, which will also issue a refresh
--	


	INSERT INTO @p VALUES ('full_object_name'		, @full_object_name) 
	INSERT INTO @p VALUES ('db'						, @db) 
	INSERT INTO @p VALUES ('schema'					, @schema) 
	INSERT INTO @p VALUES ('col_str'				, @col_str) 
	INSERT INTO @p VALUES ('prim_key_sql'			, ISNULL(@prim_key_sql,'') ) 
	INSERT INTO @p VALUES ('index_sql'				, ISNULL(@index_sql,'') ) 
	INSERT INTO @p VALUES ('this_db'				, @this_db) 
	INSERT INTO @p VALUES ('obj_name'				, @obj_name) 
	INSERT INTO @p VALUES ('obj_name_striped'		, REPLACE(REPLACE(@obj_name, '[', ''), ']', '') )
	INSERT INTO @p VALUES ('schema_id'				, @schema_id) 
	INSERT INTO @p VALUES ('prim_key'				, @prim_key ) 



	INSERT INTO @p VALUES ('unique_index'		    , @unique_index ) 
	INSERT INTO @p VALUES ('refresh_sql'			, @refresh_sql) 

	EXEC util.apply_params @sql OUTPUT, @p
	EXEC util.apply_params @sql OUTPUT, @p -- twice because of nesting

	exec dbo.exec_sql @sql 

	EXEC def.get_obj_id @full_object_name, @obj_id OUTPUT -- this will also do a refresh

	exec dbo.log 'VAR', 'object_id ? = ?', @full_object_name, @obj_id
	
	IF @obj_id IS NOT NULL 
		-- finally set column_type meta data 
	   UPDATE c 
	   SET c.column_type_id = cols.column_type_id
	   FROM @cols cols
	   INNER JOIN def.Col c ON cols.column_name = c.column_name 
	   WHERE cols.column_type_id IS NOT NULL 
		AND c.[object_id] = @obj_id

--	SET @refresh_sql = '		exec betl.def.refresh ''<schema>.<obj_name>''	'

	-- standard BETL footer code... 
    footer:
	exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @transfer_id
	-- END standard BETL footer code... 

END


























GO

print '-- 27. ddl_betl'

	  GO
	  
	  
	  
	  
-- exec dbo.ddl_betl 
CREATE procedure [dbo].[ddl_betl] as 
begin 
    declare @major_version as int
		, @minor_version as int
		, @build as int
		, @build_dt as varchar(255) = convert(varchar(255), getdate(),120) 
		, @version_str as varchar(500) ='?'

	set nocount on 

   select @major_version =major_version
		, @minor_version= minor_version
		, @build = build 

   from dbo.[Version]
   set @build+=1 
   update dbo.[Version] set build = @build , build_dt = @build_dt 
   set  @version_str = convert(varchar(10), @major_version) + '.'+ convert(varchar(10), @minor_version) + '.'+ convert(varchar(10), @build)+ ' , date: '+ @build_dt
  print '
-- START BETL Release version ' + @version_str+ '

-- schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''def'')
EXEC sys.sp_executesql N''CREATE SCHEMA [def]''

GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''util'')
EXEC sys.sp_executesql N''CREATE SCHEMA [util]''
GO
-- end schemas

-- user defined table types 
CREATE TYPE [dbo].[ColumnTable] AS TABLE(
	[ordinal_position] [int] NOT NULL,
	[column_name] [varchar](255) NULL,
	[column_value] [varchar](255) NULL,
	[data_type] [varchar](255) NULL,
	[max_len] [int] NULL,
	[column_type_id] [int] NULL,
	[is_nullable] [bit] NULL,
	[prefix] [varchar](64) NULL,
	[entity_name] [varchar](64) NULL,
	[foreign_column_name] [varchar](64) NULL,
	[foreign_sur_pkey] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[part_of_unique_index] [bit] NULL,
	[identity] [bit] NULL,
	PRIMARY KEY CLUSTERED 
(
	[ordinal_position] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

CREATE TYPE [dbo].[MappingTable] AS TABLE(
	[src_id] [int] NOT NULL,
	[trg_id] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[src_id] ASC,
	[trg_id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

CREATE TYPE [dbo].[ParamTable] AS TABLE(
	[param_name] [varchar](255) NOT NULL,
	[param_value] [sql_variant] NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](8000) NULL,
	[i] [int] NULL
)
GO
-- end user defined tables
'
	-- tables 

	declare 
		@t as varchar(255) 
		, @sql as varchar(4000) 

	declare c cursor for
		select quotename(s.name ) + '.'+ quotename(t.name) 
		from sys.tables t
		inner join sys.schemas s on t.schema_id =s.schema_id

	open c 
	fetch next from c into @t
	while @@FETCH_STATUS=0
	begin 
		print '-- create table '+ @t
		set @sql = 'exec dbo.ddl_table '''  + @t + ''''
	    print 'GO
'
 		exec (@sql) 
	
		fetch next from c into @t
	end 
	close c
	deallocate c

	    print 'GO
'
    print '
	INSERT [dbo].[Version] ([major_version], [minor_version], [build], build_dt) VALUES ('
	+convert(varchar(255), @major_version) + ','
	+convert(varchar(255), @minor_version) + ','
	+convert(varchar(255), @build) + ','''
	+convert(varchar(255), @build_dt) + ''')
	GO
	'
	exec [dbo].[ddl_other]




	exec [dbo].[ddl_content]

	print '--END BETL Release version ' + @version_str
end





GO

print '-- 28. get_obj_id'

	  GO
	  
	  
	  
	  

-- =============================================
-- 2017-09-06 BvdB Return meta data id for a full object name
-- =============================================
/*
declare @obj_id  as int 
exec [def].[get_obj_id] 'LOCALHOST', @obj_id  output--, 'NF'
--exec [def].[get_obj_id] 'AdventureWorks2014.Production.Product', @obj_id  output--, 'NF'
select @obj_id  
*/

CREATE PROCEDURE [def].[get_obj_id] 
	@full_object_name varchar(255) 
	, @obj_id int output 
	, @scope varchar(255) = null 
	, @recursive_depth int = 0
-- e.g. when this proc is called on a table in an unknown database. get_obj_id is executed on this database. 
-- but the search algorithm first needs to go up from table->schema->database->server and then down. 
	, @transfer_id as int = -1

as
BEGIN
	SET NOCOUNT ON;
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
--	exec dbo.log 'header', '? ? , scope ?, depth ?', @proc_name , @full_object_name, @scope, @recursive_depth
	-- END standard BETL header code... 

	declare 
		@full_object_name2 as varchar(255) 
		, @schema as varchar(255) 
		, @parent varchar(255) 
		, @db_name varchar(255) 
		, @debug as bit = 0

	set @full_object_name2 = @full_object_name --replace(@full_object_name, @@servername, 'LOCALHOST') 
	if @debug = 1 
		exec dbo.log 'Step', 'looking for ?, scope ? ', @full_object_name2 , @scope
	
	-- retrieve object meta data. If not found->refresh schema... 
	Set @obj_id = def.obj_id(@full_object_name2, @scope) 
	if @obj_id is null or @obj_id < 0 
	begin 
		Set @parent = util.parent(@full_object_name2) 
		if @parent is null or @parent =''
		begin
			-- this happens when a new view is just created in current database. 
			-- try to refresh current database
			--if @debug = 1 
			exec dbo.log 'Warn', 'object ? not found in scope ? and no parent ', @full_object_name2, @scope 

			-- not found-> try to find object in current db
			set @db_name = null
			SELECT @db_name = d.name
			FROM sys.dm_tran_locks
			inner join sys.databases d with(nolock) on resource_database_id  = d.database_id
			WHERE request_session_id = @@SPID and resource_type = 'DATABASE' and request_owner_type = 'SHARED_TRANSACTION_WORKSPACE'
			and d.name<>db_name() 

			if @db_name is not null 
			begin
			--	if @debug = 1 
				exec dbo.log 'INFO', 'Refreshing current db ? ', @db_name 
				exec def.refresh @db_name, 1
				-- retry
				Set @obj_id = def.obj_id(@full_object_name2, @scope) 
			end

			if @obj_id is null or @obj_id < 0 
				exec dbo.log 'Warn', 'object ? not found', @full_object_name2, @scope 
			goto footer
		end
		--if @debug = 1 
		exec dbo.log 'Warn', 'object ? not found in scope ? , trying to refresh parent ? ', @full_object_name2, @scope, @parent
		--set @recursive_depth +=1
		
		exec dbo.inc_nesting
		exec def.refresh @parent, 0, @scope -- @recursive_depth 
		exec dbo.dec_nesting

		Set @obj_id = def.obj_id(@full_object_name2, @scope) 


	end 
	if @obj_id <0 -- ambiguous object-id 
	begin
		exec dbo.log 'ERROR', 'Object name ? is ambiguous. ? duplicates.', @full_object_name, @obj_id 
		goto footer
	end

	if @debug = 1 
	begin
		if @obj_id is not null and @obj_id >0  
			exec dbo.log 'step', 'Found object-id ?(?)->?', @full_object_name, @scope, @obj_id
		else 
			exec dbo.log 'ERROR', 'Object ?(?) NOT FOUND', @full_object_name, @scope, @obj_id
	end	
	-- standard BETL footer code... 
    footer:
--	exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @recursive_depth, @transfer_id
	-- END standard BETL footer code... 
END















GO

print '-- 29. get_prop_obj_id'

	  GO
	  
	  
	  
	  


-- select  def.get_prop('etl_meta_fields' , 'idv', null)
-- select def.get_prop_obj_id('etl_meta_fields', 63) 
CREATE function [def].[get_prop_obj_id] (
	@prop varchar(255)
	, @obj_id int = null 
	)
returns varchar(255) 

as 
begin
	-- standard BETL header code... 
	--set nocount on 
	declare   @res as varchar(255) 
--			, @debug as bit =0
			, @progress as bit =0
	--		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec def.get_var 'debug', @debug output
	--exec def.get_var 'progress', @progress output
	--exec progress @progress, '? ?', @proc_name , @fullObj_name
	-- END standard BETL header code... 
	--return def.get_prop_obj_id @obj_id 

	--exec progress @progress, 'obj_id ?', @obj_id 
	;
	with q as ( 
	select o.object_id, o.object_name, p.property, p.value, p.default_value,
	case when p.[object_id] = o.[object_id] then 0 
		when p.[object_id] = o.parent_id then 1 
		when p.[object_id] = o.grand_parent_id then 2 
		when p.[object_id] = o.great_grand_parent_id then 3 end moved_up_in_hierarchy
	from def.prop_ext p 
	left join def.obj_ext o on 
		p.[object_id] = o.[object_id] 
		or p.[object_id] = o.parent_id
		or p.[object_id] = o.grand_parent_id
		or p.[object_id] = o.great_grand_parent_id
	where property = @prop
	and o.[object_id] = @obj_id 
	) 
	, q2 as ( 
	select *, row_number() over (partition by [object_id] order by moved_up_in_hierarchy asc) seq_nr 
	 from q 
	 where isnull(value , default_value) is not null 
	) 
	select --* 
	@res= isnull(value , default_value) 
	from q2 
	where seq_nr = 1

	return @res

end












GO

print '-- 30. getp'

	  GO
	  
	  
	  
	  

/*
declare @value varchar(255) 
exec betl.def.getp 'log_level', @Value output 
print 'loglevel' + isnull(@Value,'?')
select * from def.prop_ext
*/
-- declare @value varchar(255); exec def.getp 'transfer_id', @value 
CREATE PROCEDURE [def].[getp] 
	@prop varchar(255)
	, @value varchar(255) output 
	, @full_object_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 

as 

begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec dbo.log 'header', '? ? ?', @proc_name , @prop, @full_object_name
	-- END standard BETL header code... 

  -- first determine scope 
  declare @property_scope as varchar(255) 
		, @object_id int
		, @prop_id as int 
		, @debug as bit = 0

  select @property_scope = property_scope , @prop_id = property_id
  from def.Property
  where [property_name]=@prop

  if @prop_id is null 
  begin 
	if @debug = 1 
		print 'Property not found in def.Property '
		--exec dbo.log 'ERROR', 'Property ? not found in def.Property ', @prop
	goto footer
  end

  if @property_scope is null 
  begin 
	if @debug = 1 
		print 'Property scope is not defined in def.Property'
		--exec dbo.log 'ERROR', 'Scope ? is not defined in def.Property', @prop
	goto footer
  end
  -- scope is not null 

  if @property_scope = 'user' -- then we need an object_id 
  begin
	set @full_object_name =  suser_sname()
  end
  
  --select @object_id = def.object_id(@full_object_name, null) 
  select @object_id = def.obj_id(@full_object_name, null ) 
  if @debug = 1 
	print 'Object_id for '+ @full_object_name+ ' is '+ isnull(@object_id, '?') 

--  exec def.get_object_id @full_object_name, @object_id output, @property_scope=DEFAULT, @recursive_depth=DEFAULT, @transfer_id=@transfer_id
  if @object_id  is null 
  begin 
	if @property_scope = 'user' -- then create object_id 
	begin
		insert into def.Obj (object_type_id, object_name) 
		values (60, @full_object_name)
			
		select @object_id = def.obj_id(@full_object_name, null) 
	  if @debug = 1 
		print 'Object_id for '+ @full_object_name+ ' is '+ isnull(@object_id, '?') 

	end
	else 
	begin
		if @debug = 1 
			print 'ERROR object not found '

		goto footer
	end
  end
  
  select @value = isnull(value,default_value) from def.Prop_ext
  where property = @prop  and object_id = @object_id 

  footer:
  --exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @prop, @value , @full_object_name
  -- END standard BETL footer code... 
end












GO

print '-- 31. guess_entity_name'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.[guess_entity_name]('par_relatie_id')
-- SELECT def.[guess_entity_name]('relatie_id')
-- SELECT def.[guess_entity_name]('child_relatie_id')

CREATE FUNCTION [def].[guess_entity_name]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,	@foreignCol_id int
	
	SELECT @foreignCol_id  = def.guess_foreign_col_id( @column_name) 

	SELECT @res = [object_name]
	FROM def.Col c
	INNER JOIN [def].[Obj] obj ON obj.object_id = c.object_id
	WHERE column_id = @foreignCol_id  

	RETURN @res 
END











GO

print '-- 32. guess_foreign_col_id'

	  GO
	  
	  
	  
	  
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_foreign_col_id('par_relatie_id')
-- SELECT def.guess_foreign_col_id('relatie_id')
-- SELECT def.guess_foreign_col_id('dienstverband_id')

CREATE FUNCTION [def].[guess_foreign_col_id]( @column_name VARCHAR(255) ) 

RETURNS int
AS
BEGIN
	DECLARE @nat_keys AS TABLE ( 
		column_id  int 
		, column_name  varchar(255) 
		, object_name  varchar(255) 
	) 

	INSERT INTO @nat_keys 

	SELECT c.column_id, c.column_name, o.[object_name] -- , COUNT(*) cnt
	FROM def.Col c
	INNER JOIN def.Obj o ON c.object_id = o.object_id
	INNER JOIN def.Col c2 ON c.object_id = c2.object_id -- AND c2.column_id <> c.column_id 
	WHERE 
	c.column_type_id = 100 -- nat_pkey 
	AND c2.column_type_id = 100 
	AND c2.column_name NOT IN ( 'etl_data_source', 'etl_load_dt') 
	GROUP BY 
	c.column_id, c.column_name, o.[object_name]
	HAVING COUNT(*) = 1 


	DECLARE @res INT 
	,		@pos INT 

	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM @nat_keys 
	WHERE column_name = @column_name
	AND util.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub

	SET @pos = CHARINDEX('_', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)

		SELECT @res = MAX(column_id) -- for now take the last known column if >1 
		FROM @nat_keys 
		WHERE column_name = @remove_prefix
		AND util.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub
	end

	-- Return the result of the function
	RETURN @res 
END










GO

print '-- 33. guess_prefix'

	  GO
	  
	  
	  
	  
-- =============================================
-- Author:		Bas van den Berg
-- Create date: 2017-01-01
-- Description:	<Description, ,>
-- =============================================

-- SELECT def.guess_prefix('par_relatie_id')
-- SELECT def.guess_prefix('relatie_id')
CREATE FUNCTION [def].[guess_prefix]( @column_name VARCHAR(255) ) 

RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @res INT 
	,		@pos INT 
	, @prefix VARCHAR(64)=''

	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM def.Col c
	INNER JOIN def.[Obj] o ON o.[object_id] = c.[object_id]
	WHERE column_name = @column_name
	AND column_type_id = 100 -- nat_pkey
	AND util.prefix_first_underscore([object_name]) ='hub' -- foreign column should be a hub
	/* 
	declare @column_name VARCHAR(255)  = 'par_relatie_id'
	,		@pos INT 
	 SELECT CHARINDEX('_', @column_name )
	 SET @pos = CHARINDEX('_', @column_name)
	 select SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
	 */
	SET @pos = CHARINDEX('_', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
		SET @prefix = SUBSTRING(@column_name, 1, @pos-1)

		SELECT @res = MAX(column_id) -- for now take the last known column if >1 
		FROM def.Col c
		INNER JOIN def.[Obj] o ON o.[object_id] = c.[object_id]
		WHERE column_name = @remove_prefix
		AND column_type_id = 100 -- nat_pkey
		AND util.prefix_first_underscore([object_name]) ='hub'
	end

	-- Return the result of the function
	RETURN @prefix
END










GO

print '-- 34. info'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:          Bas van den Berg
-- Create date: 02-03-2012
-- ============================================

/* 
exec def.info '[C2H_PC].[AdventureWorks2014]', 'AW'
exec def.info 

*/
--[LOCALHOST].[AdventureWorks2014].[def].[ErrorLog]

CREATE PROCEDURE [def].[info]
    @full_object_name as varchar(255) =''
	, @scope as varchar(255) =null
	, @transfer_id as int = -1

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'header', '? ? ? ?', @proc_name , @full_object_name,  @scope, @transfer_id
	-- END standard BETL header code... 

	declare @object_id as int
			, @object_name as varchar(255) 
			, @search as varchar(255) 

	--exec def.refresh @full_object_name 
	--Set @object_id = def.object_id(@full_object_name) 
	--if @object_id is null 
	--	exec show_error 'Object ? not found ', @full_object_name
	--else 
	--	exec dbo.log 'INFO', 'object_id ?', @object_id 
	
	set @search = replace (@full_object_name, @@SERVERNAME , 'LOCALHOST') 
	declare @replacer as ParamTable
	insert into @replacer values ( '[', '![')
	insert into @replacer values ( ']', '!]')
	insert into @replacer values ( '_', '!_')
	
	
	SELECT @search = REPLACE(@search, param_name, convert(varchar(255), param_value) )
	FROM @replacer;

	set @search  ='%%'+ @search +'%%'
	exec dbo.log 'step', 'Searching ?', @search 
	
	select o.*, p.value target_schema_id
	from def.obj_ext o
	LEFT OUTER JOIN [def].[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	left join [def].[Prop_ext] p on o.object_id = p.object_id and p.property = 'target_schema_id' 
	where ( o.full_object_name like @search  ESCAPE '!'  or @search is null or @search = '') 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)
	order by o.object_id

	select c.*
	from [def].[Col_ext] c
	LEFT OUTER JOIN [def].[Obj] AS o on c.object_id = o.object_id 
	LEFT OUTER JOIN [def].[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where ( full_object_name like @search  ESCAPE '!'  or @search is null or @search = '') 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)
	order by c.column_id

	select p.*
	from [def].[Prop_ext] p
	LEFT OUTER JOIN [def].[Obj] AS o on p.object_id = o.object_id 



	LEFT OUTER JOIN [def].[Obj] AS parent_o ON o.parent_id = parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[object_id] 
	LEFT OUTER JOIN [def].[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[object_id] 
	where ( full_object_name like @search  ESCAPE '!'  or @search is null or @search = '') 
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)
	order by p.object_id, p.property

    footer:
	exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name,  @scope, @transfer_id
END






















GO

print '-- 35. Prop_ext'

	  GO
	  
	  
	  
	  









/* select * from [def].[Prop_ext]*/
CREATE VIEW [def].[Prop_ext]
AS
SELECT        
--o.object_id, o.object_type, o.object_name, o.srv, o.db, o.[schema], o.table_or_view
o.object_id, o.object_type, o.full_object_name
 , p.property_id , p.property_name property, pv.value, p.default_value, p.property_scope
FROM            def.Obj_ext AS o 
INNER JOIN def.Property AS p ON o.object_type = 'table' AND p.apply_table = 1 OR o.object_type = 'view' AND p.apply_view = 1 OR o.object_type = 'schema' AND p.apply_schema = 1 OR o.object_type = 'database' AND 
                         p.apply_db = 1 OR o.object_type = 'server' AND p.apply_srv = 1 
						 OR o.object_type = 'user' AND p.apply_user = 1 
LEFT OUTER JOIN
                         def.Property_Value AS pv ON pv.property_id = p.property_id AND pv.object_id = o.object_id

















GO

print '-- 36. push'

	  GO
	  
	  
	  
	  
-- =============================================
-- 2012-03-04 BvdB Push implements the core of BETL. 
-- In it's most simple form it will copy a table from A( source)  to B (target).  If target does not exist
-- it will be created. It can also do natural foreign key lookups, create and refresh lookup tables, add meta data. etc. 
-- all based on the template_id. 
-- betl will try to find the src object. If its name is ambiguous, it will trhow an error

/*

exec betl.def.setp 'log_level', debug
exec betl.dbo.push 'AdventureWorks2014.Production.Product'
exec betl.def.info 'AdventureWorks2014'
exec betl.def.setp 'recreate_tables', 1 , 'My_Staging'
exec betl.def.setp 'log_level', debug

*/

CREATE PROCEDURE [dbo].[push]
    @full_object_name as varchar(255)
	, @scope as varchar(255) = null 
	, @batch_id as int = -1
	, @template_id as smallint=0

AS
BEGIN
	set nocount on 
   declare @transfer_id as int,
	@last_batch_id as int ,
	@last_batch_start_dt datetime,
	@last_batch_name varchar(100) = null 
   -- check batch
   if isnull(@batch_id ,-1) = -1  -- no batch given-> create one... 
   begin 
		 -- first check to see if there is one running. 
		 select top 1 
			@last_batch_id = batch_id
			, @last_batch_start_dt=[batch_start_dt]
			, @last_batch_name = [batch_name] 
		 from dbo.Batch
		 order by batch_id desc

		 if @last_batch_id is not null and @last_batch_name is null and 
		    abs(datediff(day, @last_batch_start_dt, getdate() ))  < 1 
		   set @batch_id = @last_batch_id 
		else 
		begin 
		  insert into dbo.Batch(batch_name, batch_start_dt) values (null, getdate()) 
		  set @batch_id = scope_identity() 
		end 
	end 

   insert into dbo.Transfer(batch_id, start_dt, src_name)
   values (@batch_id, getdate(), @full_object_name) 
   set @transfer_id = SCOPE_IDENTITY()
	-- standard BETL header code... 
	exec def.setp 'transfer_id', @transfer_id 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log '-------', '--------------------------------------------------------------------------------'
	exec dbo.log 'header', '? ? scope ? transfer_id ? template_id ?', @proc_name , @full_object_name, @scope, @transfer_id, @template_id

	--exec def.my_info

	declare @log_level as varchar(255) =''
		, @exec_sql as varchar(255) =''
	exec [def].[getp] 'LOG_LEVEL', @log_level output 
	exec [def].[getp] 'exec_sql', @exec_sql output 
	exec dbo.log 'info', 'log_level ?, exec_sql ? ', @log_level , @exec_sql

	-- END standard BETL header code... 

	declare 
			-- source
			@obj_id as int
			, @obj_name as varchar(255) 
			, @prefix as varchar(255) 
			, @obj_name_no_prefix as varchar(255) 
			, @default_template_id smallint
			, @obj_type as varchar(255) 
			, @srv as varchar(255)
			, @db as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int 
			, @cols_pos int = 1
			, @cols dbo.ColumnTable
			, @cols_str varchar(4000) 
			, @attr_cols_str varchar(4000) 

--			, @nat_prim_keys ColumnTable
			, @nat_prim_keys_str varchar(4000)
			, @nat_prim_key1 varchar(255) 
			, @nat_prim_key_match as varchar(4000) 

			, @nat_fkeys_str varchar(4000)
			, @nat_fkeys_str2 varchar(4000)
			, @sur_pkey1 varchar(255) 
			, @nat_fkey_match as varchar(4000) 
--			, @attribute_match_str varchar(4000) 

			-- target
			, @trg_obj_id as int
			, @trg_full_obj_name as varchar(255) 
			, @trg_obj_name as varchar(255) 
			, @trg_prefix as varchar(255) 
			--, @trg_obj_schema_name as varchar(255) 
			, @trg_srv as varchar(255)
			, @trg_db as varchar(255) 
			, @trg_schema as varchar(255) 
			, @trg_schema_id as int 
			, @trg_location as varchar(1000) 
			, @trg_cols dbo.ColumnTable
			, @trg_scope as varchar(255) 


			, @trg_entity_name as varchar(255) 

			-- lookup
			, @lookup_entity_name as varchar(255) 
			, @lookup_index AS INT 
			, @lookup_col_str AS VARCHAR(255) 
			, @lookup_match_str AS VARCHAR(4000) 

			-- hub
			, @hub_name as varchar(255) 
			, @lookup_hub_or_link_name as varchar(255) 
			, @sat_name as varchar(255) 
			, @link_name as varchar(255) 

			, @full_sat_name as varchar(255) 
			, @trg_sur_pkey1 as varchar(255) 

			-- Dynamic SQL 
			, @nl as varchar(2) = char(13)+char(10)
			, @p as ParamTable
			, @sql as varchar(4000) 
			, @sql2 as varchar(4000) 
			, @sql3 as varchar(4000) 
			, @lookup_sql AS varchar(4000) 
			, @from as varchar(4000) 
			, @from2 as varchar(4000) 
			, @trg_cols_str varchar(4000) 
			, @trg_cols_str_met_alias varchar(4000) 

				-- properties
			, @use_linked_server as bit 
			, @date_datatype_based_on_suffix as bit
			, @is_localhost as bit 
			, @has_synonym_id as bit 
			, @has_record_dt as bit
			, @has_record_user as bit 
			, @etl_meta_fields as bit
			, @recreate_tables as bit
			
			-- other
			, @current_db varchar(255) 	
			, @ordinal_position_offset int 
			, @transfer_start_dt as datetime
			, @catch_sql as varchar(4000) 

	select @current_db = db_name() 


	if @transfer_start_dt is null or @transfer_start_dt < '2016-01-01' -- meaning: very old 
		set @transfer_start_dt  = getdate() 

    ----------------------------------------------------------------------------
	exec dbo.log 'STEP', 'retrieve object_id from name'
	----------------------------------------------------------------------------

	exec dbo.inc_nesting
	exec def.get_obj_id @full_object_name, @obj_id output, @scope=@scope, @recursive_depth=DEFAULT, @transfer_id=@transfer_id
	exec dbo.dec_nesting

	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log 'error',  'object ? not found.', @full_object_name
		goto footer
	end
	else 
		exec dbo.log 'step' , 'object_id resolved: ?', @obj_id 

	-- first-> refresh the meta data of @obj_id

	exec dbo.inc_nesting
	exec def.refresh_obj_id @obj_id
	exec dbo.dec_nesting

	-- get all required src meta data 
	select 
	@obj_type = object_type
	, @obj_name = [object_name]

	, @prefix = [prefix]
	, @obj_name_no_prefix = [object_name_no_prefix]
	, @default_template_id = default_template_id 
	, @srv = srv
	, @db = db
	, @schema = [schema] 
	, @use_linked_server = def.get_prop_obj_id('use_linked_server', @obj_id) 
	, @date_datatype_based_on_suffix = def.get_prop_obj_id('date_datatype_based_on_suffix', @obj_id) 
	, @is_localhost = def.get_prop_obj_id('is_localhost', @obj_id) 
	, @trg_schema_id = def.get_prop_obj_id('target_schema_id', @obj_id) 
	, @full_object_name = full_object_name
	, @template_id = case when @template_id=0 then def.get_prop_obj_id('template_id', @obj_id)   else @template_id end -- don't overwrite when specified in proc call
	from def.obj_ext 
	where [object_id] = @obj_id 

	IF ISNULL(@template_id,0)  = 0  -- no transfermethod known-> guess it. 


		SET @template_id = @default_template_id
	
	exec dbo.log 'VAR', '@template_id ? ', @template_id

	IF @prefix = 'stgh' AND @template_id NOT IN (8,9) 
	BEGIN 
		exec dbo.log 'error',  'object ? is a hub/hubsat staging table and thus needs transfermethod 8 or 9.', @full_object_name
		goto footer
	END

	IF @prefix = 'stgl' AND @template_id NOT IN (10,11) 
	BEGIN 
		exec dbo.log 'error',  'object ? is a link/hubsat staging table and thus needs transfermethod 10 or 11.', @full_object_name
		goto footer
	END

	IF @prefix = 'stgd' AND @template_id NOT IN (12) 
	BEGIN 
		exec dbo.log 'error',  'object ? is a dimension staging table and thus needs transfermethod 12.', @full_object_name
		goto footer
	END
	
	IF @prefix = 'stgf' AND @template_id NOT IN (13,14) 
	BEGIN 
		exec dbo.log 'error',  'object ? is a fact staging table and thus needs transfermethod 13 or 14.', @full_object_name
		goto footer
	END

	if @obj_type not in ('table', 'view') 
	begin 
		exec dbo.log 'ERROR', 'You can only push tables and views currently, no ?', @obj_type 
		goto footer
	END
    
    if @trg_schema_id is null 
	begin
		exec dbo.log 'error',  'Unable to determine target: No target schema specified'
		goto footer
	end 
    if not isnull(@template_id,0) > 0
	begin
		exec dbo.log 'error',  'No template specified for ?. please run ''exec betl.def.setp ''template_id

GO

print '-- 37. refresh_obj_id'

	  GO
	  
	  
	  
	  


-- ============================================================================================
-- 02-03-2012 BvdB This proc will refresh the meta data of servers, 
--	databases, schemas, tables and views
-- ============================================================================================
/* 
select * from def.obj_ext where full_object_name like '%[idv]%'
select * from def.obj_ext where full_object_name like '%stgl%'
exec def.[refresh_obj_id] 108

exec betl.def.setp 'exec_sql', 0
-- instead of executing the dynamic sql, betl will print it, so you can execute and debug it yourself.


exec betl.def.setp 'log_level', 'DEBUG' 
-- controls the amount of logging that is generated by betl. 
-- ERROR: only display errors, no progress or warnings
-- WARN: Show Errors and warnings
-- INFO : show progress in current proc. ( Log headers and footers) 
-- DEBUG: : show progress in current proc and invoked procs. (nesting+1) 
-- VERBOSE:: show progress in current proc and invoked procs. (all nestings) 

*/

CREATE PROCEDURE [def].[refresh_obj_id]
    @obj_id int
	, @recursive_depth as int = 0 -- 0->only refresh full_object_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- def.refresh 'LOCALHOST', 0 will only create a record in [def].[Obj] for the server BETL
						-- def.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- def.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- def.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill def.Col_hist with all columns meta data for each table and view. 
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'Header', '? ? , depth ?', @proc_name , @obj_id, @recursive_depth
	-- END standard BETL header code... 

	-- in this proc. no matter what exec_sql says: always exec sql. 
	declare @exec_sql as int 
	exec def.getp 'exec_sql', @exec_sql output
	exec def.setp 'exec_sql', 1

	declare
			@object_name as varchar(255) 
			, @full_object_name2 varchar(255) 
			, @object_type as varchar(100)
			, @recursive_depth2 as int
			, @lookup_object_type_id as int
             ,@srv as varchar(100)
             ,@sql as varchar(8000)
             ,@sql2 as varchar(8000)
             ,@sql3 as varchar(8000)
             ,@cols_sql as varchar(8000)
             ,@cols_sql_select as varchar(8000)
             ,@db as varchar(100)
             ,@schema as varchar(255)
             ,@server_type as int
			, @nl as varchar(2) = char(13)+char(10)
			, @schema_id int
			, @parent_id int 
			, @p as ParamTable
			, @use_linked_server as bit 
	--		, @is_localhost as bit 
			, @from varchar(255) 



			, @current_db varchar(255) 
			, @full_object_name varchar(255)
			, @entity_name as varchar(255) 

	set @current_db = db_name() 
	
	select 
	@full_object_name = full_object_name
	,@object_type = object_type
	, @object_name = [object_name]
	, @srv = srv
	, @db = db
	, @schema = [schema] 
	--, @parent_id = [parent_id] 
	, @use_linked_server = def.get_prop_obj_id('use_linked_server', @obj_id ) 
--	, @is_localhost = def.get_prop_obj_id('is_localhost', @obj_id )  
	, @entity_name = lower(object_name)
	from def.obj_ext 
	where object_id = @obj_id
	
--	exec dbo.log 'var', 'object ?.?.?.?', @srv, @db, @schema, @object_name

	if @object_type = 'server'
	begin 
	  -- lookup all db's on this server
	  set @lookup_object_type_id = def.const('database') 
	  exec dbo.log 'step', 'refreshing server ?', @object_name
	  if @use_linked_server = 1 
	     set @from = 'openquery([<srv>], "select name from sys.databases order by name" )  '
	  else 
		set @from = 'sys.databases'

	  set @sql2 = '
select distinct <object_type_id> object_type_id, NAME object_name, <parent_id> parent_id
from <from> 
where name not in ("master","model","msdb","tempdb") '
				   
  	  set @sql = '
insert into [def].[Obj] (object_type_id, object_name, parent_id) 
	<sql2>
	and NAME not in ( 
		select object_name  from [def].[Obj] where parent_id= <parent_id>)
	order by 2
						
update [def].[Obj] 				 			 
set delete_dt = 
	case when q.object_name is null and Obj.delete_dt is null then <dt> 
	when q.object_name is not null and Obj.delete_dt is not null then null end
from [def].[Obj] 
left join (<sql2>) q on Obj.object_name = q.object_name
where obj.parent_id = <parent_id> 
and  ( (q.object_name is null     and Obj.delete_dt is null ) or 
(q.object_name is not null and Obj.delete_dt is not null ) )
'
	end 

	if @object_type = 'database'
	begin 
		-- lookup all schemas in this db
	   set @lookup_object_type_id= def.const('schema') 
	   exec dbo.log 'step', 'refreshing database ?', @object_name
	   if @use_linked_server = 1 
		 set @from = 'openquery(<srv>, "select SCHEMA_NAME , schema_owner from <db>.information_schema.SCHEMATA order by SCHEMA_NAME" )  '
	  else 
		set @from =  '<db>.information_schema.SCHEMATA	'

		set @sql2 = ' select distinct <object_type_id> object_type_id, [SCHEMA_NAME] collate Latin1_General_CI_AS as [object_NAME], <parent_id> parent_id
									 from <from> '
  		set @sql = '
insert into [def].[Obj] (object_type_id, object_name, parent_id) 
	<sql2>
where schema_owner = "dbo" and [schema_NAME] collate Latin1_General_CI_AS not in ( 
	select object_name from [def].[Obj] where parent_id = <parent_id> )
					
update [def].[Obj] 				 			 
set delete_dt = case 
when q.object_name is null and Obj.delete_dt is null then <dt> 
when q.object_name  is not null and Obj.delete_dt is not null then null end
from [def].[Obj] 
left join (<sql2>) q on Obj.object_name = q.object_name 
where Obj.parent_id = <parent_id> 



and  ( (q.object_name is null     and Obj.delete_dt is null ) or 
	(q.object_name is not null and Obj.delete_dt is not null ) )
'
	end 

	if @object_type = 'schema'
	begin 
		-- lookup all tables and view in this schema 
	   exec dbo.log 'step', 'refreshing schema ?', @object_name
	   set @sql3 = ' select distinct table_name object_name, table_type, p.prefix_name prefix
					 from <db>.information_schema.tables 
					 left join [def].Prefix p on [util].[prefix_first_underscore](table_name) = p.prefix_name collate Latin1_General_CI_AS 
					 where table_schema = "<schema>"
				  '

	   if @use_linked_server = 1 
		 set @sql2 = 'select object_name from openquery(<srv>, "<sql3>" )  '
  	     else 
		set @sql2 = @sql3

  		set @sql = '
insert into [def].[Obj] (object_type_id, object_name, parent_id, prefix, object_name_no_prefix ) 
select case when table_type = "VIEW" then def.const("view") else def.const("table") end object_type_id
		, object_name, <parent_id> parent_id 
		, prefix
		, case when prefix is not null and len(prefix)>0 then substring(object_name, len(prefix)+2, len(object_name) - len(prefix)-1) else object_name end object_name_no_prefix
		from 
	(<sql2>) q 
where q.object_name collate Latin1_General_CI_AS not in ( 
	select object_name  from [def].[Obj] where parent_id = <parent_id> )
order by q.object_name
					
update [def].[Obj] 				 			 
set delete_dt = case 
when q.object_name is null and Obj.delete_dt is null then <dt> 
when q.object_name  is not null and Obj.delete_dt is not null then null end
from [def].[Obj] 
left join (<sql2>) q on Obj.object_name = q.object_name collate Latin1_General_CI_AS 
where Obj.parent_id = <parent_id> 
and  ( (q.object_name is null     and Obj.delete_dt is null ) or 
	(q.object_name is not null and Obj.delete_dt is not null ) )
					'
	end 

	if @object_type in ( 'table', 'view' ) 
	begin 
		exec dbo.log 'step', 'refreshing ? ?', @object_type, @object_name
		set @cols_sql_select = '
select 
	<obj_id> object_id 
, ordinal_position
, column_name collate Latin1_General_CI_AS column_name
, case when is_nullable="YES" then 1 whe

GO

print '-- 38. schema_name'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: <Create Date,,>
-- Description:	return schema name of this full object name 
--  e.g. C2H_PC.AdventureWorks2014.Person.Sales ->C2H_PC.AdventureWorks2014.Person
-- =============================================

--select def.schema('C2H_PC.AdventureWorks2014.Person.Sales') --> points to table 

CREATE FUNCTION [def].[schema_name]( @fullObj_name varchar(255) , @scope varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @schema_id as int 
		, @res as varchar(255) =''
		select @schema_id = def.schema_id(@fullObj_name, @scope ) 


	select @res = [full_object_name] --isnull('['+ srv + '].', '') +  isnull('['+db +'].','') + '['+ [schema] + ']'
	from def.obj_ext 
	where [object_id] = @schema_id



	return @res 
END














GO

print '-- 39. start_run'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author:		Bas van den Berg
-- Create date: 30-07-2015
-- Description:	this proc starts the betl engine.
-- syntax:
-- run '<CMD> <src> |<trg>|'

-- <CMD> = PUSH | TRUNC
-- <src> = string in format [<server>.][<db>.][<schema>.]<object>;
-- <trg> = string in format [<server>.][<db>.][<schema>.]<object>;

-- example 1: exec def.run 'PUSH AdventureWorks2014.def.Invoice' -- derive trg using default target schema for AdventureWorks.def
-- example 2: exec def.run 'PUSH localhost.AdventureWorks2014.def.Invoice'

-- betl will try to find the src object. If its name is ambiguous, it will trhow an error, otherwise it
-- will transfer the table using the tranfer_method defined 

-- SCOPE: 
-- in SSIS we enter the command string in the name of the Control flow item. So we like to keep it short and simple (no full object names). 
-- For this reason we added the scope parameter, which can be added automatically via SSIS using a package variable.  
-- The scope refers to one or more objects ( via the scope property). I usually link a scope only to a single schema object. 

-- example 3: exec def.run 'PUSH Invoice', 'AW'
-- The schema localhost.AdventureWorks2014.def has a scope property named 'AW'

-- example 4: exec def.run 'Refresh Invoice', 'AW'


-- =============================================

CREATE  PROCEDURE [dbo].[start_run]
	-- Add the parameters for the stored procedure here
	@cmd_str as varchar(2000)
	,@scope as varchar(255) = null 
	,@transfer_id int=-1  -- this id is used for logging and lineage. It refers to the Transfer that called this usp. e.g. a SSIS package. 
AS
BEGIN
	set nocount on
	exec def.setp 'nesting', 0 -- reset nesting
	exec def.setp 'transfer_id', @transfer_id 

	declare @log_level_id  as smallint
		, @log_level as varchar(255)
		, @exec_sql as bit

	exec def.getp 'log_level', @log_level OUTPUT
	if @log_level is null  -- no log level set yet-> make it INFO
		exec def.setp 'log_level', 'INFO'

	exec def.getp 'exec_sql', @exec_sql OUTPUT
	if @exec_sql  is null  
	begin
		set @exec_sql  = 1 -- default
		exec def.setp 'exec_sql',@exec_sql  
	end

	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'header', '? "?", "?", ?', @proc_name , @cmd_str , @scope, @transfer_id
	-- END standard BETL header code... 
	
	exec def.getp 'log_level',  @log_level output
	exec dbo.log 'INFO', 'log_level=?, exec_sql=?', @log_level, @exec_sql

	declare 
		@cmd as varchar(255)
		,@src as varchar(255)
		,@param1 as varchar(255)

	--declare @lst SplitList
	--insert into @lst select * from def.Split(@cmd_str, ' ')
	--select @src = def.trim(item, 1) from @lst where i=2

	declare @i as int 
	set @i = CHARINDEX(' ',@cmd_str,0)
	if not @i>0 
	   set @i = len(@cmd_str)+1  -- e.g. for run 'info'

	select @cmd = def.trim(  SUBSTRING(@cmd_str,1,@i-1) ,1 )

	select @src = def.trim(  SUBSTRING(@cmd_str,@i, len(@cmd_str) - @i+1)  ,1 )


	--select @param1 = def.trim(item, 1) from @lst where i=3

	exec dbo.log 'step' , 'cmd: ?, src: ?, param1: ?',  @cmd, @src, @param1

	if @cmd not in ( 'PUSH', 'HIS', 'TRUNC', 'REFRESH', 'INFO', 'REFRESH_VIEWS') 
	begin 
		exec dbo.log 'ERROR' , 'Invalid Command ?',@cmd
		goto footer
	end

	if @cmd in( 'REFRESH') 
	begin 
		exec dbo.inc_nesting
		exec def.refresh @src, @scope, @param1, @transfer_id
		exec dbo.dec_nesting

		exec def.info @src, @scope,  @transfer_id
	end 

	if @cmd in( 'INFO') 
	begin 
		exec def.info @src,  @scope, @transfer_id
	end 
	
	if @cmd in( 'PUSH', 'STG', 'L0') 
	begin 
		exec dbo.inc_nesting
		--print 'src='+ @src 
		exec dbo.push @src, @scope, @transfer_id
		exec dbo.dec_nesting

		exec dbo.log 'step' , '@cmd ?',  @cmd
	end 
	
	if @cmd in( 'REFRESH_VIEWS') 
	begin 
		exec dbo.log 'step' , '@cmd ? ?',  @cmd, @param1
		exec util.refresh_views @param1
	end 

	-- standard BETL footer code... 
	footer:
	exec dbo.log 'footer', 'DONE ? "?", "?", ?', @proc_name , @cmd_str , @scope, @transfer_id
	-- END standard BETL footer code... 
END
















GO

print '-- 40. dec_nesting'

	  GO
	  
	  
	  
	  

/*
log_level

10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [dbo].[dec_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec def.getp 'nesting', @nesting output

	set @nesting = isnull(@nesting-1, 0) 
	exec def.setp  'nesting', @nesting
end
















GO

print '-- 41. exec_sql'

	  GO
	  
	  
	  
	  

-- =============================================
-- Author		: Bas van den Berg
-- License		: GNU General Public License version 3 (GPLv3)
-- Project	    : http://betl.codeplex.com 
-- Description	: 
-- =============================================
CREATE PROCEDURE [dbo].[exec_sql]
	@sql as varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @exec_sql bit


	--exec def.get_var 'log_level_id', @log_level_id output
	--if @log_level_id is null 
	--	set @log_level_id= 30 -- info 

	--exec def.get_var 'nesting', @nesting output
	--if @nesting is null 
	--	set @nesting=0

	exec def.getp 'exec_sql', @exec_sql output
	if @exec_sql is null 
		set @exec_sql=1

	exec dbo.log 'sql', @sql -- whether sql is logged is determined in usp log

	--if @log_level_id>40 -- debug and verbose
	--	if not @nesting>1 -- for debug and verbose -> only exec nesting>1 
	--		return
	--	return -- don

		if @exec_sql =1 
			exec(@sql)
/*	  end try
	  begin catch
	    
		PRINT 
				'-- Error ' + CONVERT(VARCHAR(50), ERROR_NUMBER()) +
				', Severity ' + CONVERT(VARCHAR(5), ERROR_SEVERITY()) +
				', State ' + CONVERT(VARCHAR(5), ERROR_STATE()) + 
				', Line ' + CONVERT(VARCHAR(5), ERROR_LINE())+
				', Msg ' + CONVERT(VARCHAR(1000), ERROR_MESSAGE())+ 
				', SQL: '
		print @sql 
	end catch*/


END














GO

print '-- 42. get_prop'

	  GO
	  
	  
	  
	  


-- select  def.get_prop('use_linked_server' , 'C2H_PC')

CREATE function [def].[get_prop] (
	@prop varchar(255)
	, @fullObj_name varchar(255) 
	, @scope as varchar(255) = null 
	)
returns varchar(255) 

as 
begin
	declare @obj_id as int 
	Set @obj_id = def.object_id(@fullObj_name, @scope) 
	return def.get_prop_obj_id(@prop, @obj_id) 
end













GO

print '-- 43. inc_nesting'

	  GO
	  
	  
	  
	  

/*
log_level

10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [dbo].[inc_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec def.getp 'nesting', @nesting output

	set @nesting = isnull(@nesting+1 , 1) 
	exec def.setp 'nesting', @nesting
end
















GO

print '-- 44. log'

	  GO
	  
	  
	  
	  





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- exec set_var 'log_depth', 3
/*
exec dbo.log 'info', 'test'

exec dbo.log 'info', 
'
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
'
*/

CREATE PROCEDURE [dbo].[log](
--	  @log_level smallint
	--@transfer_id as int
	 @log_type varchar(50)  -- ERROR, WARN, INFO, DEBUG
	, @msg as varchar(max) 
	, @i1 as sql_variant = null
	, @i2 as sql_variant = null
	, @i3 as sql_variant = null
	, @i4 as sql_variant = null
	, @i5 as sql_variant = null
)

AS
BEGIN
	SET NOCOUNT ON;
	
	declare @transfer_id as int
	exec def.getp 'transfer_id', @transfer_id output -- we don't want to give 

	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @log_level varchar(255) 
			, @exec_sql as bit
			, @short_msg AS VARCHAR(255) 


	exec def.getp 'log_level', @log_level output 
	exec def.getp 'exec_sql' , @exec_sql output
	exec def.getp 'nesting' , @nesting output

	select @log_level_id = log_level_id
	from util.[Log_level]
	where log_level = @log_level

	if @log_level_id  is null 
	begin
		set @short_msg  = 'invalid log_level '+isnull(@log_level, '' )
		RAISERROR( @short_msg    ,15,1) WITH SETERROR
		goto footer
	end


	select @log_type_id = log_type_id, @min_log_level_id = min_log_level_id
	from util.Log_type
	where log_type = @log_type

	if 	@log_type_id = null 
	begin
		set @short_msg  = 'invalid log_type '+isnull(@log_type, '' )
		RAISERROR( @short_msg    ,15,1) WITH SETERROR
		goto footer
	end

	--print 'log_type:'+ @log_type
	--print 'log_type_id:'+ convert(varchar(255), @log_type_id) 
	--print 'log_level_id:'+ convert(varchar(255), @log_level_id) 
	--print 'log_depth:'+ convert(varchar(255), @log_depth) 

	
	if @log_level_id < @min_log_level_id -- e.g. level = ERROR, but type = sql -> 40 
		return -- don't log
	
	if @nesting>1 and @log_level_id < 50 and @log_type_id not in ( 10,20) -- header, footer
		return -- when log_level not verbose then don't log level 2 and deeper (other than header and footer).

	-- first replace ? by %1 
	declare @i as int=0
			, @j as int = 1
			,@n int = len(@msg)
	set @i = charIndex('?', @msg, @i) 
	while @i>0 
	begin
		set @msg =  SUBSTRING(@msg,1,@i-1)+ '%'+CONVERT(varchar(2), @j) +SUBSTRING(@msg,@i+1, @n-@i+1)
		set @j+= 1
		set @n = len(@msg)
		set @i = charIndex('?', @msg,@i) 
	end 
	
	if @i1 is not null and CHARINDEX('%1', @msg)=0 
		set @msg += ' @i1'
	if @i2 is not null and CHARINDEX('%2', @msg)=0 
		set @msg += ', @i2'
	if @i3 is not null and CHARINDEX('%3', @msg)=0 
		set @msg += ', @i3'
	if @i4 is not null and CHARINDEX('%4', @msg)=0 
		set @msg += ', @i4'
	if @i5 is not null and CHARINDEX('%5', @msg)=0 



		set @msg += ', @i5'
		
	set @msg = replace(@msg, '%1', isnull(convert(varchar(max), @i1), '?') )
	set @msg = replace(@msg, '%2', isnull(convert(varchar(max), @i2), '?') )
	set @msg = replace(@msg, '%3', isnull(convert(varchar(max), @i3), '?') )
	set @msg = replace(@msg, '%4', isnull(convert(varchar(max), @i4), '?') )
	set @msg = replace(@msg, '%5', isnull(convert(varchar(max), @i5), '?') )
	
	
	set @msg = replicate('  ', @nesting)+'-- '+upper(@log_type) + ': '+@msg
	
	--if charindex(@nl, @msg,0) >0 -- contains nl 
	--	set	@msg = '/*'+@nl+@msg+@nl+'*/'
	--set @msg = replace(@msg, @nl , @nl + '--') -- when logging sql prefix with --
	
	SET @short_msg = substring(@msg, 0, 255) 
	if @log_type = 'ERROR'
		RAISERROR( @short_msg ,15,1) WITH SETERROR
--	end
--	ELSE
--		RAISERROR(@msg,10,1) WITH NOWAIT
	PRINT @msg
    
	insert into dbo.Transfer_log
	values( getdate(), @msg, @transfer_id, @log_level_id, @log_type_id, @exec_sql) 
	
    footer:
END

















GO

print '-- 45. my_info'

	  GO
	  
	  
	  
	  


-- =============================================
-- Author:          Bas van den Berg
-- Create date: 02-03-2012
-- ============================================

-- this proc prints out all user bound properties / settings 
-- exec [def].[my_info]
CREATE PROCEDURE [def].[my_info]

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  
		@nesting as smallint
		, @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @output as varchar(max) = ''-- '-- Properties for '+ suser_sname() + ': 
	--exec dbo.log 'INFO', 'Properties for ? : ', suser_sname() 
	
	exec def.getp 'nesting' , @nesting output

	select @output += replicate('  ', @nesting)+'-- ' +  isnull(property,'?') + ' = ' + isnull(value, '?') + '
'
	from def.Prop_ext
--	cross apply dbo.log 'footer', 'DONE ? ', @proc_name 
	where [full_object_name] = suser_sname() 

	print @output 

    footer:
	exec dbo.log 'footer', 'DONE ? ', @proc_name 
END





















GO

print '-- 46. refresh'

	  GO
	  
	  
	  
	  
-- =============================================
-- Author      : Bas van den Berg
-- Create date : 02-03-2012
-- Description : This proc will refresh the meta data of servers, databases, schemas, tables and views
-- ============================================

/* 
exec def.refresh 'LOCALHOST',0
exec def.refresh '[LOCALHOST].[AdventureWorks2014]'
exec def.refresh 'LOCALHOST.My_Staging.NF.Center'

*/


CREATE PROCEDURE [def].[refresh]
    @full_object_name as varchar(255) 
	, @recursive_depth as int = 0 -- 0->only refresh full_object_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- def.refresh 'LOCALHOST', 0 will only create a record in def._Object for the server BETL
						-- def.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- def.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- def.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill his._Column with all columns meta data for each table and view. 
	, @scope as varchar(255) = null
	, @transfer_id as int = -1

AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'header', '? ? , scope ?, depth ?', @proc_name , @full_object_name, @scope, @recursive_depth
	-- END standard BETL header code... 

	declare @obj_id as int
	
	exec def.get_obj_id @full_object_name, @obj_id output, @scope, @recursive_depth, @transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log 'step', 'Object ? not found in scope ? .', @full_object_name, @scope 
		goto footer
	end
	else
	begin 
		exec dbo.log 'step', 'object_id resolved: ?, scope ? ', @obj_id , @scope
		exec def.refresh_obj_id @obj_id, @recursive_depth, @transfer_id
	end
	
	-- standard BETL footer code... 
    footer:
	exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @full_object_name, @recursive_depth, @transfer_id
	-- END standard BETL footer code... 

END






GO

print '-- 47. set_target_schema'

	  GO
	  
	  
	  
	  

-- =============================================
-- 2017-09-06 BvdB Sets the target schema for @full_object_name 
-- =============================================

CREATE procedure [def].[set_target_schema] 
	@full_object_name as varchar(4000) ,
	@target_schema_name as varchar(4000)
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	exec dbo.log 'header', '? ? , ?', @proc_name , @full_object_name, @target_schema_name
	-- END standard BETL header code... 

	declare @schema_id as int
	exec def.get_obj_id @target_schema_name , @schema_id output

	exec betl.def.setp 'target_schema_id'
		, @schema_id 
		, @full_object_name

	-- standard BETL footer code... 
    footer:
	exec dbo.log 'footer', 'DONE ? ? , ? (?)', @proc_name , @full_object_name, @target_schema_name, @schema_id 
	-- END standard BETL footer code... 

end 






GO

print '-- 48. setp'

	  GO
	  
	  
	  
	  


-- exec def.setp 'transfer_id', 100
-- select * from def.Prop_ext
CREATE PROCEDURE [def].[setp] 
	@prop varchar(255)
	, @value varchar(255)
	, @full_object_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 

as 

begin 
	-- standard BETL header code... 
	set nocount on 
	declare    @proc_name as varchar(255) =  OBJECT_NAME(@@PROCID);
	--exec dbo.log 'header', '? ? ?', @proc_name , @prop, @full_object_name
	-- END standard BETL header code... 

  -- first determine property_scope 
  declare @property_scope as varchar(255) 
		, @object_id int
		, @prop_id as int 
		, @debug as bit = 0

  select @property_scope = property_scope , @prop_id = property_id
  from def.Prop_ext
  where [property]=@prop

  if @prop_id is null 
  begin 
	if @debug =1 
		exec dbo.log 'ERROR', 'Property ? not found in def.Property ', @prop
	goto footer
  end

  if @property_scope is null 
  begin 
	if @debug =1 
		exec dbo.log 'ERROR', 'property_scope ? is not defined in def.Property', @property_scope
	goto footer
  end
  -- property_scope is not null 

  if @property_scope = 'user' -- then we need the obj_id of the current user
  begin
	set @full_object_name = suser_sname()
  end

  exec [def].[get_obj_id] @full_object_name, @object_id output, @scope=DEFAULT, @recursive_depth=DEFAULT, @transfer_id=@transfer_id
  if @object_id  is null 
  begin 
		if @property_scope = 'user' -- then create object_id 
		begin
			insert into def.Obj (object_type_id, object_name) 
			values (60, @full_object_name)
			
			exec [def].[get_obj_id] @full_object_name, @object_id output, @scope=DEFAULT, @recursive_depth=DEFAULT, @transfer_id=@transfer_id	
		end

		if @object_id is null 
		begin
			if @debug =1 
				exec dbo.log 'ERROR', 'object not found ? , property_scope ? ', @full_object_name , @property_scope
			goto footer
		end 
			
	end

	if @debug =1 
		exec dbo.log 'var', 'object ? (?) , property_scope ? ', @full_object_name, @object_id , @property_scope 
		
	-- delete any existing value. 
	delete from def.Property_value 
	where object_id = @object_id and property_id = @prop_id 

	insert into def.Property_value ( property_id, [object_id], value) 
	values (@prop_id , @object_id, @value)

--	select * from [def].[Property_ext]	where object_id = @object_id and property like @prop

    footer:
	--exec dbo.log 'footer', 'DONE ? ? ? ?', @proc_name , @prop, @value , @full_object_name
	-- END standard BETL footer code... 
end
















GO


GO
set nocount on 
GO
insert into def.Obj(object_type_id, object_name)
values ( 50, 'LOCALHOST')
GO
exec def.setp 'is_localhost', 1 , 'LOCALHOST'
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (0, N'Unknown')
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (100, N'Success')
GO
INSERT [dbo].[Status] ([transfer_status_id], [transfer_status_name]) VALUES (200, N'Error')


GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N'Unknown', N'Unknown,  not relevant', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')


GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N'nat_pkey', N'Natural primary key (e.g. user_key)', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N'nat_fkey', N'Natural foreign key (e.g. create_user_key)', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N'sur_pkey', N'Surrogate primary key (e.g. user_id)', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N'sur_fkey', N'Surrogate foreign key (e.g. create_user_id)', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N'attribute', N'low or non repetetive value for containing object. E.g. customer lastname, firstname.', CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N'meta data', NULL, CAST(N'2015-10-20T13:22:19.590' AS DateTime), N'bas')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (10, N'table')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (20, N'view')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (30, N'schema')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (40, N'database')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (50, N'server')
GO
INSERT [def].[Object_type] ([object_type_id], [object_type]) VALUES (60, N'user')
GO


INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgd', 12)

GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgf', 13)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgh', 8)
GO
INSERT [def].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgl', 10)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N'target_schema_id', N'used for deriving target table', N'db_object', NULL, 0, 0, 1, 1, NULL, NULL, CAST(N'2015-08-31T13:18:22.073' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (15, N'template_id', N'which ETL template to use (see def.Template) ', N'db_object', NULL, 1, 1, 1, 1, NULL, NULL, CAST(N'2017-09-07T09:12:49.160' AS DateTime), N'C2H_PC\BAS')


GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N'has_synonym_id', N'apply syn pattern (see biblog.nl)', N'db_object', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N'2015-08-31T13:18:56.070' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N'has_record_dt', N'add this column (insert date time) to all tables', N'db_object', NULL, 0, 0, 0, 0, 1, NULL, CAST(N'2015-08-31T13:19:09.607' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N'has_record_user', N'add this column (insert username ) to all tables', N'db_object', NULL, 0, 0, 1, 0, 1, NULL, CAST(N'2015-08-31T13:19:15.000' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N'use_linked_server', N'assume that servername = linked_server name. Access server via linked server', N'db_object', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-08-31T17:17:37.830' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N'date_datatype_based_on_suffix', N'if a column ends with the suffix _date then it''s a date datatype column (instead of e.g. datetime)', N'db_object', N'1', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-02T13:16:15.733' AS DateTime), N'C2H_PC\BAS')

GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N'is_localhost', N'This server is localhost. For performance reasons we don''t want to access localhost via linked server as we would with external sources', N'db_object', N'0', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-24T16:22:45.233' AS DateTime), N'C2H_PC\BAS')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N'recreate_tables', N'This will drop and create tables (usefull during initial development)', N'db_object', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)


GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N'prefix_length', N'This object name uses a prefix of certain length x. Strip this from target name. ', N'db_object', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N'etl_meta_fields', N'etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source', N'db_object', N'1', NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (110, N'transfer_id', N'Unique number identifying a transfer that loaded data into a table. ', N'user', N'0', NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL)
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (120, N'exec_sql', N'set this to 0 to print the generated sql instead of executing it. usefull for debugging', N'user', N'1', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:04:49.867' AS DateTime), N'')
GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (130, N'log_level', N'controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE', N'user', N'INFO', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:06:12.167' AS DateTime), N'')

GO
INSERT [def].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (140, N'nesting', N'used by dbo.log in combination with log_level  to determine wheter or not to print a message', N'user', N'0', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:08:02.967' AS DateTime), N'')
GO


INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (1, N'truncate_insert', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (2, N'drop_insert', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (3, N'delta insert based on a first sequential ascending column', NULL, NULL)


GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (4, N'transform based on content type (auto-generate L2 view)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (5, N'transform based on content type (don''t generate L2 view)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (6, N'transfer to switching tables (Datamart)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (7, N'delta insert based on eff_dt column', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (8, N'Datavault Hub & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (9, N'Datavault Hub Sat (part of transfer_method 8)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (10, N'Datavault Link & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (11, N'Datavault Link Sat (part of transfer_method 10)', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (12, N'Kimball Dimension', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (13, N'Kimball Fact', NULL, NULL)
GO
INSERT [def].[Template] ([template_id], [template], [record_dt], [record_name]) VALUES (14, N'Kimball Fact Append', NULL, NULL)
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (10, N'ERROR', N'Only log errors')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (20, N'WARN', N'Log errors and warnings (SSIS mode)')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (30, N'INFO', N'Log headers and footers')

GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (40, N'DEBUG', N'Log everything only at top nesting level')
GO
INSERT [util].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (50, N'VERBOSE', N'Log everything all nesting levels')
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (10, N'Header', 30)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (20, N'Footer', 30)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (30, N'SQL', 40)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (40, N'VAR', 40)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (50, N'Error', 10)
GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (60, N'Warn', 20)


GO
INSERT [util].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (70, N'Step', 30)
GO

--END BETL Release version 3.0.68 , date: 2017-09-12 14:52:54
