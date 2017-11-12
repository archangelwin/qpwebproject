----------------------------------------------------------------------------------------------------
-- ��Ȩ��2011
-- ʱ�䣺2011-08-31
-- ��;���ʺŵ�¼
----------------------------------------------------------------------------------------------------

USE RYGameMatchDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_GetRecentlyMatchRank') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_GetRecentlyMatchRank
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------

-- �ʺŵ�¼
CREATE PROCEDURE NET_PW_GetRecentlyMatchRank
	@MatchID	INT		-- ������ʶ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ��������
DECLARE @EnjoinLogon AS INT

-- ִ���߼�
BEGIN
	DECLARE @MaxRecordDate DATETIME	
	SELECT @MaxRecordDate=MAX(RecordDate) FROM StreamMatchHistory WHERE MatchID=@MatchID
	SELECT A.*,B.NickName AS NickName,B.GameID AS GameID FROM StreamMatchHistory AS A LEFT JOIN RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo AS B ON A.UserID=B.UserID
	WHERE MatchID=@MatchID AND RecordDate=@MaxRecordDate AND (RewardGold>0 OR RewardIngot>0 OR RewardExperience>0) ORDER BY RankID ASC
END

RETURN 0
GO