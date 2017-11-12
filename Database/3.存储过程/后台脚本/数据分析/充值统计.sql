----------------------------------------------------------------------
-- �汾��2013
-- ʱ�䣺2013-04-22
-- ��;����ֵͳ��
----------------------------------------------------------------------
USE [RYTreasureDB]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_AnalPayStat]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_AnalPayStat]

GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_AnalPayStat]
			
WITH ENCRYPTION AS

BEGIN
	-- ��������
	SET NOCOUNT ON
	DECLARE @PayUserCounts INT			-- ��ֵ������
	DECLARE @PayTwoUserCounts INT		-- ��ֵ����1������
	DECLARE @PayMaxAmount INT			-- ����ֵ���
	DECLARE @PayTotalAmount BIGINT		-- ��ֵ�ܽ��
	DECLARE @MaxShareID INT				-- ��ֵ�������
	DECLARE @CurrentDateMaxAmount INT	-- ���ճ�ֵ����� 
	DECLARE @PayMaxDate VARCHAR(10)		-- ����ֵ����
	DECLARE @UserTotal VARCHAR(10)		-- �û�����
	DECLARE @PayUserOutflowTotal INT	-- ��ֵ�û���ʧ��
	DECLARE @VIPPayUserTotal INT		-- ��ֵ������2000RMN�����

	-- ��ֵ������
	SELECT @PayUserCounts=COUNT(*) FROM (SELECT DISTINCT UserID FROM ShareDetailInfo) AS A
	
	-- ���γ�ֵ���
	SELECT @PayTwoUserCounts=COUNT(Total) 
	FROM (SELECT COUNT(UserID) AS Total FROM ShareDetailInfo GROUP BY UserID) AS A WHERE Total>1
	
	-- ����ܳ�ֵ���	
	SELECT @PayMaxAmount=MAX(PayAmount),@PayTotalAmount=SUM(PayAmount) FROM ShareDetailInfo
	
	-- ��ֵ�������
	SELECT TOP 1 @MaxShareID=ShareID FROM ShareDetailInfo GROUP BY ShareID ORDER BY Sum(PayAmount) DESC
	
	-- ���ճ�ֵ��߶��
	SELECT @CurrentDateMaxAmount=Max(PayAmount) FROM ShareDetailInfo 
	WHERE ApplyDate>=CONVERT(VARCHAR(10),GETDATE(),120) AND ApplyDate<=CONVERT(VARCHAR(10),GETDATE()+1,120) 
	
	-- ����ֵ����
	SELECT TOP 1 @PayMaxDate=Convert(varchar(10),ApplyDate,120) FROM ShareDetailInfo 
	GROUP BY Convert(varchar(10),ApplyDate,120) ORDER BY SUM(PayAmount) DESC
	
	-- �û�����
	SELECT @UserTotal=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE IsAndroid=0
	
	-- ��ֵ�û���ʧ��
	SELECT @PayUserOutflowTotal=Count(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE UserID IN(SELECT USERID FROM ShareDetailInfo) AND LastLogonDate<DATEADD(mm,-1,Convert(varchar(10),GetDate(),120)) AND IsAndroid=0
	
	-- ��ֵ��
	SELECT @VIPPayUserTotal=COUNT(UserID) FROM (SELECT UserID FROM ShareDetailInfo 
	GROUP BY UserID HAVING SUM(PayAmount)>=2000 ) AS A

	-- ��������
	SELECT @PayUserCounts AS PayUserCounts,@PayTwoUserCounts AS PayTwoUserCounts,ISNULL(@PayMaxAmount,0) AS PayMaxAmount,
	ISNULL(@PayTotalAmount,0) AS PayTotalAmount,ISNULL(@MaxShareID,0) AS MaxShareID,ISNULL(@CurrentDateMaxAmount,0) AS CurrentDateMaxAmount,
	ISNULL(@PayMaxDate,'') AS PayMaxDate,@UserTotal AS UserTotal,@PayUserOutflowTotal AS PayUserOutflowTotal,@VIPPayUserTotal AS VIPPayUserTotal
	
END
GO
