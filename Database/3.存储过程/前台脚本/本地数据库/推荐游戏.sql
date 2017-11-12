----------------------------------------------------------------------------------------------------
-- ��Ȩ��2013
-- ʱ�䣺2013-07-31
-- ��;�����ⷴ��
----------------------------------------------------------------------------------------------------
USE RYNativeWebDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].WSP_PW_GetRecommendGame') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].WSP_PW_GetRecommendGame
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------
-- ���ⷴ��
CREATE PROCEDURE WSP_PW_GetRecommendGame
	@Count	INT					-- ��ѯ����
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ִ���߼�
BEGIN
	
	SELECT TOP(@Count) * FROM GameRulesInfo 
	WHERE KindID IN (SELECT KindID FROM RYPlatformDBLink.RYPlatformDB.dbo.GameKindItem WHERE JoinID=2)

	RETURN 0
END
RETURN 0
GO