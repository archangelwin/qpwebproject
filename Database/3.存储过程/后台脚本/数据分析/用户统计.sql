----------------------------------------------------------------------
-- ʱ�䣺2012-10-23
-- ��;����ֵͳ��
----------------------------------------------------------------------
USE [RYAccountsDB]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_AnalUserStat]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_AnalUserStat]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_AnalUserStat]
			
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON
DECLARE @UserTotal INT						-- ���û���
DECLARE @CurrentMonthRegUserCounts INT		-- ����ע���û���
DECLARE @MaxUserRegCounts INT				-- ��ע�����ֵ
DECLARE @OnlineUserAVGCounts INT			-- ƽ����������,��δʵ��
DECLARE @OnlineUserMaxCounts INT			-- ���������������δʵ��
DECLARE @UserAVGOnlineTime INT				-- �û�ƽ������ʱ��
DECLARE @ActiveUserCounts INT				-- ��Ծ�û���
DECLARE @LossUserCounts INT					-- ��ʧ�û���

DECLARE @PayMaxAmount INT					-- ��߳�ֵ���
DECLARE @CurrentDateMaxAmount INT			-- ������߳�ֵ��� 
DECLARE @PayUserCounts INT					-- ��ֵ������
DECLARE @PayTotalAmount BIGINT				-- �ܳ�ֵ���
DECLARE @PayTwoUserCounts INT				-- ���γ�ֵ����
DECLARE @PayCurrencyAmount BIGINT			-- ��ֵ�����ܽ��
DECLARE @MaxShareID INT						-- ��ֵ�������
DECLARE @PayUserOutflowTotal INT			-- ��ֵ�û���ʧ��
DECLARE @VIPPayUserTotal INT				-- ��ֵ������2000RMN�����
DECLARE @CurrencyTotal BIGINT				-- ƽ̨������
DECLARE @GoldTotal BIGINT					-- �������
DECLARE @GameTax DECIMAL					-- ��Ϸ˰��
DECLARE @RMBRate INT						-- RMB��ƽ̨�ҵĶһ�����
DECLARE @CurrencyRate INT					-- ƽ̨������Ϸ�ҵı���

DECLARE @CurrentTime DATETIME				-- ��ǰʱ��

