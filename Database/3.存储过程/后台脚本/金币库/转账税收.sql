----------------------------------------------------------------------
-- ʱ�䣺2014-03-07
-- ��;����ѯת��˰�յ�ǰ100�����
----------------------------------------------------------------------

USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_GetUserTransferTop100]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_GetUserTransferTop100]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO
----------------------------------------------------------------------
CREATE PROCEDURE WSP_PM_GetUserTransferTop100

WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �û�����
DECLARE @CurExperience INT
	
-- ִ���߼�
BEGIN
	
	SELECT TOP 100 COUNT(RecordID) AS Counts,SUM(Revenue) AS Revenue,SUM(SourceGold) AS SourceGold,SourceUserID,
	(SELECT Accounts FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=SourceUserID) AS Accounts,
	(SELECT NickName FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=SourceUserID) AS NickName,
	(SELECT GameID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=SourceUserID) AS GameID
	FROM RecordInsure WHERE TradeType=3 
	GROUP BY SourceUserID HAVING SUM(SourceGold)>0 
	ORDER BY SUM(Revenue) DESC

END
RETURN 0
