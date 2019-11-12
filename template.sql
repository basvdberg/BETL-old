INSERT [static].[Template] ([template_id], [is_etl_template], [template_name], [template_description], [template_sql], [record_dt], [record_name]) VALUES (1000, 0, N'trig_betl_meta_data', N'This trigger makes sure that ddl events in this database will result in a refresh of the betl meta data', N'-- START <template_name>(<template_id>) on <src_db_name>
-- <template_description> 
-- batch <batch_id>(<transfer_id>). record_user <record_user>. build_dt <build_dt>

IF EXISTS(
  SELECT *
    FROM sys.triggers
   WHERE name = N''trig_betl_meta_data''
     AND parent_class_desc = N''DATABASE''
)
	DROP TRIGGER trig_betl_meta_data ON DATABASE
GO

CREATE TRIGGER trig_betl_meta_data ON DATABASE 
	FOR CREATE_TABLE, DROP_TABLE, ALTER_TABLE, CREATE_VIEW, DROP_VIEW, ALTER_VIEW, CREATE_SCHEMA, DROP_SCHEMA
AS 
	declare 
		@event_type as nvarchar(max)
		, @db_name as sysname
		, @schema_name as sysname
		, @obj_name as sysname
		, @full_object_name as nvarchar(max)

	SELECT 
		@event_type = EVENTDATA().value(''(/EVENT_INSTANCE/EventType)[1]''	, ''nvarchar(max)'')
		, @db_name = EVENTDATA().value(''(/EVENT_INSTANCE/DatabaseName)[1]''	, ''nvarchar(max)'')
		, @schema_name = EVENTDATA().value(''(/EVENT_INSTANCE/SchemaName)[1]'', ''nvarchar(max)'')
		, @obj_name = EVENTDATA().value(''(/EVENT_INSTANCE/ObjectName)[1]''	, ''nvarchar(max)'')

	exec <betl>.dbo.log  -1, ''INFO'', ''trigger trig_betl_meta_data fired because of ? on ?.?.?'', @event_type ,@db_name, @schema_name,@obj_name

	if @event_Type in ( ''CREATE_TABLE'',  ''DROP_TABLE'' , ''CREATE_VIEW'', ''DROP_VIEW'') 
		set @full_object_name = quotename(@db_name) + ''.'' + quotename(@schema_name)

	if @event_Type in ( ''CREATE_SCHEMA'', ''DROP_SCHEMA'' )
		set @full_object_name = quotename(@db_name) 

	if @event_Type in ( ''ALTER_TABLE'',  ''ALTER_VIEW'') 
		set @full_object_name = quotename(@db_name) + ''.'' + quotename(@schema_name) + ''.'' + quotename(@obj_name) 

	-- do not debug this proc... 
	declare @log_level as varchar(255) =''''
	exec <betl>.dbo.getp ''log_level'', @log_level output
	exec <betl>.dbo.setp ''log_level'', ''INFO''
	exec <betl>.dbo.refresh @full_object_name 
	exec <betl>.dbo.setp ''log_level'', @log_level 
-- END <template_name>(<template_id>). <batch_id>(<transfer_id>).', CAST(N'2019-09-24T11:29:00.833' AS DateTime), N'SVB\AVBVDBE1')
