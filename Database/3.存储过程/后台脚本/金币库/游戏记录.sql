----------------------------------------------------------------------
-- ʱ�䣺2010-03-16
-- ��;�����;���
----------------------------------------------------------------------

USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_GetRecordDrawScoreByDrawID]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_GetRecordDrawScoreByDrawID]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO
----------------------------------------------------------------------
CREATE PROCEDURE WSP_PM_GetRecordDrawScoreByDrawID
		@dwDrawID		INT			-- ��ID
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �û�����
DECLARE @CurExperience INT
	
-- ִ���߼�
BEGIN
	SELECT A.*,B.Accounts,B.Accounts,B.NickName,B.GameID,B.IsAndroid FROM RecordDrawScore AS A 
	Left JOIN RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo AS B
	ON A.UserID=B.UserID
	WHERE DrawID=@dwDrawID
END
RETURN 0
