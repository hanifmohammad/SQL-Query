USE [master];

DECLARE @kill varchar(8000) = '';  
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  in ('6')
and session_id>'50'
and session_id<>(SELECT @@SPID AS CurrentSPID)
and session_id<>('70')
and [status] in ('running','sleeping')
EXEC(@kill);


------------------------
SELECT * FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;