-- ִ���߼�
BEGIN
	SET @CurrentTime=GETDATE()
	
	-- ���û���
	SELECT @UserTotal=COUNT(UserID) FROM AccountsInfo WHERE IsAndroid=0
	
	-- ����ע���û���
	SELECT @CurrentMonthRegUserCounts=Sum(WebRegisterSuccess+GameRegisterSuccess) FROM SystemStreamInfo 
	WHERE CONVERT(char(7),CollectDate,120)=CONVERT(char(7),@CurrentTime,120)
	
	-- ��ע�����ֵ
	SELECT @MaxUserRegCounts=MAX(WebRegisterSuccess+GameRegisterSuccess) FROM SystemStreamInfo	
	
	-- ƽ������ʱ��
	SELECT @UserAVGOnlineTime=AVG(CONVERT(BIGINT,OnLineTimeCount)) FROM AccountsInfo WHERE IsAndroid=0
	
	-- ��Ծ�û���
	SELECT @ActiveUserCounts=COUNT(UserID) FROM RYTreasureDBLink.RYTreasureDB.dbo.StreamScoreInfo 
	WHERE DateID= CAST(CAST(@CurrentTime AS FLOAT) AS INT) AND OnlineTimeCount>=60*60 
	AND UserID NOT IN(SELECT UserID FROM AccountsInfo WHERE IsAndroid=1)
	
	-- ��ʧ�û���
	SELECT @LossUserCounts=Count(UserID) FROM AccountsInfo 
	WHERE LastLogonDate<DATEADD(mm,-1,Convert(varchar(10),@CurrentTime,120)) AND IsAndroid=0
	
	-- ����ܳ�ֵ���
	SELECT @PayMaxAmount=MAX(PayAmount),@PayTotalAmount=SUM(PayAmount) FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo
	
	-- ��ֵ���ҵĳ�ֵ���
	SELECT @PayCurrencyAmount=MAX(PayAmount),@PayTotalAmount=SUM(PayAmount) FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo
	
	-- ���ճ�ֵ��߶��
	SELECT @CurrentDateMaxAmount=ISNULL(0,Max(PayAmount)) FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo 
	WHERE ApplyDate>=CONVERT(VARCHAR(10),@CurrentTime,120) AND ApplyDate<DATEADD(dd,1,Convert(varchar(10),@CurrentTime,120))
	
	-- ��ֵ������
	SELECT @PayUserCounts=COUNT(UserID) FROM (SELECT UserID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo GROUP BY UserID) AS A
	
	-- ���γ�ֵ���
	SELECT @PayTwoUserCounts=COUNT(Total) FROM (SELECT COUNT(UserID) AS Total 
	FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo GROUP BY UserID) AS A WHERE Total>1
	
	-- ��ֵ�������
	--SELECT TOP 1 @MaxShareID=ShareID FROM THTreasureDBLink.THTreasureDB.dbo.ShareCollectInfo 
	--GROUP BY ShareID ORDER BY Sum(StatSellCash) DESC
	
	-- ��ֵ�û���ʧ��
	SELECT @PayUserOutflowTotal=Count(UserID) FROM AccountsInfo 
	WHERE UserID IN(SELECT USERID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo) 
	AND LastLogonDate<DATEADD(mm,-1,Convert(varchar(10),GetDate(),120)) AND IsAndroid=0
	
	-- ��ֵ��
	SELECT @VIPPayUserTotal=COUNT(UserID) 
	FROM (SELECT UserID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo GROUP BY UserID HAVING SUM(PayAmount)>=2000  ) AS A
	
	-- �������
	SELECT @GoldTotal=SUM(Score+InsureScore) 
	FROM RYTreasureDBLink.RYTreasureDB.dbo.GameScoreInfo 
	WHERE UserID NOT IN (SELECT UserID FROM AccountsInfo WHERE IsAndroid=1)
	
	-- ƽ̨������
	SELECT @CurrencyTotal=SUM(Currency) FROM RYTreasureDBLink.RYTreasureDB.dbo.UserCurrencyInfo

	-- �һ�����
	SELECT @RMBRate=StatusValue FROM SystemStatusInfo WHERE StatusName='RateCurrency'
	SELECT @CurrencyRate=StatusValue FROM SystemStatusInfo WHERE StatusName='RateGold'
	
	-- ˰��
	SELECT @GameTax=SUM(Revenue) FROM RYTreasureDBLink.RYTreasureDB.dbo.StreamScoreInfo
	
	-- ��Ĭ��ֵ
	IF @MaxUserRegCounts IS NULL
		SET @MaxUserRegCounts=0
	IF @UserAVGOnlineTime IS NULL 
		SET @UserAVGOnlineTime=0
	IF @PayMaxAmount IS NULL
		SET @PayMaxAmount=0
	IF @PayTotalAmount IS NULL
		SET @PayTotalAmount=0
	IF @PayCurrencyAmount IS NULL
		SET @PayCurrencyAmount=0
	IF @CurrentDateMaxAmount IS NULL 
		SET @CurrentDateMaxAmount=0
	IF @GoldTotal IS NULL
		SET @GoldTotal=0
	IF @CurrencyTotal IS NULL
		SET @CurrencyTotal=0
	IF @RMBRate IS NULL
		SET @RMBRate=0
	IF @CurrencyRate IS NULL
		SET @CurrencyRate=0
	IF @GameTax IS NULL
		SET @GameTax=0
	IF @MaxShareID IS NULL
		SET @MaxShareID=0
	IF @CurrentMonthRegUserCounts IS NULL
		SET @CurrentMonthRegUserCounts=0

	-- ��������
	SELECT @UserTotal AS UserTotal,@CurrentMonthRegUserCounts AS CurrentMonthRegUserCounts,@MaxUserRegCounts AS MaxUserRegCounts,
		@UserAVGOnlineTime AS UserAVGOnlineTime,@ActiveUserCounts AS ActiveUserCounts,@LossUserCounts AS LossUserCounts,
		@PayMaxAmount AS PayMaxAmount,@CurrentDateMaxAmount AS CurrentDateMaxAmount,@PayUserCounts AS PayUserCounts,
		@PayTotalAmount AS PayTotalAmount,@PayCurrencyAmount AS PayCurrencyAmount,@CurrentDateMaxAmount AS CurrentDateMaxAmount,
		@CurrentDateMaxAmount AS CurrentDateMaxAmount,@PayUserCounts AS PayUserCounts,@PayTwoUserCounts AS PayTwoUserCounts,
		@PayTwoUserCounts AS PayTwoUserCounts,@MaxShareID AS MaxShareID,@PayUserOutflowTotal AS PayUserOutflowTotal,
		@VIPPayUserTotal AS VIPPayUserTotal,@GoldTotal AS GoldTotal,@CurrencyTotal AS CurrencyTotal,@RMBRate AS RMBRate,
		@CurrencyRate AS CurrencyRate,@GameTax AS GameTax
END
GO