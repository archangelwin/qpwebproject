----------------------------------------------------------------------
-- ʱ�䣺2011-10-11
-- ��;����Ծ�û�ͳ��
----------------------------------------------------------------------
USE [RYTreasureDB]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_StatActiveUserTotalByDay]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_StatActiveUserTotalByDay]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_StatActiveUserTotalByMonth]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_StatActiveUserTotalByMonth]
GO

----------------------------------------------------------------------
CREATE PROC [WSP_PM_StatActiveUserTotalByDay]
(
	@StartDateID	INT,				-- ��ͳ����ʼʱ��
	@EndDateID		INT					-- ��ͳ�ƽ���ʱ��
)
			
WITH ENCRYPTION AS

BEGIN
	-- ��������
	SET NOCOUNT ON

	-- ��Ծ����
	DECLARE @DayActiveOnlineTime INT	-- �ջ�Ծʱ��
	SET @DayActiveOnlineTime=60*60		-- 1Сʱ
	
	SELECT COUNT(UserID) AS UserTotal,DateID FROM StreamScoreInfo
	WHERE OnlineTimeCount>@DayActiveOnlineTime AND DateID>=@StartDateID AND DateID<=@EndDateID
	GROUP BY DateID ORDER BY DateID ASC
	
END
GO

----------------------------------------------------------------------
CREATE PROC [WSP_PM_StatActiveUserTotalByMonth]

WITH ENCRYPTION AS

BEGIN
	-- ��������
	SET NOCOUNT ON

	-- ��Ծ����
	DECLARE @MonthActiveOnlineTime INT		-- �»�Ծʱ��
	SET @MonthActiveOnlineTime=40*60*60		-- 40Сʱ		
	
	SELECT COUNT(UserID) AS UserTotal,UserID,CONVERT(VARCHAR(7),LastCollectDate,120) AS StatDate,Sum(CONVERT(BIGINT,OnlineTimeCount)) as TimeCount FROM StreamScoreInfo
	GROUP BY UserID,CONVERT(VARCHAR(7),LastCollectDate,120) HAVING Sum(CONVERT(BIGINT,OnlineTimeCount))>=@MonthActiveOnlineTime
	
END
GO



