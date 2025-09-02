USE [master]
GO
/****** Object:  StoredProcedure [dbo].[Release_Committed_Memory]    Script Date: 9/2/2025 11:45:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Release_Committed_Memory] 
AS 
BEGIN 

SET NOCOUNT ON 

BEGIN 
        EXEC sys.sp_configure N'show advanced options', N'1'   
        RECONFIGURE WITH OVERRIDE 

        EXEC sys.sp_configure N'max server memory (MB)', N'20480' 
        RECONFIGURE WITH OVERRIDE 

        EXEC sys.sp_configure N'show advanced options', N'0' 
        RECONFIGURE WITH OVERRIDE 
END 

BEGIN 
        WAITFOR DELAY '00:01:00' 
        EXEC sys.sp_configure N'show advanced options', N'1'   
        RECONFIGURE WITH OVERRIDE 
        EXEC sys.sp_configure N'max server memory (MB)', N'25600' 
        RECONFIGURE WITH OVERRIDE 
        EXEC sys.sp_configure N'show advanced options', N'0' 
        RECONFIGURE WITH OVERRIDE 
END 
END 
