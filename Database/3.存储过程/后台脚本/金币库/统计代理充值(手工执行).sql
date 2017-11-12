----------------------------------------------------------------------
-- ��;����;����Ϊ��������ͳ�ƴ����ֵ��ֻ�����������ݽ���ͳ�ơ�
-- �������ڶϵ��ά��ʱ�����ǿ�����ҵִ�У����´����ֵû�м�ʱͳ�ƣ�����Ҫ�ֹ�ִ�д˴洢���̡�
--		 NOT IN����м��ϡ�UserID=a.UserID��������Ϊ�˿����ظ���ִ�д˴洢���̡�
----------------------------------------------------------------------
USE RYTreasureDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].WSP_PM_StatAgentPayHand') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].WSP_PM_StatAgentPayHand
GO

----------------------------------------------------------------------
CREATE PROC WSP_PM_StatAgentPayHand
			
WITH ENCRYPTION AS

BEGIN
	-- ��������
	SET NOCOUNT ON;
	DECLARE @DateID INT
	SET @DateID = CAST(CAST(DateAdd(d,-1,GETDATE()) AS FLOAT) AS INT)
	
	INSERT RecordAgentInfo	
	SELECT	a.DateID,a.UserID,b.AgentScale,b.PayBackScale,2,a.PayScore,a.PayScore*b.PayBackScale,0,0,GETDATE(),'',''			
	FROM  StreamAgentPayInfo a CROSS APPLY
	(        
		SELECT PayBackScore,PayBackScale,AgentScale FROM RYAccountsDB.dbo.AccountsAgent WHERE UserID=a.UserID

	) AS b WHERE a.PayScore>=b.PayBackScore AND a.DateID<=@DateID AND a.DateID NOT IN (SELECT DateID FROM RecordAgentInfo WHERE DateID=a.DateID AND TypeID=2 AND UserID=a.UserID)
END
 
 