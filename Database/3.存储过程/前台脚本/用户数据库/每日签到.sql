
----------------------------------------------------------------------------------------------------

USE RYAccountsDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PW_Signin]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PW_Signin]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------

-- ��ѯ����
CREATE PROC NET_PW_Signin
	@dwUserID INT,								-- �û� I D
	@strClientIP NVARCHAR(15),					-- �ͻ���IP
	@strErrorDescribe NVARCHAR(127) OUTPUT		-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ִ���߼�
BEGIN
	-- ��ѯ�û�
	IF NOT EXISTS(SELECT UserID FROM AccountsInfo WHERE UserID=@dwUserID)
	BEGIN
		SET @strErrorDescribe = N'��Ǹ���û������ڣ�'
		RETURN 1
	END

	-- ǩ����¼
	DECLARE @SeriesDate INT	
	DECLARE @StartDateTime DateTime
	DECLARE @LastDateTime DateTime
	SELECT @StartDateTime=StartDateTime,@LastDateTime=LastDateTime,@SeriesDate=SeriesDate FROM AccountsSignin 
	WHERE UserID=@dwUserID
	IF @StartDateTime IS NULL OR @LastDateTime IS NULL OR @SeriesDate IS NULL
	BEGIN
		SELECT @StartDateTime=GETDATE(),@LastDateTime=GETDATE(),@SeriesDate=0
		INSERT INTO AccountsSignin VALUES(@dwUserID,@StartDateTime,@LastDateTime,0)		
	END

	-- ǩ���ж�
	IF DATEDIFF(dd,@LastDateTime,GETDATE())=0 AND @SeriesDate > 0
	BEGIN
		SET @strErrorDescribe=N'��Ǹ���������Ѿ�ǩ���ˣ�'
		RETURN 3		
	END

	-- ����Խ��
	IF @SeriesDate>7
	BEGIN
		SET @strErrorDescribe=N'����ǩ����Ϣ�����쳣���������ǵĿͷ���Ա��ϵ��'
		RETURN 2				
	END

	-- ���¼�¼
	SET @SeriesDate=@SeriesDate+1
	UPDATE AccountsSignin SET LastDateTime=GETDATE(),SeriesDate=@SeriesDate WHERE UserID=@dwUserID

	-- ��ѯ����
	DECLARE @RewardGold BIGINT
	SELECT @RewardGold=RewardGold FROM RYPlatformDBLink.RYPlatformDB.dbo.SigninConfig WHERE DayID=@SeriesDate
	IF @RewardGold IS NULL 
	BEGIN
		SET @RewardGold=0
	END	

	-- �������	
	UPDATE RYTreasureDBLink.RYTreasureDB.dbo.GameScoreInfo SET Score=Score+@RewardGold WHERE UserID=@dwUserID
	IF @@ROWCOUNT=0
	BEGIN	
		INSERT INTO RYTreasureDBLink.RYTreasureDB.dbo.GameScoreInfo(UserID,Score,LastLogonIP,LastLogonMachine,RegisterIP,RegisterMachine)
		VALUES(@dwUserID,@RewardGold,@strClientIP,'',@strClientIP,'')
	END

	-- д���¼
	INSERT INTO RYRecordDBLink.RYRecordDB.dbo.RecordSignin(UserID,RewardGold,ClientID,InputDate) 
	VALUES(@dwUserID,@RewardGold,@strClientIP,GETDATE())
END

RETURN 0

GO

----------------------------------------------------------------------------------------------------