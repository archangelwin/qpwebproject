----------------------------------------------------------------------
-- �汾��2013
-- ʱ�䣺2013-04-22
-- ��;����ҷֲ�
----------------------------------------------------------------------
USE [RYTreasureDB]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_AnalGoldDistribution]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_AnalGoldDistribution]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_AnalGoldDistribution]

WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ��������û���
DECLARE	@ZeroNumber INT				-- С��10,000�����
DECLARE @OneNumber INT				-- 10,000��100,000֮�������
DECLARE @TwoNumber INT				-- 100,000��500,000֮�������
DECLARE @ThreeNumber INT			-- 500,000��1,000,000֮�������
DECLARE @FourNumber INT				-- 1,000,000��5,000,000֮�������
DECLARE @FiveNumber INT				-- 5,000,000��10,000,000֮�������
DECLARE @SixNumber INT				-- 10,000,000��30,000,000֮�������
DECLARE @SevenNumber INT			-- ����30,000,000�����
DECLARE @UserCount INT				-- �û�����

-- ϵͳ������Ϣ
DECLARE @PayAmountTotal BIGINT		-- ��ֵRMB����
DECLARE @CurrencyTotal BIGINT		-- ƽ̨������
DECLARE @GoldTotal BIGINT			-- �������
DECLARE @RMBRate INT				-- RMB��ƽ̨�ҵĶһ�����
DECLARE @CurrencyRate INT			-- ƽ̨������Ϸ�ҵı���

-- ִ���߼�
BEGIN
	-- ��ҷֲ�
	SET @ZeroNumber=0
	SET @OneNumber=0
	SET @TwoNumber=0
	SET @ThreeNumber=0
	SET @FourNumber=0
	SET @FiveNumber=0
	SET @SixNumber=0
	SET @SevenNumber=0
	SET @UserCount=0
	
	-- �������ֲ���
	SELECT @ZeroNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore<10000 
	SELECT @OneNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=10000 AND Score+InsureScore<100000
	SELECT @TwoNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=100000 AND Score+InsureScore<500000
	SELECT @ThreeNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=500000 AND Score+InsureScore<1000000
	SELECT @FourNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=1000000 AND Score+InsureScore<5000000
	SELECT @FiveNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=5000000 AND Score+InsureScore<10000000
	SELECT @SixNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=10000000 AND Score+InsureScore<30000000
	SELECT @SevenNumber=Count(*) FROM GameScoreInfo WHERE Score+InsureScore>=30000000
	
	-- ��ֵRMB����
	SELECT @PayAmountTotal=SUM(PayAmount) FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo
	
	-- �������
	SELECT @GoldTotal=SUM(Score+InsureScore) FROM GameScoreInfo 
	WHERE UserID NOT IN(SELECT UserID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE IsAndroid=1)
	
	-- ƽ̨������
	SELECT @CurrencyTotal=ISNULL(SUM(Currency),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.UserCurrencyInfo 
	WHERE UserID NOT IN(SELECT UserID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE IsAndroid=1)
	 	
	-- �û�����
	SET @UserCount=@ZeroNumber+@OneNumber+@TwoNumber+@ThreeNumber+@FourNumber+@FiveNumber+@SixNumber+@SevenNumber
	
	-- ���طֲ�
	SELECT @ZeroNumber AS ZeroNumber,@OneNumber AS OneNumber,@TwoNumber AS TwoNumber,@ThreeNumber AS ThreeNumber,
		@FourNumber AS FourNumber,@FiveNumber AS FiveNumber,@SixNumber AS SixNumber,@SevenNumber AS SevenNumber,@UserCount AS UserCount
		
	-- ��Ĭ��ֵ
	IF @PayAmountTotal IS NULL
		SET @PayAmountTotal=0
	IF @GoldTotal IS NULL
		SET @GoldTotal=0
	IF @CurrencyTotal IS NULL
		SET @CurrencyTotal=0
	
	-- �һ�����
	--SELECT @RMBRate=Field1,@CurrencyRate=Field3 FROM UCPlatformDBLink.UCPlatformDB.dbo.SystemConfigInfo WHERE ConfigKey='PayConfig'
	SELECT @RMBRate=StatusValue FROM RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='RateCurrency'
	SELECT @CurrencyRate=StatusValue FROM RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='RateGold'
	-- ���ز���
	SELECT @PayAmountTotal AS PayAmountTotal,@CurrencyTotal AS CurrencyTotal,@GoldTotal AS GoldTotal,@RMBRate AS RMBRate,@CurrencyRate AS CurrencyRate

END
GO

