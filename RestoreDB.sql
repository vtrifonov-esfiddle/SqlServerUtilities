DECLARE @DbName As nvarchar(400) = 'WideWorldImporter';
DECLARE @DbFilePath As NVarchar(400) = 'C:\Downloads\WideWorldImportersDW-Standard.bak';

DECLARE @DbRestoreDir As NVARCHAR(max) = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\';

DECLARE @fileListTable TABLE (
    [LogicalName]           NVARCHAR(128),
    [PhysicalName]          NVARCHAR(260),
    [Type]                  CHAR(1),
    [FileGroupName]         NVARCHAR(128),
    [Size]                  NUMERIC(20,0),
    [MaxSize]               NUMERIC(20,0),
    [FileID]                BIGINT,
    [CreateLSN]             NUMERIC(25,0),
    [DropLSN]               NUMERIC(25,0),
    [UniqueID]              UNIQUEIDENTIFIER,
    [ReadOnlyLSN]           NUMERIC(25,0),
    [ReadWriteLSN]          NUMERIC(25,0),
    [BackupSizeInBytes]     BIGINT,
    [SourceBlockSize]       INT,
    [FileGroupID]           INT,
    [LogGroupGUID]          UNIQUEIDENTIFIER,
    [DifferentialBaseLSN]   NUMERIC(25,0),
    [DifferentialBaseGUID]  UNIQUEIDENTIFIER,
    [IsReadOnly]            BIT,
    [IsPresent]             BIT,
	[TDEThumbprint]         VARBINARY(32),
	[SnaphsotUrl]			NVARCHAR(MAX)
)



INSERT INTO @fileListTable EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @DbFilePath + '''')
SELECT * FROM @fileListTable
DECLARE @mdfLogicalName As NVARCHAR(Max) = (SELECT LogicalName FROM @fileListTable WHERE PhysicalName like '%.mdf');
DECLARE @ndfLogicalName As NVARCHAR(Max) = (SELECT LogicalName  FROM @fileListTable WHERE PhysicalName like '%.ndf');
DECLARE @ldfLogicalName As NVARCHAR(Max) = (SELECT LogicalName  FROM @fileListTable WHERE PhysicalName like '%.ldf');


DECLARE @toMdfPath As NVARCHAR(Max) = @DbRestoreDir + @DbName + '.mdf';
DECLARE @toNdfPath As NVARCHAR(Max) = @DbRestoreDir + @DbName + '.ndf';
DECLARE @toLdfPath As NVARCHAR(Max) = @DbRestoreDir + @DbName + '.ldf';

IF (@ndfLogicalName IS NULL)
BEGIN
	RESTORE DATABASE @DbName
	FROM DISK = @DbFilePath
	WITH MOVE @mdfLogicalName TO @toMdfPath,
	MOVE @ldfLogicalName TO @toLdfPath;
END
ELSE
BEGIN
	RESTORE DATABASE @DbName
	FROM DISK = @DbFilePath
	WITH MOVE @mdfLogicalName TO @toMdfPath,
	MOVE @ndfLogicalName TO @toNdfPath,
	MOVE @ldfLogicalName TO @toLdfPath;
END