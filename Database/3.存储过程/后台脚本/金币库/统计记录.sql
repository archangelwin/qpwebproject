----------------------------------------------------------------------
-- ʱ�䣺2014-03-7
-- ��;��ͳ����Ҫ��������ݱ��¼��������¼������ڡ���¼��С���ڵ�
----------------------------------------------------------------------

USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_StatRecordTable]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_StatRecordTable]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO
----------------------------------------------------------------------
CREATE PROCEDURE WSP_PM_StatRecordTable
				
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON
	
-- ִ���߼�
BEGIN
	SELECT 1 AS ID,COUNT(ID) AS Counts,Max(LeaveTime) AS MaxTime,Min(LeaveTime) AS MinTime FROM RecordUserInout 
	UNION ALL
	SELECT 2 AS ID,COUNT(DrawID) AS Counts,Max(InsertTime) AS MaxTime,Min(InsertTime) AS MinTime FROM RecordDrawInfo
	UNION ALL
	SELECT 3 AS ID,COUNT(DrawID) AS Counts,Max(InsertTime) AS MaxTime,Min(InsertTime) AS MinTime FROM RecordDrawScore
	UNION ALL
	SELECT 4 AS ID,COUNT(RecordID) AS Counts,Max(CollectDate) AS MaxTime,Min(CollectDate) AS MinTime FROM RecordInsure
END
RETURN 0
