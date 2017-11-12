----------------------------------------------------------------------
-- �汾��2013
-- ʱ�䣺2013-04-22
-- ��;��ͳ��ÿ�����ݣ�ÿ���賿4���Զ�ͳ��
----------------------------------------------------------------------
USE [RYRecordDB]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PJ_AnalEveryDayDataStat]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PJ_AnalEveryDayDataStat]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PJ_AnalEveryDayDataStat]
			
WITH ENCRYPTION AS

-- ��������
DECLARE @UserTotal INT					-- �û�����
DECLARE @PayUserTotal INT				-- ��ֵ���
DECLARE @ActiveUserTotal INT			-- ��Ծ���
DECLARE @LossUser INT					-- ������ʧ���
DECLARE @LossUserTotal INT				-- �����ʧ����
DECLARE @LossPayUser INT				-- ���ճ�ֵ�����ʧ
DECLARE @LossPayUserTotal INT			-- ��ֵ�����ʧ����
DECLARE @PayAmountTotal BIGINT			-- ��ֵRMB����
DECLARE @PayAmountForCurrency BIGINT	-- ��ֵƽ̨��RMB����
DECLARE @CurrencyTotal BIGINT			-- ƽ̨������
DECLARE @GoldTotal BIGINT				-- �������
DECLARE @UserAVGOnlineTime BIGINT		-- ƽ��ʱ��
DECLARE @GameTax BIGINT					-- ������Ϸ˰��
DECLARE @GameTaxTotal BIGINT			-- ��Ϸ��˰��
DECLARE @BankTax BIGINT					-- ��������˰��
DECLARE @Waste BIGINT					-- ������Ϸ���

DECLARE @DateID INT						-- ͳ������ID
DECLARE @StatsStartTime DATETIME		-- ͳ���տ�ʼʱ��
DECLARE @StatsEndTime DATETIME			-- ͳ���ս���ʱ��

