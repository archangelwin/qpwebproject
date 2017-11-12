----------------------------------------------------------------------
-- ��;����ȡ�����̷ֳ�����
-- ������
----------------------------------------------------------------------
USE RYTreasureDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].WSP_PM_GetAgentFinance') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].WSP_PM_GetAgentFinance
GO

----------------------------------------------------------------------
CREATE PROC WSP_PM_GetAgentFinance
	@dwUserID		INT
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

BEGIN
	-- ��ȡ˰�շֳ�
	DECLARE @AgentRevenue BIGINT
	SELECT @AgentRevenue=ISNULL(SUM(AgentRevenue),0) FROM RecordUserRevenue WHERE AgentUserID=@dwUserID

	-- ��ȡ��ֵ�ֳ�
	DECLARE @AgentPay BIGINT
	SELECT @AgentPay=ISNULL(SUM(Score),0) FROM RecordAgentInfo WHERE UserID=@dwUserID AND TypeID=1

	-- ��ȡ��ֵ���ֳַ�
	DECLARE @AgentPayBack BIGINT
	SELECT @AgentPayBack=ISNULL(SUM(Score),0) FROM RecordAgentInfo WHERE UserID=@dwUserID AND TypeID=2
	
	-- ��ȡ����֧��
	DECLARE @AgentOut BIGINT
	SELECT @AgentOut=ISNULL(-SUM(Score),0) FROM RecordAgentInfo WHERE UserID=@dwUserID AND TypeID=3

	SELECT @AgentRevenue AS AgentRevenue,@AgentPay AS AgentPay,@AgentPayBack AS AgentPayBack,@AgentOut AS AgentOut
	
END
 
 