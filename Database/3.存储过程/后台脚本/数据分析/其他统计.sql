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

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_UsersNumberStat]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_UsersNumberStat]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_UsersNumberStat]
			
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON
DECLARE @UserTotal INT						-- ���û���
DECLARE @CurrentMonthRegUserCounts INT		-- ����ע���û���
DECLARE @MaxUserRegCounts INT				-- ��ע�����ֵ
DECLARE @UserAVGOnlineTime INT				-- �û�ƽ������ʱ��
DECLARE @ActiveUserCounts INT				-- ��Ծ�û���
DECLARE @LossUserCounts INT					-- ��ʧ�û���
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

	-- ��Ĭ��ֵ
	IF @MaxUserRegCounts IS NULL
		SET @MaxUserRegCounts=0
	IF @CurrentMonthRegUserCounts IS NULL
		SET @CurrentMonthRegUserCounts=0

	-- ��������
	SELECT @UserTotal AS UserTotal,@CurrentMonthRegUserCounts AS CurrentMonthRegUserCounts,@MaxUserRegCounts AS MaxUserRegCounts,
	@UserAVGOnlineTime AS UserAVGOnlineTime,@ActiveUserCounts AS ActiveUserCounts,@LossUserCounts AS LossUserCounts
END
GO