-- ִ���߼�
BEGIN
	SET @StatsEndTime=CONVERT(VARCHAR(10),GETDATE(),23)
	SET @StatsStartTime=CONVERT(VARCHAR(10),GETDATE()-1,23) 
	SET @DateID=CAST(CAST(GETDATE()-1 AS FLOAT) AS INT)
	
	-- �û�����
	SELECT @UserTotal=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE IsAndroid=0 AND RegisterDate<@StatsEndTime
	
	-- ��ֵ�������
	SELECT @PayUserTotal=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE UserID IN (SELECT UserID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo 
	WHERE ApplyDate<@StatsEndTime)
	
	-- ��Ծ�����
	SELECT @ActiveUserTotal=COUNT(UserID) FROM RYTreasureDBLink.RYTreasureDB.dbo.StreamScoreInfo 
	WHERE DateID=@DateID AND OnlineTimeCount>=60*60
	
	-- �����ʧ��
	SELECT @LossUserTotal=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE LastLogonDate<DATEADD(mm,-1,@StatsEndTime) AND IsAndroid=0

	SELECT @LossUser=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE LastLogonDate<DATEADD(mm,-1,@StatsEndTime) AND LastLogonDate>=DATEADD(mm,-1,@StatsStartTime) AND IsAndroid=0

	SELECT @LossPayUserTotal=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE UserID IN (SELECT UserID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo) 
	AND LastLogonDate<DATEADD(mm,-1,@StatsEndTime) AND IsAndroid=0
	
	SELECT @LossPayUser=COUNT(UserID) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE UserID IN (SELECT UserID FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo) 
	AND LastLogonDate<DATEADD(mm,-1,@StatsEndTime) AND LastLogonDate>=DATEADD(mm,-1,@StatsStartTime) AND IsAndroid=0

	-- ��ֵ����
	SELECT @PayAmountTotal= ISNULL(SUM(PayAmount),0) 
	FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo WHERE ApplyDate<@StatsEndTime
	SELECT @PayAmountForCurrency=ISNULL(SUM(PayAmount),0) 
	FROM RYTreasureDBLink.RYTreasureDB.dbo.ShareDetailInfo WHERE ApplyDate<@StatsEndTime
	
	-- �������
	SELECT @GoldTotal=ISNULL(SUM(Score+InsureScore),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.GameScoreInfo
	
	-- ��������
	SELECT @CurrencyTotal=ISNULL(SUM(Currency),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.UserCurrencyInfo
	WHERE UserID NOT IN (SELECT UserID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE IsAndroid=1)

	-- ƽ��ʱ��
	SELECT @UserAVGOnlineTime=ISNULL(AVG(CONVERT(BIGINT,OnLineTimeCount)),0) 
	FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE IsAndroid=0

	-- ��Ϸ˰������
	SELECT @GameTaxTotal=ISNULL(SUM(Revenue),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.StreamScoreInfo 
	WHERE DateID<=@DateID

	-- ������Ϸ˰�պ����
	SELECT @GameTax=ISNULL(SUM(Revenue),0),@Waste=ISNULL(SUM(Waste),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.RecordDrawInfo
	WHERE ConcludeTime<@StatsEndTime AND ConcludeTime>=@StatsStartTime

	-- ��������˰��
	SELECT @BankTax=ISNULL(SUM(Revenue),0) FROM RYTreasureDBLink.RYTreasureDB.dbo.RecordInsure
	WHERE CollectDate<@StatsEndTime AND CollectDate>=@StatsStartTime

	BEGIN TRY

		-- ÿ�ջ�������
		IF NOT EXISTS(SELECT DateID FROM RecordEveryDayData WHERE DateID=@DateID)
		BEGIN
			INSERT INTO RecordEveryDayData(DateID,UserTotal,PayUserTotal,ActiveUserTotal,LossUser,LossUserTotal,LossPayUser,LossPayUserTotal,
				PayTotalAmount,PayAmountForCurrency,GoldTotal,CurrencyTotal,GameTax,GameTaxTotal,BankTax,Waste,UserAVGOnlineTime,CollectDate)
			VALUES(@DateID,@UserTotal,@PayUserTotal,@ActiveUserTotal,@LossUser,@LossUserTotal,@LossPayUser,@LossPayUserTotal,@PayAmountTotal,
				@PayAmountForCurrency,@GoldTotal,@CurrencyTotal,@GameTax,@GameTaxTotal,@BankTax,@Waste,@UserAVGOnlineTime,GETDATE())
		END
		
		-- ��������
		IF NOT EXISTS(SELECT DateID FROM RecordEveryDayRoomData WHERE DateID=@DateID)
		BEGIN
			-- ����Ϸ��¼ͳ�Ʒ�������
			INSERT INTO RecordEveryDayRoomData
			SELECT @DateID AS DateID,KindID,ServerID,SUM(Waste) AS Waste,SUM(Revenue) AS Revenue,SUM(UserMedal) AS UserMedal,GETDATE() 
			FROM RYTreasureDBLink.RYTreasureDB.dbo.RecordDrawInfo 
			WHERE ConcludeTime>=@StatsStartTime AND ConcludeTime<@StatsEndTime
			GROUP BY KindID,ServerID

			-- ��������Ϸ��¼�ķ���
			INSERT INTO RecordEveryDayRoomData 
			SELECT @DateID AS DateID,GameID,ServerID,0,0,0,GETDATE() 
			FROM RYPlatformDBLink.RYPlatformDB.dbo.GameRoomInfo
			WHERE ServerID NOT IN(SELECT ServerID FROM RecordEveryDayRoomData WHERE DateID=@DateID)
		END
	END TRY
	BEGIN CATCH
		DELETE RecordEveryDayData WHERE DateID=@DateID
		DELETE RecordEveryDayRoomData WHERE DateID=@DateID
	END CATCH
	
	RETURN 0
END
GO

