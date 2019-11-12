
-- START BETL Release version 3.2.2 , date: 2019-11-12 10:11:25
set nocount on 
use betl 
-- WARNING: This will clear the betl database !
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'ddl_clear')
	exec dbo.ddl_clear @execute=1
-- schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'util')
begin
	EXEC sys.sp_executesql N'CREATE SCHEMA [util]'
	exec sp_addextendedproperty  
		 @name = N'Description' 
		,@value = N'Generic utility data and functions' 
		,@level0type = N'Schema', @level0name = 'util' 
end
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'static')
begin 
	EXEC sys.sp_executesql N'CREATE SCHEMA [static]'
	exec sp_addextendedproperty  
		 @name = N'Description' 
		,@value = N'Static betl data, not dependent on customer implementation' 
		,@level0type = N'Schema', @level0name = 'static' 
end-- end schemas
IF NOT EXISTS (SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = schema_ID('dbo') AND [name] = N'Description' AND [minor_id] = 0)
exec sp_addextendedproperty  
	@name = N'Description' 
	,@value = N'dbo data is specific for each customer implementation' 
	,@level0type = N'Schema', @level0name = 'dbo' 
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
	[src_mapping] varchar(255) null
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
	[param_value] varchar(max) NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](max) NULL,
	[i] [int] NULL
)
GO
-- end user defined tables
-- create table [static].[Log_level]
GO
CREATE TABLE [static].[Log_level]
(
	  [log_level_id] SMALLINT NOT NULL
	, [log_level] VARCHAR(50) NULL
	, [log_level_description] VARCHAR(255) NULL
	, CONSTRAINT [PK_Log_level_1] PRIMARY KEY ([log_level_id] ASC)
)

-- create table [static].[Log_type]
GO
CREATE TABLE [static].[Log_type]
(
	  [log_type_id] SMALLINT NOT NULL
	, [log_type] VARCHAR(50) NULL
	, [min_log_level_id] INT NULL
	, CONSTRAINT [PK_Log_type_1] PRIMARY KEY ([log_type_id] ASC)
)

-- create table [static].[Version]
GO
CREATE TABLE [static].[Version]
(
	  [major_version] INT NOT NULL
	, [minor_version] INT NOT NULL
	, [build] INT NOT NULL
	, [build_dt] DATETIME NULL
	, CONSTRAINT [PK_Version] PRIMARY KEY ([major_version] ASC, [minor_version] ASC, [build] ASC)
)

-- create table [static].[Dep_type]
GO
CREATE TABLE [static].[Dep_type]
(
	  [dep_type_id] SMALLINT NOT NULL
	, [dep_type] VARCHAR(100) NULL
	, [dep_type_description] VARCHAR(255) NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(255) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK_Dep_type] PRIMARY KEY ([dep_type_id] ASC)
)

-- create table [dbo].[Obj_dep]
GO
CREATE TABLE [dbo].[Obj_dep]
(
	  [obj_id] INT NOT NULL
	, [dep_obj_id] INT NOT NULL
	, [dep_type_id] SMALLINT NOT NULL
	, [top_sort_rank] SMALLINT NULL
	, [delete_dt] DATETIME NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(50) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK__Obj_dep__7C69C680D927C550] PRIMARY KEY ([obj_id] ASC, [dep_obj_id] ASC, [dep_type_id] ASC)
)

ALTER TABLE [dbo].[Obj_dep] WITH CHECK ADD CONSTRAINT [FK_Obj_dep_Dep_type] FOREIGN KEY([dep_type_id]) REFERENCES [static].[Dep_type] ([dep_type_id])
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Dep_type]

ALTER TABLE [dbo].[Obj_dep] WITH CHECK ADD CONSTRAINT [FK_Obj_dep_Obj] FOREIGN KEY([obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Obj]

ALTER TABLE [dbo].[Obj_dep] WITH CHECK ADD CONSTRAINT [FK_Obj_dep_Obj1] FOREIGN KEY([dep_obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Obj1]

-- create table [dbo].[Obj]
GO
CREATE TABLE [dbo].[Obj]
(
	  [obj_id] INT NOT NULL IDENTITY(1,1)
	, [obj_type_id] INT NOT NULL
	, [server_type_id] INT NULL DEFAULT((10))
	, [obj_name] NVARCHAR(128) NOT NULL
	, [parent_id] INT NULL
	, [scope] NVARCHAR(50) NULL
	, [identifier] INT NULL
	, [template_id] SMALLINT NULL
	, [delete_dt] DATETIME NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] NVARCHAR(50) NULL DEFAULT(suser_sname())
	, [prefix] NVARCHAR(50) NULL
	, [obj_name_no_prefix] NVARCHAR(128) NULL
	, CONSTRAINT [PK__Obj] PRIMARY KEY ([obj_id] DESC)
)

ALTER TABLE [dbo].[Obj] WITH CHECK ADD CONSTRAINT [FK__obj__obj] FOREIGN KEY([parent_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Obj] CHECK CONSTRAINT [FK__obj__obj]

ALTER TABLE [dbo].[Obj] WITH CHECK ADD CONSTRAINT [FK_Obj_Template] FOREIGN KEY([template_id]) REFERENCES [static].[Template] ([template_id])
ALTER TABLE [dbo].[Obj] CHECK CONSTRAINT [FK_Obj_Template]

ALTER TABLE [dbo].[Obj] WITH CHECK ADD CONSTRAINT [FK_Obj_Obj_type] FOREIGN KEY([obj_type_id]) REFERENCES [static].[Obj_type] ([obj_type_id])
ALTER TABLE [dbo].[Obj] CHECK CONSTRAINT [FK_Obj_Obj_type]

ALTER TABLE [dbo].[Obj] WITH CHECK ADD CONSTRAINT [FK_Obj_Server_type] FOREIGN KEY([server_type_id]) REFERENCES [static].[Server_type] ([server_type_id])
ALTER TABLE [dbo].[Obj] CHECK CONSTRAINT [FK_Obj_Server_type]

-- create table [static].[Template]
GO
CREATE TABLE [static].[Template]
(
	  [template_id] SMALLINT NOT NULL
	, [is_etl_template] BIT NULL
	, [template_name] VARCHAR(100) NULL
	, [template_description] VARCHAR(255) NULL
	, [template_sql] NVARCHAR(MAX) NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_name] VARCHAR(255) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK_Template] PRIMARY KEY ([template_id] ASC)
)

CREATE UNIQUE NONCLUSTERED INDEX [IX_Template_name] ON [static].[Template] ([template_name] ASC)

-- create table [dbo].[Error]
GO
CREATE TABLE [dbo].[Error]
(
	  [error_id] INT NOT NULL IDENTITY(1,1)
	, [error_code] INT NULL
	, [error_msg] VARCHAR(5000) NULL
	, [error_line] INT NULL
	, [error_procedure] VARCHAR(255) NULL
	, [error_procedure_id] VARCHAR(255) NULL
	, [error_execution_id] VARCHAR(255) NULL
	, [error_event_name] VARCHAR(255) NULL
	, [error_severity] INT NULL
	, [error_state] INT NULL
	, [error_source] VARCHAR(255) NULL
	, [error_interactive_mode] VARCHAR(255) NULL
	, [error_machine_name] VARCHAR(255) NULL
	, [error_user_name] VARCHAR(255) NULL
	, [transfer_id] INT NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(50) NULL
	, CONSTRAINT [PK_error_id] PRIMARY KEY ([error_id] DESC)
)

-- create table [dbo].[Col_hist]
GO
CREATE TABLE [dbo].[Col_hist]
(
	  [column_id] INT NOT NULL IDENTITY(1,1)
	, [eff_dt] DATETIME NOT NULL
	, [obj_id] INT NOT NULL
	, [column_name] VARCHAR(64) NOT NULL
	, [prefix] VARCHAR(64) NULL
	, [entity_name] VARCHAR(64) NULL
	, [foreign_column_id] INT NULL
	, [ordinal_position] SMALLINT NULL
	, [is_nullable] BIT NULL
	, [data_type] VARCHAR(100) NULL
	, [max_len] INT NULL
	, [numeric_precision] INT NULL
	, [numeric_scale] INT NULL
	, [column_type_id] INT NULL
	, [src_column_id] INT NULL
	, [delete_dt] DATETIME NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(50) NULL DEFAULT(suser_sname())
	, [chksum] INT NOT NULL
	, [transfer_id] INT NULL
	, [part_of_unique_index] BIT NULL DEFAULT((0))
	, CONSTRAINT [PK__Hst_column] PRIMARY KEY ([column_id] ASC, [eff_dt] DESC)
)

ALTER TABLE [dbo].[Col_hist] WITH CHECK ADD CONSTRAINT [FK_Col_hist_Obj] FOREIGN KEY([obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Col_hist] CHECK CONSTRAINT [FK_Col_hist_Obj]

ALTER TABLE [dbo].[Col_hist] WITH CHECK ADD CONSTRAINT [FK_Col_hist_Column_type] FOREIGN KEY([column_type_id]) REFERENCES [static].[Column_type] ([column_type_id])
ALTER TABLE [dbo].[Col_hist] CHECK CONSTRAINT [FK_Col_hist_Column_type]

CREATE UNIQUE NONCLUSTERED INDEX [IX_Unique__Column_obj_col_eff] ON [dbo].[Col_hist] ([obj_id] ASC, [column_name] ASC, [eff_dt] ASC)

-- create table [static].[Column_type]
GO
CREATE TABLE [static].[Column_type]
(
	  [column_type_id] INT NOT NULL
	, [column_type_name] VARCHAR(50) NULL
	, [column_type_description] VARCHAR(255) NULL
	, [record_dt] DATETIME NULL
	, [record_user] VARCHAR(50) NULL
	, CONSTRAINT [PK_Column_type] PRIMARY KEY ([column_type_id] ASC)
)

-- create table [dbo].[Key_domain]
GO
CREATE TABLE [dbo].[Key_domain]
(
	  [key_domain_name] VARCHAR(255) NOT NULL
	, [key_domain_id] INT NOT NULL
	, CONSTRAINT [PK_Key_domain] PRIMARY KEY ([key_domain_name] ASC)
)

-- create table [dbo].[sysdiagrams]
GO
CREATE TABLE [dbo].[sysdiagrams]
(
	  [name] SYSNAME NOT NULL
	, [principal_id] INT NOT NULL
	, [diagram_id] INT NOT NULL IDENTITY(1,1)
	, [version] INT NULL
	, [definition] VARBINARY(MAX) NULL
	, CONSTRAINT [PK__sysdiagr__C2B05B61EB360151] PRIMARY KEY ([diagram_id] ASC)
)

CREATE UNIQUE NONCLUSTERED INDEX [UK_principal_name] ON [dbo].[sysdiagrams] ([principal_id] ASC, [name] ASC)

-- create table [dbo].[Job]
GO
CREATE TABLE [dbo].[Job]
(
	  [job_id] INT NOT NULL IDENTITY(10,10)
	, [name] VARCHAR(255) NULL
	, [description] VARCHAR(255) NULL
	, [enabled] BIT NULL DEFAULT((1))
	, [category_name] VARCHAR(255) NULL
	, [job_schedule_id] INT NULL
	, CONSTRAINT [PK_Job] PRIMARY KEY ([job_id] ASC)
)

ALTER TABLE [dbo].[Job] WITH CHECK ADD CONSTRAINT [FK_Job_Job_schedule] FOREIGN KEY([job_schedule_id]) REFERENCES [dbo].[Job_schedule] ([job_schedule_id])
ALTER TABLE [dbo].[Job] CHECK CONSTRAINT [FK_Job_Job_schedule]

CREATE UNIQUE NONCLUSTERED INDEX [IX_Job] ON [dbo].[Job] ([name] ASC)

-- create table [dbo].[Transfer]
GO
CREATE TABLE [dbo].[Transfer]
(
	  [transfer_id] INT NOT NULL IDENTITY(1,1)
	, [batch_id] INT NULL
	, [transfer_name] VARCHAR(100) NULL
	, [src_obj_id] INT NULL
	, [target_name] VARCHAR(255) NULL
	, [transfer_start_dt] DATETIME NULL
	, [transfer_end_dt] DATETIME NULL
	, [status_id] INT NULL
	, [rec_cnt_src] INT NULL
	, [rec_cnt_new] INT NULL
	, [rec_cnt_changed] INT NULL
	, [rec_cnt_deleted] INT NULL
	, [last_error_id] INT NULL
	, [prev_transfer_id] INT NULL
	, [transfer_seq] INT NULL
	, CONSTRAINT [PK_transfer_id] PRIMARY KEY ([transfer_id] DESC)
)

ALTER TABLE [dbo].[Transfer] WITH CHECK ADD CONSTRAINT [FK_Transfer_Obj] FOREIGN KEY([src_obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Obj]

ALTER TABLE [dbo].[Transfer] WITH CHECK ADD CONSTRAINT [FK_Transfer_Error] FOREIGN KEY([last_error_id]) REFERENCES [dbo].[Error] ([error_id])
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Error]

ALTER TABLE [dbo].[Transfer] WITH CHECK ADD CONSTRAINT [FK_Transfer_Transfer] FOREIGN KEY([prev_transfer_id]) REFERENCES [dbo].[Transfer] ([transfer_id])
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Transfer]

ALTER TABLE [dbo].[Transfer] WITH CHECK ADD CONSTRAINT [FK_Transfer_Status] FOREIGN KEY([status_id]) REFERENCES [static].[Status] ([status_id])
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Status]

ALTER TABLE [dbo].[Transfer] WITH CHECK ADD CONSTRAINT [FK_Transfer_Batch] FOREIGN KEY([batch_id]) REFERENCES [dbo].[Batch] ([batch_id])
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Batch]

CREATE UNIQUE NONCLUSTERED INDEX [ix_Transfer_batch_transfer_name_unique] ON [dbo].[Transfer] ([batch_id] ASC, [transfer_name] ASC)

CREATE NONCLUSTERED INDEX [ix_transfer_transfer_name_seq_nr] ON [dbo].[Transfer] ([transfer_name] ASC, [transfer_seq] ASC)

-- create table [static].[Status]
GO
CREATE TABLE [static].[Status]
(
	  [status_id] INT NOT NULL
	, [status_name] VARCHAR(50) NULL
	, [description] VARCHAR(255) NULL
	, CONSTRAINT [PK_Status] PRIMARY KEY ([status_id] ASC)
)

-- create table [dbo].[Job_schedule]
GO
CREATE TABLE [dbo].[Job_schedule]
(
	  [job_schedule_id] INT NOT NULL IDENTITY(10,10)
	, [name] SYSNAME NOT NULL
	, [enabled] INT NOT NULL
	, [freq_type] INT NOT NULL
	, [freq_interval] INT NOT NULL
	, [freq_subday_type] INT NOT NULL
	, [freq_subday_interval] INT NOT NULL
	, [freq_relative_interval] INT NOT NULL
	, [freq_recurrence_factor] INT NOT NULL
	, [active_start_date] INT NOT NULL
	, [active_end_date] INT NOT NULL
	, [active_start_time] INT NOT NULL
	, [active_end_time] INT NOT NULL
	, CONSTRAINT [PK_Job_schedule] PRIMARY KEY ([job_schedule_id] ASC)
)

CREATE UNIQUE NONCLUSTERED INDEX [IX_Job_schedule] ON [dbo].[Job_schedule] ([job_schedule_id] ASC)

-- create table [dbo].[Privacy]
GO
CREATE TABLE [dbo].[Privacy]
(
	  [db] VARCHAR(50) NULL
	, [table_name] NVARCHAR(255) NULL
	, [sensitive] NVARCHAR(255) NULL
	, [column_name] NVARCHAR(255) NULL
	, [personal] NVARCHAR(255) NULL
)

-- create table [dbo].[Stack]
GO
CREATE TABLE [dbo].[Stack]
(
	  [stack_id] INT NOT NULL IDENTITY(1,1)
	, [value] VARCHAR(4000) NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(255) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK_Stack] PRIMARY KEY ([stack_id] DESC)
)

-- create table [dbo].[Job_step]
GO
CREATE TABLE [dbo].[Job_step]
(
	  [job_step_id] INT NOT NULL IDENTITY(1,1)
	, [step_id] INT NULL DEFAULT((1))
	, [step_name] VARCHAR(255) NULL
	, [subsystem] VARCHAR(255) NULL DEFAULT('SSIS')
	, [command] NVARCHAR(4000) NULL
	, [on_success_action] INT NULL DEFAULT((3))
	, [on_success_step_id] INT NULL DEFAULT((0))
	, [on_fail_action] INT NULL DEFAULT((2))
	, [on_fail_step_id] INT NULL
	, [database_name] VARCHAR(255) NULL DEFAULT('master')
	, [job_id] INT NULL
	, CONSTRAINT [PK_job_step] PRIMARY KEY ([job_step_id] ASC)
)

ALTER TABLE [dbo].[Job_step] WITH CHECK ADD CONSTRAINT [FK_Job_step_Job] FOREIGN KEY([job_id]) REFERENCES [dbo].[Job] ([job_id])
ALTER TABLE [dbo].[Job_step] CHECK CONSTRAINT [FK_Job_step_Job]

-- create table [static].[Obj_type]
GO
CREATE TABLE [static].[Obj_type]
(
	  [obj_type_id] INT NOT NULL
	, [obj_type] VARCHAR(100) NULL
	, [obj_type_level] INT NULL
	, CONSTRAINT [PK_obj_type] PRIMARY KEY ([obj_type_id] ASC)
)

-- create table [dbo].[Cache_user_data]
GO
CREATE TABLE [dbo].[Cache_user_data]
(
	  [user_name] NVARCHAR(128) NOT NULL
	, [log_level] NVARCHAR(128) NULL
	, [exec_sql] BIT NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [expiration_dt] DATETIME NULL
	, CONSTRAINT [PK_Cache_1] PRIMARY KEY ([user_name] ASC)
)

-- create table [static].[Property]
GO
CREATE TABLE [static].[Property]
(
	  [property_id] INT NOT NULL
	, [property_name] VARCHAR(255) NULL
	, [description] VARCHAR(255) NULL
	, [property_scope] VARCHAR(50) NULL
	, [default_value] VARCHAR(255) NULL
	, [apply_table] BIT NULL
	, [apply_view] BIT NULL
	, [apply_schema] BIT NULL
	, [apply_db] BIT NULL
	, [apply_srv] BIT NULL
	, [apply_user] BIT NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(255) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK_Property_1] PRIMARY KEY ([property_id] ASC)
)

-- create table [dbo].[Transfer_log]
GO
CREATE TABLE [dbo].[Transfer_log]
(
	  [log_id] INT NOT NULL IDENTITY(1,1)
	, [log_dt] DATETIME NULL DEFAULT(getdate())
	, [msg] VARCHAR(MAX) NULL
	, [transfer_id] INT NULL
	, [log_level_id] SMALLINT NULL
	, [log_type_id] SMALLINT NULL
	, [exec_sql] BIT NULL
	, CONSTRAINT [PK_log_id] PRIMARY KEY ([log_id] DESC)
)

ALTER TABLE [dbo].[Transfer_log] WITH CHECK ADD CONSTRAINT [FK_Transfer_log_Log_level] FOREIGN KEY([log_level_id]) REFERENCES [static].[Log_level] ([log_level_id])
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Log_level]

ALTER TABLE [dbo].[Transfer_log] WITH CHECK ADD CONSTRAINT [FK_Transfer_log_Log_type] FOREIGN KEY([log_type_id]) REFERENCES [static].[Log_type] ([log_type_id])
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Log_type]

ALTER TABLE [dbo].[Transfer_log] WITH CHECK ADD CONSTRAINT [FK_Transfer_log_Transfer] FOREIGN KEY([transfer_id]) REFERENCES [dbo].[Transfer] ([transfer_id])
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Transfer]

-- create table [dbo].[Batch]
GO
CREATE TABLE [dbo].[Batch]
(
	  [batch_id] INT NOT NULL IDENTITY(1,1)
	, [batch_name] VARCHAR(100) NULL
	, [batch_start_dt] DATETIME NULL DEFAULT(getdate())
	, [batch_end_dt] DATETIME NULL
	, [status_id] INT NULL
	, [last_error_id] INT NULL
	, [prev_batch_id] INT NULL
	, [exec_server] VARCHAR(100) NULL DEFAULT(@@servername)
	, [exec_host] VARCHAR(100) NULL DEFAULT(host_name())
	, [exec_user] VARCHAR(100) NULL DEFAULT(suser_sname())
	, [guid] BIGINT NULL
	, [continue_batch] BIT NULL DEFAULT((0))
	, [batch_seq] INT NULL
	, CONSTRAINT [PK_run_id] PRIMARY KEY ([batch_id] DESC)
)

ALTER TABLE [dbo].[Batch] WITH CHECK ADD CONSTRAINT [FK_Batch_Error] FOREIGN KEY([last_error_id]) REFERENCES [dbo].[Error] ([error_id])
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Error]

ALTER TABLE [dbo].[Batch] WITH CHECK ADD CONSTRAINT [FK_Batch_Batch] FOREIGN KEY([prev_batch_id]) REFERENCES [dbo].[Batch] ([batch_id])
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Batch]

-- create table [static].[Server_type]
GO
CREATE TABLE [static].[Server_type]
(
	  [server_type_id] INT NOT NULL
	, [server_type] VARCHAR(100) NULL
	, [compatibility] VARCHAR(255) NULL
	, CONSTRAINT [PK_Server_type] PRIMARY KEY ([server_type_id] ASC)
)

-- create table [dbo].[Property_value]
GO
CREATE TABLE [dbo].[Property_value]
(
	  [property_id] INT NOT NULL
	, [obj_id] INT NOT NULL
	, [value] VARCHAR(255) NULL
	, [record_dt] DATETIME NULL DEFAULT(getdate())
	, [record_user] VARCHAR(255) NULL DEFAULT(suser_sname())
	, CONSTRAINT [PK_Property_Value] PRIMARY KEY ([property_id] ASC, [obj_id] ASC)
)

ALTER TABLE [dbo].[Property_value] WITH CHECK ADD CONSTRAINT [FK_Property_value_Obj] FOREIGN KEY([obj_id]) REFERENCES [dbo].[Obj] ([obj_id])
ALTER TABLE [dbo].[Property_value] CHECK CONSTRAINT [FK_Property_value_Obj]

ALTER TABLE [dbo].[Property_value] WITH CHECK ADD CONSTRAINT [FK_Property_value_Property] FOREIGN KEY([property_id]) REFERENCES [static].[Property] ([property_id])
ALTER TABLE [dbo].[Property_value] CHECK CONSTRAINT [FK_Property_value_Property]

-- create table [dbo].[Prefix]
GO
CREATE TABLE [dbo].[Prefix]
(
	  [prefix_name] VARCHAR(100) NOT NULL
	, [default_template_id] SMALLINT NULL
	, CONSTRAINT [PK_Prefix_1] PRIMARY KEY ([prefix_name] ASC)
)

GO

INSERT [static].[Version] ([major_version], [minor_version], [build], build_dt) VALUES (3,2,2,'2019-11-12 10:11:25')
GO
	
print '-- 1. schema_id'
IF object_id('[dbo].[schema_id]' ) is not null 
  DROP FUNCTION [dbo].[schema_id] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB return schema_id of this full object name 
--  e.g. LOCALHOST.AdventureWorks2014.Person.Sales -> schema_id(LOCALHOST.AdventureWorks2014.Person)
*/
CREATE FUNCTION [dbo].[schema_id]( @fullObj_name varchar(255), @scope varchar(255) = null  ) 
RETURNS int
AS
BEGIN
	--declare @fullObj_name varchar(255)= 'AdventureWorks.dbo.Store'
	declare @t TABLE (item VARCHAR(8000), i int)
	declare  
	     @elem1 varchar(255)
	     ,@elem2 varchar(255)
	     ,@elem3 varchar(255)
	     ,@elem4 varchar(255)
		, @cnt_elems int 
		, @obj_id int 
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
	select @obj_id= max(o.obj_id), @cnt = count(*) 
	from dbo.[Obj] o
	LEFT OUTER JOIN dbo.[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	where 	o.[obj_name] = @elem2
	and ( @elem3 is null or parent_o.[obj_name] = @elem3) 
	and ( @elem4 is null or grand_parent_o.[obj_name] = @elem4) 
	and ( @scope is null or 
			@scope = o.scope
			or @scope = parent_o.scope
			or @scope = grand_parent_o.scope
			or @scope = great_grand_parent_o.scope) 
	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@obj_id 
	return @res 
END











GO
print '-- 2. prefix'
IF object_id('[util].[prefix]' ) is not null 
  DROP FUNCTION [util].[prefix] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns true if @s ends with @suffix
select dbo.prefix('gfjhaaaaa_aap', 4) 
*/
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
print '-- 3. ddl_table'
IF object_id('[dbo].[ddl_table]' ) is not null 
  DROP PROCEDURE [dbo].[ddl_table] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB print create table ddl (part of ddl_betl). 
exec dbo.ddl_table '[dbo].[Job]'
*/
CREATE procedure [dbo].[ddl_table] @table_name SYSNAME
as 
begin 
set nocount on 
DECLARE 
      @obj_name SYSNAME
    , @obj_id INT

SELECT 
      @obj_name = '[' + s.name + '].[' + o.name + ']'
    , @obj_id = o.[object_id]
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
    WHERE ic.[object_id] = @obj_id
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
    WHERE k.parent_object_id = @obj_id
)
SELECT @SQL = 'CREATE TABLE ' + @obj_name + CHAR(13) + '(' + CHAR(13) + STUFF((
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
--                CASE WHEN c.collation_name IS NOT NULL THEN ' COLLATE ' + c.collation_name ELSE '' END +
                CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
                CASE WHEN dc.[definition] IS NOT NULL THEN ' DEFAULT' + dc.[definition] ELSE '' END + 

                CASE WHEN ic.is_identity = 1 THEN ' IDENTITY(' + CAST(ISNULL(ic.seed_value, '0') AS varCHAR(5)) + ',' + CAST(ISNULL(ic.increment_value, '1') AS varCHAR(5)) + ')' ELSE '' END 
        END + CHAR(13)
    FROM sys.columns c WITH (NOWAIT)
    JOIN sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
    LEFT JOIN sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id
    LEFT JOIN sys.default_constraints dc WITH (NOWAIT) ON c.default_object_id != 0 AND c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
    LEFT JOIN sys.identity_columns ic WITH (NOWAIT) ON c.is_identity = 1 AND c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
    WHERE c.[object_id] = @obj_id
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
            WHERE k.parent_object_id = @obj_id 
                AND k.[type] = 'PK'), '') + ')'  + CHAR(13)
    + ISNULL((SELECT (
        SELECT CHAR(13) +
             'ALTER TABLE ' + @obj_name + ' WITH' 
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
            + CHAR(13) + 'ALTER TABLE ' + @obj_name + ' CHECK CONSTRAINT [' + fk.name  + ']' + CHAR(13)
        FROM sys.foreign_keys fk WITH (NOWAIT)
        JOIN sys.objects ro WITH (NOWAIT) ON ro.[object_id] = fk.referenced_object_id
        WHERE fk.parent_object_id = @obj_id
        FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)')), '')
    + ISNULL(((SELECT
         CHAR(13) + 'CREATE' + CASE WHEN i.is_unique = 1 THEN ' UNIQUE' ELSE '' END 
                + ' NONCLUSTERED INDEX [' + i.name + '] ON ' + @obj_name + ' (' +
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
        WHERE i.[object_id] = @obj_id
            AND i.is_primary_key = 0
            AND i.[type] = 2
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
    ), '')
PRINT @SQL
--EXEC sys.sp_executesql @SQL
end

GO
print '-- 4. Col'
IF object_id('[dbo].[Col]' ) is not null 
  DROP VIEW [dbo].[Col] 
GO

	  
CREATE VIEW [dbo].[Col] AS
	SELECT     * 
	FROM  [dbo].[Col_hist] AS h
	WHERE     (eff_dt =
                      ( SELECT     MAX(eff_dt) max_eff_dt
                        FROM       [dbo].[Col_hist] h2
                        WHERE      h.column_id = h2.column_id
                       )
              )
		AND delete_dt IS NULL 











GO
print '-- 5. sp_helpdiagrams'
IF object_id('[dbo].[sp_helpdiagrams]' ) is not null 
  DROP PROCEDURE [dbo].[sp_helpdiagrams] 
GO

	CREATE PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
	

GO
print '-- 6. Int2Char'
IF object_id('[util].[Int2Char]' ) is not null 
  DROP FUNCTION [util].[Int2Char] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select util.int2Char(2)
*/
CREATE FUNCTION [util].[Int2Char] (     @i int)
RETURNS varchar(15) AS
BEGIN
       RETURN isnull(convert(varchar(15), @i), '')
END











GO
print '-- 7. ddl_clear'
IF object_id('[dbo].[ddl_clear]' ) is not null 
  DROP PROCEDURE [dbo].[ddl_clear] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB Beware: this will clear the entire BETL database (all non ms objects) !
*/    
CREATE procedure [dbo].[ddl_clear] @execute as bit = 0  as
begin 
	set nocount on 
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
				
	if @execute = 1  
	   exec(@sql) 
	else 	
		print @sql
end











GO
print '-- 8. prefix_first_underscore'
IF object_id('[util].[prefix_first_underscore]' ) is not null 
  DROP FUNCTION [util].[prefix_first_underscore] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB extract prefix from string
SELECT dbo.guess_foreignCol_id('par_relatie_id')
SELECT [dbo].[prefix_first_underscore]('relatie_id')
*/    
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
print '-- 9. udf_min'
IF object_id('[util].[udf_min]' ) is not null 
  DROP FUNCTION [util].[udf_min] 
GO
	  

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns the minimum of two numbers
select util.udf_min(1,2)
select util.udf_min(null,2)
select util.udf_min(2,null)
select util.udf_min(2,3)
select util.udf_min(2,2)
*/
CREATE FUNCTION [util].[udf_min]
(
 @a sql_variant,
 @b sql_variant
 
)
RETURNS sql_variant
AS
BEGIN
 if @a is null or @b <= @a
  return @b
 else
  if @b is null or @a < @b
   return @a
 return null
END











GO
print '-- 10. ddl_static'
IF object_id('[dbo].[ddl_static]' ) is not null 
  DROP PROCEDURE [dbo].[ddl_static] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB part of ddl generation process ( when making new betl release) . create static data ddl. 
*/    
CREATE procedure [dbo].[ddl_static] as 
begin 
set nocount on 
print '
-- begin ddl_content
set nocount on 
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (0, N''unknown'', NULL)
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (100, N''success'', N''Execution of batch or transfer finished without any errors. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (200, N''error'', N''Execution of batch or transfer raised an error.'')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (300, N''not started'', N''Execution of batch or transfer is not started because it cannot start (maybe it''''s already running). '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (400, N''running'', N''Batch or transfer is running. do not start a new instance.'')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (600, N''continue'', N''This batch is continuing where the last instance stopped. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (700, N''stopped'', N''batch stopped without error (can be continued any time). '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (800, N''skipped'', N''Transfer is skipped because batch will continue where it has left off. '')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (900, N''deleted'', N''Transfer or batch is deleted / dropped'')
GO
'
print '
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N''unknown'', N''Unknown,  not relevant'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N''nat_pkey'', N''Natural primary key (e.g. user_key)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N''nat_fkey'', N''Natural foreign key (e.g. create_user_key)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N''sur_pkey'', N''Surrogate primary key (e.g. user_id)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N''sur_fkey'', N''Surrogate foreign key (e.g. create_user_id)'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N''attribute'', N''low or non repetetive value for containing object. E.g. customer lastname, firstname.'', CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N''meta data'', NULL, CAST(N''2015-10-20 13:22:19.590'' AS DateTime), N''bas'')
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''navision'', 1)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''exact'', 2)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N''adp'', 2)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (10, N''table'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (20, N''view'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (30, N''schema'', 30)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (40, N''database'', 20)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (50, N''server'', 10)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (60, N''user'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (70, N''procedure'', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (80, N''role'', 30)
GO
'
print'
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgd'', 12)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgf'', 13)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgh'', 8)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N''stgl'', 10)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N''target_schema_id'', N''used for deriving target table'', N''db_object'', NULL, 1, 1, 1, 1, NULL, NULL, CAST(N''2015-08-31T13:18:22.073'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (15, N''template_id'', N''which ETL template to use (see def.Template) '', N''db_object'', NULL, 0, 0, 1, 1, NULL, NULL, CAST(N''2017-09-07T09:12:49.160'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N''has_synonym_id'', N''apply syn pattern (see biblog.nl)'', N''db_object'', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N''2015-08-31T13:18:56.070'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N''has_record_dt'', N''add this column (insert date time) to all tables'', N''db_object'', NULL, 0, 0, 0, 0, 1, NULL, CAST(N''2015-08-31T13:19:09.607'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N''has_record_user'', N''add this column (insert username ) to all tables'', N''db_object'', NULL, 0, 0, 1, 0, 1, NULL, CAST(N''2015-08-31T13:19:15.000'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N''is_linked_server'', N''Should a server be accessed like a linked server (e.g. via openquery). Used for SSAS servers.'', N''db_object'', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-08-31T17:17:37.830'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N''date_datatype_based_on_suffix'', N''if a column ends with the suffix _date then it''''s a date datatype column (instead of e.g. datetime)'', N''db_object'', N''1'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-02T13:16:15.733'' AS DateTime), N''My_PC\BAS'')
GO
'
print '
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N''is_localhost'', N''This server is localhost. For performance reasons we don''''t want to access localhost via linked server as we would with external sources'', N''db_object'', N''0'', NULL, NULL, NULL, NULL, 1, NULL, CAST(N''2015-09-24T16:22:45.233'' AS DateTime), N''My_PC\BAS'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N''recreate_tables'', N''This will drop and create tables (usefull during initial development)'', N''db_object'', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N''prefix_length'', N''This object name uses a prefix of certain length x. Strip this from target name. '', N''db_object'', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N''etl_meta_fields'', N''etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source'', N''db_object'', N''1'', NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (120, N''exec_sql'', N''set this to 0 to print the generated sql instead of executing it. usefull for debugging'', N''user'', N''1'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:04:49.867'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (130, N''log_level'', N''controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE'', N''user'', N''INFO'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:06:12.167'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (140, N''nesting'', N''used by dbo.log in combination with log_level  to determine wheter or not to print a message'', N''user'', N''0'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2017-02-02T15:08:02.967'' AS DateTime), N'''')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (150, N''delete_detection'', N''detect deleted records'', N''db_object'', N''1'', 1, 1, 1, NULL, NULL, NULL, CAST(N''2017-12-19T14:08:52.533'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (160, N''use_key_domain'', N''adds key_domain_id to natural primary key of hubs to make key unique for a particular domain. push can derive key_domain e.g.  from source system name'', N''db_object'', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-01-09T10:26:57.017'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (170, N''privacy_level'', N''scale : normal, sensitive, personal'', N''db_object'', N''10'', 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-04-09T16:38:43.057'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (180, N''filter_delete_detection'', N''custom filter for delete detection'', N''db_object'', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N''2018-07-04T17:27:29.857'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (190, N''proc_max_cnt'', N''how many concurrent processes / jobs. default 4 '', N''user'', N''4'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-23T17:20:03.690'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (200, N''proc_max_wait_time_min'', N''how long should we wait for a proc to finish when proc_max_cnt is reached. default 10 minutes. please increase this value for big datasets!'', N''user'', N''10'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:27:24.543'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (210, N''proc_polling_interval_sec'', N''wait polling interval. How long till we check again. range: 1-59 . Too low might affect performance because every time we query  msdb.dbo.sysjobs'', N''user'', N''2'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:29:17.060'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
'
print '
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (220, N''proc_dead_time_sec'', N''delete jobs that are created more than @proc_dead_time_sec ago and are not running. '', N''user'', N''60'', NULL, NULL, NULL, NULL, NULL, 1, CAST(N''2019-01-25T12:40:13.197'' AS DateTime), N''MicrosoftAccount\swjvdberg@outlook.com'')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (1, N''truncate_insert'', N''truncate_insert'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (2, N''drop_insert'', N''drop_insert'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (3, N''delta_insert_first_seq'', N''delta insert based on a first sequential ascending column'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (4, N''truncate_insert_create_stgh'', N''truncate_insert imp_table then create stgh view lowercase, nvarchar->varchar, money->decimal '', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (5, N''create_stgh'', N''create stgh view (follow up on template 4)'', CAST(N''2018-05-30 11:03:13.127'' AS DateTime), N''company\991371'')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (6, N''switch'', N''transfer to switching tables (Datamart)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (7, N''delta_insert_eff_dt'', N''delta insert based on eff_dt column'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (8, N''hub_and_sat'', N''Datavault Hub & Sat (CDC and delete detection)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (9, N''hub_sat'', N''Datavault Hub Sat (part of transfer_method 8)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (10, N''link_and_sat'', N''Datavault Link & Sat (CDC and delete detection)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (11, N''link_sat'', N''Datavault Link Sat (part of transfer_method 10)'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (12, N''dim'', N''Kimball Dimension'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (13, N''fact'', N''Kimball Fact'', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (14, N''fact_append'', N''Kimball Fact Append'', NULL, NULL)
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (10, N''ERROR'', N''Only log errors'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (20, N''WARN'', N''Log errors and warnings (SSIS mode)'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (30, N''INFO'', N''Log headers and footers'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (40, N''DEBUG'', N''Log everything only at top nesting level'')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (50, N''VERBOSE'', N''Log everything all nesting levels'')
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (10, N''Header'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (20, N''Footer'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (30, N''SQL'', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (40, N''VAR'', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (50, N''Error'', 10)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (60, N''Warn'', 20)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (70, N''Step'', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (80, N''Progress'', 50)
GO

'
print '
set identity_insert dbo.Batch on 
GO
insert into dbo.Batch(batch_id, batch_name) values ( -1, ''Unknown'')
GO
set identity_insert dbo.Batch off
GO
set identity_insert dbo.Transfer on 
GO
insert into dbo.Transfer(transfer_id, transfer_name) values ( -1, ''Unknown'')
GO
set identity_insert dbo.Transfer off
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (10, N''sql server'', N''SQL Server 2012 (SP3) (KB3072779) - 11.0.6020.0 (X64)'')
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (20, N''ssas tabular'', N''SQL Server Analysis Services Tabular Databases with Compatibility Level 1200'')
GO
insert into dbo.Obj(obj_type_id, obj_name)
values ( 50, ''LOCALHOST'')
GO
exec dbo.setp ''is_localhost'', 1 , ''LOCALHOST''
'
print '-- end of ddl_content'
end













GO
print '-- 11. sp_upgraddiagrams'
IF object_id('[dbo].[sp_upgraddiagrams]' ) is not null 
  DROP PROCEDURE [dbo].[sp_upgraddiagrams] 
GO

	CREATE PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
	

GO
print '-- 12. sp_alterdiagram'
IF object_id('[dbo].[sp_alterdiagram]' ) is not null 
  DROP PROCEDURE [dbo].[sp_alterdiagram] 
GO

	CREATE PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
	

GO
print '-- 13. filter'
IF object_id('[util].[filter]' ) is not null 
  DROP FUNCTION [util].[filter] 
GO
	  
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-19 BvdB filter characters from string
select util.filter('aap','d')
select util.filter('
aap
', 'char(10),char(13)')
select util.filter('
"aap''
', 'char(10),char(13),",''')
*/
CREATE FUNCTION [util].[filter]
(
	@s varchar(255)
	, @filter varchar(200) 
--	, @return_null bit = 1 
)
RETURNS varchar(255)
AS
BEGIN
	declare @result as varchar(max)= ''
		, @i int =1
		, @n int =len(@s) 
		, @filter_list as SplitList
		, @c as char
	insert into @filter_list
	select * from  util.split(@filter, ',')
	
	update @filter_list
	set item = char(convert(int, replace(replace(item, 'char(',''), ')','')))  
	from @filter_list
	where item like 'char(%'
	while @i<@n+1
	begin
		set @c = substring(@s, @i,1) 
		if not exists ( select * from @filter_list where item = @c) 
			set @result+=@c
		set @i += 1 
	end
--	if @return_null =0 
	--	return isnull(@result , '') 
	return @result 
END











GO
print '-- 14. column_type_name'
IF object_id('[dbo].[column_type_name]' ) is not null 
  DROP FUNCTION [dbo].[column_type_name] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select dbo.[column_type_name](300) 
*/
CREATE FUNCTION [dbo].[column_type_name]
(
	@column_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @column_type_name as varchar(255) 
	select @column_type_name = [column_type_name] from static.Column_type where column_type_id = @column_type_id 
	return @column_type_name + ' (' + convert(varchar(10), @column_type_id ) + ')'
END











GO
print '-- 15. udf_max'
IF object_id('[util].[udf_max]' ) is not null 
  DROP FUNCTION [util].[udf_max] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2014-02-25 BvdB returns the maximum of two ordinal types (e.g. int or date). 
select util.udf_max(1,2)
select util.udf_max(null,2)
select util.udf_max(2,null)
select util.udf_max(2,3)
*/
CREATE FUNCTION [util].[udf_max]
(
 @a sql_variant,
 @b sql_variant
 
)
RETURNS sql_variant
AS
BEGIN
 if @a is null or @b >= @a
  return @b
 else
  if @b is null or @a > @b
   return @a
  return @a
END











GO
print '-- 16. sp_renamediagram'
IF object_id('[dbo].[sp_renamediagram]' ) is not null 
  DROP PROCEDURE [dbo].[sp_renamediagram] 
GO

	CREATE PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
	

GO
print '-- 17. split'
IF object_id('[util].[split]' ) is not null 
  DROP FUNCTION [util].[split] 
GO
	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB splits strings. Keeps string together when surrounded by [ ] 
CREATE TYPE SplitListType AS TABLE 	(item VARCHAR(8000), i int)
select * from util.split('AAP,NOOT', ',')
select * from util.split('[AAP,NOOT],VIS,[NOOT,MIES],OLIFANT', ',')
*/
CREATE  FUNCTION [util].[split](
    @s nVARCHAR(max) -- List of delimited items
  , @del nVARCHAR(16) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item NVARCHAR(max), i int)
BEGIN
	DECLARE 
		@item VARCHAR(8000)
		, @i int =1
		, @n int 
		, @del_index int
		, @bracket_index_open int
		, @bracket_index_close int
	
	set @del_index = CHARINDEX(@del,@s,0)
	set @bracket_index_open = CHARINDEX('[',@s,0)
	WHILE @del_index <> 0 -- while there is a delimiter
	BEGIN
		if @del_index < @bracket_index_open or @bracket_index_open=0 -- delimeter occurs before [ or there is no [
		begin 
			set @n = @del_index-1
			SELECT
				@item=RTRIM(LTRIM(SUBSTRING(@s,1,@n))),
				-- set @s= tail 
				@s=RTRIM(LTRIM(SUBSTRING(@s,@del_index+LEN(@del),LEN(@s)-@n)))
		end 
		else -- [ occurs before delimiter
		begin
			set @bracket_index_close = CHARINDEX(']',@s,@bracket_index_open)
			set @n = case when @bracket_index_close=0 then len(@s) else  @bracket_index_close end
			
			SELECT
				@item=RTRIM(LTRIM(SUBSTRING(@s,1,@n))),
				-- set @s= tail 
				@s=RTRIM(LTRIM(SUBSTRING(@s,@n+1,LEN(@s)-@n)))
		end
		IF LEN(@item) > 0
		begin
			INSERT INTO @List SELECT @item, @i
			set @i += 1
		end 
		set @del_index= CHARINDEX(@del,@s,0)
		set @bracket_index_open= CHARINDEX('[',@s,0)
	END
	IF LEN(@s) > 0
	 INSERT INTO @List SELECT @s , @i-- Put the last item in
	RETURN
END












GO
print '-- 18. addQuotes'
IF object_id('[util].[addQuotes]' ) is not null 
  DROP FUNCTION [util].[addQuotes] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
*/
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
print '-- 19. const'
IF object_id('[dbo].[const]' ) is not null 
  DROP FUNCTION [dbo].[const] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2015-08-31 BvdB returns int value for const string. 
this way we don't have to use ints foreign keys in our code. 
Assumption: const is unique across all lookup tables. 
Lookup tables: obj_type
select dbo.const('table')
*/
CREATE FUNCTION [dbo].[const]
(
	@const varchar(255) 
)
RETURNS int 
AS
BEGIN
	declare @res as int 
	SELECT @res = obj_type_id from static.obj_type 
	where obj_type = @const 
	
	RETURN @res
END












GO
print '-- 20. Obj_ext'
IF object_id('[dbo].[Obj_ext]' ) is not null 
  DROP VIEW [dbo].[Obj_ext] 
GO

	  
	  
	  
--select * from dbo.obj_ext
CREATE VIEW [dbo].[Obj_ext]AS
WITH q AS (
	SELECT        
	o.obj_id, o.obj_type_id, ot.obj_type, o.obj_name, o.scope, o.parent_id, parent_o.obj_name AS parent, parent_o.parent_id AS grand_parent_id, grand_parent_o.obj_name AS grand_parent, 
	grand_parent_o.parent_id AS great_grand_parent_id, great_grand_parent_o.obj_name AS great_grand_parent, o.delete_dt, o.record_dt, o.record_user, isnull(o.template_id, parent_o.template_id) template_id
	, o.prefix, o.[obj_name_no_prefix], ot.obj_type_level , st.server_type, o.server_type_id, o.identifier
--	, o.$node_id node_id
	FROM dbo.Obj AS o 
	INNER JOIN static.obj_type AS ot ON o.obj_type_id = ot.obj_type_id 
	INNER JOIN static.Server_type AS st ON o.server_type_id = st.server_type_id 
	LEFT OUTER JOIN dbo.Obj AS parent_o ON o.parent_id = parent_o.obj_id 
	LEFT OUTER JOIN dbo.Obj AS grand_parent_o ON parent_o.parent_id = grand_parent_o.obj_id 
	LEFT OUTER JOIN dbo.Obj AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.obj_id
	where o.delete_dt is null 
)
, q2 AS
    (SELECT        obj_id, obj_type , obj_name, 
/*
10	table	40
20	view	40
30	schema	30
40	database	20
50	server	10
60	user	NULL
70	procedure	40
100	cube	30
130	security role	NULL
NULL	NULL	NULL
*/
CASE 
WHEN obj_type_level = 10 THEN [obj_name] 
WHEN obj_type_level = 20 THEN parent 
WHEN obj_type_level = 30 THEN grand_parent 
WHEN obj_type_level = 40 THEN great_grand_parent 
END AS srv
,
CASE 
WHEN obj_type_level = 20 THEN obj_name
WHEN obj_type_level = 30 THEN parent 
WHEN obj_type_level = 40 THEN grand_parent 
ELSE null 
END AS db
,
CASE 
WHEN obj_type_level = 30 THEN obj_name
WHEN obj_type_level = 40 THEN parent 
ELSE null 
END AS [schema]
, CASE 
WHEN obj_type_level = 40 THEN obj_name
ELSE null 
END AS schema_object
, delete_dt, record_dt, record_user, parent_id, grand_parent_id, great_grand_parent_id, scope, q_1.template_id
, prefix, [obj_name_no_prefix], server_type, server_type_id, identifier
--, node_id
FROM q AS q_1)
SELECT        
obj_id
, 
case when obj_type in ( 'user', 'server') then [obj_name] else 
ISNULL( quotename( case when srv<>'LOCALHOST'then srv else null end  )+'.', '') -- don't show localhost
+ ISNULL( quotename(db), '') 
+ ISNULL('.[' + [schema] + ']', '') 
+ ISNULL('.[' + schema_object + ']', '') end AS full_obj_name
, isnull([schema]+ '.','') + schema_object obj_and_schema_name
, scope
, obj_type
, server_type
, obj_name
, srv [srv_name]
, db [db_name]
, [schema] [schema_name]
, schema_object
, template_id
, parent_id
, grand_parent_id
, great_grand_parent_id
, server_type_id
, delete_dt
, record_dt
, record_user
, prefix
, [obj_name_no_prefix]
, p.[default_template_id]
, identifier
--, node_id
FROM q2 AS q2_1
left join dbo.Prefix p on q2_1.prefix = p.prefix_name












GO
print '-- 21. obj_name'
IF object_id('[util].[obj_name]' ) is not null 
  DROP FUNCTION [util].[obj_name] 
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB return schema name of this full object name 
-- e.g. My_PC.AdventureWorks2014.Person.Sales ->My_PC.AdventureWorks2014.Person
select util.obj_name('My_PC.AdventureWorks2014.Person.Sales') --> points to table 
*/
CREATE FUNCTION [util].[obj_name]( @fullObj_name varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
-- standard BETL header code... 
--set nocount on 
--declare   @debug as bit =1
--		, @progress as bit =1
--		, @proc_name as varchar(255) =  object_name(@@PROCID);
--exec dbo.get_var 'debug', @debug output
--exec dbo.get_var 'progress', @progress output
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
		, @obj_id int 
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
	--select @obj_id= max(o.obj_id), @cnt = count(*) 
	--from dbo.[Obj] o
	--LEFT OUTER JOIN dbo.[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	--LEFT OUTER JOIN dbo.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	--LEFT OUTER JOIN dbo.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	--where 	o.[obj_name] = @elem2
	--and ( @elem3 is null or parent_o.[obj_name] = @elem3) 
	--and ( @elem4 is null or grand_parent_o.[obj_name] = @elem4) 
	declare @res as varchar(255) 
	--if @cnt >1 
	--	set @res =  -@cnt
	--else 
	--	set @res =@obj_id 
	set @res = '[' + @elem1 + ']'
	return @res 
END











GO
print '-- 22. content_type_name'
IF object_id('[dbo].[content_type_name]' ) is not null 
  DROP FUNCTION [dbo].[content_type_name] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB get name by id. 
select dbo.[content_type_name](300) 
*/
create FUNCTION [dbo].[content_type_name]
(
	@content_type_id int
)
RETURNS varchar(255) 
AS
BEGIN
	declare @content_type_name as varchar(255) 
	select @content_type_name = [content_type_name] from dbo.Content_type where content_type_id = @content_type_id 
	return @content_type_name + ' (' + convert(varchar(10), @content_type_id ) + ')'
END











GO
print '-- 23. remove_comments'
IF object_id('[util].[remove_comments]' ) is not null 
  DROP FUNCTION [util].[remove_comments] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB removes comments from string.  
*/    
CREATE FUNCTION [util].[remove_comments]  (@str VARCHAR(MAX))   RETURNS VARCHAR(MAX)    AS  
 BEGIN  
   declare     @i bigint=1   
    , @j bigint=null    
	, @comment_start bigint=null     
	, @comment_end bigint=null     
	, @eol_pos bigint=null     
	, @n bigint=len(@str)     
	, @c char   
	, @buf as varchar(5) =''    
	, @result as varchar(max)=''   
	
	while @i<=@n    
	begin     
		set @c = substring(@str, @i,1)      
		--print convert(varchar(50), @i) +'. ' + @c         
		 if @c in ( '/', '*', '-')    
		 begin      
		   set @buf= substring(@str, @i,2)  -- take 2     
		   --  print '@buf ' + @buf           
		   if @buf = '--'  -- find end of line or end of string      
		   begin       
			set @comment_start = @i       
			set @eol_pos = charindex(CHAR(13) , @str, @i+2)        
			if @eol_pos = 0 -- no eol found        
				set @comment_end = @n -- must be end of string then       
			else set @comment_end = @eol_pos       
		  end        
		  
		  if @buf = '/*'      
		  begin       
			set @comment_start=@i -- start comment here        
			set @j=charindex('*/', @str, @i+2)        
			--print '@j '+ convert(varchar(50), @j)        
			if @j=0 -- end of comment not found        
				set @comment_end = @n       
			else set @comment_end = @j+1 -- @comment_end is last character in comment string e.g. /      
		  end        
		  
		  if @buf in ( '*/') -- end comment without begin comment...       
		  begin       
			set @comment_start=1 -- start of string       
			set @comment_end = @i+1       
			set @result='' -- empty result       
		  end        
		  --print '@comment_start ' + convert(varchar(30), @comment_start)       
		  --print '@comment_end ' + convert(varchar(30), @comment_end)       
		  -- skip to @comment_end       
		  --print '@i' + convert(varchar(10), @i)       
		  --print '@n' + convert(varchar(10), @n)         
		  
		  if @comment_end is null -- -> no comment found       
		  set @result += @c -- non comment character      
		  else        
			set @i=@comment_end             -- in any case reset counters      
		  set @comment_start=null      
		  set @comment_end=null      
		  set @buf = null       
		  -- set @c=null      
		end     
		else       
			set @result += @c -- non comment character       
			--print @c       
			set @i+=1    
		end   
	return @result   
end    












GO
print '-- 24. fn_diagramobjects'
IF object_id('[dbo].[fn_diagramobjects]' ) is not null 
  DROP FUNCTION [dbo].[fn_diagramobjects] 
GO

	CREATE FUNCTION dbo.fn_diagramobjects() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
	

GO
print '-- 25. refresh_views'
IF object_id('[util].[refresh_views]' ) is not null 
  DROP PROCEDURE [util].[refresh_views] 
GO
	  
	  
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB The meta data of views can get outdated when underlying tables change. Use this proc to refresh all views meta data. 
exec util.refresh_views 'AdventureWorks2014'
*/    
CREATE PROCEDURE [util].[refresh_views]
	@db_name as varchar(255)  
AS
BEGIN
/*
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
	exec [dbo].[exec_sql] @sql
	--PRINT @sql 
--   EXEC(@sql)
   
   */

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
END











GO
print '-- 26. refresh_ssas_meta'
IF object_id('[dbo].[refresh_ssas_meta]' ) is not null 
  DROP PROCEDURE [dbo].[refresh_ssas_meta] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB reads ssas tabular meta data into repository
*/
CREATE procedure [dbo].[refresh_ssas_meta] as 
begin 

if object_id('tempdb..#ssas_queries') is not null
	drop table #ssas_queries
/* 
disable because : SQL Server blocked access to STATEMENT 'OpenRowset/OpenDatasource' of component 'Ad Hoc Distributed Queries' because this component is turned off as part of the security configuration for this server. A system administrator can enable the use of 'Ad Hoc Distributed Queries' by using sp_configure. For more information about enabling 'Ad Hoc Distributed Queries', search for 'Ad Hoc Distributed Queries' in SQL Server Books Online.
	 
select * into #ssas_queries from openrowset('MSOLAP',
 'DATASOURCE=ssas01.company.nl;Initial Catalog=TAB_CKTO_respons_company;User=company\991371;password=anT1svsrnv'
 , '
select [name], [QueryDefinition] from 
[$System].[TMSCHEMA_PARTITIONS]
' ) 
	
select * from 
#ssas_queries
*/
end











GO
print '-- 27. Job_step_ext'
IF object_id('[dbo].[Job_step_ext]' ) is not null 
  DROP VIEW [dbo].[Job_step_ext] 
GO
	  
-- select * from dbo.Job_ext
create view [dbo].[Job_step_ext] as 
SELECT  j.[job_id]
      ,j.[name] job_name
      ,j.[description] job_description
      ,j.[enabled] job_enabled
      ,j.[category_name]
      --,[job_schedule_id]
      ,js.[name] schedule_name 
      ,js.[enabled] schedule_enabled
	  ,[step_id]
      ,[step_name]
      ,[subsystem]
      ,[command]
      ,[on_success_action]
      ,[on_success_step_id]
      ,[on_fail_action]
      ,[on_fail_step_id]
      ,[database_name]
      
  FROM [dbo].[Job] j
  inner join dbo.Job_schedule  js on j.job_schedule_id = js.job_schedule_id
  inner join dbo.Job_step s on s.job_id = j.job_id
--  order by j.job_id, s.step_id












GO
print '-- 28. print_max'
IF object_id('[util].[print_max]' ) is not null 
  DROP PROCEDURE [util].[print_max] 
GO
/* https://weblogs.asp.net/bdill/sql-server-print-max
exec util.print_max 'atetew tewtew'
*/
CREATE  PROCEDURE util.print_max(@iInput NVARCHAR(MAX) ) 
AS
BEGIN
    IF @iInput IS NULL
    RETURN;
    DECLARE @ReversedData NVARCHAR(MAX)
          , @LineBreakIndex INT
          , @SearchLength INT;
    SET @SearchLength = 4000;
    WHILE LEN(@iInput) > @SearchLength
    BEGIN
		SET @ReversedData = LEFT(@iInput COLLATE DATABASE_DEFAULT, @SearchLength);
		SET @ReversedData = REVERSE(@ReversedData COLLATE DATABASE_DEFAULT);
		SET @LineBreakIndex = CHARINDEX(CHAR(10) + CHAR(13),
							  @ReversedData COLLATE DATABASE_DEFAULT);
		PRINT LEFT(@iInput, @SearchLength - @LineBreakIndex + 1);
		SET @iInput = RIGHT(@iInput, LEN(@iInput) - @SearchLength 
							+ @LineBreakIndex - 1);
    END;
    IF LEN(@iInput) > 0
    PRINT @iInput;
END












GO
print '-- 29. trim'
IF object_id('[util].[trim]' ) is not null 
  DROP FUNCTION [util].[trim] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB remove left and right spaces and double and single quotes. 
*/    
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
print '-- 30. sp_creatediagram'
IF object_id('[dbo].[sp_creatediagram]' ) is not null 
  DROP PROCEDURE [dbo].[sp_creatediagram] 
GO

	CREATE PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
	

GO
print '-- 31. parent'
IF object_id('[util].[parent]' ) is not null 
  DROP FUNCTION [util].[parent] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB returns parent by parsing the string. e.g. localhost.AdventureWorks2014.dbo = localhost.AdventureWorks2014
select util.parent('localhost.AdventureWorks2014.dbo')
*/    
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
print '-- 32. obj_id'
IF object_id('[dbo].[obj_id]' ) is not null 
  DROP FUNCTION [dbo].[obj_id] 
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-09-06 BvdB Return meta data id for a full object name
select dbo.obj_id'AdventureWorks2014.Person.Person', null) --> points to table 
select dbo.obj_id'AdventureWorks2014.Person', null) --> points to schema
select dbo.obj_id'AdventureWorks2014', null) --> points to db
select dbo.obj_id('BETL', null) --> points to db
select dbo.obj_id'MicrosoftAccount\swjvdberg@outlook.com', null) --> points to db
select * from dbo.Obj
*/
CREATE FUNCTION [dbo].[obj_id]( @fullObj_name sysname , @scope varchar(255) = null ) 
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
		, @obj_id int 
--		, @remove_chars varchar(255)
		, @cnt as int 
	
	insert into @t 
	select replace(replace(item, '[',''),']','') item, i 
	from util.split(@fullObj_name , '.') 
	--select * from @t 
	-- @t contains elemenents of fullObj_name 
	-- can be [server].[db].[schema].[table|view]
	-- as long as it's unique 
	select @cnt_elems = MAX(i) from @t	
	select @elem1 = item from @t where i=@cnt_elems
	select @elem2 = item from @t where i=@cnt_elems-1
	select @elem3 = item from @t where i=@cnt_elems-2
	select @elem4 = item from @t where i=@cnt_elems-3
	select @obj_id= max(o.obj_id), @cnt = count(*) 
	from dbo.[Obj] o
	LEFT OUTER JOIN dbo.[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	LEFT OUTER JOIN dbo.[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	where 
	(
		o.delete_dt is null 
		and o.obj_type_id<> 60 -- not a user
		and o.[obj_name] = @elem1 
		and ( @elem2 is null or parent_o.[obj_name] = @elem2 ) 
		and ( @elem3 is null or grand_parent_o.[obj_name] = @elem3) 
		and ( @elem4 is null or great_grand_parent_o.[obj_name] = @elem4) 
		and ( @scope is null 
				or @scope = o.scope 
				or @scope = parent_o.scope 
				or @scope = grand_parent_o.scope 
				or @scope = great_grand_parent_o.scope 
				or o.obj_type_id= 50 -- scope not relevant for servers. 
			)  
	) 
	or 
	(
		o.delete_dt is null 
		and o.obj_type_id=60 -- user
		and o.obj_name = @fullObj_name
	) 

	
	declare @res as int
	if @cnt >1 
		set @res =  -@cnt
	else 
		set @res =@obj_id 
	return @res 
END











GO
print '-- 33. Batch_ext'
IF object_id('[dbo].[Batch_ext]' ) is not null 
  DROP VIEW [dbo].[Batch_ext] 
GO
	  
create view dbo.Batch_ext as 
select 
b.[batch_id] 
,b.[batch_name] 
,b.[batch_start_dt] 
,b.[batch_end_dt] 
, s.status_name batch_status 
, b.prev_batch_id
, prev_b.batch_start_dt prev_batch_start_dt
, prev_b.batch_end_dt prev_batch_end_dt
, prev_s.status_name prev_batch_status 
from dbo.Batch b
inner join static.Status s on s.status_id = b.status_id
left join dbo.Batch prev_b on b.prev_batch_id = prev_b.batch_id 
left join static.Status prev_s on prev_s.status_id = prev_b.status_id












GO
print '-- 34. parse_sql'
IF object_id('[util].[parse_sql]' ) is not null 
  DROP FUNCTION [util].[parse_sql] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-04-19 BvdB performs a very basic parsing of a sql statement. returns colom clause before first from 
	and first table after first from.  first record in @List is table, others are columns. 
declare @sql as varchar(8000) = '--aap
SELECT rel.naam_parent1 as top_relatie    ,rel.relatie_nummer as relatienummer    ,rel.naam as relatienaam    ,rel.kostenplaats_omschrvijving as kostenplaats    ,rpa as primaire_resource     ,regioteam    ,regioklantmanager as regioklantmanager    ,rel.cp_vz_naam_formeel as cp_naam    ,rel.cp_vz_email as cp_email    ,rel.cp_vz_telefoon as cp_telefoon       ,verzuimgevalnr    ,activiteit_id as activiteitID1       ,kld_herstel.datum as datum_invoer_herstel       ,kld_toegevoegd.datum as datum_toegevoegd    ,kld_verstuurd.datum as datum_versturen_uitnodiging    ,kld_verstuurd.jaar    ,kld_verstuurd.kortmaandnaam as maand       ,uitgenodigd.omschrijving as uitgenodigd       ,niet_uitgenodigd.reden_niet_uitgenodigd       ,ingevuld.ckto_ingevuld       ,kld_ingevuld.datum datum_ckto_ingevuld   FROM [feit_ckto_response] ckto   left outer join dim_Relatie as rel on ckto.dkey_relatie = rel.dkey_relatie --  left outer join dim_professional prof on rel.dkey_primaire_resource = prof.dkey_professional   left outer join dim_kalender as kld_herstel on ckto.dkey_datum_invoer_herstel = kld_herstel.dkey_kalender   left outer join dim_kalender as kld_toegevoegd on ckto.dkey_datum_toegevoegd = kld_toegevoegd.dkey_kalender   left outer join dim_kalender as kld_verstuurd on ckto.dkey_datum_versturen_uitnodiging = kld_verstuurd.dkey_kalender   left outer join dim_kalender as kld_ingevuld on ckto.dkey_datum_ckto_ingevuld = kld_ingevuld.dkey_kalender   left outer join dim_ja_nee as uitgenodigd on ckto.dkey_uitgenodigd_voor_ckto_ja_nee = uitgenodigd.jn_key   left outer join dim_reden_niet_uitgenodigd as niet_uitgenodigd on ckto.dkey_reden_niet_uitgenodigd = niet_uitgenodigd.dkey_reden_niet_uitgenodigd   left outer join dim_ckto_ingevuld as ingevuld on ckto.dkey_ckto_ingevuld = ingevuld.dkey_ckto_ingevuld
'
set @sql ='SELECT [hub_relatie_sid]
      ,[type_account]
      ,[account_id]
      ,[account_code]
           ,[korting5_percentage]
FROM [feit_totaallijst_bb]
WHERE aap '
set @sql = 'SELECT [dkey_functie]       ,[functiegroep]       ,[functie]   FROM [dim_functie] WHERE dkey_functie in (  SELECT [dkey_functie]   FROM [dbo].[dim_professional]   where dkey_professional in (SELECT[dkey_professional_pa]   FROM [dbo].[dim_verzuim]))'
select * from util.parse_sql(@sql)
*/
CREATE function [util].[parse_sql] (@sql VARCHAR(MAX)
  ) RETURNS @List TABLE (item VARCHAR(8000), i int)
BEGIN
	declare @transfer_id as int = -1

	-- END standard BETL header code... 
	--set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID)
	
		, @i as int 
		, @pos_space as int 
		, @pos_char10 as int 
		, @pos_char13 as int 
		, @select_clause as varchar(8000)
		, @from_clause as varchar(8000)
	set @sql = util.remove_comments(@sql) 
	--print @proc_name		
	set @i = charindex('FROM', @sql, 0) 
	if isnull(@i,0) =0 
	begin
		--exec dbo.log @transfer_id, 'ERROR', 'no from found in sql query ?', @sql
		--print 'no from found in sql query ?'
		goto footer
	end
	-- split on first occurance of FROM 
	set @from_clause =substring(@sql,@i+4,len(@sql)-@i-3) 
	set @select_clause =replace(replace( substring(@sql,0, @i-1) ,'select', '')  , 'as','') 
	-- parse from clause 
	set @from_clause = ltrim(@from_clause) 
	set @pos_space  = charindex(' ', @from_clause,0)  
	if @pos_space = 0 set @pos_space = null 
	set @pos_char10 = charindex(char(10), @from_clause,0) 
	if @pos_char10 = 0 set @pos_char10 = null 
	set @pos_char13 = charindex(char(13), @from_clause,0) 
	if @pos_char13 = 0 set @pos_char13 = null 
	--insert into @List values ( 'pos_space', @pos_space ) 
	--insert into @List values ( '@pos_char10', @pos_char10 ) 
	--insert into @List values ( '@pos_char13', @pos_char13 ) 
	set @i = convert(int, util.udf_min3(@pos_space , @pos_char10 , @pos_char13 ) )
	if isnull(@i,0) =0 
			set @i= len(@from_clause) 
	set @from_clause = substring(@from_clause, 1, @i-1) 
	insert into @List values (@from_clause,0) 
	;
	with q as( 
		select ltrim(rtrim(util.filter(item,'char(10),char(13)'))) item 
		,i
		from util.split( @select_clause, ',') 
	) 
	insert into @List 
	select item
	, row_number() over (order by i) 
	from q 
	where len(item)>0
	
	--exec dbo.log @transfer_id, 'VAR', '@from_clause ?', @from_clause
--	exec dbo.log @transfer_id, 'VAR', '@select_clause ?', @select_clause
 
	footer:
 	--exec dbo.log @transfer_id, 'footer', 'DONE ?', @proc_name 
	return
END












GO
print '-- 35. apply_params'
IF object_id('[util].[apply_params]' ) is not null 
  DROP PROCEDURE [util].[apply_params] 
GO
	  	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB replaces parameters in a string by it's value
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
	, @apply_defaults as bit = 1 
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
	if @apply_defaults =1 
	begin 
		declare @default_params ParamTable
		insert into @default_params  values ('"', '''' ) 
		insert into @default_params  values ('<dt>', ''''+ convert(varchar(50), GETDATE(), 121)  + '''' ) 
		select @sql = REPLACE(@sql, p.param_name, convert(Varchar(255), p.param_value) )
		from @default_params  p
	end 
	
	select @sql = REPLACE(@sql, '<'+ p.param_name+ '>', isnull(convert(varchar(max), p.param_value), '<' + isnull(p.param_name, '?') + ' IS NULL>'))
	from @params  p

END













GO
print '-- 36. current_db'
IF object_id('[dbo].[current_db]' ) is not null 
  DROP FUNCTION [dbo].[current_db] 
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2015-08-31 BvdB returns current database in kind of dirty way... 
-- when betl is called from a different database. e.g. My_Staging we want to return My_Staging as current db instead of the db where this function lives. 

use master
select betl.dbo.current_db()
-- should return master. however this requires view server state permissions. 

*/
CREATE FUNCTION [dbo].[current_db]() RETURNS varchar(1000) 
AS
BEGIN
	declare @db_name  as varchar(1000) 

	-- first check to see if current user has view server state permission
	if exists ( 
		SELECT l.name as grantee_name, p.state_desc, p.permission_name 
		FROM sys.server_permissions AS p 
		JOIN sys.server_principals AS l ON p.grantee_principal_id = l.principal_id
		WHERE
		permission_name = 'VIEW Server State' 
	) 
		SELECT @db_name = d.name
		FROM sys.dm_tran_locks -- requires elevated permissions
		inner join sys.databases d with(nolock) on resource_database_id  = d.database_id
		WHERE request_session_id = @@SPID and resource_type = 'DATABASE' and request_owner_type = 'SHARED_TRANSACTION_WORKSPACE'
	else 
		SELECT @db_name = db_name() 
--	and d.name<>db_name() 

	RETURN @db_name  
END












GO
print '-- 37. Job_ext'
IF object_id('[dbo].[Job_ext]' ) is not null 
  DROP VIEW [dbo].[Job_ext] 
GO
	  

-- select * from dbo.Job_ext
CREATE view [dbo].[Job_ext] as 
SELECT  j.[job_id]
      ,j.[name] job_name
      ,j.[description] job_description
      ,j.[enabled] job_enabled
      ,j.[category_name]
      ,j.[job_schedule_id]
      ,js.[name] schedule_name 
      ,js.[enabled] schedule_enabled
      ,[freq_type]
      ,[freq_interval]
      ,[freq_subday_type]
      ,[freq_subday_interval]
      ,[freq_relative_interval]
      ,[freq_recurrence_factor]
      ,[active_start_date]
      ,[active_end_date]
      ,[active_start_time]
      ,[active_end_time]
  FROM [dbo].[Job] j
  inner join dbo.Job_schedule  js on j.job_schedule_id = js.job_schedule_id
  --inner join dbo.Job_step s on s.job_id = j.job_id
--  order by j.job_id, s.step_id












GO
print '-- 38. get_cols'
IF object_id('[dbo].[get_cols]' ) is not null 
  DROP FUNCTION [dbo].[get_cols] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns a table with all column meta data 
-- Unfortunately we have to re-define the columTable type here... 
-- see http://stackoverflow.com/questions/2501324/can-t-sql-function-return-user-defined-table-type
select * from dbo.get_cols(32)
exec dbo.info
*/
CREATE FUNCTION [dbo].[get_cols]
(
	@obj_id int
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
	[identity] [bit] NULL,
	[src_mapping] varchar(255) null
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
		from dbo.Col_ext
		where [obj_id] = @obj_id 
	--SET IDENTITY_INSERT @cols OFF
	RETURN
end

--SELECT * from vwCol











GO
print '-- 39. sp_dropdiagram'
IF object_id('[dbo].[sp_dropdiagram]' ) is not null 
  DROP PROCEDURE [dbo].[sp_dropdiagram] 
GO

	CREATE PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
	

GO
print '-- 40. suffix_first_underscore'
IF object_id('[util].[suffix_first_underscore]' ) is not null 
  DROP FUNCTION [util].[suffix_first_underscore] 
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
SELECT dbo.guess_foreignCol_id('par_relatie_id')
SELECT [dbo].[suffix_first_underscore]('relatie_id')
*/    
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
print '-- 41. suffix'
IF object_id('[util].[suffix]' ) is not null 
  DROP FUNCTION [util].[suffix] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns true if @s ends with @suffix
select util.suffix('gfjh_aap', '_aap') 
select util.suffix('gfjh_aap', 4) 
select util.suffix('gfjh_aap', '_a3p') 
*/
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
print '-- 42. Transfer_ext'
IF object_id('[dbo].[Transfer_ext]' ) is not null 
  DROP VIEW [dbo].[Transfer_ext] 
GO
	  
CREATE view [dbo].[Transfer_ext] as 
select 
t.[transfer_id]
,t.[transfer_name]
,t.[src_obj_id]
,t.[target_name]
,t.[transfer_start_dt]
,t.[transfer_end_dt]
,s.status_name status
,t.[rec_cnt_src]
,t.[rec_cnt_new]
,t.[rec_cnt_changed]
,t.[rec_cnt_deleted]
,t.[last_error_id]
,b.batch_id
, b.[batch_start_dt] 
,b.[batch_end_dt] 
, b.batch_name
, s.status_name batch_status 
from dbo.Transfer t
left join dbo.Batch b on t.batch_id = b.batch_id 
left join static.Status s on s.status_id = t.status_id












GO
print '-- 43. sp_helpdiagramdefinition'
IF object_id('[dbo].[sp_helpdiagramdefinition]' ) is not null 
  DROP PROCEDURE [dbo].[sp_helpdiagramdefinition] 
GO

	CREATE PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
	

GO
print '-- 44. Col_ext'
IF object_id('[dbo].[Col_ext]' ) is not null 
  DROP VIEW [dbo].[Col_ext] 
GO

	  

CREATE VIEW [dbo].[Col_ext]
AS
SELECT    
c.column_id
, c.column_name
, c.Column_type_id
, ct.Column_type_name
,o.[schema_name]
, o.[db_name],
o.full_obj_name,   c.prefix, c.[entity_name], c.foreign_column_id , foreign_c.column_name foreign_column_name, lookup_foreign_cols.foreign_sur_pkey  , lookup_foreign_cols.foreign_sur_pkey_name
, c.is_nullable, c.ordinal_position, c.data_type, c.max_len, c.numeric_precision, c.numeric_scale, c.src_column_id,  o.[obj_id] , o.[obj_name]
, c.chksum
, c.part_of_unique_index
, o.server_type_id 
FROM dbo.Col AS c 
INNER JOIN dbo.Obj_ext AS o ON c.obj_id = o.obj_id
LEFT JOIN static.Column_type ct ON c.Column_type_id = ct.Column_type_id
LEFT JOIN dbo.Col AS foreign_c ON foreign_c.column_id = c.foreign_column_id  AND foreign_c.delete_dt IS NULL 
LEFT JOIN ( 
	SELECT c1.column_id, c1.foreign_column_id, c3.column_id foreign_sur_pkey, c3.column_name foreign_sur_pkey_name
	, ROW_NUMBER() OVER (PARTITION BY c1.column_id ORDER BY c3.ordinal_position ASC) seq_nr 
	FROM dbo.Col c1
	INNER JOIN dbo.Col c2 ON c1.[foreign_column_id] = c2.column_id 
	INNER JOIN dbo.Col c3 ON c3.[obj_id] = c2.[obj_id] AND c3.Column_type_id=200 -- sur_pkey
	WHERE c1.[foreign_column_id] IS NOT NULL 
) lookup_foreign_cols ON lookup_foreign_cols.column_id = c.column_id AND lookup_foreign_cols.seq_nr = 1 
WHERE        (c.delete_dt IS NULL) 
/*
SELECT * 
FROM vw_column
WHERE column_id IN ( 1140) 
*/











GO
print '-- 45. create_job'
IF object_id('[dbo].[create_job]' ) is not null 
  DROP PROCEDURE [dbo].[create_job] 
GO
	  

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-01-25 BvdB creates job in msdb from betl job meta data (dbo.Job_ext) 
select * from dbo.job_ext
exec dbo.create_job 10 , 1 
*/ 
CREATE procedure [dbo].[create_job] @job_id as int, @drop as bit = 1 as 
begin 
	set nocount on 
	declare 
--		@job_id as int = 10 
		@step_id as int
		,@transfer_id as int = 0 
	--	,@drop as bit = 1 
		,@sql as varchar(max) = ''
		,@sql_header as varchar(max) = ''
		,@step_sql as varchar(max) = ''
		,@job_sql as varchar(max) = ''
		,@ReturnCode INT=0
		,@jobId BINARY(16)
		,@prefix as varchar(100) = 'dev'
		,@schedule_enabled as bit = 0 
		--,@drop as bit = 1 
		, @job_params as ParamTable
		, @step_params as ParamTable
set @sql_header = '
declare 
	@ReturnCode INT=0
	,@jobId BINARY(16)
	,@schedule_enabled as bit = 0 
	
'
select @sql = @sql_header + '
declare @drop as bit =<drop>
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''<category_name>'' AND category_class=1)
BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''<category_name>''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
select @jobId= job_id from msdb.dbo.sysjobs where name=''<job_name>''
if @drop=1 and @jobId is not null 
begin
	exec msdb.dbo.sp_delete_job @jobId
	set @jobId = null 
end
if @jobId is null 
begin 
	BEGIN TRANSACTION
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=''<job_name>'', 
			@enabled=<job_enabled>, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=''<job_description>'',
			@category_name=''<category_name>'', 
			@job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N''<schedule_name>'', 
			@enabled=<schedule_enabled>, 
			@freq_type=<freq_type>, 
			@freq_interval=<freq_interval>, 
			@freq_subday_type=<freq_subday_type>, 
			@freq_subday_interval=<freq_subday_interval>, 
			@freq_relative_interval=<freq_relative_interval>, 
			@freq_recurrence_factor=<freq_recurrence_factor>, 
			@active_start_date=<active_start_date>, 
			@active_end_date=<active_end_date>, 
			@active_start_time=<active_start_time>, 
			@active_end_time=<active_end_time>
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
'
;
with params as ( 
	select [name], [value]
	fROM ( 
		SELECT convert(varchar(255), [job_id])  job_id 
			  ,convert(varchar(255), [job_name]) [job_name]
			  , convert(varchar(255), [job_description]) [job_description]
			  ,convert(varchar(255), [job_enabled]) [job_enabled]
			  ,convert(varchar(255), [category_name]) [category_name]
			  ,convert(varchar(255), [schedule_name]) [schedule_name]
			  ,convert(varchar(255), [schedule_enabled]) [schedule_enabled]
			  ,convert(varchar(255),[freq_type]) [freq_type]
			  ,convert(varchar(255),[freq_interval]) [freq_interval]
			  ,convert(varchar(255),[freq_subday_type]) [freq_subday_type]
			  ,convert(varchar(255),[freq_subday_interval]) [freq_subday_interval]
			  ,convert(varchar(255),[freq_relative_interval]) [freq_relative_interval]
			  ,convert(varchar(255),[freq_recurrence_factor]) [freq_recurrence_factor]
			  ,convert(varchar(255),[active_start_date]) [active_start_date]
			  ,convert(varchar(255),[active_end_date]) [active_end_date]
			  ,convert(varchar(255),[active_start_time]) [active_start_time]
			  ,convert(varchar(255),[active_end_time]) [active_end_time]
		FROM dbo.[Job_ext]
    	where job_id = @job_id 
		) p 
		unpivot( [value] for [name] in ( 
			  job_id 
			  ,[job_name]
			  ,[job_description]
			  ,[job_enabled]
			  ,[category_name]
			  ,[schedule_name]
			  ,[schedule_enabled]
			  ,[freq_type]
			  ,[freq_interval]
			  ,[freq_subday_type]
			  ,[freq_subday_interval]
			  ,[freq_relative_interval]
			  ,[freq_recurrence_factor]
			  ,[active_start_date]
			  ,[active_end_date]
			  ,[active_start_time]
			  ,[active_end_time]
			) 
			) as unpvt 
		) 
		insert into @job_params
		select * from  params 
		insert into @job_params values ('drop', @drop) 
		EXEC util.apply_params @sql output, @job_params
	set @sql += '
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
	goto EndSave
END
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave: print ''job created'' 
'
	exec [dbo].[exec_sql] @transfer_id, @sql
	------------------------------
	--- STEPS 
	------------------------------
	set @sql = @sql_header+ '
BEGIN
	select @jobId= job_id from msdb.dbo.sysjobs where name=''<job_name>''
	BEGIN TRANSACTION
'
		
	DECLARE c CURSOR FOR   
	SELECT step_id 
	FROM dbo.Job_step_ext
	WHERE job_id = @job_id 
	order by step_id asc
	OPEN c
	FETCH NEXT FROM c INTO @step_id 
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
--		print 'step_id' + convert(varchar(255), @step_id ) 
		delete from @step_params
		;
		with params as ( 
			select [name], [value]
			fROM ( 
				SELECT
						--convert(varchar(255), [job_id])  job_id 
						-- ,convert(varchar(255), [job_name]) [job_name]
						-- , convert(varchar(255), [job_description]) [job_description]
						-- ,convert(varchar(255), [job_enabled]) [job_enabled]
						-- ,convert(varchar(255), [category_name]) [category_name]
						-- ,convert(varchar(255), [schedule_name]) [schedule_name]
						-- ,convert(varchar(255), [schedule_enabled]) [schedule_enabled]
						convert(varchar(255), [step_id]) [step_id]
						,convert(varchar(255), [step_name]) [step_name]
						,convert(varchar(255), [subsystem]) [subsystem]
						,convert(varchar(255), [command]) [command]
						,convert(varchar(255), [on_success_action]) [on_success_action]
						,convert(varchar(255), [on_success_step_id]) [on_success_step_id]
						,convert(varchar(255), [on_fail_action]) [on_fail_action]
						,convert(varchar(255), [on_fail_step_id]) [on_fail_step_id]
						,convert(varchar(255), [database_name]) [database_name]
				FROM dbo.[Job_step_ext]
    			where job_id = @job_id 
				and step_id = @step_id 
				) p 
				unpivot( [value] for [name] in ( 
						--job_id 
						--,[job_name]
						--,[job_description]
						--,[job_enabled]
						--,[category_name]
						--,[schedule_name]
						--,[schedule_enabled]
						[step_id]
						,[step_name]
						,[subsystem]
						,[command]
						,[on_success_action]
						,[on_success_step_id]
						,[on_fail_action]
						,[on_fail_step_id]
						,[database_name]
					) 
			) as unpvt 
		) 
		insert into @step_params
		select * from params 
		--select * from  @step_params
		set @step_sql = '
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''<step_name>'', 
		@step_id=<step_id>, 
		@cmdexec_success_code=0, 
		@on_success_action=<on_success_action>, 
		@on_success_step_id=<on_success_action>, 
		@on_fail_action=<on_fail_action>, 
		@on_fail_step_id=<on_fail_step_id>, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N''<subsystem>'', 
		@command=N''<command>'', 
		@database_name=N''<database_name>'', 
		@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
'
			
		--update @step_params set param_value = replace( convert(varchar(255), param_value) , '''', '"') 
		--where param_name = 'command'
		EXEC util.apply_params @step_sql output, @step_params, 0
		set @sql += @step_sql 
		--print @step_sql 
			
		FETCH NEXT FROM c INTO @step_id 
	end
	CLOSE c;  
	DEALLOCATE c;  
	set @sql += '
	COMMIT TRANSACTION
	goto EndSave
END
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave: print ''job created''
'
	EXEC util.apply_params @sql output, @job_params, 0 
	--print @sql 
	exec [dbo].[exec_sql] @transfer_id, @sql
end












GO
print '-- 46. create_jobs'
IF object_id('[dbo].[create_jobs]' ) is not null 
  DROP PROCEDURE [dbo].[create_jobs] 
GO
	  
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-01-25 BvdB creates job in msdb from betl job meta data (dbo.Job_ext) 
select * from dbo.job_ext
select * from dbo.job_step_ext
exec dbo.create_jobs 1 
exec dbo.create_job 10
update dbo.job set name = replace ( name, 'dev', 'acc') 
update dbo.job_step_ext
set command = replace(command, 'ssis01-ota.company.nl\ww_dev', 'ssis01-ota.company.nl\ww_acc') 
*/ 
CREATE procedure [dbo].[create_jobs]  @drop as bit = 1 as 
begin 
	set nocount on 
	declare 
		@sql as varchar(max) = ''
		, @transfer_id as int = 0 
	select @sql += 'exec dbo.create_job ' + convert(varchar(255), job_id) + ',' + convert(varchar(255), @drop) +'
select '''+ job_name + ''' as job_name 
'	
	
	from dbo.Job_ext
	--print @sql 
	exec [dbo].[exec_sql] @transfer_id, @sql
end












GO
print '-- 47. create_obj'
IF object_id('[dbo].[create_obj]' ) is not null 
  DROP PROCEDURE [dbo].[create_obj] 
GO
	  

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-09 BvdB creates record in dbo.obj
select * from dbo.obj_ext
  
exec betl.dbo.create_obj @obj_name = 'ssas01.company.nl', @obj_type = 'server', @server_type_id = 20
	, @is_linked_server =0
select * from dbo.obj_ext
*/ 
CREATE procedure [dbo].[create_obj] @obj_name as varchar(255), @obj_type as varchar(255) , @server_type_id as int, @is_linked_server as bit=0 , @transfer_id as int = 0 as 
begin 
	set nocount on 
	declare 
		@sql as varchar(max) = ''
		, @p as ParamTable
		, @obj_type_id as int 
	-- standard BETL header code... 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ?(?) ', @proc_name , @obj_name, @obj_type_id
	set @obj_type_id = dbo.const(@obj_type) 
	if not exists ( select * from dbo.server_type where server_type_id = isnull(@server_type_id,0) ) 
	begin
		exec dbo.log @transfer_id, 'error',  'Invalid server_type_id ?.', @server_type_id
		goto footer
	end 
	if isnull(@obj_type_id,0)  not in ( 50) 
	begin
		exec dbo.log @transfer_id, 'error',  'obj_type ?(?) must be created using a dbo.refresh of a parent object.', @obj_type, @obj_type_id
		goto footer
	end 
	if exists (select * from dbo.obj where obj_type_id = @obj_type_id and [obj_name] = @obj_name and server_type_id = @server_type_id) 
	begin 
		exec dbo.log @transfer_id, 'info',  'Object already exists ?(?) .', @obj_name , @obj_type_id
		goto footer
	end 
	if @obj_type_id = 50 and @server_type_id =20 -- ssas server
	begin
		set @obj_name = replace( @obj_name ,'[','')
		set @obj_name = replace( @obj_name ,']','')
		if @is_linked_server = 1
		begin
			exec dbo.log @transfer_id, 'info',  'Trying to connect to linked server ? ', @obj_name 
			
			set @sql ='
				select count(*) cnt from openquery(<server> , 
				"select [CATALOG_NAME], [date_modified] from  $System.DBSCHEMA_CATALOGS"
				) 
				'
			delete from @p
			insert into @p values ('server'					, @obj_name) 
			EXEC util.apply_params @sql output, @p
			DECLARE @CountResults TABLE (CountReturned INT)
			insert @CountResults 
			exec(@sql) 
			
			if not exists ( select * from  @CountResults ) 
			begin
				exec dbo.log @transfer_id, 'error',  'Failed to connect to linked server, please check for example credentials...'
				goto footer
			end else
				exec dbo.log @transfer_id, 'info',  'Connection to linked server ? successfull.', @obj_name 
		end 
	end
	insert into dbo.obj ([obj_type_id], [obj_name] , server_type_id) 
	values ( @obj_type_id, @obj_name, @server_type_id) 

	exec dbo.log @transfer_id, 'info',  'Object ?(?:?) created.', @obj_name , @obj_type_id, @server_type_id
	footer:
	-- standard BETL footer code... 
	exec dbo.log @transfer_id, 'footer', '? ?(?) ', @proc_name , @obj_name, @obj_type_id
end












GO
print '-- 48. create_table'
IF object_id('[dbo].[create_table]' ) is not null 
  DROP PROCEDURE [dbo].[create_table] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB create table ddl 
--don't create primary keys for performance reasons (lock last page clustered index )
--unique indexes:
--hubs:
--on all nat_pkeys 
--hub sats:
--on all nat_pkeys 
--note that etl_load_dt is included
--links
--on all sur_fkeys + nat_pkeys
--link sats
--on all sur_fkeys + nat_pkeys
--note that etl_load_dt is included
--drop PROCEDURE [dbo].[create_table]
*/
CREATE PROCEDURE [dbo].[create_table]
    @full_obj_name AS VARCHAR(255) 
    , @scope AS VARCHAR(255) 
	, @cols AS dbo.ColumnTable READONLY
	, @transfer_id AS INT = -1
	, @create_pkey AS BIT =1 
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  object_name(@@PROCID)
		, @betl varchar(100) =db_name() 

	exec dbo.log @transfer_id, 'header', '? ?, scope ? ?', @proc_name , @full_obj_name,  @scope, @transfer_id 
	-- END standard BETL header code... 
	declare @sql as varchar(max) 
			, @col_str as varchar(max) =''
			, @nl as varchar(2) = char(13)+char(10)
			, @db as varchar(255) 
			, @obj_name as varchar(255) 
			, @schema as varchar(255) 
			, @schema_id as int
			, @this_db as varchar(255) = db_name()
			, @prim_key as varchar(1000) =''
			, @prim_key_sql as varchar(max)=''
			, @p ParamTable
			, @unique_index as varchar(1000)=''
			, @index_sql as varchar(max) 
			, @refresh_sql as varchar(max)
			, @recreate_tables as BIT
            , @obj_id AS INT 
	select @schema_id=dbo.schema_id(@full_obj_name, @scope)  -- 
	select 
		@db = db 
		, @schema = [schema]
		, @obj_name =  util.obj_name(@full_obj_name) 
	from dbo.obj_ext 
	where obj_id = @schema_id
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
		+ ' -- '+ dbo.column_type_name(column_type_id) +@nl
	from @cols 
	select @prim_key+= case when @prim_key='' then '' else ',' end + 
	'['+ column_name + ']' + @nl
	from @cols 
	where column_type_id = 200 -- sur_pkey
	order by ordinal_position asc
	select @unique_index+= case when @unique_index='' then '' else ',' end + '['+ column_name + ']' + @nl
	from @cols 
	where part_of_unique_index = 1 
	order by ordinal_position asc
	
	-- exec dbo.log @transfer_id, 'VAR', '@unique_index ?', @unique_index
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
	REFERENCES [dbo].[etl_data_source] ([etl_data_source])
	ALTER TABLE <schema>.<obj_name> CHECK CONSTRAINT FK_<obj_name_striped>_<schema_id>_etl_data_source
end
*/
	set @sql ='
-------------------------------------------------
-- Start create table DDL <full_obj_name>
-------------------------------------------------	
USE <db> 
'
	select @recreate_tables = dbo.get_prop_obj_id('recreate_tables', @schema_id ) 
	if @recreate_tables =1 
	begin
		exec dbo.log @transfer_id, 'step', '@recreate_tables =1->drop table ?', @full_obj_name
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
-- End create table DDL <full_obj_name>
-------------------------------------------------	
'
SET @refresh_sql = '
	exec <betl>.dbo.refresh ''[<db>].[<schema>].<obj_name>'' -- make sure that betl meta data is up to date
'
-- not needed because we do a get_obj_id after this, which will also issue a refresh
--	
	insert into @p values ('betl'					, @betl) 
	INSERT INTO @p VALUES ('full_obj_name'		, @full_obj_name) 
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
	exec dbo.exec_sql @transfer_id, @sql
	EXEC dbo.get_obj_id @full_obj_name, @obj_id OUTPUT -- this will also do a refresh
	exec dbo.log @transfer_id, 'VAR', 'obj_id ? = ?', @full_obj_name, @obj_id
	IF @obj_id IS NOT NULL 
		-- finally set column_type meta data 
	   UPDATE c 
	   SET c.column_type_id = cols.column_type_id
	   FROM @cols cols
	   INNER JOIN dbo.Col c ON cols.column_name = c.column_name 
	   WHERE cols.column_type_id IS NOT NULL 
		AND c.[obj_id] = @obj_id
--	SET @refresh_sql = '		exec betl.dbo.refresh ''<schema>.<obj_name>''	'
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @transfer_id
	-- END standard BETL footer code... 
END












GO
print '-- 49. create_view'
IF object_id('[dbo].[create_view]' ) is not null 
  DROP PROCEDURE [dbo].[create_view] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB Create ddl for view  
declare @cols dbo.ColumnTable,
	@obj_id as int ,
	@src_obj as varchar(255) = 'AdventureWorks2014.rdv.imp_f_subs_cd_subscription'
exec dbo.get_obj_id @src_obj, @obj_id output
insert into @cols 
select * from dbo.get_cols(@obj_id)
exec create_view 'AdventureWorks2014.rdv.stgh_f_subs_cd_subscription', null, @cols, @src_obj 
*/ 
CREATE PROCEDURE [dbo].[create_view]
    @full_trg_obj_name AS VARCHAR(255) 
    , @scope AS VARCHAR(255) 
	, @cols AS dbo.ColumnTable READONLY
    , @full_src_obj_name AS VARCHAR(255) 
	, @transfer_id AS INT = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  
		@proc_name as varchar(255) = object_name(@@PROCID)
		, @betl varchar(100) = db_name() 
	exec dbo.log @transfer_id, 'header', '? ?(?), scope ? ?', @proc_name , @full_trg_obj_name,  @full_src_obj_name, @scope, @transfer_id 
	-- END standard BETL header code... 
	declare @sql as varchar(max) 
		, @col_str as varchar(8000) =''
		, @nl as varchar(2) = char(13)+char(10)
		, @trg_db as varchar(255) 
		, @trg_obj_name as varchar(255) 
		, @src_obj_name as varchar(255) 
		, @trg_schema as varchar(255) 
		, @src_schema as varchar(255) 
		, @trg_schema_id as int
		, @src_schema_id as int
		, @this_db as varchar(255) = db_name()
		, @prim_key as varchar(1000) =''
		, @prim_key_sql as varchar(8000)=''
		, @p ParamTable
		, @unique_index as varchar(1000)=''
		, @index_sql as varchar(4000) 
		, @refresh_sql as varchar(4000) 
		, @recreate_tables as BIT
        , @obj_id AS INT 
	select @trg_schema_id=dbo.schema_id(@full_trg_obj_name, @scope) 
	select @src_schema_id=dbo.schema_id(@full_src_obj_name, @scope) 
	exec dbo.log @transfer_id, 'VAR', '@trg_schema_id ? ',@trg_schema_id
	exec dbo.log @transfer_id, 'VAR', '@src_schema_id ? ',@src_schema_id
	if @trg_schema_id < 0 
	begin
		exec dbo.log @transfer_id, 'ERROR', 'schema name is ambiguous. Please specify database name as well. ? ',@full_trg_obj_name
		goto footer
	end 
	if @trg_schema_id is null 
	begin
		exec dbo.log @transfer_id, 'ERROR', 'Cannot find target schema in betl meta data. ? ',@full_trg_obj_name
		goto footer
	end
	select 
		@trg_db = db 
		, @trg_schema = [schema]
		, @trg_obj_name =  util.obj_name(@full_trg_obj_name) 
	from dbo.obj_ext 
	where obj_id = @trg_schema_id
	select 
		@src_schema = [schema]
		, @src_obj_name =  util.obj_name(@full_src_obj_name) 
	from dbo.obj_ext 
	where obj_id = @src_schema_id
	exec dbo.log @transfer_id, 'VAR', '@trg_db ? ',@trg_db
	exec dbo.log @transfer_id, 'VAR', '@trg_obj_name  ? ',@trg_obj_name 
	
	select @col_str+= case when @col_str='' then '' else ',' end + 

			+ case 
				when data_type in ('money', 'smallmoney')  then ' convert(decimal('+ convert(varchar(10), numeric_precision) +  
																			   isnull ( ',' + convert(varchar(10), numeric_scale), '') + '),' 
																			    +'['+ lower(column_name) + '] ) as '+ '['+ lower(column_name) + ']'
				when data_type in ('nvarchar')  then ' convert(varchar'+ isnull('('+ case when max_len<0 then 'MAX' else convert(varchar(10), max_len ) end + ')', '')+',' 
																			    +'['+ lower(column_name) + '] ) as '+ '['+ lower(column_name) + ']'
				else '['+ lower(column_name) + '] '
			  end+ '
'
	from @cols 
	set @sql ='USE <trg_db>'

	set @sql ='
-------------------------------------------------
-- Start (re)create view DDL <full_trg_obj_name>
-------------------------------------------------	
--USE <trg_db>;
if object_id(''<trg_schema>.<trg_obj_name>'') is not null 
	drop view <trg_schema>.<trg_obj_name>
;
--GO
exec("
-- exec betl.dbo.push ""<trg_schema>.<trg_obj_name>""
create view <trg_schema>.<trg_obj_name> as
	SELECT 
	<col_str>
	FROM <src_schema>.<src_obj_name>
") 
--USE <this_db> 
-------------------------------------------------
-- End create view ddl <full_trg_obj_name>
-------------------------------------------------	
'
SET @refresh_sql = '
	exec <betl>.dbo.refresh "<trg_obj_name>" -- make sure that betl meta data is up to date
'
	insert into @p values ('betl'					, @betl) 
	INSERT INTO @p VALUES ('trg_obj_name'			, @trg_obj_name) 
	INSERT INTO @p VALUES ('full_trg_obj_name'		, @full_trg_obj_name) 
	INSERT INTO @p VALUES ('src_obj_name'			, @src_obj_name) 
	INSERT INTO @p VALUES ('full_src_obj_name'		, @full_src_obj_name) 
	INSERT INTO @p VALUES ('trg_db'						, @trg_db) 
	INSERT INTO @p VALUES ('trg_schema'					, @trg_schema) 
	INSERT INTO @p VALUES ('src_schema'					, @src_schema) 
	INSERT INTO @p VALUES ('col_str'				, @col_str) 
	INSERT INTO @p VALUES ('this_db'				, @this_db) 
	INSERT INTO @p VALUES ('refresh_sql'			, @refresh_sql) 
	EXEC util.apply_params @sql OUTPUT, @p
	EXEC util.apply_params @sql OUTPUT, @p -- twice because of nesting
	
	exec dbo.exec_sql @transfer_id, @sql, @trg_db
	EXEC dbo.get_obj_id @trg_obj_name, @obj_id OUTPUT -- this will also do a refresh
	exec dbo.log @transfer_id, 'VAR', 'obj_id ? = ?', @trg_obj_name, @obj_id
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @trg_obj_name, @transfer_id
	-- END standard BETL footer code... 
END











GO
print '-- 50. ddl_betl'
IF object_id('[dbo].[ddl_betl]' ) is not null 
  DROP PROCEDURE [dbo].[ddl_betl] 
GO
	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB generate a tsql script that contains a betl release 
exec dbo.ddl_betl 
*/
CREATE procedure [dbo].[ddl_betl] as 
begin 
	set nocount on 
    declare @major_version as int
		, @minor_version as int
		, @build as int
		, @build_dt as varchar(255) = convert(varchar(255), getdate(),120) 
		, @version_str as varchar(500) ='?'

   select @major_version =major_version
		, @minor_version= minor_version
		, @build = build 
   from static.[Version]
   set @build+=1 
   update static.[Version] set build = @build , build_dt = @build_dt 
   set  @version_str = convert(varchar(10), @major_version) + '.'+ convert(varchar(10), @minor_version) + '.'+ convert(varchar(10), @build)+ ' , date: '+ @build_dt
  print '
-- START BETL Release version ' + @version_str+ '
set nocount on 
use betl 
-- WARNING: This will clear the betl database !
IF EXISTS (SELECT * FROM sys.objects WHERE type = ''P'' AND name = ''ddl_clear'')
	exec dbo.ddl_clear @execute=1
-- schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''util'')
begin
	EXEC sys.sp_executesql N''CREATE SCHEMA [util]''
	exec sp_addextendedproperty  
		 @name = N''Description'' 
		,@value = N''Generic utility data and functions'' 
		,@level0type = N''Schema'', @level0name = ''util'' 
end
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N''static'')
begin 
	EXEC sys.sp_executesql N''CREATE SCHEMA [static]''
	exec sp_addextendedproperty  
		 @name = N''Description'' 
		,@value = N''Static betl data, not dependent on customer implementation'' 
		,@level0type = N''Schema'', @level0name = ''static'' 
end-- end schemas
IF NOT EXISTS (SELECT NULL FROM SYS.EXTENDED_PROPERTIES WHERE [major_id] = schema_ID(''dbo'') AND [name] = N''Description'' AND [minor_id] = 0)
exec sp_addextendedproperty  
	@name = N''Description'' 
	,@value = N''dbo data is specific for each customer implementation'' 
	,@level0type = N''Schema'', @level0name = ''dbo'' 
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
	[src_mapping] varchar(255) null
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
	[param_value] varchar(max) NULL,
	PRIMARY KEY CLUSTERED 
(
	[param_name] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
CREATE TYPE [dbo].[SplitList] AS TABLE(
	[item] [varchar](max) NULL,
	[i] [int] NULL
)
GO
-- end user defined tables
'
	-- tables 
	declare 
		@t as varchar(255) 
		, @sql as varchar(max) 
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
INSERT [static].[Version] ([major_version], [minor_version], [build], build_dt) VALUES ('
	+convert(varchar(255), @major_version) + ','
	+convert(varchar(255), @minor_version) + ','
	+convert(varchar(255), @build) + ','''
	+convert(varchar(255), @build_dt) + ''')
GO
	'
	exec [dbo].[ddl_other]
	exec [dbo].[ddl_static]
	set nocount on 
	print '--END BETL Release version ' + @version_str
end












GO
print '-- 51. ddl_other'
IF object_id('[dbo].[ddl_other]' ) is not null 
  DROP PROCEDURE [dbo].[ddl_other] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-21 BvdB part of ddl generation process ( when making new betl release) . 
exec [dbo].[ddl_other]
*/    
CREATE procedure [dbo].[ddl_other] as 
begin
	set nocount on 
	-- first create a temp table of dependencies #dep
	if object_id('tempdb..#dep') is not null 
	drop table tempdb.#dep
	;
	WITH dep -- (object_id, obj_name, dep_id, dep_name, level, [type_desc], [schema])
			AS
		(
		SELECT DISTINCT
			sd.referencing_id object_id,
			object_name(sd.referencing_id) obj_name,
			so.[type_desc],
			schema_name(so.schema_id) [schema],
			Referenced_ID dep_id, -- = sd.referenced_major_id,
			Referenced_entity_name dep_name, -- Object = object_name(sd.referenced_major_id),
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
					sd.referencing_id object_id,
					object_name(sd.referencing_id)  obj_name,
					sd.referencing_id  dep_id, -- = sd.referenced_major_id,
					sd.Referenced_entity_name dep_name, -- Object = object_name(sd.referenced_major_id),
					Level+1
			--select * 
			 FROM  sys.sql_expression_dependencies sd
				join  dep do
					   ON sd.referenced_id = do.object_id
			 WHERE					sd.Referenced_ID <> sd.referencing_id    		
  */
			 --SELECT
				--	sd.object_id,
				--	object_name(sd.object_id),
				--	object_name(referenced_major_id),
				--	obj_id,
				--	Level + 1
			 --FROM    
				--	sys.sql_dependencies sd
				-- JOIN DependentObjectCTE do ON sd.referenced_major_id = do.DependentObjectID       
			
			 )
			 SELECT object_id, obj_name , [type_desc], [schema] , dep_id, dep_name--   max(level) level
			 into #dep
			 FROM  dep	
			--drop table #dep

	--select * from  #dep 
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
	 ,[type_desc] varchar(100) 
	 ,[schema] varchar(100) 
	) 
	insert into @t
			select o.name, object_definition(o.object_id) def
			, o.[type_desc]
			, schema_name(o.schema_id) 
			from sys.objects o
			left join #dep d on o.object_id =d.object_id
			where o.[type_desc] in ('SQL_SCALAR_FUNCTION',
			'SQL_STORED_PROCEDURE',
			'SQL_TABLE_VALUED_FUNCTION',
			'SQL_TRIGGER',
			'VIEW')
			and d.dep_name is null 
	while @level < 10
	begin --select * from @t
		insert into @t
			select distinct d.obj_name, object_definition(object_id) def, [type_desc], [schema]
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
		, @obj_type varchar(100) 
		, @type_desc varchar(100) 
		, @schema varchar(100) 
		, @newline nchar(2)= nchar(13) + nchar(10)
		, @full_obj_name as varchar(255) 
	while @i <= ( select max(id) from @t ) 
	begin
		SELECT @DEF= def , @id = id, @obj_name =obj_name 
		, @obj_type = 
		    case [type_desc]
				when  'SQL_SCALAR_FUNCTION' then 'FUNCTION' 
				when  'SQL_STORED_PROCEDURE' then 'PROCEDURE' 
				when  'SQL_TABLE_VALUED_FUNCTION' then 'FUNCTION' 
				when  'SQL_TRIGGER' then 'TRIGGER' 
				when  'VIEW' then 'VIEW' 
			end 
		, @type_desc = [type_desc] 
		, @schema = [schema]
		, @full_obj_name = '['+ [schema] + '].['+ [obj_name] + ']'
		from @t where id = @i
      print 'print ''-- '+ convert(varchar(255), @id) + '. '+ @obj_name + '''
IF object_id('''+ @full_obj_name + ''' ) is not null 
  DROP '+ @obj_type + ' ' +@full_obj_name + ' 
GO
'
	   /*
	   set @n = len(@def) 
	   set @j = 1 
	   set @nextspace=0
	   
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
		 */
	   exec util.print_max @def -- print is limited to 4000 chars workaround:
	   print '
GO
'
		set @i+=1
	end
end











GO
print '-- 52. exec_template'
IF object_id('[dbo].[exec_template]' ) is not null 
  DROP PROCEDURE [dbo].[exec_template] 
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-24 BvdB execute template @template_name on object @full_object_name 
-- =============================================

select @@nestlevel
exec reset
exec debug

exec exec_template 'trig_betl_meta_data', 'DDP_IDW'

*/
CREATE PROCEDURE [dbo].[exec_template]
	 @template_name as varchar(255)
	, @full_obj_name as nvarchar(255)
	, @transfer_id as int =0 
	, @batch_id as int = 0 -- see logging hierarchy above.
	, @async as bit=0 -- run asynchronously 


AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ?(?) ', @proc_name , @template_name, @full_obj_name
	-- END standard BETL header code... 

	declare 
		@sql as nvarchar(max) 
		, @p as ParamTable
		, @template_id int
		, @template_description as varchar(255)
		, @result as int =0 

		, @src_obj_id as int
		, @src_obj_type as varchar(255) 
		, @src_srv_name as varchar(255)
		, @src_db_name as varchar(255) 
		, @src_schema_name as varchar(255) 
		, @src_obj_name as varchar(255) 
		, @src_prefix as varchar(255) 
		, @src_obj_name_no_prefix as varchar(255) 


	-- retrieve sql template code 
	select @sql = template_sql , @template_id = template_id , @template_description= template_description
	from static.Template
	where template_name = @template_name

	if @sql is null 
	begin
		exec dbo.log @transfer_id, 'error', 'template [?] not found.', @template_name
		goto footer
	end

    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieve obj_id from name ?', @full_obj_name
	----------------------------------------------------------------------------
	exec dbo.get_obj_id @full_obj_name, @src_obj_id output, @transfer_id=@transfer_id

	if @src_obj_id is null or @src_obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error', 'object ? not found.', @full_obj_name
		goto footer
	end


	select 
	@src_obj_type = obj_type
	, @src_srv_name = srv_name
	, @src_db_name = db_name
	, @src_schema_name = [schema_name] 
	, @src_obj_name = [obj_name]
	, @src_prefix = [prefix]
	, @src_obj_name_no_prefix = [obj_name_no_prefix]
	from dbo.obj_ext 
	where [obj_id] = @src_obj_id


	-- now we have an obj_id and a template sql --> let's merge these two and replace the placeholders with values. 
	-- there are a set of parameters which are default supplied. these are:
	-- generic parameters. Like betl ( what is the name of the betl database). 
	-- object source and target properties. Like db_name, schema_name etc. 
	-- generate a list of default parameters:

	delete from @p

	-- insert generic global variables
	insert into @p values ('betl'					, db_name() ) -- name of the betl database is current database name.
	insert into @p values ('build_dt'				, getdate()) 
	insert into @p values ('record_user'			, suser_sname()) 

	-- insert stored procedure scoped variables
	insert into @p values ('template_id'			, @template_id) 
	insert into @p values ('template_name'			, @template_name) 
	insert into @p values ('template_description'	, @template_description) 
	insert into @p values ('batch_id'				, @batch_id ) 
	insert into @p values ('transfer_id'			, @transfer_id ) 

	-- insert object dependent variables
	insert into @p values ('src_full_obj_name'		, @full_obj_name) 
	insert into @p values ('src_obj_type'			, @src_obj_type) 
	insert into @p values ('src_srv_name'			, @src_srv_name) 
	insert into @p values ('src_db_name'			, @src_db_name) 
	insert into @p values ('src_schema_name'		, @src_schema_name) 
	insert into @p values ('src_obj_name'			, @src_obj_name) 
	insert into @p values ('src_prefix'				, @src_prefix) 
	insert into @p values ('src_obj_name_no_prefix'	, @src_obj_name_no_prefix) 
	insert into @p values ('src_obj_id'				, @src_obj_id) 
	
	EXEC util.apply_params @sql output, @p

	exec @result = dbo.exec_sql @transfer_id=@transfer_id, @sql=@sql,  @async=@async, @trg_db_name = @src_db_name

	footer:
	exec dbo.log @transfer_id, 'footer', 'done ? ?(?) ', @proc_name , @template_name, @full_obj_name
	-- END standard BETL footer code... 

END

GO
print '-- 53. get_dep_obj_id'
IF object_id('[dbo].[get_dep_obj_id]' ) is not null 
  DROP PROCEDURE [dbo].[get_dep_obj_id] 
GO
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-03-19 BvdB find dependencies for this object using betl and sql server meta data.
-- there are different types of dependencies. namely: 
-- 1. a transfer dependency. ( A-> B)  B is dependent on A. 
-- 2. a stored procedure dependency sp p uses tables a,b and c and view d
-- 3. A referencing dependency. view x references table a and b and view c ( using sys.dm_sql_referenced_entities) 
-- note that referencing dependencies include stored procedure depdendencies. However the reliability of sys.dm_sql_referenced_entities is not very good, so 
-- to be complete I wrote a template to get the 'forgotten' dependencies in stored procedures. 
-- 4. A foreign key dependency. table x references tables y and z. Based on the existance of foreign keys. (used for deriving control flow of the refresh job). 

exec get_dep_obj_id 195
exec debug
*/
--select * from dbo.Obj_dep
CREATE procedure [dbo].[get_dep_obj_id] 
	@obj_id int
	, @dependency_tree_depth as int =0
	, @obj_tree_depth as int = 0
	, @display  as int = 0
	, @transfer_id as int = -1 
as
begin 
	--declare 
	--@obj_id int=56
	--, @dependency_tree_depth as int =1
	--, @obj_tree_depth as int = 0
	--, @display  as int = 1
	--	, @transfer_id as int = -1 

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ?,@obj_tree_depth ? , @dependency_tree_depth ?, @display ? ', @proc_name , @obj_id, @obj_tree_depth, @dependency_tree_depth, @display 
	-- END standard BETL header code... 

	declare 
		@obj_name as sysname
		, @rows as int=0
		, @dep_obj_id int
		, @dep_obj_name sysname
--		, @nesting as int
		, @full_obj_name as nvarchar(500) 
		--, @scope as varchar(255) = null 
		--, @transfer_id as int =-1
		 , @db_name sysname
		 , @obj_db sysname
		 , @schema_name sysname 
		 , @obj_schema_name sysname
		 , @obj_type as varchar(255) 
		 , @server_type_id as int 
		 , @p as ParamTable
		 , @identifier as int
		 , @sql as varchar(max)=''
		 , @result as int =0 

	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error',  'invalid obj_id ? .', @obj_id
		goto footer
	end
	
	select 
		@full_obj_name = full_obj_name
		, @obj_schema_name = quotename([schema_name]) + '.'+ quotename(obj_name)
		, @schema_name = [schema_name]
		, @obj_name = [obj_name]
	    , @obj_type = obj_type
		, @server_type_id = server_type_id
		, @obj_db = db_name
		, @identifier = identifier
	from dbo.Obj_ext
	where obj_id = @obj_id 	

	exec dbo.log @transfer_id, 'VAR', 'object: ? ?(?,?) , server type ?', @obj_type , @full_obj_name , @obj_id, @obj_id, @server_type_id 

	if object_id('tempdb..#dep') is not null
		drop table #dep

	-- first create a list of dependent objects #dep
	-- after this-> add this list to dbo.dep_rel (node table). 
	set @sql = '
if object_id(N''[tempdb]..#dep'', ''U'') is not null 
	drop table #dep

create table #dep(
	obj_name varchar(100) not null
	, schema_name varchar(100) not null
	, [dep_type_id] varchar(255) not null 
	, obj_id int
	primary key (obj_name , schema_name, [dep_type_id]) 
) 
'
--select * into betl.[db_name]o.test from sys.objects	
-- sysname 

	if @server_type_id = 10 -- sql server
	begin
		-- step 1
		set @sql += '
-- step 1. look in transfer log to find dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep
select distinct lookup_obj.[obj_name], lookup_obj.[schema_name], 1 [dep_type_id], lookup_obj.obj_id
from dbo.transfer t
inner join dbo.obj_ext lookup_obj on t.src_obj_id = lookup_obj.obj_id 
where t.target_name = "<full_obj_name>"
'
		set @sql += '
-- step 2. find sql referenced entities for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep 
SELECT distinct lookup_obj.[obj_name], lookup_obj.[schema_name], 2 [dep_type_id], lookup_obj.obj_id
FROM <obj_db>.sys.dm_sql_referenced_entities("<obj_schema_name>", "Object") d
inner join dbo.Obj_ext lookup_obj on d.[referenced_schema_name] = lookup_obj.[schema_name] collate database_default and d.[referenced_entity_name] = lookup_obj.obj_name collate database_default
and lookup_obj.[db_name]="<obj_db>" collate database_default
'
		set @sql += '
-- step 3. find stored procedure dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>
/*
insert into #dep 
SELECT distinct s.name schema_name , so.name obj_name, 3 [dep_type_id], lookup_obj.obj_id
FROM <obj_db>.sys.syscomments sc
INNER JOIN <obj_db>.sys.objects so ON sc.id=so.object_id 
inner join <obj_db>.sys.schemas s on s.schema_id = so.schema_id  
inner join dbo.Obj_ext lookup_obj on s.name = lookup_obj.[schema_name] collate database_default  and lookup_obj.obj_name = so.name collate database_default 
	and lookup_obj.[db_name]="<obj_db>" collate database_default 
WHERE 
	betl.util.remove_comments( text) 
	LIKE "%<obj_name>%" and type = "P"
*/
'

		set @sql += '
-- step 4. find foreign key dependencies for <full_obj_name>( <obj_id>, <obj_type>) , server type: <server_type_id>

insert into #dep 
-- SELECT distinct s.name schema_name , so.name obj_name, 4 [dep_type_id], lookup_obj.obj_id

SELECT
distinct
PK.TABLE_SCHEMA schema_name ,
PK.TABLE_NAME obj_name, 
4 [dep_type_id], 
lookup_obj.obj_id
FROM <obj_db>.INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
INNER JOIN <obj_db>.INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
INNER JOIN <obj_db>.INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
inner join dbo.Obj_ext lookup_obj on PK.TABLE_SCHEMA = lookup_obj.[schema_name] collate database_default  and lookup_obj.obj_name = PK.TABLE_NAME collate database_default 
	and lookup_obj.[db_name]="<obj_db>" collate database_default 
where 
FK.TABLE_SCHEMA = "<schema_name>"
AND FK.TABLE_NAME = "<obj_name>"
'


	end -- if @server_type_id = 10 sql server
--	else 
--	begin -- server_type = 20 ssas
--		-- step 1
--		if @obj_type='table'
--			exec dbo.log @transfer_id, 'step' , 'try to relate cube tables to datamart tables in sql server ? (?) object type ?, server type ? ', @full_obj_name, @obj_id , @obj_type, @server_type_id 
--		insert into #dep
--		select 
--		obj.obj_id dep_obj_id, 'ssas to sql mapping'  [dep_type_id] 
--		--cube_obj.[db_name],
--		--cube_obj.[obj_name] , cube_obj.obj_name 
--		--, obj.[db_name]
--		--, obj.[obj_name] , obj.obj_name 
--		from dbo.obj_ext cube_obj
--		left join dbo.obj_ext obj on 
--		cube_obj.obj_name = obj.obj_name
--		and cube_obj.obj_id <> obj.obj_id 
--		and case when cube_obj.[db_name] like '%_company%' then 'bi_ready_dm' else 'MyDWH_dm' end = obj.[db_name]
--		-- object must live inside relevant datamart.
--		and obj.server_type_id=10 -- sql server 
--		where cube_obj.server_type_id = 20
--		and cube_obj.obj_type = 'table'
--		and cube_obj.obj_id = @obj_id 
--		and obj.obj_id is not null --> same as inner join
--		-- but not always the name of the tables are similar-> try 
--		-- to fix this using the sql query behind the table
--		if @@rowcount=0 and @obj_type = 'table'-- no name match..
--		begin 
--			declare @cnt as int 
--			select @cnt =count(*) from dbo.Obj_dep where obj_id = @obj_id 
--			if @cnt>0
--				goto footer -- there is already >1 dependency
--			-- step 2
--			exec dbo.log @transfer_id, 'step' , 'no name match-> try to match using sql behind ssas table'
--			if object_id('tempdb..#ssas_queries') is not null
--				drop table #ssas_queries
	
--			set @sql  ='
--if object_id("tempdb..<temp_table>") is not null
--	drop table <temp_table>
--select convert(varchar(255), name) name, convert(varchar(8000),[QueryDefinition]) sql 
--into <temp_table> 
--from openrowset(''MSOLAP'', ''DATASOURCE=ssas01.company.nl;Initial Catalog=<db>;<credentials>''
--			 , ''
--			select [name], [QueryDefinition] from 
--SYSTEMRESTRICTSCHEMA([$System].[TMSCHEMA_PARTITIONS], [TableID]=""<identifier>"" )
--			'')
--declare @sql as varchar(8000) 
--	, @parsed_sql as SplitList 
--select @sql=[sql] 
--from <temp_table> 
--insert into @parsed_sql select * from util.parse_sql(@sql) 
--select @from_clause = item 
--from @parsed_sql
--where i=0 
--'
--			--select * into #ssas_queries exec(@sql) 
--			delete from @p 		
--			insert into @p values('credentials'	, 'User=domain\user;password=secret') 
--			insert into @p values('db'				, @db_name) 
--			insert into @p values('identifier'				, @identifier) 
--			insert into @p values('obj_id', @obj_id) 
--			insert into @p values('obj_name', @obj_name) 
--			insert into @p values('temp_table' ,	'#ssas_query_<obj_id>') 

		
--			EXEC util.apply_params @sql output, @p
--			EXEC util.apply_params @sql output, @p -- twice
--			declare @from_clause as varchar(8000) 
--			-- exec dbo.log @transfer_id, 'VAR' , '@sql ?', @sql
--			exec dbo.log @transfer_id, 'VAR' , 'identifier ?', @identifier
--			exec dbo.log @transfer_id, 'VAR' , 'SQL ?', @sql
--			EXECUTE sp_executesql @sql, N'@from_clause as varchar(8000) OUTPUT', @from_clause = @from_clause OUTPUT
--			-- select @from_clause = util.filter(@from_clause , 'char(10),char(13)') 
--			exec dbo.log @transfer_id, 'VAR' , '@from_clause ?', @from_clause 
--			if @from_clause not like '%MyDWH_dm%' or
--			   @from_clause not like '%bi_ready_dm%'
--			begin 
--				set @dep_obj_name  = 
--					case when @db_name like '%_company%' then '[bi_ready_dm].' else '[MyDWH_dm].' end + @from_clause
--			end
--			exec dbo.log @transfer_id, 'VAR' , '@dep_obj_name:?', @dep_obj_name 
--			exec dbo.get_obj_id @full_obj_name=@dep_obj_name , @obj_id=@dep_obj_id output 
			
----			select @dep_obj_id = dbo.obj_id(@dep_obj_name , null) 
--			exec dbo.log @transfer_id, 'VAR' , '@dep_obj_id ?', @dep_obj_id
--			if @dep_obj_id is null 
--			begin 
--				-- if not found->try without db name
--				exec dbo.get_obj_id @full_obj_name=@from_clause , @obj_id=@dep_obj_id output 
--				exec dbo.log @transfer_id, 'VAR' , 'option 2 @dep_obj_id ?', @dep_obj_id
--			end 
			
--			if @dep_obj_id is not null 
--				insert into #dep
--				select 
--				@dep_obj_id dep_obj_id, 'ssas sql parsing'  [dep_type_id] 
--		end 
--		--print @sql 
--	end -- server_type = 20 ssas

set @sql += '

-- finally store the dependencies
-- select * from #dep 

-- update delete_dt
update d2
set delete_dt = 
	case when d.obj_id is null /* the dependency does not exists anymore */ 
		then getdate() 
	else null end 
	, record_dt = getdate()
	, record_user = suser_sname() 
from dbo.Obj_dep d2
left join #dep d on d2.dep_obj_id = d.obj_id and d2.dep_type_id = d.dep_type_id
where d2.obj_id = <obj_id>
-- deleted or undeleted
and ( (d.obj_id is null and d2.delete_dt is null ) /* the dependency does not exists anymore */ 
or ( d2.delete_dt is not null and d.obj_id is not null) ) 

-- insert new dependencies
insert into dbo.Obj_dep(obj_id, dep_obj_id, [dep_type_id]) 
select N"<obj_id>", obj_id, [dep_type_id]
from #dep
except 
select obj_id, dep_obj_id, [dep_type_id]
from dbo.Obj_dep
where obj_id = "<obj_id>" 

'

	delete from @p 		
	insert into @p values('obj_db'					, @obj_db) 
	insert into @p values('obj_id'					, @obj_id) 
	insert into @p values('obj_name'				, @obj_name) 
	insert into @p values('schema_name'				, @schema_name) 
	insert into @p values('full_obj_name'			, @full_obj_name) 
	insert into @p values('obj_schema_name'			, @obj_schema_name) 
	
	EXEC util.apply_params @sql output, @p

	exec @result = dbo.exec_sql @transfer_id, @sql 

	if @display = 1
		select * from dbo.Obj_dep_ext	
		where obj_id = @obj_id 
	
	--exec dbo.getp 'nesting' , @nesting output
	declare @save_@dependency_tree_depth as int = @dependency_tree_depth 
			, @dep_id as int

	-- we build a stack of to do items, that will be sequentially processed outside this procedure to prevent too many simultaneous executions. 
	-- first go down the dependency tree ( dependencies of objects that are dependent of @obj_id) 
	if @dependency_tree_depth > 0 -- travel through dependency tree
	begin 
		set @dependency_tree_depth += -1 
		set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @dependency_tree_depth = <dependency_tree_depth>, @obj_tree_depth=<obj_tree_depth>, @display=<display>, @transfer_id=<transfer_id> -- <full_obj_name>'
		
		delete from @p 		
		insert into @p values ('transfer_id'			, @transfer_id ) 
		insert into @p values ('display'				, @display ) 
		insert into @p values ('obj_tree_depth'			, @obj_tree_depth) 
		insert into @p values ('dependency_tree_depth'	, @dependency_tree_depth) 
		EXEC util.apply_params @sql output, @p

		insert into dbo.Stack([value]) 
		select replace(replace(@sql, '<obj_id>', d.dep_obj_id) , '<full_obj_name>', o.full_obj_name) 
		from dbo.Obj_dep_ext d
		inner join dbo.Obj_ext o on d.dep_obj_id = o.obj_id
		where d.obj_id = @obj_id
	end 

	-- second go down the object tree ( dependencies of objects that are childs of @obj_id). e.g. tables when @obj_id is a schema. 
	if @obj_tree_depth > 0 -- travel through object tree
	begin 
		set @obj_tree_depth += -1 
		set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @dependency_tree_depth = <dependency_tree_depth>, @obj_tree_depth=<obj_tree_depth>, @display=<display>, @transfer_id=<transfer_id> -- <full_obj_name>'
		delete from @p 		
		insert into @p values ('transfer_id'			, @transfer_id ) 
		insert into @p values ('display'				, @display ) 
		insert into @p values ('obj_tree_depth'			, @obj_tree_depth) 
		insert into @p values ('dependency_tree_depth'	, @dependency_tree_depth) 
		EXEC util.apply_params @sql output, @p

		insert into dbo.Stack([value]) 
		select replace(replace(@sql, '<obj_id>', obj_id) , '<full_obj_name>', full_obj_name) 
		from dbo.Obj_ext
		where parent_id = @obj_id
	end 

	footer:
	
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @dependency_tree_depth, @transfer_id
	-- END standard BETL footer code... 
 end 

GO
print '-- 54. get_obj_id'
IF object_id('[dbo].[get_obj_id]' ) is not null 
  DROP PROCEDURE [dbo].[get_obj_id] 
GO
	  
/*
------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------

-- 2017-09-06 BvdB Return meta data id for a full object name
-- full object name can be a table, view, schema, database or ... 

declare @obj_id  as int 
exec [dbo].[get_obj_id] '[DDP_IDW].[dbo]', @obj_id  output


exec [dbo].[get_obj_id] 'LOCALHOST', @obj_id  output--, 'NF'
exec [dbo].[get_obj_id] 'AdventureWorks2014.Production.Product', @obj_id  output--, 'NF'

select @obj_id  

*/
CREATE PROCEDURE [dbo].[get_obj_id] 
	@full_obj_name varchar(255) 
	, @obj_id int output 
	, @scope varchar(255) = null 
	, @obj_tree_depth int = 0
	, @transfer_id as int = -1
as
BEGIN
	-- standard BETL header code. perform some logging.
	set nocount on 
	declare @proc_name as varchar(255) = object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header_detail', '? ? , scope ?, depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth
	-- END standard BETL header code... 

	declare 
		@schema as varchar(255) 
		, @parent varchar(255) 
		, @db_name varchar(255) 

	--exec dbo.log @transfer_id, 'progress', 'looking for ?, scope ? ', @full_obj_name , @scope
	
	-- retrieve object meta data. If not found->refresh parent (schema)... 

	Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 

	-- When this proc is called on a table in an unknown database. The table obviously cannot be found in the meta data. 
	-- When this happens this procedure will try to go find the schema in the meta data. If this fails, it will try to get the database. If failed it will try to get the server name. 
	-- When successfull it wil go down again until it reaches the table. 
	
/*
	if @obj_id is null or @obj_id < 0 -- not found 
	begin -- refresh parent

		Set @parent = util.parent(@full_obj_name) 

		if @parent is null or @parent = ''
		begin
			-- this happens when for example a new view is just created in current database. 
			-- try to refresh current database
			exec dbo.log @transfer_id, 'Warn', 'object ? not found in scope ? and no parent ', @full_obj_name, @scope 

			select @db_name = dbo.current_db() 
			if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
				and @full_obj_name <> 'localhost' -- always stop at localhost. 
			begin
				exec dbo.log @transfer_id, 'INFO', 'Refreshing current db ? ', @db_name 
				exec dbo.refresh @db_name, 1
				-- retry
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
			end
			
			if @obj_id is null or @obj_id < 0 
			begin -- refreshing current database did not work -> try refreshing localhost
				exec dbo.log @transfer_id, 'INFO', 'Refreshing localhost '
				exec dbo.refresh 'localhost', 0
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 

				if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
				begin 
					exec dbo.log @transfer_id, 'INFO', 'Attempt to refresh current db ? ', @db_name
					exec dbo.refresh @db_name, 1
				end 
				-- retry
				Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
			end

			if @obj_id is null or @obj_id < 0 
				exec dbo.log @transfer_id, 'Warn', 'object ? not found', @full_obj_name, @scope 

			goto footer
		end
		exec dbo.log @transfer_id, 'Warn', 'object ?(?) not found. Try to refresh parent -> ? ', @full_obj_name, @scope , @parent
		exec dbo.refresh @parent, 0, @scope -- @obj_tree_depth 
		Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
	end 
	*/
	if @obj_id <0 -- ambiguous object-id 
	begin
		exec dbo.log @transfer_id, 'ERROR', 'Object name ? is ambiguous. ? duplicates.', @full_obj_name, @obj_id 

		-- this can occur when for example @full_obj_name = <schema>.<table|view>  and this object exists in more than 1 database.
		-- try to fix this by prefixing the current db_name
		select @db_name = dbo.current_db() 
		if @db_name is not null and @db_name <> @full_obj_name -- not already refreshing current db. 
			and @full_obj_name <> 'localhost' -- always stop at localhost. 
		begin
			set @full_obj_name = quotename(@db_name) + '.'+ @full_obj_name 
			-- retry
			Set @obj_id = dbo.obj_id(@full_obj_name, @scope) 
		end

		goto footer
	end

    footer:

	if isnull(@obj_id,0)  <= 0 
		exec dbo.log @transfer_id, 'ERROR', 'Object ? NOT FOUND', @full_obj_name, @scope

--				exec dbo.log @transfer_id, 'step', 'Found object-id ?(?)->?', @full_obj_name, @scope, @obj_id

	-- standard BETL footer code... 
	exec dbo.log @transfer_id, 'footer_detail', 'DONE ? ?(?)', @proc_name , @full_obj_name, @obj_id -- @obj_tree_depth, @transfer_id
	-- END standard BETL footer code... 
END

GO
print '-- 55. get_prop'
IF object_id('[dbo].[get_prop]' ) is not null 
  DROP FUNCTION [dbo].[get_prop] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB wrapper for getting property value
select  dbo.get_prop('use_linked_server' , 'My_PC')
*/
CREATE function [dbo].[get_prop] (
	@prop varchar(255)
	, @fullObj_name varchar(255) 
	, @scope as varchar(255) = null 
	)
returns varchar(255) 
as 
begin
	declare @obj_id as int 
	Set @obj_id = dbo.obj_id(@fullObj_name, @scope) 
	return dbo.get_prop_obj_id(@prop, @obj_id) 
end












GO
print '-- 56. get_prop_obj_id'
IF object_id('[dbo].[get_prop_obj_id]' ) is not null 
  DROP FUNCTION [dbo].[get_prop_obj_id] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
select dbo.get_prop_obj_id('etl_meta_fields', 63) 
*/
CREATE function [dbo].[get_prop_obj_id] (
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
			, @property_id  as int 
	--		, @proc_name as varchar(255) =  object_name(@@PROCID);
	
	-- END standard BETL header code... 
	--return dbo.get_prop_obj_id @obj_id 
	
	select @property_id = [property_id] from [static].[Property]
	where property_name = @prop 
	if @property_id is null 
		return 'invalid property !'
	;
	with q as ( 
	select o.obj_id, o.obj_name, p.property, p.value, p.default_value,
	case when p.[obj_id] = o.[obj_id] then 0 
		when p.[obj_id] = o.parent_id then 1 
		when p.[obj_id] = o.grand_parent_id then 2 
		when p.[obj_id] = o.great_grand_parent_id then 3 end moved_up_in_hierarchy
	from dbo.prop_ext p 
	left join dbo.obj_ext o on 
		p.[obj_id] = o.[obj_id] 
		or p.[obj_id] = o.parent_id
		or p.[obj_id] = o.grand_parent_id
		or p.[obj_id] = o.great_grand_parent_id
	where property = @prop
	and o.[obj_id] = @obj_id 
	) 
	, q2 as ( 
	select *, row_number() over (partition by [obj_id] order by moved_up_in_hierarchy asc) seq_nr 
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
print '-- 57. getp'
IF object_id('[dbo].[getp]' ) is not null 
  DROP PROCEDURE [dbo].[getp] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB get property value
declare @value varchar(255) 
exec betl.dbo.getp 'log_level', @Value output 
print 'loglevel' + isnull(@Value,'?')
select * from dbo.prop_ext
*/
CREATE PROCEDURE [dbo].[getp] 
	@prop varchar(255)
	, @value varchar(255) output 
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine scope 
  declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 0 -- set to 1 to debug this proc
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ? ?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @property_scope = property_scope , @prop_id = property_id
  from static.Property
  where [property_name]=@prop
  if @debug = 1 
   	  exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Property scope ?', @i1 =@property_scope, @simple_mode = 1
  if @prop_id is null 
  begin 
	print 'Property not found in static.Property '
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property ? not found in static.Property ', @i1 =@prop, @simple_mode = 1
	goto footer
  end
  if @property_scope is null 
  begin 
	print 'Property scope is not defined in static.Property'
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property scope ? defined in static.Property', @i1 =@prop, @simple_mode = 1
	goto footer
  end
  -- scope is not null 
  if @property_scope = 'user' -- then we need an obj_id 
  begin
	set @full_obj_name =  suser_sname()
  end
  
  --select @obj_id = dbo.obj_id(@full_obj_name, null) 
  select @obj_id = dbo.obj_id(@full_obj_name, null ) 
  if @debug = 1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Lookup ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
  -- exec dbo.get_obj_id @full_obj_name, @obj_id output, @property_scope=DEFAULT, @recursive_depth=DEFAULT, @transfer_id=@transfer_id
  if @obj_id  is null 
  begin 
	if @property_scope = 'user' -- then create obj_id 
	begin
		insert into dbo.Obj (obj_type_id, obj_name) 
		values (60, @full_obj_name)
			
		select @obj_id = dbo.obj_id(@full_obj_name, null) 
	    if @debug = 1 
		  exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='Created object ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1

	end
	else 
	begin
		if @debug = 1 
			exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='object not found ?(?) ', @i1 =@full_obj_name, @i2=@obj_id ,  @simple_mode = 1
		goto footer
	end
  end
  
  select @value = isnull(value,default_value) from dbo.Prop_ext
  where property = @prop  and obj_id = @obj_id 
  if @debug = 1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='var', @msg ='property value ?(?) ', @i1 =@prop, @i2=@value ,  @simple_mode = 1
  footer:
  if @debug=1 
	exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='DONE ? ? ?->?', @i1 =@proc_name , @i2 =@prop, @i3 =@full_obj_name, @i4=@value, @simple_mode = 1
  -- END standard BETL footer code... 
end

GO
print '-- 58. guess_entity_name'
IF object_id('[dbo].[guess_entity_name]' ) is not null 
  DROP FUNCTION [dbo].[guess_entity_name] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB try to guess default entity name. when incorrect, user can change it
SELECT dbo.[guess_entity_name]('par_relatie_id')
SELECT dbo.[guess_entity_name]('relatie_id')
SELECT dbo.[guess_entity_name]('child_relatie_id')
*/
CREATE  FUNCTION [dbo].[guess_entity_name]( @column_name VARCHAR(255), @obj_id int ) 
RETURNS VARCHAR(255) 
AS
BEGIN
	DECLARE @res VARCHAR(255) 
	,	@foreignCol_id int
	
	SELECT @foreignCol_id  = foreign_column_id
	from dbo.Col_hist
	where obj_id = @obj_id and column_name= @column_name
	if @foreignCol_id  is null 
		SELECT @foreignCol_id  = dbo.guess_foreign_col_id( @column_name, @obj_id ) 
	SELECT @res = [obj_name]
	FROM dbo.Col c
	INNER JOIN [dbo].[Obj] obj ON obj.obj_id = c.obj_id
	WHERE column_id = @foreignCol_id  
	RETURN @res 
END











GO
print '-- 59. guess_foreign_col_id'
IF object_id('[dbo].[guess_foreign_col_id]' ) is not null 
  DROP FUNCTION [dbo].[guess_foreign_col_id] 
GO
	  
	  
  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB gueses foreign column. Currently based on datavault hub natural keys
-- 2018-05-14 BvdB give prevalence to columns in same schema (same parent object). 
SELECT * 
from dbo.col_ext 
where column_id = dbo.guess_foreign_col_id('aanstelling_id', 346) 
select * from dbo.obj_ext
select dbo.guess_foreign_col_id('datum', 3367 )
select dbo.guess_foreign_col_id('top_relatie_id', 12212 )
select dbo.guess_foreign_col_id('werknemer_id', 13473 )
select dbo.guess_foreign_col_id('top_relatie_id', 13484 )
*/ 
CREATE FUNCTION [dbo].[guess_foreign_col_id]( @column_name VARCHAR(255) , @obj_id int=0 ) 
RETURNS int
AS
BEGIN
	DECLARE @nat_keys AS TABLE ( 
		column_id  int 
		, column_name  varchar(255) 
		, obj_name  varchar(255) 
		, trg_parent_id int 
		, src_parent_id int 
		, same_parent bit
		, diff_col_obj varchar(255) 
		, seq_nr int 
	) 
	;
	with foreign_cols as ( 
		SELECT c.column_id, c.column_name, o.[obj_name], o.parent_id trg_parent_id , o_src.parent_id  src_parent_id-- , COUNT(*) cnt
		, case when o.parent_id =o_src.parent_id  then 1 else 0 end same_parent
		, replace(o.[obj_name],  replace(c.column_name, '_id', ''), '') diff_col_obj
		FROM dbo.Col c
		INNER JOIN dbo.Obj o ON c.obj_id = o.obj_id
		left join dbo.Obj o_src ON o_src.obj_id =  @obj_id 
	--	INNER JOIN dbo.Col c2 ON c.obj_id = c2.obj_id -- AND c2.column_id <> c.column_id 
		WHERE 
			c.column_type_id = 100 -- nat_pkey 
			and o.delete_dt is null 
			and o_src.delete_dt is null 
			--and c.column_name=@column_name 
			-- AND c2.column_type_id = 100 
			-- AND c2.column_name NOT IN ( 'etl_data_source', 'etl_load_dt') 
			and o.obj_name like 'hub_%'
	) 
	INSERT INTO @nat_keys 
	select * 
	, row_number() over (partition by column_name order by same_parent desc,
	len (diff_col_obj)  asc 
	 ) seq_nr -- , COUNT(*) cnt
	 from foreign_cols 
	DECLARE @res INT 
	,		@pos INT 
	SELECT @res = column_id -- for now take the last known column if >1 
	FROM @nat_keys 
	WHERE column_name = @column_name
	AND util.prefix_first_underscore([obj_name]) ='hub' -- foreign column should be a hub
	and seq_nr = 1 
	SET @pos = CHARINDEX('_', @column_name)
	IF @res IS NULL AND @pos IS NOT NULL  
	BEGIN 
		DECLARE @remove_prefix AS VARCHAR(255) = SUBSTRING(@column_name, @pos+1, LEN(@column_name) - @pos)
		SELECT @res = 
		( 
		select top 1 column_id -- for now take the last known column if >1 
		FROM @nat_keys 
		WHERE column_name = @remove_prefix
		AND util.prefix_first_underscore([obj_name]) ='hub' -- foreign column should be a hub
		order by len(obj_name) asc
		) 	end
	-- Return the result of the function

	RETURN @res 
END











GO
print '-- 60. guess_prefix'
IF object_id('[dbo].[guess_prefix]' ) is not null 
  DROP FUNCTION [dbo].[guess_prefix] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- SELECT dbo.guess_prefix('par_relatie_id')
-- SELECT dbo.guess_prefix('relatie_id')
*/
CREATE FUNCTION [dbo].[guess_prefix]( @column_name VARCHAR(255) ) 
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @res INT 
	,		@pos INT 
	, @prefix VARCHAR(64)=''
	SELECT @res = MAX(column_id) -- for now take the last known column if >1 
	FROM dbo.Col c
	INNER JOIN dbo.[Obj] o ON o.[obj_id] = c.[obj_id]
	WHERE column_name = @column_name
	AND column_type_id = 100 -- nat_pkey
	AND util.prefix_first_underscore([obj_name]) ='hub' -- foreign column should be a hub
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
		FROM dbo.Col c
		INNER JOIN dbo.[Obj] o ON o.[obj_id] = c.[obj_id]
		WHERE column_name = @remove_prefix
		AND column_type_id = 100 -- nat_pkey
		AND util.prefix_first_underscore([obj_name]) ='hub'
	end
	-- Return the result of the function
	RETURN @prefix
END











GO
print '-- 61. info'
IF object_id('[dbo].[info]' ) is not null 
  DROP PROCEDURE [dbo].[info] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB 
exec dbo.info '[My_PC].[AdventureWorks2014]', 'AW'
exec dbo.info 
*/
CREATE PROCEDURE [dbo].[info]
    @full_obj_name as varchar(255) =''
	, @scope as varchar(255) =null
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ? ?', @proc_name , @full_obj_name,  @scope, @transfer_id
	-- END standard BETL header code... 
	declare @obj_id as int
			, @obj_name as varchar(255) 
			, @search as varchar(255) 
	--exec dbo.refresh @full_obj_name 
	--Set @obj_id = dbo.obj_id(@full_obj_name) 
	--if @obj_id is null 
	--	exec show_error 'Object ? not found ', @full_obj_name
	--else 
	--	exec dbo.log @transfer_id, 'INFO', 'obj_id ?', @obj_id 
	
	set @search = replace (@full_obj_name, @@SERVERNAME , 'LOCALHOST') 
	declare @replacer as ParamTable
	insert into @replacer values ( '[', '![')
	insert into @replacer values ( ']', '!]')
	insert into @replacer values ( '_', '!_')
	
	SELECT @search = REPLACE(@search, param_name, convert(varchar(255), param_value) )
	FROM @replacer;
	set @search  ='%%'+ @search +'%%'
	exec dbo.log @transfer_id, 'step', 'Searching ?', @search 
	declare @objects Table(
		obj_id int primary key
	) 
	insert into @objects 
	select o.obj_id
	from dbo.obj_ext o
	LEFT OUTER JOIN [dbo].[Obj] AS parent_o ON o.parent_id = parent_o.[obj_id] 
	LEFT OUTER JOIN [dbo].[Obj] AS grand_parent_o ON parent_o.parent_id = grand_parent_o.[obj_id] 
	LEFT OUTER JOIN [dbo].[Obj] AS great_grand_parent_o ON grand_parent_o.parent_id = great_grand_parent_o.[obj_id] 
	where ( o.full_obj_name like @search  ESCAPE '!'  or @search is null or @search = ''
	or 
	case when o.obj_type in ( 'user', 'server') then o.[obj_name] else 
		ISNULL( case when o.[srv_name]<>'LOCALHOST'then o.[srv_name] else null end  + '.', '') -- don't show localhost
		+ ISNULL( o.[db_name] , '') 
		+ ISNULL('.' + o.[schema_name] , '') 
		+ ISNULL('.' + o.schema_object , '') end  --full_obj_name_no_brackets
		like @search  ESCAPE '!'  
	) 
	
	and ( @scope is null 
			or @scope = o.scope 
			or @scope = parent_o.scope 
			or @scope = grand_parent_o.scope 
			or @scope = great_grand_parent_o.scope 
			)
	
	select o.* 
	from dbo.obj_ext o 
	inner join @objects os on o.obj_id = os.obj_id
	order by o.obj_id
	select c.*
	from [dbo].[Col_ext] c
	inner join @objects os on os.obj_id = c.obj_id
	order by c.ordinal_position asc
	select p.*
	from [dbo].[Prop_ext] p
	inner join @objects os on os.obj_id = p.obj_id
	order by p.obj_id, p.property

    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name,  @scope, @transfer_id
END











GO
print '-- 62. log_error'
IF object_id('[dbo].[log_error]' ) is not null 
  DROP PROCEDURE [dbo].[log_error] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
2018-01-02 BvdB centralize error handling. Allow custom code to integrate external logging
exec dbo.log_error 0, 'Something went wrong', 11 , 0, 0, 'aap'
-----------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[log_error](
	    --@batch_id as int
		@transfer_id as int
		, @msg as varchar(255) 
		, @severity as int 
		, @number as int = null 
		, @line as int = null 
		, @procedure as varchar(255) = null
		)
AS
BEGIN
	SET NOCOUNT ON;
	declare @batch_id as int
		,@sp_name as varchar(255) = object_name(@@PROCID)
	select @batch_id = batch_id from dbo.Transfer where transfer_id = @transfer_id 
	
	set @msg = '-- Error: '+ convert(varchar(255), isnull(@msg,'')) 
	print @msg

	insert into dbo.Transfer_log(log_dt, msg, transfer_id,log_type_id)
	values( getdate(), @msg, @transfer_id, 50) 

--	exec dbo.log @transfer_id, 'header', '?(?) severity ? ?', @sp_name ,@transfer_id, @severity, @msg
    INSERT INTO [dbo].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[transfer_id]) 
    VALUES (
    [util].Int2Char(@number)
    , isnull(@msg,'')
    , [util].Int2Char(@line) 
    ,  isnull(@procedure,'')
    , [util].Int2Char(@severity)
    , [util].Int2Char(@transfer_id))
	declare @last_error_id as int = SCOPE_IDENTITY()
    update dbo.[Transfer] set transfer_end_dt = getdate(), status_id = 200
    , last_error_id = @last_error_id
    where transfer_id = @transfer_id
    update dbo.[Batch] set batch_end_dt = getdate(), status_id = 200
    , last_error_id = @last_error_id
    where batch_id = @batch_id
       
--	exec dbo.log @transfer_id, 'ERROR' , @msg
	
   footer:
END












GO
print '-- 63. Obj_dep_ext'
IF object_id('[dbo].[Obj_dep_ext]' ) is not null 
  DROP VIEW [dbo].[Obj_dep_ext] 
GO


	  
-- select * from [dbo].[Obj_dep_ext] 
CREATE VIEW [dbo].[Obj_dep_ext] AS
select 
 obj.obj_id obj_id
, obj_dep.top_sort_rank
,obj.full_obj_name full_obj_name
, dep.obj_id dep_obj_id 
, dep.full_obj_name dep_full_obj_name
, obj_dep.dep_type_id
, dt.dep_type 

, obj.db_name obj_db_name
, obj.[schema_name] obj_schema_name
, obj.obj_name obj_name
, obj.obj_type 

, dep.db_name dep_db_name
, dep.[schema_name] dep_schema_name
, dep.obj_name dep_obj_name
, dep.obj_type dep_obj_type 


from dbo.Obj_dep obj_dep 
inner join static.dep_type dt on obj_dep.dep_type_id = dt.dep_type_id 
inner join dbo.obj_ext obj on obj_dep.obj_id = obj.obj_id
inner join dbo.obj_ext dep on obj_dep.dep_obj_id = dep.obj_id 
where obj_dep.delete_dt is null 

GO
print '-- 64. Obj_transfer'
IF object_id('[dbo].[Obj_transfer]' ) is not null 
  DROP VIEW [dbo].[Obj_transfer] 
GO
	  
CREATE  view dbo.Obj_transfer as 
select o.[schema_name], obj_id, scope, full_obj_name,  obj_type, max_transfer_dt
from dbo.Obj_ext o
left join ( 
	select src_obj_id , max([transfer_start_dt])  max_transfer_dt
	from dbo.transfer 
	where status_id= 100 -- success
	and src_obj_id is not null and [transfer_start_dt] is not null 
	group by src_obj_id 
) t	on o.obj_id = t.src_obj_id 
where 
 full_obj_name like '%stg%%' 
and obj_type in ('view', 'table') 

--order by [schema], o.scope, full_obj_name

GO
print '-- 65. onPreExecute'
IF object_id('[dbo].[onPreExecute]' ) is not null 
  DROP PROCEDURE [dbo].[onPreExecute] 
GO
	  
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-12 BvdB this is used in ssis event handling. 
declare @batch_id int ,
	@transfer_id int
exec dbo.start_transfer @batch_id output , @transfer_id output , 'test'
select * from dbo.batch where batch_id = @batch_id 
select * from dbo.transfer where transfer_id = @transfer_id
-- HEADER: onPreExecute batch_id 0, transfer_id 0,@src_obj_name :shared(?), @step_name ververs_kubus_cluster
declare @batch_id int =0
, @transfer_id int=0
, @package_name varchar(255) = ? 
, @scope varchar(255) = ?
, @schema varchar(255) = ?
, @src_obj_name varchar(255) =?
, @package_batch_id int =?
, @step_name as varchar(255) =?
exec betl.dbo.onPreExecute @batch_id output , @transfer_id output , @package_name, @scope , @schema , @src_obj_name , @package_batch_id , @step_name 
select @batch_id batch_id, @transfer_id transfer_id
*/
CREATE procedure [dbo].[onPreExecute]
	@batch_id int output
	, @transfer_id int output 
	, @package_name as varchar(255) 
	, @scope varchar(255) =null  
	, @schema varchar(255) ='' 
	, @src_obj_name varchar(255) ='' 
	, @package_batch_id int =null 
	, @step_name as varchar(255) =null
	, @guid as bigint = null 
	, @interactive_mode as int =null
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@target as varchar(255) 
		,@batch_name as varchar(255) 
		,@src_obj_id as int
	if @step_name in ('onPreExecute', 'onPostExecute')
		goto footer
	set @target = isnull(@schema+'_','') + isnull(@package_name,'') 
	set @batch_name = convert(Varchar(255), 
	isnull(@schema+'_','') + isnull(@scope,'') + 
		case when @package_name <> 'master' then isnull('_'+ @package_name,'') else '' end) 
	if @interactive_mode=1 	--If a package is running in SSIS Designer, 
	-- this property is set to True. If a package is running using the DTExec command prompt utility
	--, the property is set to False.
		set @guid = -1 
	--if @guid is null or len(@guid) <2 
	--	set @guid =   isnull(suser_sname() ,'')  + isnull('@'+ host_name() ,'') 
	if len(isnull(@src_obj_name,'')) > 0 
	begin
		select @src_obj_id  = dbo.obj_id(@src_obj_name, @scope) 
		if @src_obj_id  is null --try without scope 
			select @src_obj_id  = dbo.obj_id(@src_obj_name, null) 
	end
	--exec dbo.log @transfer_id, 'header', '? batch_id ?, transfer_id ?,@src_obj_name ?:?(?), @step_name ?', @proc_name , @batch_id, @transfer_id , @src_obj_name, @scope, @src_obj_id, @step_name
	--exec dbo.log @transfer_id, 'var', 'package_name ?',  @package_name
	--exec dbo.log @transfer_id, 'var', 'batch_name ?',  @batch_name
	--exec dbo.log @transfer_id, 'var', 'target ?',  @target
	if isnull( @package_batch_id  , -1 ) > 0 -- package batch id known-> if not then start_transfer will start the batch also
		set @batch_id = @package_batch_id  
	--exec dbo.log @transfer_id, 'step', 'pre start_transfer'
	if isnull( @transfer_id , -1 ) <=0 -- no transfer id known
		exec dbo.start_transfer @batch_id output , @transfer_id output , @package_name, @target, @src_obj_id, @batch_name , @guid
	--exec dbo.log @transfer_id, 'step', 'post start_transfer'
	
	--if isnull( @transfer_id , -1 ) <=0 -- no transfer id known
	--begin
	--	set @msg =  isnull( @step_name , '?')
	--	RAISERROR( @msg ,15,1) WITH SETERROR
	--end 
	--else
	begin
		if @step_name not in ('onPreExecute', 'onPostExecute')
		begin 
			--exec dbo.log @transfer_id, 'var', '@step_name ?', @step_name	
			exec dbo.log @transfer_id, 'header', '? ?', @proc_name , @step_name	
		end
	end
	
	footer: 
	
	--exec dbo.log 0, 'footer', '? batch_id ?, transfer_id ? ', @proc_name , @batch_id, @transfer_id 
end











GO
print '-- 66. Prop_ext'
IF object_id('[dbo].[Prop_ext]' ) is not null 
  DROP VIEW [dbo].[Prop_ext] 
GO

	  
	  
/* select * from [dbo].[Prop_ext]*/
CREATE VIEW [dbo].[Prop_ext]
AS
SELECT        
--o.obj_id, o.obj_type, o.obj_name, o.srv, o.db, o.[schema], o.table_or_view
o.obj_id, o.obj_type, o.full_obj_name
 , p.property_id , p.property_name property, pv.value, p.default_value, p.property_scope
 , pv.record_dt 
FROM            dbo.Obj_ext AS o 
INNER JOIN static.Property AS p ON o.obj_type = 'table' AND p.apply_table = 1 OR o.obj_type = 'view' AND p.apply_view = 1 OR o.obj_type = 'schema' AND p.apply_schema = 1 OR o.obj_type = 'database' AND 
                         p.apply_db = 1 OR o.obj_type = 'server' AND p.apply_srv = 1 
						 OR o.obj_type = 'user' AND p.apply_user = 1 
LEFT OUTER JOIN
                         dbo.Property_Value AS pv ON pv.property_id = p.property_id AND pv.obj_id = o.obj_id












GO
print '-- 67. pull'
IF object_id('[dbo].[pull]' ) is not null 
  DROP PROCEDURE [dbo].[pull] 
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-30 BvdB @full_obj_name can be a table or a schema_name. when @full_obj_name is a schema_name then 
-- pull will apply itself to all tables in this schema in the following way: 
-- construct a control flow for pulling all tables in @schema_name in the right order (based on foreign key dependencies). 
-- pull each table. 

-- when @full_obj_name is a table_name then pull will 
-- apply the push procedure on the source of this table. 

-- Pull is a top-down approach ( e.g. for the integrated datawarehouse). The target database model is leading. 
-- Push is a botom-up approach ( e.g. for staging layer and raw data warehouse). The raw source data is leading. 

exec reset
exec debug
exec verbose

exec dbo.pull 'betl.[dbo]' 
select * from dbo.obj_dep
where obj_id = 195
*/

CREATE PROCEDURE [dbo].[pull]
    @full_obj_name as sysname
	, @batch_id as int = null
	, @transfer_id as int = -1
	, @async as bit=0 -- run asynchronously 
AS

BEGIN
	begin try 

		declare 
			-- source
			@betl varchar(100) =db_name() 
			, @obj_id as int
			, @obj_name as sysname
			, @prefix as nvarchar(255) 
			, @obj_name_no_prefix as sysname
			, @obj_type as varchar(255) 
			, @srv_name as sysname
			, @schema_name as sysname
			, @db_name as sysname
			, @schema_id as int 

			-- other
			, @proc_name as varchar(255) =  object_name(@@PROCID)
			, @msg as varchar(255)
			, @sev as int = 15
			, @number as int =0
			, @result as int =0 
			, @status as varchar(100) = 'success'
			, @transfer_name as varchar(255) = 'pull '+ @full_obj_name 
		
		set @msg = 'error in '+@proc_name

		-- standard BETL header code... 
		set nocount on 
		exec dbo.log @transfer_id, 'Header', '?(t?,b?) ?, async=?', @proc_name ,  @transfer_id, @batch_id, @full_obj_name, @async
		-- END standard BETL header code... 

		exec dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name

		exec dbo.log @transfer_id, 'INFO', 'START ? ?, ?(?), async=?', @proc_name , @full_obj_name, @batch_id, @transfer_id, @async


		if @transfer_id = 0 
		begin
			set @status= 'skipped' --  select * from betl.static.status
			exec dbo.log @transfer_id, 'info', 'transfer_id is zero->skipping push'
			goto footer
		end

		exec dbo.get_obj_id @full_obj_name, @obj_id output, @obj_tree_depth=DEFAULT, @transfer_id=@transfer_id

		if @obj_id is null or @obj_id < 0 
		begin
			exec dbo.log @transfer_id, 'error',  'object ? not found.', @full_obj_name
			goto footer
		end
		else 
			exec dbo.log @transfer_id, 'step' , 'obj_id resolved: ?', @obj_id 

		select 
			@obj_type = obj_type
			, @obj_name = [obj_name]
			, @prefix = [prefix]
			, @obj_name_no_prefix = [obj_name_no_prefix]
			, @db_name = db_name
			, @schema_name = [schema_name] 
		from dbo.obj_ext 
		where [obj_id] = @obj_id 

		if @obj_type = 'schema'
		begin 
			exec dbo.log @transfer_id, 'step' , 'pull schema ?', @schema_name
			-- retrieve all foreign key dependencies for this schema
			-- exec dbo.get_dep @full_obj_name, 0, 1
			exec dbo.get_dep_obj_id @obj_id =@obj_id, @dependency_tree_depth = 0
					, @obj_tree_depth = 1,	@transfer_id=@transfer_id, @display = 0
			
			-- the stack may contain dependency searches for children or dependent objects of @obj_id. 
			exec dbo.process_stack @transfer_id

			exec [dbo].[top_sort_obj_dep] @transfer_id

			-- construct a control flow for pulling all tables in @schema_name in the right order (based on foreign key dependencies). 
			select d.* 
			from [dbo].[Obj_dep_ext] d
			inner join dbo.obj o on d.obj_id=o.obj_id
			where o.parent_id = @obj_id and obj_type ='table'


		end
		else
			begin 
				if @obj_type = 'table'
				begin
					exec dbo.log @transfer_id, 'step' , 'pull table ?', @obj_name

				end
				else
				begin 
					exec dbo.log @transfer_id, 'error' , 'pull can only be applied on schemas and tables. Not on a ?, for object= ?(?)', @obj_type, @full_obj_name, @obj_id
					goto footer
				end
			end


		-- standard BETL footer code... 
		footer:

	end try 
	begin catch
		set @msg  =isnull(error_procedure()+ ', ','')+ ERROR_MESSAGE() 
		set @sev = ERROR_SEVERITY()
		set @number = ERROR_NUMBER() 
		exec dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@number
		set @result = -3
		set @status='error'
	end catch 
	
	if @result is null
		set @result =-1
	if @result<>0 and @result<> -3
	begin
		set @status='error'
		exec dbo.log @transfer_id, 'error' , '? received error code ?', @proc_name, @result
	end

	exec dbo.end_transfer @transfer_id  ,@status
   
	exec dbo.log @transfer_id, 'footer', '? ?, ?(?), async=?', @proc_name , @full_obj_name, @batch_id, @transfer_id, @async
  
	-- make sure that caller also receives error 
	if @result <> 0 
	begin 
		set @msg  =isnull(error_procedure()+ ' ','')+ ' ended with error status.'
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
	end
		
   return @result 
END







GO
print '-- 68. push'
IF object_id('[dbo].[push]' ) is not null 
  DROP PROCEDURE [dbo].[push] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-04 BvdB push implements the core of BETL. 
-- In it's most simple form it will copy a table from A (source) to B (target). If target does not exist
-- it will be created. It can also do natural foreign key lookups, create and refresh lookup tables, add meta data. etc. 
-- all based on the template_id. 
-- betl will try to find the src object. If its name is ambiguous, it will trhow an error
logging hierarchy
-----------------
batch_id -> transfer_id -> transfer_log_id 
You can choose to let BETL generate the logging hierarchy, or you can integrate 
external logging hierachy. In this case you should supply the batch_id. 
The logging hierarchy is used in betl ssrs run log. 
exec betl.dbo.setp 'log_level', 'debug'
exec betl.dbo.push 'AdventureWorks2014.Production.Product'
exec betl.dbo.info 'AdventureWorks2014'
exec betl.dbo.setp 'recreate_tables', 1 , 'My_Staging'
exec betl.dbo.setp 'log_level', verbose
exec betl.[dbo].[my_info]
exec betl.[dbo].[info] '[AdventureWorks2014].[idv].[stgh_relatie]'
exec betl.dbo.push '[AdventureWorks2014].[idv].[stgh_relatie]'
*/
CREATE PROCEDURE [dbo].[push]
    @full_obj_name as nvarchar(255)
	, @batch_id as int = 0 -- see logging hierarchy above.
	, @template_id as smallint=null
	, @scope as varchar(255) = null 
	, @transfer_id as int = 0 -- see logging hierarchy above.
	, @async as bit=0 -- run asynchronously 
AS
BEGIN
	begin try 
--declare
--    @full_obj_name as varchar(255) = '[AdventureWorks2014].[idv].[stgl_relatieboom]'
--	, @batch_id as int = -1
--	, @scope as varchar(255) = null 
--	, @transfer_id as int = -1 -- see logging hierarchy above.
   set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	declare @template as varchar(100) 
			, @result as int =0 
    SELECT @template = template_name 
    from [static].[Template]
	where template_id = @template_id 
--   exec dbo.log @transfer_id, '-------', '--------------------------------------------------------------------------------'
   declare @transfer_name as varchar(255) = 'push '+ @full_obj_name + isnull(' [' + convert(varchar(10), @template)+ ']' ,'') 
	, @is_running_in_batch as bit = 0
	, @status as varchar(100) = 'success'
	--, @transfer_id as int =0 
   if @batch_id>0 -- meaning: a batch_id was given as parameter.
	  set @is_running_in_batch=1
   --exec dbo.start_batch @batch_id output, @transfer_name
   exec dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name
	-- standard BETL header code... 
	exec dbo.log @transfer_id, 'header', '? ?(?) batch_id ? transfer_id ? template_id ?', @proc_name , @full_obj_name, @scope, @batch_id, @transfer_id, @template_id
	if @transfer_id = 0 
	begin
		set @status= 'skipped' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'info', 'transfer_id is zero->skipping push'
		goto footer
	end
	--exec dbo.my_info
	declare @log_level as varchar(255) =''
		, @exec_sql as varchar(255) =''
	exec [dbo].[getp] 'log_level', @log_level output 
	exec [dbo].[getp] 'exec_sql', @exec_sql output 
	exec dbo.log @transfer_id, 'info', 'log_level ?, exec_sql ? ', @log_level , @exec_sql
	-- END standard BETL header code... 
	declare 
			-- source
			@betl varchar(100) =db_name() 
			, @obj_id as int
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
			, @src_col_str varchar(4000) 
			, @compare_col_str_src varchar(4000) 
			, @compare_col_str_trg varchar(4000) 
			, @key_domain_id varchar(20) = ''
--			, @nat_prim_keys ColumnTable
			, @nat_prim_keys_str varchar(4000)
			, @nat_prim_key1 varchar(255) 
			, @nat_prim_key_match as varchar(4000) 
			, @trg_col_listing_str varchar(4000)
			, @src_col_value_str varchar(4000)
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
			-- mapping (copy columns from source to target)
			, @col_mapping_src dbo.ColumnTable
			, @col_mapping_trg dbo.ColumnTable
			, @col_mapping_src_str as varchar(4000)
			, @col_mapping_src_str_delete_detectie as varchar(4000)
			, @col_mapping_trg_str as varchar(4000)
			-- lookup
			, @lookup_entity_name as varchar(255) 
			, @lookup_index AS INT 
			, @lookup_col_listing_str AS VARCHAR(4000) 
			, @trg_join_str AS VARCHAR(4000) 
			-- hub
			, @hub_name as varchar(255) 
			, @lookup_hub_or_link_name as varchar(255) 
			, @sat_name as varchar(255) 
			, @link_name as varchar(255) 
			, @full_sat_name as varchar(255) 
			
			-- Dynamic SQL 
			, @nl as varchar(2) = char(13)+char(10)
			, @p as ParamTable
			, @sql as varchar(max) 
			, @sql2 as varchar(max) 
			, @sql_delete_detection as varchar(max) 
			, @lookup_sql AS varchar(max) 
			, @from as varchar(max) 
			, @from2 as varchar(max) 
			, @trg_cols_str varchar(max) 
			, @insert_cols_str varchar(max) 
			, @key_domain_sql as varchar(max)  = ''
			, @key_domain_match as varchar(255)  = ''
			, @key_domain_match_upd_old_sat as varchar(255) = ''
				-- properties
			, @is_linked_server as bit 
			, @date_datatype_based_on_suffix as bit
			, @is_localhost as bit 
			, @has_synonym_id as bit 
			, @has_record_dt as bit
			, @has_record_user as bit 
			, @etl_meta_fields as bit
			, @recreate_tables as bit
			, @use_key_domain as bit
			, @delete_detection as bit=0 
			, @filter_delete_detection as varchar(255) 
			
			-- other
			, @current_db varchar(255) 	
			, @ordinal_position_offset int 
			, @transfer_start_dt as datetime
			, @catch_sql as varchar(4000) 
			, @msg as varchar(255) = 'error in '+@proc_name
			, @sev as int = 15
			, @number as int =0
	if charindex('%', @full_obj_name )  >0 
	begin
		exec @result = dbo.push_all     
			@full_obj_name 
			, @batch_id 
			, @template_id 
			, @scope 
			, @transfer_id  -- stay within same transfer
		goto footer
	end
	select @current_db = db_name() 
	if @transfer_start_dt is null or @transfer_start_dt < '2016-01-01' -- meaning: very old 
		set @transfer_start_dt  = getdate() 
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieve obj_id from name ?', @full_obj_name
	----------------------------------------------------------------------------
	exec dbo.inc_nesting
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=@scope, @transfer_id=@transfer_id
	exec dbo.dec_nesting
	if @obj_id is null or @obj_id < 0 
	begin
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ? not found.', @full_obj_name
		goto footer
	end
	else 
		exec dbo.log @transfer_id, 'step' , 'obj_id resolved: ?', @obj_id 
	
	exec dbo.update_transfer @transfer_id=@transfer_id, @src_obj_id = @obj_id  
	-- first-> refresh the meta data of @obj_id
	exec dbo.inc_nesting
	exec dbo.refresh_obj_id @obj_id= @obj_id, @transfer_id = @transfer_id  -- refresh schema again. add trg to meta data. 
	exec dbo.dec_nesting
	-- get all required src meta data 
	select 
	@obj_type = obj_type
	, @obj_name = [obj_name]
	, @prefix = [prefix]
	, @obj_name_no_prefix = [obj_name_no_prefix]
	, @default_template_id = default_template_id 
	, @srv = srv
	, @db = db
	, @schema = [schema] 
	, @is_linked_server = dbo.get_prop_obj_id('is_linked_server', @obj_id) 
	, @date_datatype_based_on_suffix = dbo.get_prop_obj_id('date_datatype_based_on_suffix', @obj_id) 
	, @is_localhost = dbo.get_prop_obj_id('is_localhost', @obj_id) 
	, @trg_schema_id = dbo.get_prop_obj_id('target_schema_id', @obj_id) 
	, @delete_detection = dbo.get_prop_obj_id('delete_detection', @obj_id ) 
	, @filter_delete_detection = dbo.get_prop_obj_id('filter_delete_detection', @obj_id ) 
	, @full_obj_name = full_obj_name
	, @template_id = case when isnull(@template_id,0) =0 then dbo.get_prop_obj_id('template_id', @obj_id)   else @template_id end -- don't overwrite when specified in proc call
	from dbo.obj_ext 
	where [obj_id] = @obj_id 
	IF ISNULL(@template_id,0)  = 0  -- no transfermethod known-> take default 
		SET @template_id = @default_template_id
	
	exec dbo.log @transfer_id, 'VAR', '@template_id ? ', @template_id
	IF @prefix = 'stgh' AND @template_id NOT IN (8,9) 
	BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ? is a hub/hubsat staging table and thus needs transfermethod 8 or 9.', @full_obj_name
		goto footer
	END
	IF @prefix = 'stgl' AND @template_id NOT IN (10,11) 
	BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ? is a link/hubsat staging table and thus needs transfermethod 10 or 11.', @full_obj_name
		goto footer
	END
	IF @prefix = 'stgd' AND @template_id NOT IN (12) 
	BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ? is a dimension staging table and thus needs transfermethod 12.', @full_obj_name
		goto footer
	END
	
	IF @prefix = 'stgf' AND @template_id NOT IN (13,14) 
	BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ? is a fact staging table and thus needs transfermethod 13 or 14.', @full_obj_name
		goto footer
	END
	if @obj_type not in ('table', 'view') 
	begin 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'ERROR', 'You can only push tables and views currently, no ?', @obj_type 
		goto footer
	END
    
    if @trg_schema_id is null 
	begin
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'Unable to determine target: No target schema specified'
		goto footer
	end 
    if not isnull(@template_id,0) > 0
	begin
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'No template specified for ?. please run ''exec ?.dbo.setp ''template_id'' , <template_id>, <full_obj_name>'' ', @full_obj_name, @betl 
		goto footer
	end 
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieving source columns'
	----------------------------------------------------------------------------
	insert into @cols 
	select * from dbo.get_cols(@obj_id)
	 -- select * from @cols 
	 -- do some checks...
	 if ( select count(*) from @cols WHERE column_type_id=100 ) = 0  and @template_id=8 -- we need >0 nat_pkey
	 begin
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'natural primary keys not found for ?. Please set column_type_id 100 in [dbo].[Col_ext].', @full_obj_name
		goto footer
	END
	 if ( select count(*) from @cols WHERE column_type_id=110 ) = 0  and @template_id=10 -- we need >0 nat_pkey
	 BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'natural foreign keys not found for ?. Please set column_type_id 110 in [dbo].[Col_ext].', @full_obj_name
		goto footer
	 END
	 if ( select count(*) from @cols WHERE column_type_id=300 ) = 0  and @template_id in (9) -- we need >0 attributes
	 BEGIN 
		exec dbo.log @transfer_id, 'INFO',  'Satelite contains no attributes and will not be created. @full_obj_name=?', @full_obj_name
		goto footer
	 END
 	 if ( select count(*) from @cols WHERE column_name='etl_data_source' ) = 0  and @template_id in (8,9,10,11) 
	 BEGIN 
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'ERROR',  'etl_data_source is a required column for hubs,links and sats. Please add this to your source table ?', @full_obj_name
		goto footer
	 END
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'determine target table name'
	----------------------------------------------------------------------------
	select
	 @trg_obj_name = @obj_name_no_prefix
	, @srv = [srv]
	, @trg_db = [db]
	, @trg_schema = [schema]
	, @trg_srv = [srv]
	, @trg_scope = [scope]
	from dbo.obj_ext
	where [obj_id] = @trg_schema_id  -- must exist (FK) 
	exec dbo.log @transfer_id, 'VAR', '@trg_obj_name ? ', @trg_obj_name
	exec dbo.log @transfer_id, 'VAR', '@trg_schema_id ? ', @trg_schema_id
	set @trg_location = isnull('['+ case when @trg_srv='LOCALHOST' then null else @trg_srv end + '].','') + isnull('['+@trg_db+'].','') + isnull('['+@trg_schema+']','') 
	set @trg_prefix = 
	case 
		when @template_id = 4 then 'imp_' + @schema
		when @template_id = 5 then 'stgh'
		when @template_id = 8 then 'hub'
		when @template_id in (9,11) then 'sat'
		when @template_id = 10 then 'link'
		when @template_id = 12 then 'dim'
		when @template_id in ( 13, 14 ) then 'feit'
	end  + '_' 
	if @template_id = 5 
		set @trg_obj_name = replace(@trg_obj_name, 'imp_' ,'') 
	
	set @lookup_hub_or_link_name = CASE WHEN @template_id IN (8 ,9) THEN 'hub_'+ isnull(@trg_obj_name,'') 
										WHEN @template_id IN (10,11) THEN 'link_'+ isnull(@trg_obj_name,'') 
									END 
	set @lookup_hub_or_link_name = @trg_location + '.[' + isnull( @lookup_hub_or_link_name ,'') +']'
	set @trg_obj_name    = isnull(@trg_prefix,'') + isnull(@trg_obj_name,'') 
	set @trg_full_obj_name = @trg_location + '.[' + isnull(@trg_obj_name,'') +']'
	set @full_sat_name = isnull(@trg_prefix,'')  + '.[' + isnull(@sat_name,'') +']'
	exec dbo.log @transfer_id, 'STEP', 'push will copy ?(?) to ?(?) using template ?', @full_obj_name, @obj_id, @trg_full_obj_name, @trg_obj_id, @template_id
	select
		@has_synonym_id= dbo.get_prop_obj_id('has_synonym_id', @trg_schema_id ) 
		, @has_record_dt = dbo.get_prop_obj_id('has_record_dt', @trg_schema_id ) 
		, @has_record_user = dbo.get_prop_obj_id('has_record_user', @trg_schema_id ) 
		, @etl_meta_fields = dbo.get_prop_obj_id('etl_meta_fields', @trg_schema_id) 
		, @recreate_tables = dbo.get_prop_obj_id('recreate_tables', @trg_schema_id ) 
		--, @use_key_domain = dbo.get_prop_obj_id('use_key_domain', @trg_schema_id) 
	set @trg_entity_name = @obj_name_no_prefix
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'determine key_domain'
	----------------------------------------------------------------------------
	set @use_key_domain  = dbo.get_prop_obj_id('use_key_domain', @obj_id) 
	if isnull(@use_key_domain,0) = 0 
	begin 
		with q as( 
			select foreign_cols.full_obj_name, convert( int, dbo.get_prop_obj_id('use_key_domain', foreign_cols.obj_id) )  use_key_domain
			FROM @cols cols
			INNER JOIN [dbo].[Col_ext] [foreign_cols] ON cols.[foreign_sur_pkey] = foreign_cols.column_id
			WHERE cols.column_type_id = 110 -- nat_fkey 
		) 
		select @use_key_domain  = use_key_domain
		from q 
		where use_key_domain=1 
	end
	
	exec dbo.log @transfer_id, 'VAR', '@use_key_domain ? ', @use_key_domain
	
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'determine target columns'
	----------------------------------------------------------------------------
	if @template_id in (4)  -- create etl_data_source col
		insert into @cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable , src_mapping) 
		values ( (select max(ordinal_position)+1 from @cols)	,  'etl_data_source',  null,       'varchar'	, 10 , 999				, 0,  replace(@schema, 'medcare', 'mc'))  
		-- 300 instead of 999 because 999 is skipped

	if @template_id in ( 1,4,5)  -- T/I 
		insert into @trg_cols
		select * from @cols
		where not ( @template_id = 5 and column_type_id=999 and column_name <> 'etl_data_source') -- skip meta data for template 5 except etl_Data_source
	-- create sur_pkey 
	if @template_id=8 -- hub
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'hub_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey
	if @template_id=10 -- link
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'link_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey
	set @ordinal_position_offset = 1
	if @template_id IN (9,11)  -- sat
	begin
		insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
		, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, [identity]) 
		values ( 1, 'sat_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 200,1 ) -- sur_pkey
		IF @template_id =9 
			insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
			, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, src_mapping) 
			values ( 2, 'hub_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 210, 'trg.[hub_'+ lower(@trg_entity_name) + '_sid]') 
		IF @template_id =11 
			insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,is_nullable
			, [entity_name] ,[numeric_precision] ,[numeric_scale] , column_type_id, src_mapping) 
			values ( 2, 'link_'+ lower(@trg_entity_name) + '_sid', null, 'int', null, 0, null, null, null, 210, 'trg.[link_'+ lower(@trg_entity_name) + '_sid]') 
		set @ordinal_position_offset = 2
	end
	-- add link sur_fkey
	INSERT into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,column_type_id, is_nullable
	, [entity_name] ,[numeric_precision] ,[numeric_scale] , [part_of_unique_index], [src_mapping]) 
	select row_number() over (order by c.ordinal_position) + @ordinal_position_offset
			,  CASE WHEN ISNULL(c.prefix,'') = '' THEN '' ELSE c.prefix+ '_' END 
				+ ISNULL(sur_fkey.column_name, 'invalid_sur_fkey') column_name 
			, null
			, sur_fkey.data_type
			, sur_fkey.[max_len] 
			, 210
			, 1 [is_nullable]
			, c.[entity_name]
			, sur_fkey.[numeric_precision] 
			, sur_fkey.[numeric_scale] 
			, 1 part_of_unique_index
			, 'trg.'+quotename( CASE WHEN ISNULL(c.prefix,'') = '' THEN '' ELSE c.prefix+ '_' END 
				+ ISNULL(sur_fkey.column_name, 'invalid_sur_fkey') ) 
	from @cols c -- identical 
	INNER JOIN dbo.Col sur_fkey ON sur_fkey.column_id = c.[foreign_sur_pkey] -- get [foreign_sur_pkey] details
	where 
		( @template_id IN ( 10,11)  and c.column_type_id in ( 110) ) -- links sur_fkey
	order by c.ordinal_position asc
	SELECT @ordinal_position_offset = isnull(MAX(ordinal_position) ,0) 
	FROM @trg_cols 
	insert into @trg_cols(ordinal_position,column_name,column_value,data_type,max_len,column_type_id, is_nullable
	, [entity_name] ,[numeric_precision] ,[numeric_scale] , [part_of_unique_index] , [src_mapping]) 
	select row_number() over (order by ordinal_position) + @ordinal_position_offset
			, column_name 
			, column_value
			,case when @date_datatype_based_on_suffix=1 and util.suffix(column_name, 5) = '_date' then 
				'date' else [data_type]  end 
			, [max_len] 
			, case 
					when [util].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id = 12 
						and ordinal_position = 1 -- dim 
					then 200 
					when [util].[prefix_first_underscore]( column_name ) = 'fkey' and @template_id in (13,14)
						and ordinal_position = 1 -- feit
					then 200 
					when [util].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id = 12 
						and ordinal_position > 1 -- dim 
					then 210 
					when [util].[prefix_first_underscore]( column_name ) = 'dkey' and @template_id in ( 13,14)  -- feit
					then 210 

					else column_type_id end  column_type_id 

			,case when column_type_id in (100, 200, 210) then 0 else [is_nullable] end
			,case when column_type_id in (210) then @trg_entity_name else [entity_name]  end 
			,[numeric_precision] 
			,[numeric_scale] 
			, CASE 
				WHEN @template_id in (8,9) AND column_type_id in (100, 110)  THEN 1 
				WHEN @template_id in (10,11) AND column_type_id in (100)  THEN 1 ELSE 0 END [part_of_unique_index] -- link and link sats only nat_pkeys
			, 'src.'+quotename(column_name) 
	from @cols c -- identical 
	where 
			( @template_id = 8 and column_type_id in ( 100) ) -- hubs
		or ( @template_id IN (9,11)  and column_type_id in ( 100, 300) ) -- sats
		OR ( @template_id IN (10,11)  and column_type_id in ( 100, 110) ) -- link attributes 
		OR ( @template_id IN (12,13,14)  ) -- facts and dims
	order by ordinal_position asc
	
	SELECT @ordinal_position_offset = MAX(ordinal_position) 
	FROM @cols 
	if @use_key_domain =1 
	begin
		if @template_id IN (8,9)   -- hubs and links
        	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] , src_mapping) 
			VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'key_domain_id'	, null				, 'int'	, NULL	  , 100			, 0 , 1, 'isnull(src.[key_domain_id],-1) key_domain_id') 
		if @template_id IN (10,11)   -- hubs and links
        	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] , src_mapping) 
			VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'key_domain_id'	, null				, 'int'	, NULL	  , 300			, 0 , 0, 'isnull(src.[key_domain_id],-1) key_domain_id') 

		--if @template_id IN (9,11)   -- hubs and links
  --      	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] , src_mapping) 
		--	VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'key_domain_id'	, null				, 'int'	, NULL	  , 100			, 0 , 1, 'isnull(src.[key_domain_id],-1) key_domain_id') 
	
		set @key_domain_sql = 'left join <betl>.dbo.Key_domain kd on src.etl_data_source = kd.key_domain_name'
	end
	if @etl_meta_fields =1 
	begin
		if @template_id IN (8,9,10,11)  -- hub sats and link sats
			and not exists ( select * from 	@trg_cols where column_name = 'etl_data_source' ) -- not already present (via column_type). 
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable , src_mapping) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_data_source',  null,       'varchar'	, 10 , 999				, 0, 'src.etl_data_source') 
		if @template_id IN (9,11)   -- hub sats and link sats
		begin
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 

			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_active_flg'	, 1					, 'bit'			, NULL	  , 999				, 0) 
        	INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] , src_mapping) 
			VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_load_dt'	, null				, 'datetime'	, NULL	  , 100			, 0 , 1, '''<transfer_start_dt>''') 
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_end_dt'	,  '''2999-12-31'''		, 'datetime'	, NULL	  , 999				, 0) 
		end
		else
			if @template_id not IN (5) 
        		INSERT into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, [part_of_unique_index] , src_mapping) 
				VALUES ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_load_dt'	, null				, 'datetime'	, NULL	  , 999			, 0 , 0, '''<transfer_start_dt>''') 
		
		if @template_id IN (9,11)  -- hub sats and link sats
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_deleted_flg'	, 0				, 'bit'			, NULL	  , 999				, 0) 
		if @template_id not IN (5) 
			insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable, src_mapping) 
			values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_transfer_id'		, null				, 'int'			, NULL	  , 999				, 0, '<transfer_id>') 
	end
					
	if @has_synonym_id=1 
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'synonym_id'		, null				, 'int'			, NULL	  , 999				, 1) 
	if @has_record_dt =1 
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]	, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_record_dt'	, 'getdate()'		, 'datetime'	, NULL	  , 999				, 0) 
	if @has_record_user =1 and @template_id<> 5
		insert into @trg_cols ( [ordinal_position]					, [column_name]		, [column_value]			, data_type		, max_len , column_type_id ,is_nullable) 
		values ( (select max(ordinal_position)+1 from @trg_cols)	,  'etl_record_user'	, 'suser_sname()'		, 'varchar'		, 255	  , 999				, 0) 
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'create table or view ddl'
	----------------------------------------------------------------------------
	declare @create_pkey as bit 
	set @create_pkey = case when @template_id >= 12 then 1 else 0 end 
	
	if @template_id=5 
		exec create_view @trg_full_obj_name, @trg_scope, @trg_cols, @full_obj_name, @transfer_id
	else 
		exec create_table @trg_full_obj_name, @trg_scope, @trg_cols, @transfer_id, @create_pkey
	exec dbo.inc_nesting 
	exec dbo.refresh_obj_id @obj_id= @trg_schema_id, @transfer_id = @transfer_id  -- refresh schema again. add trg to meta data. 
	exec dbo.get_obj_id @trg_full_obj_name , @trg_obj_id output, @trg_scope, @transfer_id
	exec dbo.dec_nesting
	if @trg_obj_id is null 
	begin
		set @status= 'error' --  select * from betl.static.status
		exec dbo.log @transfer_id, 'error',  'object ?(?) cannot be created', @trg_full_obj_name, @trg_scope
		goto footer
	end
	if @template_id=4
		set @scope = @schema -- set scope = source schema. e.g. adapt 
	if @template_id in (4,5) -- set scope in betl base
	begin
		update betl.dbo.Obj_ext
		set scope = @scope
		where [obj_id] = @trg_obj_id 
	end 
	if @template_id=5 -- nothing more todo
	begin
		exec dbo.inc_nesting
		exec dbo.refresh @full_obj_name = @trg_full_obj_name , @transfer_id = @transfer_id
		exec dbo.dec_nesting
		select @trg_full_obj_name trg_full_obj_name
		exec betl.dbo.update_transfer @transfer_id, @target_name = @trg_full_obj_name
		goto footer
	end
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'column mappings old'
	----------------------------------------------------------------------------
	 set @cols_str = ''
	 select @cols_str+=case when @cols_str='' then '' else ',' end + isnull('"'+ src_mapping +'"', 'src.'+quotename(column_name) ) 
	 from @cols
	 -- where column_type_id <> 999 -- no meta cols
	 order by ordinal_position asc

	 SET @attr_cols_str=''
	 select @attr_cols_str+= 'src.'+quotename(column_name)  + ','
	 from @cols
	 where column_type_id = 300
	 order by ordinal_position asc
	 	 
	set @nat_prim_keys_str=''
	select @nat_prim_keys_str+=case when @nat_prim_keys_str='' then '' else ',' end + 'src.'+column_name
	from @cols WHERE column_type_id=100 and column_name <> 'etl_data_source'
	order by ordinal_position asc
	if @use_key_domain=1 
		set @nat_prim_keys_str+= case when @nat_prim_keys_str='' then '' else ',' end + ' isnull(kd.key_domain_id,-1)' 
	set @src_col_value_str=''
	select @src_col_value_str+=case when @src_col_value_str='' then '' else ',' end + 'src.'+column_name
	from @cols WHERE column_type_id in ( 100,110) 
	set @trg_col_listing_str=''
	select @trg_col_listing_str+=case when @trg_col_listing_str='' then '' else ',' end + column_name
	from @cols WHERE column_type_id in ( 100,110) 
	if @use_key_domain=1 
	begin
		set @src_col_value_str+= case when @src_col_value_str='' then '' else ',' end + 'isnull(kd.key_domain_id,-1)' 
		set @trg_col_listing_str+= case when @trg_col_listing_str='' then '' else ',' end + 'key_domain_id' 
	end
	select @nat_prim_key1 = column_name
	from @cols 

	WHERE column_type_id in ( 100,110) 

	AND ordinal_position = ( select min(ordinal_position ) from @cols WHERE column_type_id in ( 100,110)  ) 
	--build @nat_prim_key_match 
	set @nat_prim_key_match =''
	select @nat_prim_key_match += case when @nat_prim_key_match ='' then 'src.' else ' AND src.' end 
	+  cols.column_name + ' = trg.' + cols.column_name 
	from @cols cols
	where ( column_type_id = 100 AND @template_id in (8, 9)   )  OR 
		  ( column_type_id in (100, 110)  AND @template_id in (10, 11) )  
	 -- natprim_keys 
	 if @use_key_domain = 1 
	 begin
		if @template_id in (8,10) 
		begin
			set @key_domain_match = ' AND isnull(kd.key_domain_id,-1) = trg.key_domain_id '
			set	@key_domain_match_upd_old_sat = ' And src.key_domain_id = trg.key_domain_id '
			set @key_domain_id = ', key_domain_id'
		end
		--	set @key_domain_match_del = ' And kd.key_domain_id = src.key_domain_id '
		if @template_id in (9,11)  
		begin
			set @key_domain_match = ' AND isnull(kd.key_domain_id,-1) = trg.key_domain_id '
			set	@key_domain_match_upd_old_sat = ' And src.key_domain_id = trg.key_domain_id '
			set @key_domain_id = ', key_domain_id'
		end
		--	set @key_domain_match_del = ' And kd.key_domain_id = src.key_domain_id '
	end
	select @sur_pkey1 = column_name
	from @trg_cols
	where column_type_id = 200 AND ordinal_position = ( select min(ordinal_position ) from @trg_cols WHERE column_type_id=200 ) 
	set @nat_fkey_match =''
	select @nat_fkey_match += case when @nat_fkey_match ='' then 'src.' else ' AND src.' end 
	+  cols.column_name + ' = trg.' + cols.column_name 
	from @cols cols
	where column_type_id = 110 -- natfkeys 
	set @trg_cols_str=''
	--set @trg_cols_str_met_alias=''
	select @trg_cols_str+=case when @trg_cols_str='' then '' else ',' end + quotename(column_name )
		--, @trg_cols_str_met_alias+=case when @trg_cols_str_met_alias='' then '' else ',' end + 'trg.'+ quotename(column_name) 
	from @trg_cols
		where 
		( 
		  ( column_type_id in ( 100, 210, 300) and @template_id in ( 10)  ) or 
		  ( column_type_id in ( 100, 110, 300) and @template_id IN ( 9,11)  ) or 
		  ( column_type_id in ( 100) and @template_id=8 )  or
		  ( @template_id in (1,4,12,13,14)  ) 
		  or ( column_name ='etl_data_source' )  
		) AND column_name not in (  'etl_load_dt', 'etl_transfer_id', 'etl_record_user')  -- added manually
	order by ordinal_position asc
	set @insert_cols_str=@trg_cols_str
	if @use_key_domain = 1 
	begin
		set @trg_cols_str = replace( @trg_cols_str, '[key_domain_id]',  'isnull([key_domain_id],-1) key_domain_id') 
	end
	exec dbo.log @transfer_id, 'var', 'cols_str ?', @cols_str
	exec dbo.log @transfer_id, 'var', 'trg_cols_str ?', @trg_cols_str
	exec dbo.log @transfer_id, 'var', 'insert_cols_str ?', @insert_cols_str
	exec dbo.log @transfer_id, 'var',  '@nat_prim_keys_str ?'    , @nat_prim_keys_str
	exec dbo.log @transfer_id, 'var',  '@nat_prim_key_match ?'   , @nat_prim_key_match
	exec dbo.log @transfer_id, 'var',  '@nat_prim_key1 ?'        , @nat_prim_key1 
	exec dbo.log @transfer_id, 'var',  '@src_col_value_str ?'  ,  @src_col_value_str
	exec dbo.log @transfer_id, 'var',  '@trg_col_listing_str ?'  ,  @trg_col_listing_str
	exec dbo.log @transfer_id, 'var',  '@nat_fkey_match ?' ,  @nat_fkey_match
	exec dbo.log @transfer_id, 'var',  '@sur_pkey1 ?'      ,  @sur_pkey1
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'column mappings new'
	----------------------------------------------------------------------------
	set @col_mapping_trg_str = ''
	select @col_mapping_trg_str += 
		case when @col_mapping_trg_str = '' then '' else ',' end + quotename(column_name) 
	from @trg_cols
	where src_mapping is not null 
	set @col_mapping_src_str = ''
	select @col_mapping_src_str += 
		case when @col_mapping_src_str = '' then '' else ',' end + src_mapping
	from @trg_cols
	where src_mapping is not null 
	set @col_mapping_src_str = replace(@col_mapping_src_str , 'trg.', 'src.') 
	set @col_mapping_src_str_delete_detectie = replace(@col_mapping_src_str , 'src.', 'trg.') 
	set @compare_col_str_src = ''
	select @compare_col_str_src+=case when @compare_col_str_src='' then '' else ',' end + src_mapping
	from @trg_cols
	where column_type_id in ( 100, 110, 210, 300 ) -- cdc is done on these columns (actually only 300, but link-sats need at least something)
	and column_name <> 'etl_load_dt'
	or column_name = 'etl_data_source'
	order by ordinal_position asc
	set @compare_col_str_src = replace(@compare_col_str_src, 'src.[key_domain_id]','trg.[key_domain_id]' ) 
	set @compare_col_str_trg = replace(@compare_col_str_src, 'src.', 'trg.') 
	exec dbo.log @transfer_id, 'var',  '@col_mapping_src_str ?'      ,  @col_mapping_src_str
	exec dbo.log @transfer_id, 'var',  '@col_mapping_src_str_delete_detectie ?'      ,  @col_mapping_src_str_delete_detectie
	exec dbo.log @transfer_id, 'var',  '@col_mapping_trg_str ?'      ,  @col_mapping_trg_str
	exec dbo.log @transfer_id, 'var',  '@compare_col_str_src ?'			 ,  @compare_col_str_src
	
    ----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'build template sql'
	----------------------------------------------------------------------------
	set @catch_sql ='
		END TRY
		BEGIN CATCH
       			use <current_db>
				declare @msg_<obj_id>_<transfer_id> as varchar(255) =ERROR_MESSAGE() 
						, @sev_<obj_id>_<transfer_id> as int = ERROR_SEVERITY()
						, @number_<obj_id>_<transfer_id> as int = ERROR_NUMBER() 
				IF @@TRANCOUNT > 0
                      ROLLBACK TRANSACTION
				set @status_id = 200				
				exec <betl>.dbo.update_transfer @transfer_id=<transfer_id>, @rec_cnt_src = @rec_cnt_src, @rec_cnt_new = @rec_cnt_new, @rec_cnt_changed=@rec_cnt_changed, @target_name = ''<trg_full_obj_name>'', @status_id =@status_id 
				exec dbo.log_error @transfer_id=<transfer_id>, @msg=@msg_<obj_id>_<transfer_id>,  @severity=@sev_<obj_id>_<transfer_id>, @number=@number_<obj_id>_<transfer_id> 

		END CATCH 
		if @status_id in ( 200, 300) 
			RAISERROR("push raised error" , 15 , 0)  WITH NOWAIT
		exec <betl>.dbo.update_transfer @transfer_id=<transfer_id>, @rec_cnt_src = @rec_cnt_src, @rec_cnt_new = @rec_cnt_new, @rec_cnt_changed=@rec_cnt_changed, @target_name = ''<trg_full_obj_name>'', @status_id =@status_id 
'
	exec dbo.log @transfer_id, 'STEP', 'build push sql'
	
	set @sql=''
	set @sql2 = '
---------------------------------------------------------------------------------------------------
-- start transfer method <template_id> <full_obj_name>(<obj_id>) to <trg_full_obj_name>(<trg_obj_id>)
---------------------------------------------------------------------------------------------------
select ''<trg_full_obj_name>'' trg_full_obj_name
'	
	  exec dbo.log @transfer_id, 'step', 'transfering ?(?) to ?(?) ', @full_obj_name, @obj_id, @trg_full_obj_name, @trg_obj_id
	  if @is_linked_server = 1 
	     set @from = 'openquery(<srv>, "select count(*) cnt from <full_obj_name> ") '
	  else 
		set @from = 'select count(*) cnt from <full_obj_name>'
	
	delete from @p
	insert into @p values ('betl'					, @betl) 
	insert into @p values ('full_obj_name'		, @full_obj_name) 
	insert into @p values ('trg_full_obj_name'		, @trg_full_obj_name) 
	insert into @p values ('srv'					, @srv ) 
	insert into @p values ('trg_obj_id'				, @trg_obj_id) 
	insert into @p values ('template_id'			, @template_id) 
	insert into @p values ('batch_id'				, @batch_id ) 
	insert into @p values ('transfer_id'			, @transfer_id ) 
	insert into @p values ('obj_id'					, @obj_id) 
	insert into @p values ('current_db'				, @current_db) 
	EXEC util.apply_params @catch_sql output, @p
	insert into @p values ('catch_sql'				, @catch_sql) 
	EXEC util.apply_params @from output, @p
	insert into @p values ('from'					, @from) 
	EXEC util.apply_params @sql2 output, @p
	set @sql+= @sql2
	set @from2 = 'select <top> <cols> from <full_obj_name>'
	if @is_linked_server = 1 
	    set @from = 'openquery(<srv>, "<from2> ") '
	
	if @template_id in (1,4,12,13)   -- truncate insert
	begin 
		set @sql2 = '
BEGIN TRY 
	-- truncate insert
	use <trg_db>;
	declare @rec_cnt_src as int
		, @rec_cnt_new as int
		, @rec_cnt_changed as int
		, @status_id as int = 100 
	select @rec_cnt_src = ( select count(*) from <full_obj_name> src ) 
	use <trg_db>;
	truncate table <trg_full_obj_name>;
	insert into <trg_full_obj_name>(<insert_cols_str>, etl_transfer_id, etl_load_dt)
		select <cols_str>, <transfer_id>, ''<transfer_start_dt>''
		from <full_obj_name> src ;
	
	set @rec_cnt_new =@@rowcount
	use <current_db>
	
<catch_sql> 
' 
	end -- truncate insert
	if @template_id in (14)   -- append insert
	begin 
		set @sql2 = '
BEGIN try
	-- truncate insert
	use <trg_db>;
	declare @rec_cnt_src as int = ( select count(*) from <full_obj_name> src ) 
	use <trg_db>;
	insert into <trg_full_obj_name>(<insert_cols_str>, etl_transfer_id, etl_load_dt)

		select <cols_str>, <transfer_id>, ''<transfer_start_dt>''
		from <full_obj_name> src;
	set @rec_cnt_new = @@rowcount
	use <current_db>
<catch_sql> 
' 
	end -- truncate insert
	
	if @template_id=8 -- Datavault Hub  (CDC)
	begin
		--build HUB 
		set @sql2 = '
BEGIN TRY
	-- build HUB 
	use <trg_db>;
	declare @rec_cnt_src as int
			, @rec_cnt_new as int
			, @rec_cnt_changed as int
			, @status_id as int = 100 
	
	select  @rec_cnt_src  = ( select count(*) from <full_obj_name> src ) 
	-- insert new hub keys
	insert into <trg_full_obj_name>(<insert_cols_str>, etl_transfer_id, etl_load_dt)
		select distinct <nat_prim_keys_str>, src.etl_data_source, <transfer_id>, ''<transfer_start_dt>''
		from <full_obj_name> src
		<key_domain_sql>
		left join <trg_full_obj_name> trg on <nat_prim_key_match> <key_domain_match> 
		where trg.<nat_prim_key1> is null -- not exist
	set @rec_cnt_new =@@rowcount
<catch_sql> 
'
	end
	if @template_id IN ( 9,11)  -- Datavault Sat (CDC)
	begin
		-- build SAT
		set @sql2 = '
BEGIN TRY 
-- build SAT
use <trg_db>;
	declare @rec_cnt_src as int
			, @rec_cnt_new as int
			, @rec_cnt_changed as int
			, @status_id as int = 100 
set @rec_cnt_src = ( select count(*) from <full_obj_name> src ) 
use <trg_db>;
if object_id(N''[tempdb]..#src'', ''U'') is not null 
	drop table #src
select src.* 	into #src
	from ( 
		select <compare_col_str_src>
		from <full_obj_name> src
		<key_domain_sql>
		inner join <lookup_hub_or_link_name> trg on <nat_prim_key_match> <key_domain_match>
		except 
		select <compare_col_str_trg>
		from <trg_full_obj_name> trg
		where trg.etl_active_flg=1 and trg.etl_deleted_flg=0
	) src
	begin transaction 
	insert into <trg_full_obj_name>(<col_mapping_trg_str>)
	select <col_mapping_src_str> 
	from #src src
	--inner join <lookup_hub_or_link_name> trg on <nat_prim_key_match> <key_domain_match>
	declare @cnt_new_and_changed as int =@@rowcount
	-- end date old sat records
	update trg set etl_active_flg = 0, etl_end_dt = src.etl_load_dt
	from <trg_full_obj_name> trg
	inner join <trg_full_obj_name> src on <nat_prim_key_match> <key_domain_match_upd_old_sat> and src.etl_transfer_id = <transfer_id>
	where trg.etl_active_flg = 1 and trg.etl_load_dt < src.etl_load_dt
	set @rec_cnt_changed =@@rowcount	
	set @rec_cnt_new = isnull(@cnt_new_and_changed,0)  - isnull(@rec_cnt_changed , 0) 
	
	commit transaction 
<catch_sql> 
'
if @delete_detection=1 
	set @sql_delete_detection= '
	-- Apply delete detection 
	BEGIN TRY 
	use <trg_db>;
	declare @rec_cnt_src as int
		, @rec_cnt_new as int
		, @rec_cnt_changed as int
		, @status_id as int = 100 
		, @cnt as int
	select @cnt = count(*) from <full_obj_name> src 
	if @cnt = 0 
		goto footer
	begin transaction
	
	insert into <trg_full_obj_name>(<col_mapping_trg_str>, etl_deleted_flg)
		select <col_mapping_src_str_delete_detectie>, 1 etl_deleted_flg
		from <trg_full_obj_name> trg

		left join (select src.* <key_domain_id>
				   from <full_obj_name> src
				   <key_domain_sql> ) src
					on <nat_prim_key_match> <key_domain_match_upd_old_sat>
		where 
		trg.etl_active_flg = 1 and trg.etl_deleted_flg = 0 
		<filter_delete_detection>
		and src.<nat_prim_key1> is null -- key does not exist anymore in src
		declare @rec_cnt_deleted as int =@@rowcount
	-- end date old sat records
	update trg set etl_active_flg = 0, etl_end_dt = src.etl_load_dt
	from <trg_full_obj_name> trg
	inner join <trg_full_obj_name> src on <nat_prim_key_match>  <key_domain_match_upd_old_sat> and src.etl_transfer_id = <transfer_id>
		and src.etl_deleted_flg=1 
	where trg.etl_active_flg = 1 and trg.etl_load_dt < src.etl_load_dt
	commit transaction
	footer:
	exec <betl>.dbo.update_transfer @transfer_id=<transfer_id>, @rec_cnt_deleted=@rec_cnt_deleted
	<catch_sql> 
	' 
	else 
	set @sql_delete_detection= ' -- delete detection is disabled for <full_obj_name>'
	end
	if @template_id=10 -- Datavault Link 
	BEGIN
		SET @lookup_sql =''
		SET @lookup_col_listing_str =''
		SET @trg_join_str = ''
		SELECT @lookup_sql += 
		'INNER JOIN '
		+ foreign_cols.[full_obj_name] 
		+ ' as lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) 
		+ ' ON lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.' + cols.[foreign_column_name] + ' = src.' + quotename(cols.column_name)
		+ case when dbo.get_prop_obj_id('use_key_domain', foreign_cols.obj_id) = 1 then  -- foreign hub has key domain column 
		' AND lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.key_domain_id = isnull(kd.key_domain_id,-1)' else '' end  + '
		'
			, @trg_col_listing_str += CASE WHEN @trg_col_listing_str ='' THEN '' ELSE ',' END 
			+ CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [foreign_cols].column_name + '
			'
			, @src_col_value_str += CASE WHEN @src_col_value_str ='' THEN '' ELSE ',' END 
			+'lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.'+ [foreign_cols].column_name + ' as '  
			+ CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [foreign_cols].column_name + '
			'
		
			, @trg_join_str += CASE WHEN @trg_join_str ='' THEN '' ELSE ' AND ' END 
			+'lookup_' + CONVERT(VARCHAR(25), cols.ordinal_position) +'.'+ [foreign_cols].column_name + 
			' = trg.' + CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [foreign_cols].column_name 
		FROM @cols cols
		INNER JOIN [dbo].[Col_ext] [foreign_cols] ON cols.[foreign_sur_pkey] = foreign_cols.column_id
		WHERE cols.column_type_id in (110) -- nat_fkey 
		select 
			@trg_join_str += CASE WHEN @trg_join_str ='' THEN '' ELSE ' AND ' END 
			+'src.'+ [cols].column_name + 
			' = trg.' + CASE WHEN ISNULL(cols.prefix, '') <> '' THEN cols.prefix + '_' ELSE '' END + [cols].column_name 
		FROM @cols cols
		WHERE cols.column_type_id in (100) -- nat_pkey 
		exec dbo.log @transfer_id, 'var',  '@trg_col_listing_str ?'  ,  @trg_col_listing_str

		exec dbo.log @transfer_id, 'var',  '@trg_join_str ?'  ,  @trg_join_str
		set @sql2 = '
BEGIN TRY
-- build LINK
use <trg_db>;
	declare @rec_cnt_src as int
			, @rec_cnt_new as int
			, @rec_cnt_changed as int
			, @status_id as int = 100 
set @rec_cnt_src = ( select count(*) from <full_obj_name> src ) 
-- insert new link keys
insert into <trg_full_obj_name>(<trg_col_listing_str>, etl_transfer_id, etl_load_dt, etl_data_source)
select <src_col_value_str>
, <transfer_id> etl_transfer_id
, ''<transfer_start_dt>'' etl_load_dt
, src.etl_data_source
from <full_obj_name> src
<key_domain_sql>
<lookup_sql>
left join <trg_full_obj_name> trg on <trg_join_str> 
where trg.<sur_pkey1> is null -- not exist
	
set @rec_cnt_new =@@rowcount
<catch_sql> 
---------------------------------------------------------------------------------------------------
-- end transfer method <template_id> <full_obj_name>(<obj_id>) to <trg_full_obj_name>(<trg_obj_id>)
---------------------------------------------------------------------------------------------------
'
	end
	
	--insert into @p values ('betl'					, @betl) 
	insert into @p values ('full_sat_name'				, @full_sat_name) 
	insert into @p values ('lookup_hub_or_link_name'	, @lookup_hub_or_link_name)  
	insert into @p values ('cols_str'					, @cols_str) 
	insert into @p values ('attr_cols_str'				, @attr_cols_str) 
	EXEC util.apply_params @key_domain_sql  output		 , @p
	insert into @p values ('key_domain_sql'				 , @key_domain_sql) 
	insert into @p values ('key_domain_match'			 , @key_domain_match) 
	insert into @p values ('key_domain_match_upd_old_sat', @key_domain_match_upd_old_sat)
	insert into @p values ('key_domain_id'				 , @key_domain_id)
	
	INSERT into @p values ('trg_cols_str'				, @trg_cols_str) 
	INSERT into @p values ('insert_cols_str'			, @insert_cols_str) 
	insert into @p values ('src_col_str'				, @src_col_str) 
	insert into @p values ('trg_db'				, @trg_db) 
	insert into @p values ('transfer_start_dt'		, @transfer_start_dt) 
	insert into @p values ('lookup_col_listing_str'		, @lookup_col_listing_str ) 
	insert into @p values ('sur_pkey1'			, @sur_pkey1) 
	insert into @p values ('col_mapping_trg_str'			, @col_mapping_trg_str) 
	insert into @p values ('col_mapping_src_str_delete_detectie'			, @col_mapping_src_str_delete_detectie) 
	insert into @p values ('col_mapping_src_str'			, @col_mapping_src_str) 
	insert into @p values ('compare_col_str_src'					, @compare_col_str_src	) 
	insert into @p values ('compare_col_str_trg'					, @compare_col_str_trg	) 
	
	insert into @p values ('trg_join_str'	, @trg_join_str ) 
	insert into @p values ('nat_prim_keys_str'	, @nat_prim_keys_str ) 
	insert into @p values ('nat_prim_key1'		, @nat_prim_key1 ) 
	insert into @p values ('nat_prim_key_match'	, @nat_prim_key_match ) 
	insert into @p values ('src_col_value_str'		, @src_col_value_str ) 
	insert into @p values ('trg_col_listing_str'		, @trg_col_listing_str ) 
	INSERT into @p values ('top'				, '')  -- you can fill in e.g. top 100 here
	INSERT into @p values ('filter_delete_detection'	, isnull('AND /* filter_delete_detection */'+ @filter_delete_detection,'') )  
	EXEC util.apply_params @lookup_sql output, @p
	insert into @p values ('lookup_sql'			, @lookup_sql) 
	EXEC util.apply_params @sql2 output, @p
	EXEC util.apply_params @sql_delete_detection output, @p
	set @sql+= @sql2
	exec @result = dbo.exec_sql @transfer_id=@transfer_id, @sql=@sql,  @async=@async
	if @result <> 0 
		goto footer
	exec @result = dbo.exec_sql @transfer_id, @sql_delete_detection
	if @result <> 0 
		goto footer
	select @status = status_name
	from static.status s
	inner join dbo.[transfer] t on s.status_id = t.status_id
	where t.transfer_id=@transfer_id
	if @status = 'error'
		goto footer
	-- END standard BETL footer code... 
	if @template_id IN ( 8)  -- Datavault Hub Sat (CDC and delete detection)
		exec @result = [dbo].[push]
			@full_obj_name=@full_obj_name
			, @batch_id=@batch_id
			, @template_id = 9 -- only sat
			, @scope =@scope
			, @async= @async
--			, @transfer_id=@transfer_id
	if @template_id IN ( 10)  -- Datavault Link Sat (CDC and delete detection)
		exec @result = [dbo].[push]
			@full_obj_name=@full_obj_name
			, @batch_id=@batch_id
			, @template_id = 11 -- only sat
			, @scope =@scope
--			, @transfer_id=@transfer_id
			, @async= @async

	if @template_id IN ( 4)  -- Truncate insert -> create stgh view
		exec @result = [dbo].[push]
			@full_obj_name=@trg_obj_name
			, @batch_id=@batch_id
			, @template_id = 5 -- only sat
			, @scope = @scope -- set current schema as scope
			, @async= @async
--			, @transfer_id=@transfer_id
		-- standard BETL footer code... 
   footer:

	end try 
	begin catch
		set @msg  =isnull(error_procedure()+ ', ','')+ ERROR_MESSAGE() 
		set @sev = ERROR_SEVERITY()
		set @number = ERROR_NUMBER() 
		exec dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@number
		set @result = -3
		set @status='error'
	end catch 
	
   if @result is null
		set @result =-1
	if @result<>0 and @result<> -3
	begin
		set @status='error'
		exec dbo.log @transfer_id, 'error' , '? received error code ?', @proc_name, @result
	end
   exec dbo.end_transfer @transfer_id  ,@status
   if @is_running_in_batch=0 or @status in ('error')-- when push is not running part of a running batch-> close the batch that was created for this push ... 
	   exec dbo.end_batch @batch_id, @status
   
   exec dbo.log @transfer_id, 'footer', '?(?) ?(?) transfer_id ?', @proc_name, @status , @full_obj_name, @scope, @transfer_id
   
   -- make sure that caller ( e.g. ssis) also receives error 
   if @result <> 0 
   begin 
		set @msg  =isnull(error_procedure()+ ' ','')+ ' ended with error status.'
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
	end
		
   return @result 
END












GO
print '-- 69. push_all'
IF object_id('[dbo].[push_all]' ) is not null 
  DROP PROCEDURE [dbo].[push_all] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB wrapper to call push for several objects
exec betl.dbo.push '%[dm].[stgd_%' , @batch_id =-1,  @scope = 'shared'
exec betl.dbo.push '%[idv].[stgl_%' , @batch_id =-1,  @scope = 'shared'
exec betl.dbo.push '%[medcare].[%' , @batch_id =0
-----------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[push_all]
    @full_obj_names as varchar(255)
	, @batch_id as int 
	, @template_id as smallint=0
	, @scope as varchar(255) = null 
	, @transfer_id as int =null
AS
BEGIN
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID)
		,@transfer_name as varchar(255) = 'push_all '+ @full_obj_names + isnull(' --' + convert(varchar(10), @template_id) ,'') 
	exec dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name
	-- standard BETL header code... 
	exec dbo.log @transfer_id, '-------', '--------------------------------------------------------------------------------'
	exec dbo.log @transfer_id, 'header', '? ?(?) batch_id ? transfer_id ? template_id ?', @proc_name , @full_obj_names, @scope, @batch_id, @transfer_id, @template_id
	exec dbo.log @transfer_id, '-------', '--------------------------------------------------------------------------------'
	-- END standard BETL header code... 
	
	if not isnull(@transfer_id,0)  > 0 and isnull(@batch_id,0)  > 0 
	begin
		exec dbo.log @transfer_id, 'ERROR', '? needs to be called via dbo.push', @proc_name
		goto footer
	end
	
	if not charindex('%', @full_obj_names )  >0 
	begin
		exec dbo.log @transfer_id, 'ERROR', '? needs % sign in @full_obj_names: ?', @proc_name, @full_obj_names
		goto footer
	end
	
	-- refresh @full_obj_names..  it will fail at %, but then it will try to refresh the parent ( without %)
	exec betl.[dbo].refresh @full_obj_names

	declare @sql as varchar(max)
			, @p as ParamTable
			, @betl varchar(100) =db_name() 
	set @full_obj_names = replace(@full_obj_names, '[', '\[') 
	set @full_obj_names = replace(@full_obj_names, ']', '\]') 
	set @sql = '
		declare @sql as varchar(max) =''begin try
''
		;
		with q As( 
			SELECT betl.full_obj_name 
			FROM <betl>.dbo.obj_ext betl
			where 
				1=1
				<scope_sql>
				and full_obj_name like "<full_obj_names>" ESCAPE "\"
		) 
		select @sql+= ''	exec <betl>.dbo.push @full_obj_name=''''''+ q.full_obj_name  + '''''', @batch_id =<batch_id>, @async=1
''
		from q
		
		select @sql+= ''
			declare @result as int=0 
			exec betl.dbo.log <transfer_id>, ""INFO"", ""done push_all <full_obj_names>""
		end try 
		begin catch
				declare @msg_<transfer_id> as varchar(255) =ERROR_MESSAGE() 
						, @sev_<transfer_id> as int = ERROR_SEVERITY()
						, @number_<transfer_id> as int = ERROR_NUMBER() 
				set @result =@number_<transfer_id>

				IF @@TRANCOUNT > 0
                      ROLLBACK TRANSACTION
				exec dbo.log_error @transfer_id=<transfer_id>, @msg=@msg_<transfer_id>,  @severity=@sev_<transfer_id>, @number=@number_<transfer_id> 
		end catch 
	   -- make sure that caller ( e.g. ssis) also receives error 
	   if @result<>0
	   begin 
			-- exec dbo.log <transfer_id>, ""ERROR"", ""push_all caught error code ?"", @result
			RAISERROR(""error in [dbo].[push_all]"" , 15 , 0)  WITH NOWAIT
		end
''
		declare @result as int=0
		exec @result = dbo.exec_sql <transfer_id>, @sql 
		if @result<>0 
			exec dbo.log <transfer_id>, "ERROR", "push_all result indicates an error ?", @result
		
	'
	insert into @p values ('full_obj_names'			, @full_obj_names) 
	declare @scope_sql as varchar(255) 
	set @scope_sql = 'and scope = "'+@scope+ '"'
	insert into @p values ('scope_sql'					, isnull(@scope_sql, '') ) 
	insert into @p values ('betl'						, @betl) 
	insert into @p values ('batch_id'					, @batch_id) 
	insert into @p values ('transfer_id'				, @transfer_id) 
	EXEC util.apply_params @sql output, @p
	declare @result as int=0
	exec @result = dbo.exec_sql @transfer_id, @sql 
	if @result<>0 
		exec dbo.log @transfer_id, 'error', '? returned error code ?', @proc_name, @result
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? scope ? transfer_id ?', @proc_name , @full_obj_names, @scope, @transfer_id
	return @result
end












GO
print '-- 70. refresh_obj_id'
IF object_id('[dbo].[refresh_obj_id]' ) is not null 
  DROP PROCEDURE [dbo].[refresh_obj_id] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 02-03-2012 BvdB This proc will refresh the meta data of servers, 
--	databases, schemas, tables and views (also ssas) 
-- 2018-03-26 BvdB added stored procedures to schema refresh
-- 2018-04-10 BvdB added server_type_id. Note that sql server via linked server is not finished.
select * from dbo.obj_ext where full_obj_name like '%[idv]%'
select * from dbo.obj_ext where full_obj_name like '%stgl%'
exec betl.dbo.reset
exec betl.dbo.setp 'exec_sql', 0
-- instead of executing the dynamic sql, betl will print it, so you can execute and debug it yourself.
delete from dbo.obj 
where server_type_id =20
exec [dbo].[refresh_obj_id] 9453,1
exec dbo.reset
exec dbo.setp 'exec_sql', 0 
exec dbo.setp 'log_level', 'verbose'
select * from dbo.obj_ext
where server_type_id = 20
order by 1 desc
*/
CREATE PROCEDURE [dbo].[refresh_obj_id]
    @obj_id int
	, @obj_tree_depth as int = 0 -- 0->only refresh full_obj_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- dbo.refresh 'LOCALHOST', 0 will only create a record in [dbo].[Obj] for the server BETL
						-- dbo.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- dbo.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- dbo.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill dbo.Col_hist with all columns meta data for each table and view. 
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ? , depth ?', @proc_name , @obj_id, @obj_tree_depth
	-- END standard BETL header code... 
	
	-- delete columns not related to objects... 
	delete c
	from dbo.col c
	left join dbo.obj o on c.obj_id = o.obj_id 
	where o.obj_id is null 
	-- in this proc. no matter what exec_sql says: always exec sql. 
	declare @exec_sql as int 
	exec dbo.getp 'exec_sql', @exec_sql output
	exec dbo.setp 'exec_sql', 1
	declare
			@obj_name as varchar(255) 
			, @full_obj_name2 varchar(255) 
			, @obj_type_id as int
			, @obj_tree_depth2 as int
             ,@sql as varchar(8000)
             ,@sql2 as varchar(8000)
             ,@sql3 as varchar(8000)
			 ,@sql_lookup_prefix as varchar(8000)
			
			, @sql_from as varchar(8000)
			, @sql_from2 as varchar(8000)
			, @sql_openrowset_ssas as varchar(8000) 
			, @sql_openquery as varchar(8000) 
             ,@cols_sql as varchar(8000)
             ,@cols_sql_select as varchar(8000)
             ,@db_name as varchar(100)
             ,@srv_name as varchar(100)
             ,@schema_name as varchar(255)
             ,@server_type as  varchar(255)
			, @nl as varchar(2) = char(13)+char(10)
			, @schema_id int
			, @p as ParamTable
			, @is_linked_server as bit 
			 ,@temp_table varchar(255)
			, @from varchar(8000) 
			, @from2 varchar(8000) 
			, @current_db varchar(255) 
			, @full_obj_name varchar(255)
			, @entity_name as varchar(255) 
			, @server_type_id as int 
			, @identifier as int 
			, @obj_type as varchar(255) 
	set @current_db = db_name() 
	set @sql_lookup_prefix   =  'cross join (select null prefix_name) prefix'
	select 
	@full_obj_name = full_obj_name
	,@obj_type = obj_type
	, @server_type_id = isnull(server_type_id, 10) -- default -> sql server
	, @server_type = server_type
	, @obj_name = [obj_name]
	, @srv_name = srv_name
	, @db_name = isnull(db_name,'') 
	, @schema_name = [schema_name] 
	, @is_linked_server = dbo.get_prop_obj_id('is_linked_server', @obj_id ) 
	, @entity_name = lower(obj_name)
	, @identifier = identifier
	from dbo.obj_ext 
	where obj_id = @obj_id
	exec dbo.log @transfer_id, 'step', 'refreshing ? ? ?', @server_type , @obj_type, @obj_name
	if @obj_type = 'server'  -- get all databases
	begin 
		if @server_type_id = 10 -- sql server
		begin
			set @from  = 'select name as obj_name, null as identifier, <const_database> as obj_type_id from sys.databases
						  where name not in ("master","model","msdb","tempdb") '
		end
		if @server_type_id = 20 -- ssas
			set @from   = 'select [CATALOG_NAME] as obj_name, null as identifier, "<const_database>" as obj_type_id from $System.DBSCHEMA_CATALOGS'
	end 
	if @obj_type = 'database' -- get all schemas and ssas roles
	begin 
		if @server_type_id = 10 -- sql server
--			set @from  = 'select schema_name as obj_name , null as identifier, "<const_schema>" as obj_type_id from <db>.information_schema.SCHEMATA	'
			set @from  = 'select s.name as obj_name , null as identifier, "<const_schema>" as obj_type_id 
						  FROM <db>.sys.schemas s inner join sys.sysusers u on u.uid = s.principal_id 
						  where u.issqluser = 1 and u.name not in ("sys", "guest", "INFORMATION_SCHEMA")	'
		if @server_type_id = 20 -- ssas
		begin	
			set @from   = 'select [Name] as obj_name, [ID] as identifier, "<const_schema>" as obj_type_id FROM [$System].[TMSCHEMA_MODEL]'
			set @from2  = 'select [Name] as obj_name, [ID] as identifier, "<const_role>" as obj_type_id FROM [$System].[TMSCHEMA_ROLES]'
		end 
	end 
	if @obj_type = 'role' 
	begin 
		if @server_type_id = 20 -- ssas
			set @from   = 'select [MemberName] as obj_name, [ID] as identifier, "<const_user>" as obj_type_id FROM 
							    SYSTEMRESTRICTSCHEMA([$System].[TMSCHEMA_ROLE_MEMBERSHIPS], [RoleID]=""<identifier>"" )'
	end 
	if @obj_type = 'schema' 
	begin 
		if @server_type_id = 10 -- sql server
		begin 
			set @from =  '
						select distinct o.name as obj_name , null as identifier, 
						case 
							when o.type = "V" then <const_view> 
							when o.type = "U" then <const_table> 
							when o.type = "P" then <const_procedure> 
						end obj_type_id 
						from <db>.sys.objects o
						inner join <db>.sys.schemas s on o.schema_id = s.schema_id
						where o.type in ( "U","V", "P") 
								  and s.name = "<schema>"
						and o.object_id not in (select major_id from <db>.sys.extended_properties 
									where name = N"microsoft_database_tools_support" and minor_id = 0 and class = 1) -- exclude ssms diagram procedures


'
			set @sql_lookup_prefix ='left join [dbo].Prefix prefix on [util].[prefix_first_underscore](obj_name) = prefix.prefix_name
			'
		end
		if @server_type_id = 20 -- ssas
			set @from   = 'select [Name] as obj_name, [ID] as identifier, "<const_table>" as obj_type_id FROM 
						          SYSTEMRESTRICTSCHEMA ([$System].[TMSCHEMA_TABLES], [IsHidden]=""0"")'
	end 

	set @sql_openrowset_ssas =  'select * from openrowset("MSOLAP", "DATASOURCE=<srv>;Initial Catalog=<db>;<credentials>", "<from>" )  '
	set @sql_openquery       =  'select * from openquery([<srv>], "<from>" )'
	if @from2 is null -- single from 
	begin
		if @is_linked_server =1 -- use linked server
			if @server_type_id = 10 -- sql server
				set @sql_from = @sql_openquery
			else 								
				set @sql_from = 'linked server not supported for non sql server servertype'
		else -- @is_linked_server =0
			if @server_type_id = 10 
				set @sql_from = 'select * from (<from>) q_from'
			else  --if @server_type_id = 20 
				set @sql_from = @sql_openrowset_ssas 	
	end 
	else -- composite from  (2 froms) 
		if @is_linked_server =1 -- use linked server
			if @server_type_id = 10 -- sql server
				set @sql_from = @sql_openquery +' union all '+ replace(@sql_openquery, '<from>', '<from2>') 
			else 								
				set @sql_from = 'linked server not supported for non sql server servertype'
		else -- @is_linked_server =0
			if @server_type_id = 10 
				set @sql_from = 'select * from (<from>) q_from1 union all select * from (<from2>) q_from2'
			else  --if @server_type_id = 20 
				set @sql_from = @sql_openrowset_ssas +' union all '+ replace(@sql_openrowset_ssas, '<from>', '<from2>') 
	
	set @sql2 = '
begin try 
begin transaction 
	if object_id("tempdb..<temp_table>") is not null 
		drop table <temp_table>
   
    -- create temp table using default collation ( instead of select into ) 
	CREATE TABLE <temp_table>(
		[obj_type_id] [int] NULL,
		[obj_name] [varchar](255) NULL,
		[parent_id] [int] NOT NULL,
		[server_type_id] [int] NOT NULL,
		[identifier] [int] NULL,
		[prefix_name] [varchar](255) NULL,
		[obj_name_no_prefix] [varchar](255) NULL
	) 
	insert into <temp_table> with (tablock)
	select q.*, prefix_name 
	, case when prefix_name is not null and len(prefix_name)>0 then substring(q.obj_name, len(prefix_name)+2, len(q.obj_name) - len(prefix_name)-1) else q.obj_name end obj_name_no_prefix
	from (
		select convert(int, convert(nvarchar(255), obj_type_id)) obj_type_id, convert(varchar(255), obj_name) obj_name, <parent_id> parent_id, <server_type_id> server_type_id, convert(int, convert(nvarchar(255), identifier)) identifier
		from ( <sql_from> ) q2
	) q
	<sql_lookup_prefix>
'
	set @sql = '<sql2>
	insert into [dbo].[Obj] (obj_type_id, obj_name, parent_id, server_type_id, identifier, prefix, obj_name_no_prefix) 
	select q.* 
	from <temp_table> q 
	left join [dbo].[Obj] obj on q.obj_name = obj.obj_name and q.obj_type_id = obj.obj_type_id and q.parent_id = obj.parent_id 
	where obj.obj_name is null -- not exist 
					
	update [dbo].[Obj] 				 			 
	set delete_dt = 
		case when q.obj_name is null and Obj.delete_dt is null then <dt> 
		when q.obj_name is not null and Obj.delete_dt is not null then null end
		,record_dt = getdate(), record_user = suser_sname()
	from [dbo].[Obj] 
	left join <temp_table> q on Obj.obj_name = q.obj_name and obj.obj_type_id = q.obj_type_id 
	where obj.parent_id = <parent_id> 
	and  ( (q.obj_name is null     and Obj.delete_dt is null ) or 
  	       (q.obj_name is not null and Obj.delete_dt is not null ) )
	
	drop table <temp_table>
	commit transaction 
end try 
begin catch 
	declare 
		@msg as varchar(255)
		, @sev as int
	
	set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),""))
	set @sev = ERROR_SEVERITY()
	RAISERROR("Error Occured in [refresh_columns]: %s", @sev, 1,@msg) WITH LOG
	IF @@TRANCOUNT > 0  
		rollback transaction 
end catch 
'
		-- refresh columns 
	if @obj_type in ( 'table', 'view' ) and @server_type_id in (  10,20)  -- sql server
	begin 
		exec dbo.log @transfer_id, 'step', 'refreshing ? ? ?', @obj_type, @obj_name, @server_type_id 
		if @server_type_id = 10 
		begin 
			set @from   = 'something'
			set @cols_sql_select = '
	select 
		<obj_id> obj_id 
	, ordinal_position
	, column_name collate database_default   column_name
	, case when is_nullable="YES" then 1 when is_nullable="NO" then 0 else NULL end is_nullable
	, data_type 
	, character_maximum_length max_len
	, case when DATA_TYPE in ("int", "bigint", "smallint", "tinyint", "bit") then cast(null as int) else numeric_precision end numeric_precision
	, case when DATA_TYPE in ("int", "bigint'', ''smallint", "tinyint'', "bit") then cast(null as int) else numeric_scale end numeric_scale
	, case when util.suffix(column_name, 4) = "_key" then 
				case when lower(util.prefix(column_name, 4)) = "<entity_name>" then 100 else 110 end -- nat_key
			when util.suffix(column_name, 4) = "_sid" 
				then case when util.prefix_first_underscore(column_name) = ''hub'' then 200 else 210 end 
			when column_name= ''etl_data_source'' then 999 
			when left(column_name, 4) = "etl_" then 999
			else 300 -- attribute
		end derived_column_type_id 
	'
			if @is_linked_server = 1 
				set @cols_sql = '
	<cols_sql_select>
	from openquery( [<srv>], 
	"select ordinal_position, COLUMN_NAME collate database_default column_name
	, IS_NULLABLE, DATA_TYPE data_type, CHARACTER_MAXIMUM_LENGTH max_len
	, numeric_precision
	, numeric_scale
	from <db>.information_schema.columns where TABLE_SCHEMA = ""<schema>""
	and table_name = ""<obj_name>""
	order by ordinal_position asc"
			'
			else
				set @cols_sql = '
	<cols_sql_select>
	from <db>.information_schema.columns where TABLE_SCHEMA = "<schema>"
	and table_name = "<obj_name>"
				'
		end -- if @server_type_id = 10 
		if @server_type_id = 20 --ssas
		begin
			exec dbo.log @transfer_id, 'step', 'refreshing ssas ? ?', @obj_type, @obj_name
			-- set @sql_openrowset_ssas =  'select * from openrowset("MSOLAP", "DATASOURCE=<srv>;Initial Catalog=<db>;<credentials>", "<from>" )  '
			set @from = 'select 
	columnStorageID
	, sourceColumn as column_name
	, IsNullable as is_nullable
	, ExplicitDataType
	, isHidden
	, [TableID]
	FROM SYSTEMRESTRICTSCHEMA ([$System].[TMSCHEMA_COLUMNS], [TableID]=""<identifier>"", [IsHidden]=""0"", [Type]=""1"")'
		set @sql_from = @sql_openrowset_ssas
	
		set @cols_sql = ' 
	select 
		<obj_id> obj_id 
	, row_number() over (partition by <obj_id> order by columnStorageID) ordinal_position
	, convert(varchar(255), column_name) column_name
	, case when is_nullable="True" then 1 when is_nullable="False" then 0 else NULL end is_nullable
	, case when ExplicitDataType = 6 then "int" 
		when ExplicitDataType = 2 then "varchar" 
	  end data_type 
	, null max_len
	, null numeric_precision
	, null numeric_scale
	, null derived_column_type_id 
	from (<sql_from>) sql_from '
		end --if @server_type_id = 20 
			set @sql = '
	-----------------------------------------
	-- START refresh_obj_id <full_obj_name>(<obj_id>)
	-----------------------------------------
	BEGIN TRANSACTION T_refresh_columns
	BEGIN TRY
		if object_id("tempdb..<temp_table>") is not null drop table <temp_table>;
		with cols as ( 
			<cols_sql> 
		) 
		, q as ( 
		select 
		case when src.obj_id is null then trg.obj_id else src.obj_id end obj_id 
		, case when src.column_name is null then trg.column_name else src.column_name end column_name
		, src.ordinal_position
		, src.is_nullable
		, util.trim(src.data_type, 0) data_type
		, src.max_len
		, src.numeric_precision
		, src.numeric_scale
		, src.derived_column_type_id
		, trg.[column_type_id]
		, trg.src_column_id
		, trg.chksum old_chksum
		, getdate() eff_dt
		, trg.column_id trg_sur_key
		, case when trg.[prefix] is null AND trg.column_type_id = 110 THEN dbo.guess_prefix(src.column_name) ELSE trg.[prefix] END prefix
		, case when trg.[entity_name] is null AND trg.column_type_id = 110 THEN dbo.guess_entity_name(src.column_name, <obj_id>) ELSE trg.[entity_name] END entity_name
		, case when check_foreign_column.column_id is null AND trg.column_type_id = 110 then dbo.guess_foreign_col_id(src.column_name, <obj_id>) ELSE trg.foreign_column_id END foreign_column_id
		, case when src.obj_id is not null then 1 else 0 end in_src
		, case when trg.obj_id is not null then 1 else 0 end in_trg
		from cols src
		full outer join dbo.Col trg on src.obj_id = trg.obj_id AND src.column_name = trg.column_name
		left join dbo.Col check_foreign_column on check_foreign_column.column_id = trg.foreign_column_id
		where 
		not ( src.obj_id is null and trg.obj_id is null ) 
		and ( trg.obj_id is null or trg.obj_id in ( select obj_id from cols) ) 
		and trg.delete_dt is null 
		
		) , q2 as (
			select *, 
			 checksum("sha1", util.trim(src.ordinal_position, 0)
			 +"|"+util.trim(src.is_nullable, 0)
			 +"|"+util.trim(src.data_type, 0)
			 +"|"+util.trim(src.max_len, 0)
			 +"|"+util.trim(src.numeric_precision, 0)
			 +"|"+util.trim(src.numeric_scale, 0) 
			 +"|"+util.trim(src.entity_name, 0) 
			 +"|"+util.trim(src.foreign_column_id, 0) 
			 ) chksum 
			 from q src
		 ) 
			select 
					case 
					when old_chksum is null then "NEW" 
					when in_src=1 and old_chksum <> chksum and obj_id is not null then "CHANGED"
					when in_src=1 and old_chksum = chksum then "UNCHANGED"
					when in_src=0 and in_trg=1 then "DELETED"
					end mutation
					, * 
			into <temp_table>
			from q2
		      
			-- new records
			insert into dbo.Col_hist ( obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, transfer_id, column_type_id,src_column_id, prefix, entity_name, foreign_column_id) 
			select obj_id,column_name, eff_dt, ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale, chksum, -1 , derived_column_type_id,src_column_id , prefix, entity_name, foreign_column_id from <temp_table>
			where mutation = "NEW"
  
			-- changed records and deleted records
			set identity_insert dbo.Col_hist on
  
			insert into dbo.Col_hist ( obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len, numeric_precision,numeric_scale , delete_dt, column_id, chksum, transfer_id, column_type_id, src_column_id , prefix, entity_name, foreign_column_id) 
			select obj_id,column_name, eff_dt,  ordinal_position,is_nullable,data_type,max_len,numeric_precision,numeric_scale 
			, case when mutation = "DELETED" then getdate()  else null end delete_dt
			, trg_sur_key -- take target key for deleted and changed records
			, chksum
			, -1
			, column_type_id 
			, src_column_id
			,prefix 
			,  [entity_name]
			, foreign_column_id
			from <temp_table>
			where mutation in ("CHANGED", "DELETED")
  
			set identity_insert dbo.Col_hist off
		
			drop table <temp_table>
			-----------------------------------
			-- END HISTORIZE <temp_table>
			-----------------------------------
			USE <current_db>
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
			ROLLBACK TRANSACTION T_refresh_columns
     
		INSERT INTO [dbo].[Error]([error_code],[error_msg],[error_line],[error_procedure],[error_severity],[transfer_id]) 
		VALUES (
		[util].Int2Char(ERROR_NUMBER())
		, isnull(ERROR_MESSAGE(),"")
		, [util].Int2Char(ERROR_LINE()) 
		,  isnull(error_procedure(),"")
		, [util].Int2Char(ERROR_SEVERITY())
		, [util].Int2Char(<transfer_id>)    )
						       
		update dbo.[Transfer] set transfer_end_dt = getdate(), status_id = 200
		, last_error_id = SCOPE_IDENTITY() 
		where transfer_id = [util].Int2Char(<transfer_id>) 
		declare 
			@msg as varchar(255)
			, @sev as int
	
			set @msg = convert(varchar(255), isnull(ERROR_MESSAGE(),""))
			set @sev = ERROR_SEVERITY()
			RAISERROR("Error Occured in [refresh_obj_id]: %s", @sev, 1,@msg) WITH LOG
		USE <current_db>
	END CATCH
	-----------------------------------------
	-- DONE refresh_obj_id <full_obj_name>(<obj_id>)
	-----------------------------------------
	'
	end -- @obj_type in ( 'table', 'view' ) and @server_type_id in (  10,20)  -- sql server
	if @from is null -- e.g. user or procedure
		goto footer
	delete from @p
	insert into @p values ('obj_type_id'							, @obj_type_id) 
	-- insert all obj_types as const_ parameters 
	insert into @p(param_name, param_value) 
	select 'const_'+ obj_type,  convert(varchar(255), obj_type_id ) 
	from static.obj_type 
	
	insert into @p values ('sql_openrowset_ssas'	, @sql_openrowset_ssas) 
	insert into @p values ('sql_openquery'			, @sql_openquery) 
	insert into @p values ('parent_id'				, @obj_id) 
	insert into @p values ('obj_name'			, @obj_name ) 
	insert into @p values ('entity_name'			, @entity_name ) 
	insert into @p values ('identifier'				, @identifier ) 
	insert into @p values ('full_obj_name'		, @full_obj_name ) 
	insert into @p values ('obj_id'					, @obj_id) 
	insert into @p values ('server_type_id'			, @server_type_id) 
	insert into @p values ('srv'					, @srv_name ) 
	insert into @p values ('schema'				    , @schema_name ) 
	insert into @p values ('transfer_id'			, util.trim(@transfer_id,0)) 
	insert into @p values ('date'				    , util.addQuotes(convert(varchar(50), getdate(),109) ) ) 
	insert into @p values ('db'						, @db_name ) 
	insert into @p values ('current_db'				, @current_db ) 
	insert into @p values ('from'					, @from ) 
	insert into @p values ('from2'					, @from2 ) 
	insert into @p values ('sql_from'				, @sql_from ) 
	insert into @p values ('sql_lookup_prefix'		, @sql_lookup_prefix ) 
	insert into @p values ('credentials'			, 'User=company\991371;password=anT1svsrnv') 
	insert into @p values ('temp_table'				, '#betl_meta_<obj_id>') 

	EXEC util.apply_params @cols_sql_select output, @p
	insert into @p values ('cols_sql_select'						, @cols_sql_select) 
	EXEC util.apply_params @cols_sql output, @p
	insert into @p values ('cols_sql'				, @cols_sql) 
	-- select * from @p
	EXEC util.apply_params @sql2 output, @p
	insert into @p values ('sql2'					, @sql2) 
	EXEC util.apply_params @sql output, @p
	EXEC util.apply_params @sql output, @p -- twice because some parameters might contain other parameters
	EXEC util.apply_params @sql output, @p -- three time because some parameters might contain other parameters
	--print @sql 

	exec dbo.exec_sql @transfer_id, @sql 
	
	set @sql = 'exec dbo.get_dep_obj_id @obj_id=<obj_id>, @transfer_id=<transfer_id> -- <full_obj_name>'
	delete from @p 		
	insert into @p values ('obj_id'					, @obj_id ) 
	insert into @p values ('transfer_id'			, @transfer_id ) 
	insert into @p values ('full_obj_name'			, @full_obj_name ) 
	EXEC util.apply_params @sql output, @p

	insert into dbo.Stack([value]) 
	values( @sql) 

	if @obj_tree_depth> 0 
	begin 
		declare c cursor LOCAL for 
			select full_obj_name from dbo.obj_ext
			where parent_id = @obj_id and delete_dt is null 
		open c
		fetch next from c into @full_obj_name2
		while @@FETCH_STATUS=0 
		begin
			set @obj_tree_depth2= @obj_tree_depth-1
			exec dbo.refresh @full_obj_name=@full_obj_name2, @obj_tree_depth=@obj_tree_depth2, @transfer_id=@transfer_id 
			fetch next from c into @full_obj_name2
		end 
		close c
		deallocate c
	end 
	-- standard BETL footer code... 
    footer:
	
	-- restore exec_sql setting 
	exec dbo.setp 'exec_sql', @exec_sql
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @obj_tree_depth, @transfer_id
	-- END standard BETL footer code... 
END











GO
print '-- 71. reset_col'
IF object_id('[dbo].[reset_col]' ) is not null 
  DROP PROCEDURE [dbo].[reset_col] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB reset column meta data
-----------------------------------------------------------------------------------------------
exec dbo.reset_col 1811
*/
CREATE PROCEDURE [dbo].[reset_col]  
	@column_id as int 
	, @transfer_id int =0
	as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 
	exec dbo.log @transfer_id, 'INFO' , 'BEFORE reset'
	select * from dbo.col_ext where column_id = @column_id 
	
	set identity_insert [dbo].[Col_hist] on 
	INSERT INTO [dbo].[Col_hist]
           (column_id 
		   , [eff_dt]
           ,[obj_id]
           ,[column_name]
           ,[prefix]
           ,[entity_name]
           ,[foreign_column_id]
           ,[ordinal_position]
           ,[is_nullable]
           ,[data_type]
           ,[max_len]
           ,[numeric_precision]
           ,[numeric_scale]
           ,[column_type_id]
           ,[src_column_id]
           ,[delete_dt]
           ,[chksum]
           ,[transfer_id]
           ,[part_of_unique_index])
	SELECT [column_id]
      ,getdate()
      ,[obj_id]
      ,[column_name]
      ,[prefix]
      ,null [entity_name]
      ,null [foreign_column_id]
      ,[ordinal_position]
      ,[is_nullable]
      ,[data_type]
      ,[max_len]
      ,[numeric_precision]
      ,[numeric_scale]
      ,[column_type_id]
      ,[src_column_id]
      ,[delete_dt]
      ,0 [chksum]
      ,[transfer_id]
      ,[part_of_unique_index]
  FROM [betl].[dbo].[Col]
	where column_id = @column_id
	set identity_insert [dbo].[Col_hist] off
	exec dbo.log @transfer_id, 'INFO', 'AFTER reset'
	declare @obj_id as int
	select @obj_id = obj_id from dbo.col_ext where column_id = @column_id
	exec dbo.refresh_obj_id @obj_id
	select * from dbo.col_ext where column_id = @column_id 
	footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 
end











GO
print '-- 72. schema_name'
IF object_id('[dbo].[schema_name]' ) is not null 
  DROP FUNCTION [dbo].[schema_name] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB return schema name of this full object name 
--  e.g. My_PC.AdventureWorks2014.Person.Sales ->My_PC.AdventureWorks2014.Person
select dbo.schema('My_PC.AdventureWorks2014.Person.Sales') --> points to table 
*/
CREATE FUNCTION [dbo].[schema_name]( @fullObj_name varchar(255) , @scope varchar(255) ) 
RETURNS varchar(255) 
AS
BEGIN
	declare @schema_id as int 
		, @res as varchar(255) =''
		select @schema_id = dbo.schema_id(@fullObj_name, @scope ) 

	select @res = [full_obj_name] --isnull('['+ srv + '].', '') +  isnull('['+db +'].','') + '['+ [schema] + ']'
	from dbo.obj_ext 
	where [obj_id] = @schema_id
	return @res 
END











GO
print '-- 73. script_table_data'
IF object_id('[dbo].[script_table_data]' ) is not null 
  DROP PROCEDURE [dbo].[script_table_data] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB used by ddl_betl release script
exec [dbo].[script_table_data] 'dbo.col_hist'
*/
CREATE PROCEDURE [dbo].[script_table_data]
    @full_obj_name AS VARCHAR(255) 
--    , @scope AS VARCHAR(255) 
--	, @cols AS dbo.ColumnTable READONLY
	, @transfer_id AS INT = -1
--	, @create_pkey AS BIT =1 
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  @proc_name as varchar(255) =  object_name(@@PROCID)
			, @betl varchar(100) =db_name() 
	exec dbo.log @transfer_id, 'header', '? ?, ?', @proc_name , @full_obj_name,  @transfer_id 
	-- END standard BETL header code... 
	declare @sql as varchar(max) 
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
            , @object_id AS INT  -- ms  object_id 
			, @obj_id as int -- betl obj_id 
	----------------------------------------------------------------------------
	exec dbo.log @transfer_id, 'STEP', 'retrieve obj_id from name ?', @full_obj_name
	----------------------------------------------------------------------------
	exec dbo.inc_nesting
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=null, @transfer_id=@transfer_id
	exec dbo.dec_nesting
	select @db = db from dbo.obj_ext where obj_id = @obj_id 
	if @obj_id is null 
	begin 
		exec log 'error' , 'object ? not found', @full_obj_name
		goto footer
	end
	exec dbo.inc_nesting
	exec dbo.refresh_obj_id @obj_id
	exec dbo.dec_nesting

	set @sql ='
-------------------------------------------------
-- Start script table data <full_obj_name>
-------------------------------------------------
USE <db> 
'
	insert into @p values ('betl'					, @betl) 
	INSERT INTO @p VALUES ('full_obj_name'		, @full_obj_name) 
	INSERT INTO @p VALUES ('db'						, @db) 
	EXEC util.apply_params @sql OUTPUT, @p
	print @sql
/*
--Author Florian Reischl
   @handle_big_binary
      If set to 1 the user defined function udf_varbintohexstr_big will be used
      to convert BINARY, VARBINARY and IMAGE data. For futher information see remarks.
   @column_names
      If set to 0 only the values to be inserted will be scripted; the column names wont.
      This saves memory but the destination tables needs exactly the same columns in 
      same order.
      If set to 1 also the names of the columns to insert the values into will be scripted.
Remarks
=======
Attention:
   In case of colums of type BINARY, VARBINARY or IMAGE
   you either need the user defined function udf_varbintohexstr_big
   and option @handle_big_binary set to 1 or you risk a loss of data
   if the data of a cell are larger than 3998 bytes
Data type sql_variant is not supported.
*/
SET NOCOUNT ON
DECLARE @table_name SYSNAME
DECLARE @handle_big_binary BIT
DECLARE @column_names BIT
-- ////////////////////
-- -> Configuration
SET @table_name = @full_obj_name
SET @handle_big_binary = 1
SET @column_names = 1
-- <- Configuration
-- ////////////////////
print '
select ''set nocount on'' sql_statement
union all 
select ''truncate table '+@full_obj_name +''' sql_statement
union all 
select ''set identity_insert '+ @full_obj_name + ' on'' sql_statement
union all 
'

--SELECT * FROM sys.all_objects
SELECT @object_id = object_id, @schema_id = schema_id 
   FROM sys.tables 
   WHERE object_id = object_id(@table_name)
DECLARE @columns TABLE (column_name SYSNAME, ordinal_position INT, data_type SYSNAME, data_length INT, is_nullable BIT)
-- Get all column information
INSERT INTO @columns
   SELECT column_name, ordinal_position, data_type, character_maximum_length, CASE WHEN is_nullable = 'YES' THEN 1 ELSE 0 END
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = SCHEMA_NAME(@schema_id)
   AND TABLE_NAME = object_name(@object_id)
DECLARE @select VARCHAR(MAX)
DECLARE @insert VARCHAR(MAX)
DECLARE @crlf CHAR(2)
DECLARE @first BIT
DECLARE @pos INT
SET @pos = 1
SET @crlf = CHAR(13) + CHAR(10)
WHILE EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position >= @pos)
BEGIN
   DECLARE @column_name SYSNAME
   DECLARE @data_type SYSNAME
   DECLARE @data_length INT
   DECLARE @is_nullable BIT
   -- Get information for the current column
   SELECT @column_name = column_name, @data_type = data_type, @data_length = data_length, @is_nullable = is_nullable
      FROM @columns
      WHERE ordinal_position = @pos
   -- Create column select information to script the name of the source/destination column if configured
   IF (@select IS NULL)
      SET @select = ' ''' + QUOTENAME(@column_name)
   ELSE
      SET @select = @select + ','' + ' + @crlf + ' ''' + QUOTENAME(@column_name)
   -- Handle NULL values
   SET @sql = ' '
   SET @sql = @sql + 'CASE WHEN ' + QUOTENAME(@column_name) + ' IS NULL THEN ''NULL'' ELSE '
   -- Handle the different data types
   IF (@data_type IN ('bigint', 'bit', 'decimal', 'float', 'int', 'money', 'numeric',
 'real', 'smallint', 'smallmoney', 'tinyint'))
   BEGIN
      SET @sql = @sql + 'CONVERT(VARCHAR(40), ' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type IN ('char', 'nchar', 'nvarchar', 'varchar'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(' + QUOTENAME(@column_name) + ', '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type = 'date')

   BEGIN
      SET @sql = @sql + '''CONVERT(DATE, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(3), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'time')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(5), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime2')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME2, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'smalldatetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(SMALLDATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(4), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'text')
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(VARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('ntext', 'xml'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('binary', 'varbinary'))
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (' + QUOTENAME(@column_name) + ')'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type = 'timestamp')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIMESTAMP, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'uniqueidentifier')
   BEGIN
      SET @sql = @sql + '''CONVERT(UNIQUEIDENTIFIER, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(16), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'image')
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
   END
   ELSE
   BEGIN
      PRINT 'ERROR: Not supported data type: ' + @data_type
      RETURN
   END
   SET @sql = @sql + ' END'
   -- Script line end for finish or next column
   IF EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position > @pos)
      SET @sql = @sql + ' + '', '' +'
   ELSE
      SET @sql = @sql + ' + '
   -- Remember the data script
   IF (@insert IS NULL)
      SET @insert = @sql
   ELSE

      SET @insert = @insert + @crlf + @sql
   SET @pos = @pos + 1
END
-- Close the column names select
SET @select = @select + ''' +'
-- Print the INSERT INTO part
PRINT 'SELECT ''INSERT INTO ' + @table_name + ''' + '
-- Print the column names if configured
IF (@column_names = 1)
BEGIN
 PRINT ' ''('' + '
 PRINT @select
 PRINT ' '')'' + '
END
PRINT ' '' VALUES ('' +'
-- Print the data scripting
PRINT @insert
-- Script the end of the statement
PRINT ' '')'''
PRINT ' FROM ' + @table_name
print '
union all
select ''set identity_insert '+ @full_obj_name + ' off'' sql_statement
print ''done''
'
print
'-------------------------------------------------
-- End script table data  <full_obj_name>
-------------------------------------------------
print ''done''
'
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @transfer_id
	-- END standard BETL footer code... 
END











GO
print '-- 74. set_scope'
IF object_id('[dbo].[set_scope]' ) is not null 
  DROP PROCEDURE [dbo].[set_scope] 
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set scope of an object. scope groups object together so that they for example
-- can be be pushed together ( via push_all ) . 
exec betl.dbo.info '[idv].[stgl_klantverloop]'
exec betl.dbo.set_scope '[AdventureWorks2014].[idv].[stgl_klantverloop]' , 'final'
select * from betl.dbo.obj_ext 
where scope is null and ( 
	
	obj_name like 'stgl%'
	or 
	obj_name like 'stgh%'
	)
*/
 
CREATE  PROCEDURE [dbo].[set_scope] 
	@full_obj_name as varchar(255) 
	, @scope as varchar(255) 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @transfer_id as int = 0 -- for internal betl procedures
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ?', @proc_name , @full_obj_name, @scope
	-- END standard BETL header code... 

	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=null, @obj_tree_depth=default, @transfer_id=@transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?(?), scope ? ',@full_obj_name, @obj_id , @scope
	update dbo.obj set scope = @scope 
	where obj_id = @obj_id
	select * from dbo.obj_ext 
	where obj_id = @obj_id
	footer:
		exec dbo.log @transfer_id, 'footer', 'DONE ? ? ', @proc_name , @full_obj_name, @scope
	-- END standard BETL footer code... 
end











GO
print '-- 75. sp_import'
IF object_id('[dbo].[sp_import]' ) is not null 
  DROP PROCEDURE [dbo].[sp_import] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
declare @run_id as int =0
	, @target_table as varchar(255) = 'f_subs_cd_subscription'
	, @schema as varchar(255) ='idv' 
declare @target_table_full as varchar(255) = @schema +'.'+ @target_table 
exec dbo.sp_import @src_sql, @target_table_full, @run_id 
*/
CREATE procedure [dbo].[sp_import]
	@src_sql as varchar(8000) 
	, @target_table as varchar(255) 
	, @batch_id as int=0 
as
begin 
	set nocount on 
	declare 
		@transfer_id int =0 
		, @proc_name as varchar(255) =  object_name(@@PROCID)
		, @sql as varchar(8000) 
		, @is_running_in_batch as bit = 0
	declare 
		 @transfer_name as varchar(255) = @proc_name+ ' '+ @target_table
	if @batch_id>0 -- meaning: a batch_id was given as parameter.
		set @is_running_in_batch=1
   exec betl.dbo.start_batch @batch_id output
   exec betl.dbo.start_transfer @batch_id output , @transfer_id output , @transfer_name 
   if @is_running_in_batch=0 -- this push is running in a batch 
	 update betl.dbo.Batch set batch_name = @transfer_name where batch_id = @batch_id 
	exec betl.dbo.log @transfer_id , 'header', 'start ?(?) target table ?', @proc_name , @transfer_id, @target_table 
	declare @p as ParamTable 
	set @sql = '
if object_id("<target_table") is not null -- exists 
	truncate table <target_table> 
	insert into <target_table> 
	<src_sql>
else 
	
	select * into <target_table> 
	from ( 
		<src_sql> 
	) q 
select @@ROWCOUNT
'
	INSERT into @p values ('target_table', @target_table)  
	INSERT into @p values ('src_sql', @src_sql)  
	EXEC util.apply_params @sql output, @p
	
	print @sql 
	exec betl.dbo.log @transfer_id , 'footer', 'start ?(?) target table ?', @proc_name , @transfer_id, @target_table 
end












GO
print '-- 76. top_sort_obj_dep'
IF object_id('[dbo].[top_sort_obj_dep]' ) is not null 
  DROP PROCEDURE [dbo].[top_sort_obj_dep] 
GO

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
--2019-10-01 BvdB top_sort_obj_dep will 
-- apply a topological sort on a a-cylic directed graph. ( mathematically) 
-- or just determine the order in which to process dependencies so that dependent objects can be processed before the
-- object that has the dependencies. 
--
-- This can be used for determining the control flow for pulling tables based on foreign key dependencies. 
-- the foreign key dependencies form a directed graph. Which should be a-cyclic. To-DO: check this. 
-- this procedure returns a list which you can sort on rank to determine the processing order 
-- (and avoid foreign key lookup errors during processing). 
-- it will be applied on all object dependencies of type 'foreign key' 
-- when processing. First process all tables with no top_sort_ranking (e.g. no foreign keys). 
-- Then process descending. Thus starting with highest top_sort_ranking. 

exec [dbo].top_sort_obj_dep
select * from dbo.obj_dep_ext where dep_type_id = 4
*/

CREATE procedure [dbo].[top_sort_obj_dep]
	@transfer_id as int = -1
as
begin 
	declare 
--		@transfer_id as int = null
		@debug as bit = 0

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '?', @proc_name
	-- END standard BETL header code... 

	declare @dep table 
	(
	  id int identity 
	  ,obj_id int 
	  ,dep_obj_id int
	  ,[rank]       int
	  primary key (id) 
	);

	insert into @dep (obj_id, dep_obj_id) 

	select d.obj_id, d.dep_obj_id-- , * 
	from [dbo].[Obj_dep_ext] d
	inner join dbo.obj o on d.obj_id=o.obj_id
	where o.obj_type_id = 10 /*table*/ and dep_type_id = 4 /*'foreign key' */ and d.obj_id <> d.dep_obj_id
	and d.obj_db_name = 'ddp_idw'
	-- add all other tables that have no foreign key dependencies, but are part of the graph
	-- it's important to have the leave nodes of the graph as well, because they form the stop criterium for
	-- the algoritm

	insert into @dep (obj_id) 
	select dep_obj_id
	from @dep
	except 
	select obj_id
	from @dep

	declare @rank as smallint = 0

	update @dep
	set rank = 0
	where dep_obj_id is null -- leave nodes

	-- post rank=1 for parents of leave nodes. 
	while @@rowcount>0 and @rank <8 -- while there is something to do and do not continue after 30
	begin 
		--if @debug = 1  			select * , @rank rank_var from @dep

		set @rank += 1

		update @dep
		set rank = @rank
		where dep_obj_id in (
			select  obj_id 
			from @dep 
			where rank = @rank-1 
		)
		and rank is null -- only set rank once. 
		
	end 

	-- if there was a cycle then @dep contains a dubplicate obj_id with different ranking
	if exists ( 
		select d1.obj_id, d1.[rank]
		from @dep d1
		inner join @dep d2 on d1.obj_id = d2.obj_id and d1.rank<> d2.rank
		-- same object id with different ranks
	) 
	begin
		exec log @transfer_id , 'error', 'Cyclic foreign key dependency found. Unable to determine toplogical sorting'

		-- print out the erronous rows
		select d1.obj_id cyclic_foreign_key_obj_id, d1.dep_obj_id, d1.[rank]
		from @dep d1
		inner join @dep d2 on d1.obj_id = d2.obj_id and d1.rank<> d2.rank
	end



	-- select * from @dep
	--with recursive_dep as
	--(
	--  select obj_id, dep_obj_id, 0 as links_traversed 
	--  from @dep where dep_obj_id is null

	--  union all

	--  select dep.obj_id, dep.dep_obj_id, links_traversed+1
	--  from @dep dep
	--  join recursive_dep on dep.dep_obj_id = recursive_dep.obj_id
	--)
	--select obj_id, dep_obj_id, links_traversed
	--from recursive_dep
	--order by links_traversed


	footer:
	
	if @debug =1 select * from @dep 

	-- update all object dependencies. set to top_sort_rank to null where left join does not succeed
	update dbo.Obj_dep 
	set top_sort_rank = [rank]
	from dbo.Obj_dep 
	left join  @dep d on d.obj_id = Obj_dep.obj_id and d.dep_obj_id = Obj_dep.dep_obj_id
	where dbo.Obj_dep.dep_type_id = 4 -- foreign key

	if @debug =1 
	begin
		select d.* , o.full_obj_name, dep_obj.full_obj_name 
		from @dep d
		inner join dbo.Obj_ext o on d.obj_id= o.obj_id
		left join dbo.Obj_ext dep_obj on dep_obj.obj_id= d.dep_obj_id
		order by rank

		select * 
		from dbo.Obj_dep_ext
		where dep_type_id = 4
		order by top_sort_rank 
	end 
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 

end 

GO
print '-- 77. top_sort_obj_dep_old'
IF object_id('[dbo].[top_sort_obj_dep_old]' ) is not null 
  DROP PROCEDURE [dbo].[top_sort_obj_dep_old] 
GO

/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
--2019-10-01 BvdB top_sort_obj_dep will 
-- apply a topological sort on a a-cylic directed graph. ( mathematically) 
-- or just determine the order in which to process dependencies so that dependent objects can be processed before the
-- object that has the dependencies. 
--
-- This can be used for determining the control flow for pulling tables based on foreign key dependencies. 
-- the foreign key dependencies form a directed graph. Which should be a-cyclic. To-DO: check this. 
-- this procedure returns a list which you can sort on rank to determine the processing order 
-- (and avoid foreign key lookup errors during processing). 
-- it will be applied on all object dependencies of type 'foreign key' 
-- when processing. First process all tables with no top_sort_ranking (e.g. no foreign keys). 
-- Then process descending. Thus starting with highest top_sort_ranking. 

exec [dbo].top_sort_obj_dep
select * from dbo.obj_dep_ext where dep_type_id = 4

*/

CREATE procedure [dbo].[top_sort_obj_dep_old]
	@transfer_id as int = -1
as
begin 
	declare 
--		@transfer_id as int = null,
		 @debug as bit = 0

	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '?', @proc_name
	-- END standard BETL header code... 

	declare @dep table 
	(
	  id int identity 
	  ,obj_id int 
	  ,dep_obj_id int
	  ,[rank]       int         default 0
	  ,degree       int         NULL
	  primary key (id) 
	);

	insert into @dep (obj_id, dep_obj_id) 

	select d.obj_id, d.dep_obj_id-- , * 
	from [dbo].[Obj_dep_ext] d
	inner join dbo.obj o on d.obj_id=o.obj_id
	where o.obj_type_id = 10 /*table*/ and dep_type_id = 4 /*'foreign key' */ and d.obj_id <> d.dep_obj_id
	-- add all other tables that have no foreign key dependencies, but are part of the graph
	insert into @dep (obj_id) 
	select dep_obj_id
	from @dep
	except 
	select obj_id
	from @dep

	--select * from @dep

	declare @step_no int

	-- computing the degree of the nodes
	-- the degree is the number of dependencies. e.g. the number of foreign keys to other objects (not to itself). 
	update  d set d.degree = isnull(count_degree,0) 
	from @dep d
	left join ( 
		select obj_id obj_id, count(*) count_degree
		from @dep
		where dep_obj_id is not null 
		group by obj_id 
	) d2
	on d.obj_id = d2.obj_id
	
	if @debug =1 select * from @dep 
	
	set @step_no = 1
	while 1 = 1
	begin
		update @dep set rank = @step_no, degree = NULL  where degree = 0
		if (@@rowcount = 0) break

		update d set d.degree = isnull(count_degree, 0) 
		from @dep d
		left join ( 
			select dep_obj_id obj_id, count(*) count_degree
			from @dep
			where obj_id in (select tt.obj_id from @dep tt where tt.rank = 0) -- meaning unvisited
			and dep_obj_id is not null 
			group by dep_obj_id 
		) d2
		on d.obj_id = d2.obj_id
		where d.degree is not null
		/*
		update d set degree = (
			select count(*) from @dep t
			where t.dep_obj_id = d.obj_id and t.obj_id != t.dep_obj_id
			and t.obj_id in (select tt.obj_id from @dep tt where tt.rank = 0)) -- meaning unvisited
		from @dep d
		where d.degree is not null
		*/
		set @step_no = @step_no + 1
	end

	footer:
	
	if @debug =1 select * from @dep 

	-- update all object dependencies. set to top_sort_rank to null where left join does not succeed
	update dbo.Obj_dep 
	set top_sort_rank = [rank]
	from dbo.Obj_dep 
	left join  @dep d on d.obj_id = Obj_dep.obj_id and d.dep_obj_id = Obj_dep.dep_obj_id
	where dbo.Obj_dep.dep_type_id = 4 -- foreign key

	if @debug =1 
	begin
		select d.* , o.full_obj_name, dep_obj.full_obj_name 
		from @dep d
		inner join dbo.Obj_ext o on d.obj_id= o.obj_id
		left join dbo.Obj_ext dep_obj on dep_obj.obj_id= d.dep_obj_id
		order by rank

		select * 
		from dbo.Obj_dep_ext
		where dep_type_id = 4
		order by top_sort_rank 
	end 
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 

end 

GO
print '-- 78. udf_max3'
IF object_id('[util].[udf_max3]' ) is not null 
  DROP FUNCTION [util].[udf_max3] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns max value 
*/
create FUNCTION [util].[udf_max3]
(
 @a sql_variant,
 @b sql_variant,
 @c sql_variant
) 
RETURNS sql_variant
as 
begin
	return util.udf_max(dbo.udf_max(@a, @b) , @c) 
end












GO
print '-- 79. udf_min3'
IF object_id('[util].[udf_min3]' ) is not null 
  DROP FUNCTION [util].[udf_min3] 
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB returns min value
*/
CREATE FUNCTION [util].[udf_min3]
(
 @a sql_variant,
 @b sql_variant,
 @c sql_variant
) 
RETURNS sql_variant
as 
begin
	return util.udf_min(util.udf_min(@a, @b) , @c) 
end












GO
print '-- 80. dec_nesting'
IF object_id('[dbo].[dec_nesting]' ) is not null 
  DROP PROCEDURE [dbo].[dec_nesting] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB decreate nesting level (e.g. for logging). 
-- DEPRECATED. Use @@NESTLEVEL instead

log_level
10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [dbo].[dec_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec dbo.getp 'nesting', @nesting output
	set @nesting = isnull(@nesting-1, 0) 
	exec dbo.setp  'nesting', @nesting
end











GO
print '-- 81. exec_sql'
IF object_id('[dbo].[exec_sql]' ) is not null 
  DROP PROCEDURE [dbo].[exec_sql] 
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB execute and log sql statement ( if exec_sql = 1) 
exec betl.dbo.setp 'log_level', 'verbose'
declare @result as int=0
exec @result = dbo.exec_sql 0, 'WAITFOR DELAY ''00:01:02''  ', 'tempdb', 1

--
exec dbo.exec_sql 0, 'select db_name() aap
GO  select getdate()
', 'ddp_idw'

, 'tempdb', 1
exec @result = dbo.exec_sql 0, 'select db_name()'
print @result 
-- =============================================
*/
CREATE PROCEDURE [dbo].[exec_sql]
	@transfer_id as int =0 
	, @sql as nvarchar(max)
	, @trg_db_name as sysname =null 
	, @async bit =0 -- set to 1 to run asynchronously 
AS
BEGIN
	SET NOCOUNT ON;
	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @exec_sql bit
			, @result as int =0
			, @msg as varchar(255) = 'error in exec_sql'
			, @sev as int = 15
			, @number as int =0
			, @db_exec nvarchar(1000)
			, @proc_max_cnt as int = 0 
			, @cnt_proc as int = 0 
			, @category_id as int 
			, @cnt_procs as int
			, @proc_name_pattern as varchar(255) = 'betl_proc_' -- +convert(varchar(255), @transfer_id) 
			, @wait_time_sec as int 
			, @proc_max_wait_time_min as int 
			, @proc_max_wait_time_sec as int 
			, @job_id as uniqueidentifier 
			, @job_name as varchar(255) 
			, @tmp_sql as varchar(max) 
			, @proc_polling_interval_sec as int 
			, @time_str as varchar(50) 
			, @proc_dead_time_sec as int 
			, @sql_statement as nvarchar(max)

	exec dbo.getp 'exec_sql', @exec_sql output
	if @exec_sql is null 
		set @exec_sql=1

	if @trg_db_name is null 
		set @trg_db_name = db_name()

	--exec dbo.log @transfer_id, 'sql', @sql -- whether sql is logged is determined in usp log

	if @exec_sql =1 
	begin
		-- always declare and open this local cursor. closing is done in the 
		DECLARE cur CURSOR LOCAL READ_ONLY FORWARD_ONLY FOR   
		select item [sql_statement] from util.split(@sql, @nl + 'GO' )
		OPEN cur  

		begin try

			SET @db_exec = quotename(@trg_db_name)+ '.sys.sp_executesql';

			if @async =0
			begin
				-- split @sql in multiple sql statements separated by GO<newline>
				FETCH NEXT FROM cur INTO @sql_statement
				WHILE @@FETCH_STATUS = 0  
				BEGIN
					exec log @transfer_id , 'sql', '? ? ' , @db_exec, @sql_statement
					exec @result = @db_exec @sql_statement
					if @result <> 0 
						goto footer

					FETCH NEXT FROM cur INTO @sql_statement
				END
			
			end
			else
			begin -- @async =1
				-- how many concurrent processes / jobs. default 4 
				exec dbo.getp 'proc_max_cnt', @proc_max_cnt output
				-- how long should we wait for a proc to finish when proc_max_cnt is reached. default 1 minute
				-- in other words. When proc_max_cnt are running simultaneously. How long will it take for a slot to come free. 
				exec dbo.getp 'proc_max_wait_time_min', @proc_max_wait_time_min output
				set @proc_max_wait_time_sec = @proc_max_wait_time_min * 60
				-- wait polling interval. How long till we check again. range: 1-59 
				exec dbo.getp 'proc_polling_interval_sec', @proc_polling_interval_sec output
				set @time_str = '00:00:'+convert(varchar(2), @proc_polling_interval_sec) ;  
				-- delete jobs that are created more than @proc_dead_time_sec ago and are not running. 
				-- warning: do not set this too low or else new jobs that are being setup are deleted as well. 
				exec dbo.getp 'proc_dead_time_sec', @proc_dead_time_sec output
				
				if isnull(@proc_max_cnt,0) <=0 
					goto footer

				-- make sure that the job category exists 
				select @category_id = category_id from msdb.dbo.syscategories where category_class = 1 and category_type = 1 and name ='betl'
				if @category_id is null 
					exec msdb.dbo.sp_add_category @class = 'job', @type = 'local', @name = 'betl'
			    select @category_id = category_id from msdb.dbo.syscategories where category_class = 1 and category_type = 1 and name ='betl'
				if @category_id is null 
				begin 
					exec dbo.log @transfer_id, 'ERROR', 'cannot create job category betl'
					goto footer
				end 
					
				-- select *from msdb.dbo.syscategories  where category_class = 1 and category_type = 1 and name ='betl'
			    -- EXEC msdb.dbo.sp_delete_category  @class=N'job',  @name=N'betl' ;  

				-- cleanup any not running jobs. 
				-- i.e. jobs that are created more than a minute ago and are not running. 
				-- jobs are created in a transaction, so there should not be a partially created job
				-- but to be sure we added a check on the last step ( set servername). 
				set @tmp_sql = '' 
				select @tmp_sql += 'exec msdb.dbo.sp_delete_job @job_id='''+ convert(varchar(255), j.job_id) + '''' + @nl
				from msdb.dbo.sysjobs j
				inner join msdb.sys.servers s on j.originating_server_id = s.server_id
				left join msdb.dbo.sysjobactivity AS a ON a.job_id = j.job_id
				where category_id = @category_id and j.name like @proc_name_pattern+ '%'
				and not ( a.start_execution_date IS not NULL and a.stop_execution_date IS NULL)  -- not running 
				and datediff(second, j.date_created, getdate()) > @proc_dead_time_sec
				and s.name = @@servername

				if isnull(@tmp_sql,'')  <> ''
				begin
					exec dbo.log @transfer_id, 'info', @tmp_sql
					exec [dbo].[exec_sql] @transfer_id, @tmp_sql, 'msdb'
				end
				-- try to create job, but wait for a proc to finish when @cnt_procs >= @proc_max_cnts (maximum @proc_max_wait_time_min seconds)
				set @wait_time_sec = 0 
				select @cnt_procs = count(*)  
				from msdb.dbo.sysjobs
				where category_id = @category_id and name like @proc_name_pattern + '%'

				while @wait_time_sec < @proc_max_wait_time_sec and @cnt_procs >= @proc_max_cnt
				begin 
					exec dbo.log @transfer_id, 'PROGRESS', 'Waiting ? seconds for a process to finish', @proc_polling_interval_sec
					RAISERROR ('Waiting...', 0, 1) WITH NOWAIT
					
					WAITFOR DELAY @time_str 
					set @wait_time_sec += @proc_polling_interval_sec; 

					select @cnt_procs = count(*)  
					from msdb.dbo.sysjobs
					where category_id = @category_id and name like @proc_name_pattern+ '%'
				end 

				exec dbo.log @transfer_id, 'INFO', 'procs ?,max ?,wait time ?,max ?, polling_interval ?', @cnt_procs, @proc_max_cnt, @wait_time_sec , @proc_max_wait_time_sec, @proc_polling_interval_sec
				
				if @cnt_procs < @proc_max_cnt
				begin

					-- create sql agent job 
					set @job_name = @proc_name_pattern  + 	format(getdate(), 'yyyy_MM_dd_HH_mm_ss_') + convert(varchar(255), @transfer_id) + '_'+convert(Varchar(255), newid() ) 
					exec dbo.log @transfer_id, 'INFO', 'create job ?', @job_name 

					BEGIN TRANSACTION
					EXEC @result =  msdb.dbo.sp_add_job @job_name=@job_name, 
							@enabled=1, 
							@notify_level_eventlog=0, 
							@notify_level_email=0, 
							@notify_level_netsend=0, 
							@notify_level_page=0, 
							@delete_level=0, 
							@description='betl auto created job',
							@category_name='betl', 
							@job_id = @job_id OUTPUT
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @transfer_id, 'ERROR', 'Error creating job ? , ?', @job_name, @cnt_procs
					end
					else
					begin 
						exec dbo.log @transfer_id, 'INFO', 'Job ?(?) created. Other procs running: ?', @job_name, @job_id , @cnt_procs
					end 
					
					-- for some reason jobs. skip the set options of e.g. views. 
					-- this may result in errors like: SELECT failed because the following SET options have incorrect settings: 'QUOTED_IDENTIFIER'. 
					set @sql = 'SET ANSI_NULLS ON' + @nl + 'GO'+ @nl + 'SET QUOTED_IDENTIFIER ON'+ @nl+ 'GO' + @nl+ @sql 

					EXEC @result = msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name=N'exec betl sql', 
						@step_id=1, 
						@cmdexec_success_code=0, 
						@subsystem = N'TSQL',  
						@command = @sql,   
    					@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, 
						@database_name=@trg_db_name , 
						@on_success_action=3, -- go to next step
						@on_fail_action=3, -- also go to next step
						@flags=0
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @transfer_id, 'ERROR', 'Error creating job step exec sql for job ? ', @job_id
					end

					set @tmp_sql = 'exec msdb.dbo.sp_delete_job @job_id=''' + convert(varchar(255),@job_id)+''''
					EXEC @result = msdb.dbo.sp_add_jobstep @job_id=@job_id, @step_name=N'delete myself', 
						@step_id=2, 
						@cmdexec_success_code=0, 
						@subsystem = N'TSQL',  
						@command = @tmp_sql,
    					@retry_attempts=0, 
						@retry_interval=0, 
						@os_run_priority=0, 
						@database_name='master' , 
						@flags=0
					IF (@@ERROR <> 0 OR @result <> 0) 
					begin
						exec dbo.log @transfer_id, 'ERROR', 'Error creating job step to delete myself for job ? ', @job_id
					end

					EXEC @result =  msdb.dbo.sp_add_jobserver @job_id=@job_id, 
						@server_name = @@servername

					COMMIT TRANSACTION 
					-- start the job
				
					EXEC @result = msdb.dbo.sp_start_job @job_id=@job_id
					if @result<> 0 
						exec betl.dbo.log @transfer_id, 'error', 'error starting job ? using msdb.dbo.sp_start_job. note that sp_start_job errors cannot be caught, but are printed when executed from ssms', @job_id
				end 
				else
				begin 
					exec dbo.log @transfer_id, 'ERROR', 'Waited for ? seconds, but no process finished', @wait_time_sec
					goto footer
				end

			end -- @async =1

	
			footer:

		end try 
		begin catch
				set @msg  =ERROR_MESSAGE() 
				set @sev = ERROR_SEVERITY()
				set @number = ERROR_NUMBER() 
				IF @@trancount > 0 ROLLBACK TRANSACTION
				exec dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@number
				print '-- exec_sql caught error in the following sql statement:'
				print @sql_statement
				if @result =0 
					set @result = -1
		end catch 

		CLOSE cur;  
		DEALLOCATE cur;  
	end

	if @result is null 
		set @result =-2
	
	if @result <> 0 
		RAISERROR(@msg , @sev ,@number)  WITH NOWAIT
	return @result 
END











GO
print '-- 82. get_dep'
IF object_id('[dbo].[get_dep]' ) is not null 
  DROP PROCEDURE [dbo].[get_dep] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-03-19 BvdB find dependencies for this object using betl and sql server meta data.

exec dbo.get_dep '[AW_Staging].[dbo].[Illustration]'
exec dbo.get_dep '[betl].[dbo]'

select * from stack
*/ 
CREATE procedure [dbo].[get_dep] 
	@full_obj_name varchar(255)
	, @dependency_tree_depth as int =0
	, @obj_tree_depth as int = 0
	, @display as bit = 0 
	, @scope as varchar(255) = null 
	, @transfer_id as int = -1 -- see logging hierarchy above.

as
begin 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ?, scope ? , object tree depth ?, dep tree depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth, @dependency_tree_depth
	declare 
		@obj_id as int

	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope=@scope, @obj_tree_depth=DEFAULT, @transfer_id=@transfer_id

	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'error',  'object ? not found.', @full_obj_name
		goto footer
	end
	else 
		exec dbo.log @transfer_id, 'step' , 'obj_id resolved: ?', @obj_id 

	exec dbo.get_dep_obj_id @obj_id =@obj_id, @dependency_tree_depth = @dependency_tree_depth 
		, @obj_tree_depth = @obj_tree_depth,	@transfer_id=@transfer_id, @display = @display 

	exec dbo.process_stack

	footer:
	
	exec dbo.log @transfer_id, 'Footer', '? ?, scope ? , depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth
end 

GO
print '-- 83. get_user_vars'
IF object_id('[dbo].[get_user_vars]' ) is not null 
  DROP PROCEDURE [dbo].[get_user_vars] 
GO
	  
/*
------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-09-06 BvdB get user scope variables. Implement caching. 
-- nesting is DEPRECATED. Use @@NESTLEVEL instead
exec get_user_vars @log_level output, @exec_sql output, @nesting output

*/
CREATE PROCEDURE [dbo].[get_user_vars] 
	@log_level varchar(255) output
	, @exec_sql bit output
	, @transfer_id as int = -1
as

BEGIN
	-- standard BETL header code. perform some logging.
	set nocount on 
	declare 
		@proc_name as varchar(255) = object_name(@@PROCID)
		, @cache_hit as bit=0;
	-- prevent cyclic error
	--exec dbo.log @transfer_id, 'header_detail', '?', @proc_name
	-- END standard BETL header code... 

	
	begin try
	begin transaction 
		select @log_level=log_level, @exec_sql=exec_sql, @cache_hit = 1 
		from dbo.Cache_user_data
		where user_name = suser_sname() and expiration_dt > getdate() 

		if @cache_hit=0
		begin
			delete from  dbo.Cache_user_data where user_name = suser_sname()

		 	exec dbo.getp 'log_level', @log_level output 
			exec dbo.getp 'exec_sql' , @exec_sql output
			--exec dbo.getp 'nesting' , @nesting output
	
			insert into dbo.Cache_user_data ( user_name, log_level, exec_sql, expiration_dt) values ( suser_sname(), @log_level , @exec_sql , dateadd(hour,1,getdate()) ) 
		end
		--else 			print 'cache hit'
	commit transaction 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		declare @msg as varchar(255) = 'error in [get_user_vars]' +  isnull( ERROR_MESSAGE() , '?') 
		, @sev as int = ERROR_SEVERITY()
		-- , @number as int = ERROR_NUMBER() 

		RAISERROR(@msg  , @sev , 0)  WITH NOWAIT

	END CATCH 


	-- standard BETL footer code... 
    --footer:
	-- prevent cyclic error
	--exec dbo.log @transfer_id, 'footer_detail', 'DONE ?', @proc_name 
	-- END standard BETL footer code... 
END

GO
print '-- 84. inc_nesting'
IF object_id('[dbo].[inc_nesting]' ) is not null 
  DROP PROCEDURE [dbo].[inc_nesting] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB increase nesting (for logging)
-- DEPRECATED. Use @@NESTLEVEL instead
log_level
10 ERROR
20 INFO : show progress in current proc
30 DEBUG: : show progress in current proc and invoked procs. 
*/
CREATE PROCEDURE [dbo].[inc_nesting] 
as 
begin 
	declare @nesting as smallint 
	exec dbo.getp 'nesting', @nesting output
	set @nesting = isnull(@nesting+1 , 1) 
	exec dbo.setp 'nesting', @nesting
end











GO
print '-- 85. log'
IF object_id('[dbo].[log]' ) is not null 
  DROP PROCEDURE [dbo].[log] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB write to [dbo].[Transfer_log] using log hierarchy
exec dbo.log 30820, 'error', 'test'
exec dbo.log @transfer_id =30820, @log_type ='error', @msg ='test', @simple_mode =1
*/
CREATE PROCEDURE [dbo].[log](
--	  @log_level smallint
	@transfer_id as int
	 ,@log_type varchar(50)  -- ERROR, WARN, INFO, DEBUG
	, @msg as varchar(max) 
	, @i1 as varchar(max) = null
	, @i2 as varchar(max) = null
	, @i3 as varchar(max)= null
	, @i4 as varchar(max)= null
	, @i5 as varchar(max)= null
	, @i6 as varchar(max)= null
	, @i7 as varchar(max)= null
	, @simple_mode as bit = 0 -- use this to skip getp and prevent getting into a loop. 
)
AS
BEGIN
	SET NOCOUNT ON;
	set @transfer_id = isnull(@transfer_id,-1) -- default for unknown transfer_id is -1 
	--declare @transfer_id as int
	--exec dbo.getp 'transfer_id', @transfer_id output 
	declare @log_level_id smallint
			, @log_type_id smallint
			, @nesting smallint
			, @nl as varchar(2) = char(13)+char(10)
			, @min_log_level_id smallint
			, @log_level varchar(255) 
			, @exec_sql as bit
			, @short_msg AS VARCHAR(255) 
	
	set @nesting =@@NESTLEVEL

	if isnull(@simple_mode,0) = 1 
	begin 
		set @log_level = 'INFO'
		set @exec_sql= 1
	end 
	else
	begin 
		exec get_user_vars @log_level output, @exec_sql output
	end 

	--print 'nesting: '+ convert(varchar(100) , @nesting) 
	select @log_level_id = log_level_id
	from static.[Log_level]
	where log_level = @log_level
	if @log_level_id  is null 
	begin
		set @log_level_id  =30 -- info
		goto footer
		--set @short_msg  = 'invalid log_level '+isnull(@log_level, '' )
		--RAISERROR( @short_msg    ,15,1) WITH SETERROR
	end
	select @log_type_id = log_type_id, @min_log_level_id = min_log_level_id
	from static.Log_type
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
	--print 'min_log_level_id:'+ convert(varchar(255), @min_log_level_id) 
	--print 'nesting:'+ convert(varchar(255), @nesting) 
		
	if @log_level_id < @min_log_level_id -- e.g. level = ERROR, but type = sql -> 40 
		return -- don't log
	
	--if @nesting>4 and @log_level_id < 50 and @log_type_id not in ( 10,20) -- header, footer
		--return -- when log_level not verbose then don't log level 2 and deeper (other than header and footer).
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
	if @i6 is not null and CHARINDEX('%6', @msg)=0 
		set @msg += ', @i6'
	if @i7 is not null and CHARINDEX('%7', @msg)=0 
		set @msg += ', @i7'
		
	set @msg = replace(@msg, '%1', isnull(convert(varchar(max), @i1), '?') )
	set @msg = replace(@msg, '%2', isnull(convert(varchar(max), @i2), '?') )
	set @msg = replace(@msg, '%3', isnull(convert(varchar(max), @i3), '?') )
	set @msg = replace(@msg, '%4', isnull(convert(varchar(max), @i4), '?') )
	set @msg = replace(@msg, '%5', isnull(convert(varchar(max), @i5), '?') )
	set @msg = replace(@msg, '%6', isnull(convert(varchar(max), @i6), '?') )
	set @msg = replace(@msg, '%7', isnull(convert(varchar(max), @i7), '?') )
	
	if @nesting > 2 set @nesting+=-2 else set @nesting=0 -- nesting always starts at 2  ( because there is always one calling proc that calls the log proc). 

	set @msg = replicate('  ', @nesting) + '-- ' + upper(@log_type) + ': '+@msg
	
	--if charindex(@nl, @msg,0) >0 -- contains nl 
	--	set	@msg = '/*'+@nl+@msg+@nl+'*/'
	--set @msg = replace(@msg, @nl , @nl + '--') -- when logging sql prefix with --
--	end
--	ELSE
--		RAISERROR(@msg,10,1) WITH NOWAIT
	-- START CUSTOM_CODE. 
	--exec MyDWH_repository.dbo.SP_SSIS_LOGMSG @transfer_id, @msg
	-- END CUSTOM_CODE
	if @log_type = 'ERROR'
	begin
		exec betl.dbo.log_error @transfer_id, @msg, 15
		--SET @short_msg = substring(@msg, 0, 255) 
		--RAISERROR( @short_msg ,15,1) WITH SETERROR
	end 
	else 
	begin 
		PRINT cast(@msg as text) -- because print is limited to 8000 characters
		
		-- troubleshoot foreign key error !
		if @transfer_id=0 
			print '--ERROR transfer_id should not be 0. Use -1 for unknown transfer_id !'

		insert into dbo.Transfer_log
		values( getdate(), @msg, @transfer_id, @log_level_id, @log_type_id, @exec_sql) 
	end 

    footer:
END












GO
print '-- 86. my_info'
IF object_id('[dbo].[my_info]' ) is not null 
  DROP PROCEDURE [dbo].[my_info] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB this proc prints out all user bound properties / settings 
exec [dbo].[my_info]
*/
CREATE PROCEDURE [dbo].[my_info]
	@transfer_id as int=-1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare  
		@nesting as smallint
		, @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @output as varchar(max) = ''-- '-- Properties for '+ suser_sname() + ': 
	--exec dbo.log @transfer_id, 'INFO', 'Properties for ? : ', suser_sname() 

	set @nesting = @@NESTLEVEL
	if @nesting > 2 set @nesting+=-2 else set @nesting=0 -- nesting always starts at 2  ( because there is always one calling proc that calls the log proc). 

--	exec dbo.getp 'nesting' , @nesting output
	select @output += replicate('  ', @nesting)+'-- ' +  isnull(property,'?') + ' = ' + isnull(value, '?') + '
'
	from dbo.Prop_ext
--	cross apply dbo.log 'footer', 'DONE ? ', @proc_name 
	where [full_obj_name] = suser_sname() 
	print @output 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
END











GO
print '-- 87. onError'
IF object_id('[dbo].[onError]' ) is not null 
  DROP PROCEDURE [dbo].[onError] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-11 BvdB this is used in ssis event handling for maintaining log administration/ error handling. 
*/
CREATE procedure [dbo].[onError]
	@transfer_id int 
	, @status as varchar(255) output
	, @source_name as varchar(255) =null
	, @error_desc as varchar(1000) =null
	, @error_code as varchar(255) =null
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(2000) =''
	set @msg = '['+ isnull(@source_name,'') + '] ' + isnull(@error_desc ,'') + '('+ isnull(@error_code,'') + ')'
	set @status = 'Error'
	exec betl.dbo.log_error @transfer_id, @msg, 9 -- do not throw exception. -> else setting status fails
--	exec betl.dbo.log @transfer_id, 'ERROR', @msg
	footer: 
	
end












GO
print '-- 88. refresh'
IF object_id('[dbo].[refresh]' ) is not null 
  DROP PROCEDURE [dbo].[refresh] 
GO

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-02 BvdB This proc will refresh the meta data of servers, databases, schemas, tables, views and stored procedures
exec dbo.refresh '[LOCALHOST].[AdventureWorks2014]'
exec dbo.refresh 'LOCALHOST.My_Staging.NF.Center'
exec dbo.refresh @full_obj_name='SSAS01_TAB_CUSTOMER', @obj_tree_depth=2
*/
CREATE PROCEDURE [dbo].[refresh]
    @full_obj_name as varchar(255) 
	, @obj_tree_depth as int = 0 -- 0->only refresh full_obj_name, if 1 -> refresh childs under this object as well. 
						---if 2 then for each child also refresh it's childs.. e.g. 
						-- dbo.refresh 'LOCALHOST', 0 will only create a record in dbo._Object for the server BETL
						-- dbo.refresh 'LOCALHOST', 1 will also create a record for all db's in this server (e.g. BETL). 
						-- dbo.refresh 'LOCALHOST', 2 will create records in object for each table and view on this server in every database.
						-- dbo.refresh 'LOCALHOST', 3 will create records in object for each table and view on this server in every database and
						-- also fill his._Column with all columns meta data for each table and view. 
	, @scope as varchar(255) = null
	, @transfer_id as int = -1
AS
BEGIN
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? , scope ?, depth ?', @proc_name , @full_obj_name, @scope, @obj_tree_depth
	-- END standard BETL header code... 
	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope, @obj_tree_depth, @transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	else
	begin 
--		exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?, scope ? ', @obj_id , @scope
		exec dbo.refresh_obj_id @obj_id, @obj_tree_depth, @transfer_id
		exec process_stack @transfer_id 
	end
	
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @obj_tree_depth, @transfer_id
	-- END standard BETL footer code... 
END












GO
print '-- 89. set_column_type'
IF object_id('[dbo].[set_column_type]' ) is not null 
  DROP PROCEDURE [dbo].[set_column_type] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB 
exec betl.dbo.info '[idv].[stgl_klantverloop]'
exec betl.dbo.set_column_type '[AdventureWorks2014].[idv].[stgl_klantverloop]' , 'datum' , 102
*/
  
CREATE  PROCEDURE [dbo].[set_column_type] 
	@full_obj_name as varchar(255) 
	, @column_name as varchar(255) 
	, @column_type_id as int 
	, @scope as varchar(255) =null 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @transfer_id as int = 0 -- for internal betl procedures
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? ? ?', @proc_name , @full_obj_name, @column_name, @column_type_id
	-- END standard BETL header code... 

	declare @obj_id as int
	exec dbo.get_obj_id @full_obj_name, @obj_id output, @scope , @obj_tree_depth=default, @transfer_id=@transfer_id
	if @obj_id is null or @obj_id < 0 
	begin
		exec dbo.log @transfer_id, 'step', 'Object ? not found in scope ? .', @full_obj_name, @scope 
		goto footer
	end
	exec dbo.log @transfer_id, 'step', 'obj_id resolved: ?(?), scope ? ',@full_obj_name, @obj_id , @scope
	-- first check column_type_id 
	declare @c_type as int 
	select @c_type  = column_type_id 
	from static.Column_type 
	where column_type_id = @column_type_id
	if @c_type is null 
		exec dbo.log @transfer_id, 'error', 'invalid column type ?' , @column_type_id 
	else 
	begin 
		declare @column_id as int 
		
		select @column_id = column_id 
		from dbo.col_hist 
		where column_name = @column_name and obj_id = @obj_id 
		
		if @column_id is null 
			exec dbo.log @transfer_id, 'error', 'column ? does not exist for object ?(?) ' , @column_name, @full_obj_name, @obj_id
		else 
		begin 
			exec dbo.log @transfer_id, 'var', 'column_id resolved: ?(?)',@column_name, @column_id
			update dbo.col_hist  set column_type_id = @column_type_id
			where column_id = @column_id 
			
			select * from dbo.col_ext where column_id = @column_id 
		end
		end 
	footer:
		exec dbo.log @transfer_id, 'footer', 'DONE ? ? ? ?', @proc_name , @full_obj_name, @column_name, @column_type_id
	-- END standard BETL footer code... 
end











GO
print '-- 90. set_target_schema'
IF object_id('[dbo].[set_target_schema]' ) is not null 
  DROP PROCEDURE [dbo].[set_target_schema] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB Sets the target schema for @full_obj_name 
*/
CREATE procedure [dbo].[set_target_schema] 
	@full_obj_name as varchar(4000) ,
	@target_schema_name as varchar(4000), 
	@transfer_id as int = -1 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ? , ?', @proc_name , @full_obj_name, @target_schema_name
	-- END standard BETL header code... 
	declare @schema_id as int
	exec dbo.get_obj_id @target_schema_name , @schema_id output
	exec betl.dbo.setp 'target_schema_id'
		, @schema_id 
		, @full_obj_name
	-- standard BETL footer code... 
    footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ? , ? (?)', @proc_name , @full_obj_name, @target_schema_name, @schema_id 
	-- END standard BETL footer code... 
end 











GO
print '-- 91. setp'
IF object_id('[dbo].[setp]' ) is not null 
  DROP PROCEDURE [dbo].[setp] 
GO
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2017-01-01 BvdB set property value
exec betl.dbo.setp 'log_level', 'debug'
select * from dbo.Prop_ext
*/
CREATE PROCEDURE [dbo].[setp] 
	@prop varchar(255)
	, @value varchar(255)
	, @full_obj_name varchar(255) = null -- when property relates to a persistent object, otherwise leave empty
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
  -- first determine property_scope 
  declare @property_scope as varchar(255) 
		, @obj_id int
		, @prop_id as int 
		, @debug as bit = 0
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL header code... 

  select @property_scope = property_scope , @prop_id = property_id
  from dbo.Prop_ext
  where [property]=@prop
  if @prop_id is null 
  begin 
	print 'Property not found in static.Property '
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property ? not found in static.Property ', @i1 =@prop, @simple_mode = 1
	goto footer
  end
  if @property_scope is null 
  begin 
	print 'Property scope is not defined in static.Property'
	exec dbo.log @transfer_id =@transfer_id, @log_type ='error', @msg ='Property scope ? defined in static.Property', @i1 =@prop, @simple_mode = 1
	goto footer
  end

  -- scope is not null 
  if @property_scope = 'user' -- then we need the obj_id of the current user
  begin
	set @full_obj_name = suser_sname()
  end
  exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @scope=DEFAULT, @transfer_id=@transfer_id

  if @obj_id  is null 
  begin 
	if @property_scope = 'user' -- then create obj_id 
	begin
		insert into dbo.Obj (obj_type_id, obj_name) 
		values (60, @full_obj_name)
			
		exec [dbo].[get_obj_id] @full_obj_name, @obj_id output, @scope=DEFAULT, @transfer_id=@transfer_id	
	end

	if @obj_id is null 
	begin
		if @debug =1 
			exec dbo.log @transfer_id, 'ERROR', 'object not found ? , property_scope ? ', @full_obj_name , @property_scope
		goto footer
	end 
  end

	if @debug =1 
		exec dbo.log @transfer_id, 'var', 'object ? (?) , property_scope ? ', @full_obj_name, @obj_id , @property_scope 
		
	begin try 
		begin transaction 
			-- delete any existing value. 
			delete from dbo.Property_Value 
			where obj_id = @obj_id and property_id = @prop_id 
			insert into dbo.Property_Value ( property_id, [obj_id], value) 
			values (@prop_id , @obj_id, @value)

			-- invalidate the user cache. So that it gets refreshed next time. 
			update dbo.Cache_user_data set expiration_dt = getdate() 
			where user_name = suser_sname() and expiration_dt  > getdate()  -- only when set in the future

		commit transaction


	end try 
	begin catch
		declare @msg as varchar(4000) 
		set @msg = ERROR_MESSAGE() 
		if @@TRANCOUNT>0 
			rollback transaction
		exec dbo.log @transfer_id, 'ERROR', 'msg ? ', @msg
	end catch 

--	select * from [dbo].[Property_ext]	where obj_id = @obj_id and property like @prop
    footer:
		if @debug=1 
		exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='done ? ? ? for ?', @i1 =@proc_name , @i2 =@prop, @i3 =@value, @i4=@full_obj_name, @simple_mode = 1
	-- END standard BETL footer code... 
end











GO
print '-- 92. sp_start'
IF object_id('[dbo].[sp_start]' ) is not null 
  DROP PROCEDURE [dbo].[sp_start] 
GO
	  

/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-03-21 BvdB this sp is handles the logging administation and skip logic for every customer stored procedure. 
exec betl.dbo.sp_start 'dm.sp_imp_benchmarktype'
*/    
CREATE  procedure dbo.[sp_start] ( @sp_name as varchar(4000) , @batch_id int=0  ) 
as
begin
	set nocount on 
	if object_id(@sp_name)  is null 
		set @sp_name = 'AdventureWorks2014.' + @sp_name  -- default db
	-- betl batch admin
	declare 
			@rec_cnt_src as int 
			, @rec_cnt_new as int 
			, @rec_cnt_changed as int 
			, @rec_cnt_deleted as int 
			, @status as varchar(100) = 'success'
			, @transfer_id as int
			, @param_string as varchar(4000) 
			, @sql as nvarchar(4000) 
			, @msg varchar(1000)
			, @sev as int 
			, @error_number as int 
			, @param_def as nvarchar(255) = '' 
			
	exec betl.dbo.start_transfer @batch_id output, @transfer_id output , @sp_name
	if @transfer_id = 0  -- skip this sp. e.g. because the batch is continuing a previous batch. 
		goto footer
	-- end betl batch admin
	set @param_def = N'@transfer_id int, @rec_cnt_src int output, @rec_cnt_new int output, @rec_cnt_changed int output, @rec_cnt_deleted int output'
	set @sql= N'exec '+ @sp_name +' @transfer_id , @rec_cnt_src output, @rec_cnt_new output, @rec_cnt_changed output, @rec_cnt_deleted output'
	
	begin try 
		execute sp_executesql @sql, @param_def, @transfer_id=@transfer_id, @rec_cnt_src=@rec_cnt_src output 
				, @rec_cnt_new=@rec_cnt_new output , @rec_cnt_changed=@rec_cnt_changed output , @rec_cnt_deleted=@rec_cnt_deleted output 
--		exec betl.dbo.exec_sql @transfer_id , @sql
	end try
	begin catch
		set @msg =ERROR_MESSAGE() 
		set @sev = ERROR_SEVERITY()
		set @error_number = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec betl.dbo.log_error @transfer_id=@transfer_id, @msg=@msg,  @severity=@sev, @number=@error_number 
		set @status = 'error'
	end catch 
	footer:
		exec betl.dbo.end_transfer @transfer_id, @status, @rec_cnt_src, @rec_cnt_new, @rec_cnt_changed , @rec_cnt_deleted 
	if @status = 'error'
	begin 
		set @msg = 'error in ' + @sp_name +  isnull(@msg,'') 
		RAISERROR(@msg , 15 , 0)  WITH NOWAIT
	end 
end











GO
print '-- 93. start_batch'
IF object_id('[dbo].[start_batch]' ) is not null 
  DROP PROCEDURE [dbo].[start_batch] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB continue batch if running or start new batch. allow custom code integration 
--  with external batch administration
declare @batch_id int 
exec dbo.start_batch @batch_id output 
print @batch_id 
select * from dbo.batch 
where batch_id = @batch_id 
*/
CREATE procedure [dbo].[start_batch] 
	@batch_id int output 
	, @batch_name as varchar(255) ='adhoc' 
	, @guid as bigint= null  
as 
begin 
   declare 
		@prev_batch_id as int 
		,@prev_status as varchar(255) 
		,@status as varchar(255) 
		,@legacy_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit =0 
		,@prev_seq_nr as int 
		,@sql as varchar(max) 
	-- first check for aborted jobs in ssisdb execution history -> update batch status accordingly

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log -1, 'Header', '? ?', @proc_name , @batch_name
	-- END standard BETL header code... 

	set @sql = '
	update b set status_id = 
		CASE e.Status 
               WHEN 4 THEN 200 -- error 
               else 700  -- stopped
			end 
	from dbo.batch b
	inner join static.Status s on b.status_id = s.status_id 
	inner join ssisdb.catalog.executions e on e.execution_id  = b.guid
	where s.status_name in (  ''running'' , ''continue'') 
	and 	 CASE e.Status 
               WHEN 1 THEN ''created'' 
               WHEN 2 THEN ''running'' 
               WHEN 3 THEN ''canceled'' 
               WHEN 4 THEN ''failed'' 
               WHEN 5 THEN ''pending'' 
               WHEN 6 THEN ''ended unexpectedly'' 
               WHEN 7 THEN ''succeeded'' 
               WHEN 8 THEN ''stopping'' 
               WHEN 9 THEN ''completed'' 
			   else ''unknown''
			end <> ''running''
	'
	if db_id('ssisdb') is not null
		exec(@sql) 
	-- update status of running batches which are started from visual studio. 
	update b
	set status_id = 700 
	from dbo.batch b
	--inner join static.Status s on b.status_id = s.status_id 
	where guid =-1 and status_id = 400 -- started in visual studio
	--and exec_user = suser_sname() 
	and batch_name=@batch_name
	-- also stop transfers for stopped batches
	update t
	set status_id = 700 
	from dbo.Transfer t
	inner join dbo.Batch b on t.batch_id = b.batch_id 
	where b.status_id = 700 and t.status_id in ( 600, 400) 
	begin try 
	begin transaction		
   if not isnull(@batch_id ,-1) > 0   -- no batch given-> create one... 
   begin 
		-- reset betl nesting etc. 
		exec dbo.setp 'nesting' , 0
		 -- first check to see if there is one running. 
		 select @prev_batch_id = max(batch_id) 
		 from dbo.Batch  b
		 inner join static.Status s on b.status_id = s.status_id 
		 where batch_name = @batch_name
			and isnull(status_name, '')   not in ( 'Not started', 'deleted') 
		
		 select @prev_status=status_name
		, @continue_batch=continue_batch
		, @prev_seq_nr = batch_seq
		 from dbo.Batch  b
		 left join static.Status s on b.status_id = s.status_id 
		 where b.batch_id = @prev_batch_id 
		set @status= 
		case @prev_status 
			when 'Success'		then 'Running'
			when 'Error'		then 'Continue'
			when 'Running'		then 'Not started' 
			when 'Restart'		then 'Running'
			when 'Continue'		then 'Not started' 
			when 'Stopped'		then 'Continue'
			else 'Running'
		end 
		if @continue_batch=0 and @status='Continue'
			set @status='running' 
		select @status_id = status_id 
		from static.Status 
		where status_name = @status
		insert into dbo.Batch(batch_name, batch_start_dt, status_id, prev_batch_id, guid, batch_seq )
		values (@batch_name, @nu, @status_id, @prev_batch_id, @guid, isnull(@prev_seq_nr+1,0) ) 
		set @batch_id = SCOPE_IDENTITY()
	end 
	footer: 
	
	commit transaction
	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec dbo.log_error 0, @msg=@msg2,  @severity=@sev, @number=@number 
	end catch 
	if not isnull(@batch_id, -1) > 0 
		RAISERROR( 'failed to start batch' ,15,1) WITH SETERROR
	
	if @status='Not started' 
	begin 
		-- for logging we need a transfer_id 
		set @status_id = 300 -- not started
		declare @transfer_id as int 
		-- create transfer
		insert into dbo.Transfer(batch_id, transfer_start_dt, transfer_name, target_name,src_obj_id, status_id, prev_transfer_id, transfer_seq)
		values (@batch_id, @nu, 'empty' , '', null, @status_id, null, 0) 
		set @transfer_id = SCOPE_IDENTITY()
		exec dbo.log @transfer_id , 'Info', 'batch was not started because there is already one instance running with name ?, namely ? ', @batch_name , @prev_batch_id 
	    set @batch_id = -1 
	end 
	exec dbo.log -1, 'footer', '? ?(b?)..? (?)', @proc_name , @batch_name, @batch_id, @prev_batch_id, @status
end












GO
print '-- 94. start_transfer'
IF object_id('[dbo].[start_transfer]' ) is not null 
  DROP PROCEDURE [dbo].[start_transfer] 
GO
  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB create transfer if not exist 
declare @batch_id int ,
	@transfer_id int
exec dbo.start_transfer @batch_id output , @transfer_id output , 'test'
select * from dbo.batch where batch_id = @batch_id 
select * from dbo.transfer where transfer_id = @transfer_id
*/
CREATE procedure [dbo].[start_transfer]
	@batch_id int output
	, @transfer_id int output 
	, @transfer_name as varchar(255) 
	, @target varchar(255) ='' 
	, @src_obj_id int=null 
	, @batch_name as varchar(255) =null
	, @guid as bigint =null
as 
begin 
	set nocount on 
	declare 
		@prev_batch_id as int 
		,@prev_transfer_id as int 
		,@batch_status as varchar(255) 
		,@status as varchar(255) 
		,@prev_batch_status as varchar(255) 
		,@prev_status as varchar(255) 
		,@prev_transfer_end_dt as datetime
		,@new_status as varchar(255) 
		,@prev_batch_start_dt datetime
		,@prev_batch_name varchar(100) = null 
		,@status_id as int 
		,@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID)
		,@continue_batch as bit
		,@prev_seq_nr as int =0 

	-- standard BETL header code... 
	set nocount on 
	exec dbo.log -1, 'Header', '?(b?) ?', @proc_name , @batch_id, @transfer_name
	-- END standard BETL header code... 
	
	set @batch_name = isnull(@batch_name , isnull( @transfer_name ,'')) 
   	if not isnull(@batch_id,-1)>0 
		exec dbo.start_batch @batch_id output , @batch_name, @guid
	
	begin try 
	begin transaction		
	
	if not isnull(@batch_id,-1)>0 -- error no batch.. 
		goto footer
    -- exec dbo.log 0, 'var', 'batch_id ?, transfer_id ? ', @batch_id, @transfer_id 
	-- check @transfer_id
	if not isnull(@transfer_id,-1) > 0   -- no transfer_id given-> create one... 
	begin 
		select @transfer_id=transfer_id , @status =s.status_name
		from dbo.[Transfer] t
		inner join static.Status s on t.status_id = s.status_id
		where transfer_name = @transfer_name and batch_id = @batch_id 
		if @transfer_id >0 -- already exists
			goto footer 
		select @batch_status = s.status_name 
			, @prev_batch_id = prev_batch_id
		from dbo.Batch  b
		inner join static.Status s on b.status_id = s.status_id 
		where batch_id = @batch_id 
		select @prev_batch_status = s.status_name 
			, @continue_batch = continue_batch
		from dbo.Batch  b
		inner join static.Status s on b.status_id = s.status_id 
		where batch_id = @prev_batch_id 
		select @prev_status = s.status_name 
			, @prev_transfer_end_dt = t.transfer_end_dt
			, @prev_transfer_id = t.transfer_id 
			, @prev_seq_nr = transfer_seq
		from dbo.[Transfer] t 
		inner join static.status s on t.status_id = s.status_id
		where t.batch_id=@prev_batch_id
		and t.transfer_name = @transfer_name -- same name 
		if @batch_status is null 
		begin 
			-- a batch should always have a batch_status
			-- probably the batch_id that was supplied is invalid-> quit
			-- set batch status to running
			update dbo.Batch
			set status_id = (select status_id from static.status where status_name = 'running') 
			where batch_id = @batch_id 
			if @@ROWCOUNT = 0  
			begin 
				set @msg = 'Invalid batch id '+convert(varchar(255), @batch_id ) 
				set @status = 'error' 
				goto footer
			end
			set @batch_status = 'running' 
		end 
		if @status is null and @batch_status in ( 'error', 'stopped') 
		begin
			set @status = 'Not started' 
			set @msg = 'Transfer is not started because batch has status '+@batch_status 
		end 
		if @status is null and @continue_batch = 1 
		begin 
			--if @prev_batch_status in ( 'error', 'running', 'continue', 'stopped') 
			if isnull(@prev_status,'')  in ( 'success', 'skipped')
			--	and datediff(hour, @prev_transfer_end_dt , getdatE()) < 20 -- binnen 20 uur herstart ->continue
				set @status = 'skipped' -- skip this step 
			else
				set @status = 'running' -- run this step
			 set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status+ ' prev_status: '+@prev_status
		end 
		if @status is null and @batch_status in ( 'success') 
		begin 
			set @msg = 'Batch status changed from success to running'
			-- set batch status to running
			update dbo.Batch
			set status_id = (select status_id from static.status where status_name = 'running') 
			where batch_id = @batch_id 
			set @status = 'running' 
		end
		if @status is null and @batch_status in (  'running', 'restart') -- note that Restart should not occur. Because this 
		--- status is only set to previous batch
		begin 
			set @status = 'running' 
			set @msg = 'Batch status '+ @batch_status  + ', transfer status: '+ @status
		end 
		if @status is null 
		begin
			set @status='error'
			set @msg = 'error starting transfer for batch status '+ @batch_status  
		end 
		select @status_id = status_id from static.Status where status_name = @status

		insert into dbo.Transfer( batch_id, transfer_start_dt, transfer_name, target_name,src_obj_id, status_id, prev_transfer_id, transfer_seq)
		values (@batch_id, @nu, @transfer_name , @target, @src_obj_id, @status_id, @prev_transfer_id, isnull(@prev_seq_nr,0) +1) 
		select @transfer_id = SCOPE_IDENTITY()
		
		--exec dbo.log @transfer_id, 'INFO', @msg
	end  -- create transfer
	footer: 
	
	commit transaction
	end try
	begin catch 
		declare @msg2 as varchar(255) =ERROR_MESSAGE() 
				, @sev as int = ERROR_SEVERITY()
				, @number as int = ERROR_NUMBER() 
		IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION
		exec dbo.log_error @transfer_id, @msg=@msg2,  @severity=@sev, @number=@number 
	end catch 
	
	if @status in ( 'error', 'not started', 'stopped') 
	begin 
		set @msg = 'failed to start transfer '+isnull(@msg,'')+ isnull(', @batch_id = '+convert(varchar(10), @batch_id),'') 
		exec dbo.log @transfer_id, 'error', '? batch_id ?, transfer ?(transfer_id) : ? ? ? ', @proc_name , @msg
	end 
	if 	@status in ('skipped', 'error', 'Not started', 'stopped') 
		set @transfer_id = 0

	exec dbo.log @transfer_id, 'footer', '?(?) ?', @proc_name , @transfer_id, @msg

end











GO
print '-- 95. add_db'
IF object_id('[dbo].[add_db]' ) is not null 
  DROP PROCEDURE [dbo].[add_db] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2019-09-24 BvdB This will add @db_name to the Betl meta data repository and places a trigger 
-- to capture all ddl changes so that the structure of @db_name is synched to betl. 

*/
create PROCEDURE [dbo].add_db
	@db_name sysname
	, @transfer_id as int = -1 -- use this for logging. 
as 
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id =@transfer_id, @log_type ='header', @msg ='? ', @i1 =@proc_name , @i2 =@db_name
	-- END standard BETL header code... 

	-- first add @db_name to the repositoru
	exec dbo.refresh @db_name

	-- then place a trigger
    exec exec_template 'trig_betl_meta_data',  @db_name



  -- START standard BETL footer code... 
  footer:
 
 	exec dbo.log @transfer_id =@transfer_id, @log_type ='footer', @msg ='? ', @i1 =@proc_name , @i2 =@db_name
  -- END standard BETL footer code... 
end

GO
print '-- 96. debug'
IF object_id('[dbo].[debug]' ) is not null 
  DROP PROCEDURE [dbo].[debug] 
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-12-17 BvdB wrapper proc for enabling debug info
exec debug 1
*/
CREATE PROCEDURE [dbo].[debug]
	@enable bit = 1 
AS
BEGIN
	SET NOCOUNT ON;
	
	exec betl.dbo.reset 

	if @enable =1
		exec betl.dbo.setp 'log_level', 'debug'

    footer:
	exec my_info
END












GO
print '-- 97. drop_batch'
IF object_id('[dbo].[drop_batch]' ) is not null 
  DROP PROCEDURE [dbo].[drop_batch] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
--2018-07-23 BvdB remove batch and corresponding transfers
exec dbo.drop_batch 10028
*/
CREATE procedure [dbo].[drop_batch]
	@batch_id int 
as 
begin 
	declare 
		@proc_name as varchar(255) =  object_name(@@PROCID)
		, @transfer_id as int =0
	update dbo.Batch set status_id = 400 -- running temporarily
	where batch_id = @batch_id 
	--exec dbo.start_transfer @batch_id, @transfer_id output, @proc_name 
	exec dbo.log @transfer_id, 'step', '? batch_id ', @proc_name , @batch_id
	update [dbo].[Batch]
	set [status_id] = (select status_id from static.status where status_name = 'deleted') 
	where batch_id = @batch_id 
	--update [dbo].[Transfer]
	--set [status_id] = (select status_id from static.status where status_name = 'deleted') 
	--where batch_id = @batch_id 
	--exec dbo.end_transfer @transfer_id
end











GO
print '-- 98. end_batch'
IF object_id('[dbo].[end_batch]' ) is not null 
  DROP PROCEDURE [dbo].[end_batch] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB log ending of batch. allow custom code integration with external logging. 
declare @batch_id int 
exec dbo.end_batch @batch_id output 
print @batch_id 
*/
CREATE procedure [dbo].[end_batch] 
	@batch_id int output ,
	@status as varchar(255) ,
	@transfer_id as int = null 
as 
begin 
	declare @status_id as int 
		,@nu as datetime = getdatE() 
		,@proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'step', '?(b?,t?) status ?', @proc_name , @batch_id, @transfer_id ,  @status
	if not @batch_id > 0 
		goto footer
	select @status_id =status_id 
	from static.Status 
	where status_name = @status
	update [dbo].[Batch]
	set [status_id] = @status_id , batch_end_dt =@nu
	where batch_id = @batch_id 
	and status_id <> 200 -- never overwrite error batch status
	footer:
end












GO
print '-- 99. end_transfer'
IF object_id('[dbo].[end_transfer]' ) is not null 
  DROP PROCEDURE [dbo].[end_transfer] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-12-21 BvdB log transfer ending 
declare @batch_id int ,
	@transfer_id int
exec dbo.end_transfer @batch_id output , @transfer_id output , 'test'
print @batch_id 
print @transfer_id 
*/
CREATE procedure [dbo].[end_transfer]
	@transfer_id int 
	, @status as varchar(255) = 'success'
	, @rec_cnt_src as int =null 
	, @rec_cnt_new as int =null 
	, @rec_cnt_changed as int =null 
	, @rec_cnt_deleted as int =null 

as 
begin 
	declare @nu as datetime = getdatE() 
		, @status_id as int 
		,@proc_name as varchar(255) =  object_name(@@PROCID)

	exec dbo.log @transfer_id, 'step', '?(t?) status ?', @proc_name , @transfer_id ,  @status
	
	select @status_id =status_id 
	from static.Status 
	where status_name = @status
		
	update dbo.Transfer set status_id = @status_id, transfer_end_dt = @nu
		, rec_cnt_src = isnull(@rec_cnt_src,  rec_cnt_src) 
	, rec_cnt_new = isnull(@rec_cnt_new ,rec_cnt_new) 
	, rec_cnt_changed = isnull(@rec_cnt_changed , rec_cnt_changed) 
	, rec_cnt_deleted = isnull(@rec_cnt_deleted , rec_cnt_deleted) 
	where transfer_id = @transfer_id  

	-- if batch has same name as transfer-> end batch. 
	-- this is because batch was automatically created 
	-- by start_transfer
	declare @batch_id as int 
	select @batch_id = b.batch_id 
	from dbo.batch b
	inner join dbo.Transfer t on t.batch_id = b.batch_id
	where b.batch_name= t.transfer_name
	and t.transfer_id = @transfer_id

	if @batch_id is not null 
		exec dbo.end_batch @batch_id, @status, @transfer_id
	footer: 
end












GO
print '-- 100. onPostExecute'
IF object_id('[dbo].[onPostExecute]' ) is not null 
  DROP PROCEDURE [dbo].[onPostExecute] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-07-12 BvdB this is used in ssis event handling. 
declare 
@batch_id int =?
, @transfer_id int=?
, @package_name varchar(255) = ? 
, @status as varchar(255) = ?
, @package_batch_id int = ?
, @step_name as varchar(255) = ?
, @rec_cnt_src as int = ?
, @rec_cnt_new as int = ?
, @rec_cnt_changed as int = ?
, @rec_cnt_deleted as int = ?
exec betl.dbo.onPostExecute @batch_id, @transfer_id, @package_name, @status, @package_batch_id , @step_name 
, @rec_cnt_src , @rec_cnt_new , @rec_cnt_changed , @rec_cnt_deleted 
*/
CREATE procedure [dbo].[onPostExecute]
	@batch_id int 
	, @transfer_id int 
	, @package_name as varchar(255) 
	, @status as varchar(255) 
	, @package_batch_id int =null 
	, @step_name as varchar(255) =null
	, @rec_cnt_src as int =null 
	, @rec_cnt_new as int =null 
	, @rec_cnt_changed as int =null 
	, @rec_cnt_deleted as int =null 
as 
begin 
	set nocount on 
	declare 
		@msg as varchar(255) =''
		,@nu as datetime = getdate() 
		,@proc_name as varchar(255) =  object_name(@@PROCID);	
	if @step_name not in ('onPreExecute', 'onPostExecute')
	--exec dbo.log @transfer_id, 'header', '? batch_id ?, transfer_id ? ', @proc_name , @batch_id, @transfer_id 
	set @rec_cnt_src = case when isnull(@rec_cnt_src ,-1) < 0 then null else @rec_cnt_src  end 
	set @rec_cnt_new = case when isnull(@rec_cnt_new ,-1) < 0 then null else @rec_cnt_new  end 
	set @rec_cnt_changed = case when isnull(@rec_cnt_changed ,-1) < 0 then null else @rec_cnt_changed  end 
	set @rec_cnt_deleted = case when isnull(@rec_cnt_deleted ,-1) < 0 then null else @rec_cnt_deleted  end 
	if @rec_cnt_src >=0 and @rec_cnt_new is null 
		set @rec_cnt_new = @rec_cnt_src  -- simple truncate insert
	--exec dbo.log @transfer_id, 'var', '@rec_cnt_src ?, @rec_cnt_new ?,@rec_cnt_changed ?,@rec_cnt_deleted ?', @rec_cnt_src , @rec_cnt_new ,@rec_cnt_changed ,@rec_cnt_deleted 
	if isnull(@package_name,'') = isnull(@step_name,'')  -- post execute of package. 
	begin
		exec betl.dbo.end_transfer @transfer_id, @status
				, @rec_cnt_src 
				, @rec_cnt_new 
				, @rec_cnt_changed 
				, @rec_cnt_deleted 
		if isnull(@package_batch_id  ,-1) <= 0 -- package is not part of bigger batch-> end batch
			exec betl.dbo.end_batch @batch_id, @status, @transfer_id
	end
	if @step_name not in ('onPreExecute', 'onPostExecute')
		exec dbo.log @transfer_id, 'footer', '? ?', @proc_name ,@step_name
	footer: 
	
end












GO
print '-- 101. process_stack'
IF object_id('[dbo].[process_stack]' ) is not null 
  DROP PROCEDURE [dbo].[process_stack] 
GO
	  
	
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-23 BvdB
exec dbo.process_stack
*/
CREATE procedure [dbo].[process_stack]
	@transfer_id as int = -1 
as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ', @proc_name 
	-- END standard BETL header code... 

	declare @stack_id as int
	select @stack_id = max(stack_id) from dbo.Stack
	
	exec dbo.log @transfer_id, 'VAR', 'stack id ?', @stack_id 
	while @stack_id is not null
	begin 
		exec dbo.log @transfer_id, 'Step', 'processing stack id ?', @stack_id 
		exec dbo.process_stack_id @stack_id 
		select @stack_id = min(stack_id) from dbo.Stack
	end 


	footer:
	
	exec dbo.log @transfer_id, 'Footer', '? ', @proc_name 
end

 












GO
print '-- 102. process_stack_id'
IF object_id('[dbo].[process_stack_id]' ) is not null 
  DROP PROCEDURE [dbo].[process_stack_id] 
GO
	  
	
/*---------------------------------------------------------------------------------------------
BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL
-----------------------------------------------------------------------------------------------
-- 2018-04-23 BvdB
 exec dbo.process_stack_id 1 

 */
CREATE procedure [dbo].[process_stack_id] 
	@stack_id as int 
	, @transfer_id as int = -1 

as
begin
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'Header', '? ', @proc_name 
	-- END standard BETL header code... 

	--exec dbo.log @transfer_id, 'Header', '?', @proc_name 
	declare @sql as nvarchar(max) 
		--, @stack_id as int
	--select @stack_id = min(stack_id) from dbo.Stack
	if @stack_id is not null 
	begin 
		select @sql = [value] from dbo.Stack where stack_id = @stack_id 
		
		exec dbo.log @transfer_id, 'VAR', '@sql ? ', @sql

		exec dbo.exec_sql @transfer_id, @sql 
		delete from dbo.Stack 
		where stack_id = @stack_id 
		--exec [dbo].process_stack
	end 

	footer:
	exec dbo.log @transfer_id, 'Footer', '? ', @proc_name 

end

GO
print '-- 103. reset'
IF object_id('[dbo].[reset]' ) is not null 
  DROP PROCEDURE [dbo].[reset] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2012-03-21 BvdB reset (user bound) properties
exec dbo.reset 
*/
CREATE PROCEDURE [dbo].[reset]  
	@transfer_id int = -1 
	as
begin 
	-- standard BETL header code... 
	set nocount on 
	declare @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '? ', @proc_name 
	-- END standard BETL header code... 
--	exec dbo.log @transfer_id, 'INFO' , 'BEFORE reset'
--	exec dbo.my_info @transfer_id
	exec dbo.setp 'exec_sql', 1
	exec dbo.setp 'LOG_LEVEL', 'INFO'
	exec dbo.setp 'nesting' , 0
--	exec dbo.log @transfer_id, 'INFO', 'AFTER reset'
	--exec dbo.my_info @transfer_id
	truncate table dbo.Stack

	footer:
	exec dbo.log @transfer_id, 'footer', 'DONE ? ', @proc_name 
	-- END standard BETL footer code... 
end












GO
print '-- 104. update_transfer'
IF object_id('[dbo].[update_transfer]' ) is not null 
  DROP PROCEDURE [dbo].[update_transfer] 
GO
	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-02-05 BvdB update the transfer details. 
select * from dbo.transfer where transfer_id = 100
exec dbo.update_transfer @transfer_id=100, @rec_cnt_src=418
*/
CREATE procedure [dbo].[update_transfer] 
	@transfer_id int
	, @start_dt as datetime = null
	, @end_dt as datetime = null
	, @transfer_name as varchar(100) = null
	, @target_name as varchar(100) = null
	, @rec_cnt_src as int=null
	, @rec_cnt_new as int=null
	, @rec_cnt_changed as int=null
	, @rec_cnt_deleted as int=null
	, @status_id as int = null
	, @last_error_id as int = null
	, @src_obj_id as int = null 
as 
begin 
	declare   @proc_name as varchar(255) =  object_name(@@PROCID);
	exec dbo.log @transfer_id, 'header', '?[?] @start_dt ? , @end_dt ?, @rec_cnt_src ? , @rec_cnt_new ?, @status_id ?', @proc_name , @transfer_id, @start_dt, @end_dt, @rec_cnt_src, @rec_cnt_new, @status_id 
	update dbo.Transfer set 
		transfer_start_dt = isnull(@start_dt , transfer_start_dt ) 
		, transfer_end_dt = isnull(@end_dt , transfer_end_dt ) 
		, transfer_name = isnull(@transfer_name , transfer_name) 
		, target_name = isnull(@target_name , target_name) 
		, rec_cnt_src=  isnull(@rec_cnt_src , rec_cnt_src) 
		, rec_cnt_new = isnull(@rec_cnt_new , rec_cnt_new ) 
		, rec_cnt_changed  = isnull(@rec_cnt_changed , rec_cnt_changed ) 
		, rec_cnt_deleted = isnull(@rec_cnt_deleted ,rec_cnt_deleted ) 
		, status_id = isnull(@status_id , status_id) 
		, last_error_id = isnull(@last_error_id , last_error_id) 
		, src_obj_id = isnull(@src_obj_id , src_obj_id) 
	where transfer_id = @transfer_id  
	declare @msg as varchar(255) 
	if @rec_cnt_new is not null 
		exec dbo.log @transfer_id, 'INFO', 'rec_cnt_new : ?',  @rec_cnt_new
	if @rec_cnt_src  is not null 
		exec dbo.log @transfer_id, 'INFO', 'rec_cnt_src  : ?',  @rec_cnt_src 
		
	footer: 
end












GO
print '-- 105. verbose'
IF object_id('[dbo].[verbose]' ) is not null 
  DROP PROCEDURE [dbo].[verbose] 
GO

	  
/*------------------------------------------------------------------------------------------------
-- BETL, meta data driven ETL generation, licensed under GNU GPL https://github.com/basvdberg/BETL 
--------------------------------------------------------------------------------------------------
-- 2018-12-17 BvdB wrapper proc for enabling debug info
exec debug
*/
CREATE PROCEDURE [dbo].[verbose]
	@enable bit = 1 
AS
BEGIN
	SET NOCOUNT ON;
	
	exec betl.dbo.reset 

	if @enable =1
		exec betl.dbo.setp 'log_level', 'verbose'

    footer:
	exec my_info
END












GO

-- begin ddl_content
set nocount on 
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (0, N'unknown', NULL)
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (100, N'success', N'Execution of batch or transfer finished without any errors. ')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (200, N'error', N'Execution of batch or transfer raised an error.')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (300, N'not started', N'Execution of batch or transfer is not started because it cannot start (maybe it''s already running). ')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (400, N'running', N'Batch or transfer is running. do not start a new instance.')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (600, N'continue', N'This batch is continuing where the last instance stopped. ')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (700, N'stopped', N'batch stopped without error (can be continued any time). ')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (800, N'skipped', N'Transfer is skipped because batch will continue where it has left off. ')
GO
INSERT [static].Status ([status_id], [status_name], [description]) VALUES (900, N'deleted', N'Transfer or batch is deleted / dropped')
GO

INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (-1, N'unknown', N'Unknown,  not relevant', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (100, N'nat_pkey', N'Natural primary key (e.g. user_key)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (110, N'nat_fkey', N'Natural foreign key (e.g. create_user_key)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (200, N'sur_pkey', N'Surrogate primary key (e.g. user_id)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (210, N'sur_fkey', N'Surrogate foreign key (e.g. create_user_id)', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (300, N'attribute', N'low or non repetetive value for containing object. E.g. customer lastname, firstname.', CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [static].[Column_type] ([column_type_id], [column_type_name], [column_type_description], [record_dt], [record_user]) VALUES (999, N'meta data', NULL, CAST(N'2015-10-20 13:22:19.590' AS DateTime), N'bas')
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N'navision', 1)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N'exact', 2)
GO
INSERT [dbo].[Key_domain] ([key_domain_name], [key_domain_id]) VALUES (N'adp', 2)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (10, N'table', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (20, N'view', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (30, N'schema', 30)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (40, N'database', 20)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (50, N'server', 10)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (60, N'user', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (70, N'procedure', 40)
GO
INSERT [static].[Obj_type] ([obj_type_id], [obj_type], [obj_type_level]) VALUES (80, N'role', 30)
GO

INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgd', 12)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgf', 13)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgh', 8)
GO
INSERT [dbo].[Prefix] ([prefix_name], [default_template_id]) VALUES (N'stgl', 10)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (10, N'target_schema_id', N'used for deriving target table', N'db_object', NULL, 1, 1, 1, 1, NULL, NULL, CAST(N'2015-08-31T13:18:22.073' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (15, N'template_id', N'which ETL template to use (see def.Template) ', N'db_object', NULL, 0, 0, 1, 1, NULL, NULL, CAST(N'2017-09-07T09:12:49.160' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (20, N'has_synonym_id', N'apply syn pattern (see biblog.nl)', N'db_object', NULL, 0, 0, 0, 1, NULL, NULL, CAST(N'2015-08-31T13:18:56.070' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (30, N'has_record_dt', N'add this column (insert date time) to all tables', N'db_object', NULL, 0, 0, 0, 0, 1, NULL, CAST(N'2015-08-31T13:19:09.607' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (40, N'has_record_user', N'add this column (insert username ) to all tables', N'db_object', NULL, 0, 0, 1, 0, 1, NULL, CAST(N'2015-08-31T13:19:15.000' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (50, N'is_linked_server', N'Should a server be accessed like a linked server (e.g. via openquery). Used for SSAS servers.', N'db_object', NULL, NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-08-31T17:17:37.830' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (60, N'date_datatype_based_on_suffix', N'if a column ends with the suffix _date then it''s a date datatype column (instead of e.g. datetime)', N'db_object', N'1', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-02T13:16:15.733' AS DateTime), N'My_PC\BAS')
GO

INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (70, N'is_localhost', N'This server is localhost. For performance reasons we don''t want to access localhost via linked server as we would with external sources', N'db_object', N'0', NULL, NULL, NULL, NULL, 1, NULL, CAST(N'2015-09-24T16:22:45.233' AS DateTime), N'My_PC\BAS')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (80, N'recreate_tables', N'This will drop and create tables (usefull during initial development)', N'db_object', NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (90, N'prefix_length', N'This object name uses a prefix of certain length x. Strip this from target name. ', N'db_object', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (100, N'etl_meta_fields', N'etl_run_id, etl_load_dts, etl_end_dts,etl_deleted_flg,etl_active_flg,etl_data_source', N'db_object', N'1', NULL, NULL, 1, 1, NULL, NULL, NULL, NULL)
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (120, N'exec_sql', N'set this to 0 to print the generated sql instead of executing it. usefull for debugging', N'user', N'1', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:04:49.867' AS DateTime), N'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (130, N'log_level', N'controls the amount of logging. ERROR,INFO, DEBUG, VERBOSE', N'user', N'INFO', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:06:12.167' AS DateTime), N'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (140, N'nesting', N'used by dbo.log in combination with log_level  to determine wheter or not to print a message', N'user', N'0', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2017-02-02T15:08:02.967' AS DateTime), N'')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (150, N'delete_detection', N'detect deleted records', N'db_object', N'1', 1, 1, 1, NULL, NULL, NULL, CAST(N'2017-12-19T14:08:52.533' AS DateTime), N'company\991371')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (160, N'use_key_domain', N'adds key_domain_id to natural primary key of hubs to make key unique for a particular domain. push can derive key_domain e.g.  from source system name', N'db_object', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N'2018-01-09T10:26:57.017' AS DateTime), N'company\991371')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (170, N'privacy_level', N'scale : normal, sensitive, personal', N'db_object', N'10', 1, 1, NULL, NULL, NULL, NULL, CAST(N'2018-04-09T16:38:43.057' AS DateTime), N'company\991371')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (180, N'filter_delete_detection', N'custom filter for delete detection', N'db_object', NULL, 1, 1, NULL, NULL, NULL, NULL, CAST(N'2018-07-04T17:27:29.857' AS DateTime), N'company\991371')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (190, N'proc_max_cnt', N'how many concurrent processes / jobs. default 4 ', N'user', N'4', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2019-01-23T17:20:03.690' AS DateTime), N'MicrosoftAccount\swjvdberg@outlook.com')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (200, N'proc_max_wait_time_min', N'how long should we wait for a proc to finish when proc_max_cnt is reached. default 10 minutes. please increase this value for big datasets!', N'user', N'10', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2019-01-25T12:27:24.543' AS DateTime), N'MicrosoftAccount\swjvdberg@outlook.com')
GO
INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (210, N'proc_polling_interval_sec', N'wait polling interval. How long till we check again. range: 1-59 . Too low might affect performance because every time we query  msdb.dbo.sysjobs', N'user', N'2', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2019-01-25T12:29:17.060' AS DateTime), N'MicrosoftAccount\swjvdberg@outlook.com')
GO

INSERT [static].[Property] ([property_id], [property_name], [description], [property_scope], [default_value], [apply_table], [apply_view], [apply_schema], [apply_db], [apply_srv], [apply_user], [record_dt], [record_user]) VALUES (220, N'proc_dead_time_sec', N'delete jobs that are created more than @proc_dead_time_sec ago and are not running. ', N'user', N'60', NULL, NULL, NULL, NULL, NULL, 1, CAST(N'2019-01-25T12:40:13.197' AS DateTime), N'MicrosoftAccount\swjvdberg@outlook.com')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (1, N'truncate_insert', N'truncate_insert', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (2, N'drop_insert', N'drop_insert', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (3, N'delta_insert_first_seq', N'delta insert based on a first sequential ascending column', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (4, N'truncate_insert_create_stgh', N'truncate_insert imp_table then create stgh view lowercase, nvarchar->varchar, money->decimal ', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (5, N'create_stgh', N'create stgh view (follow up on template 4)', CAST(N'2018-05-30 11:03:13.127' AS DateTime), N'company\991371')
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (6, N'switch', N'transfer to switching tables (Datamart)', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (7, N'delta_insert_eff_dt', N'delta insert based on eff_dt column', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (8, N'hub_and_sat', N'Datavault Hub & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (9, N'hub_sat', N'Datavault Hub Sat (part of transfer_method 8)', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (10, N'link_and_sat', N'Datavault Link & Sat (CDC and delete detection)', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (11, N'link_sat', N'Datavault Link Sat (part of transfer_method 10)', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (12, N'dim', N'Kimball Dimension', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (13, N'fact', N'Kimball Fact', NULL, NULL)
GO
INSERT [static].[Template] ([template_id], [template], [template_description], [record_dt], [record_name]) VALUES (14, N'fact_append', N'Kimball Fact Append', NULL, NULL)
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (10, N'ERROR', N'Only log errors')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (20, N'WARN', N'Log errors and warnings (SSIS mode)')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (30, N'INFO', N'Log headers and footers')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (40, N'DEBUG', N'Log everything only at top nesting level')
GO
INSERT [static].[Log_level] ([log_level_id], [log_level], [log_level_description]) VALUES (50, N'VERBOSE', N'Log everything all nesting levels')
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (10, N'Header', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (20, N'Footer', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (30, N'SQL', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (40, N'VAR', 40)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (50, N'Error', 10)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (60, N'Warn', 20)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (70, N'Step', 30)
GO
INSERT [static].[Log_type] ([log_type_id], [log_type], [min_log_level_id]) VALUES (80, N'Progress', 50)
GO


set identity_insert dbo.Batch on 
GO
insert into dbo.Batch(batch_id, batch_name) values ( -1, 'Unknown')
GO
set identity_insert dbo.Batch off
GO
set identity_insert dbo.Transfer on 
GO
insert into dbo.Transfer(transfer_id, transfer_name) values ( -1, 'Unknown')
GO
set identity_insert dbo.Transfer off
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (10, N'sql server', N'SQL Server 2012 (SP3) (KB3072779) - 11.0.6020.0 (X64)')
GO
INSERT [static].[Server_type] ([server_type_id], [server_type], [compatibility]) VALUES (20, N'ssas tabular', N'SQL Server Analysis Services Tabular Databases with Compatibility Level 1200')
GO
insert into dbo.Obj(obj_type_id, obj_name)
values ( 50, 'LOCALHOST')
GO
exec dbo.setp 'is_localhost', 1 , 'LOCALHOST'
-- end of ddl_content
--END BETL Release version 3.2.2 , date: 2019-11-12 10:11:25

