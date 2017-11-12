
----------------------------------------------------------------------------------------------------

USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PW_LotteryUserInfo]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PW_LotteryUserInfo]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PW_LotteryStart]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PW_LotteryStart]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------
-- ���ؽ���
CREATE PROC NET_PW_LotteryUserInfo
	@dwUserID INT,								-- �û���ʶ
	@strLogonPass NCHAR(32),					-- �û�����
	@strErrorDescribe NVARCHAR(127) OUTPUT		-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

DECLARE @nAlreadyCount INT
DECLARE @nFreeCount INT
DECLARE @nChargeFee INT

-- ִ���߼�
BEGIN

	DECLARE @strPassword NCHAR(32)
	SELECT @strPassword=LogonPass FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=@dwUserID
	IF @strPassword IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�����ĸ�����Ϣ�����쳣���齱���ò�ѯʧ�ܣ�'
		RETURN 1
	END

	IF @strPassword<>@strLogonPass
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�����ĵ�¼���벻��ȷ���齱���ò�ѯʧ�ܣ�'
		RETURN 2
	END

	DECLARE @DateID INT
	SET @DateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)

	-- ����������Ѵ���
	SELECT @nAlreadyCount=COUNT(*) FROM RYRecordDBLink.RYRecordDB.dbo.RecordLottery 
	WHERE UserID=@dwUserID AND ChargeFee=0 AND DATEDIFF(DAY,CollectDate,GETDATE())=0

	SELECT @nFreeCount=Field1,@nChargeFee=Field2 FROM RYNativeWebDBLink.RYNativeWebDB.dbo.ConfigInfo WHERE ConfigKey='LotteryConfig'
	IF @nFreeCount IS NULL
	BEGIN
		SET @nFreeCount=3
		SET @nChargeFee=600
	END

	SELECT @nFreeCount AS FreeCount, @nChargeFee AS ChargeFee, @nAlreadyCount AS AlreadyCount

END

RETURN 0

GO

----------------------------------------------------------------------------------------------------
-- �齱��ʼ
CREATE PROC NET_PW_LotteryStart
	@dwUserID INT,								-- �û���ʶ
	@strLogonPass NCHAR(32),					-- �û�����
	@strClientIP NVARCHAR(15),					-- ���ӵ�ַ	
	@strErrorDescribe NVARCHAR(127) OUTPUT		-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

DECLARE @nWined INT
DECLARE @nWinItemIndex INT
DECLARE @nWinItemType INT
DECLARE @nWinItemQuota INT
DECLARE @Score INT
DECLARE @Currency DECIMAL(18,2)

-- ִ���߼�
BEGIN

	DECLARE @strPassword NCHAR(32)
	SELECT @strPassword=LogonPass FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=@dwUserID
	IF @strPassword IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�����ĸ�����Ϣ�����쳣���齱ʧ�ܣ�'
		RETURN 1
	END

	IF @strPassword<>@strLogonPass
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�����ĵ�¼���벻��ȷ���齱ʧ�ܣ�'
		RETURN 2
	END

	--��������
	DECLARE @nAlreadyCount INT
	DECLARE @nUserChargeFee INT
	DECLARE @nFreeCount INT
	DECLARE @nChargeFee INT
	DECLARE @IsCharge TINYINT
	DECLARE @nItemCount INT	

	-- ����������Ѵ���
	SELECT @nAlreadyCount=COUNT(*) FROM RYRecordDBLink.RYRecordDB.dbo.RecordLottery 
	WHERE UserID=@dwUserID AND ChargeFee=0 AND DATEDIFF(DAY,CollectDate,GETDATE())=0

	-- �ܹ���Ѵ���
	SELECT @nFreeCount=FreeCount,@nChargeFee=ChargeFee,@IsCharge=IsCharge FROM LotteryConfig WHERE ID=1
	IF @nFreeCount IS NULL
	BEGIN
		SET @nFreeCount=3
		SET @nChargeFee=600
		SET @IsCharge=0
	END

	IF @IsCharge=0 -- �������ѳ齱
	BEGIN
		IF @nAlreadyCount>=@nFreeCount
		BEGIN
			SET @strErrorDescribe=N'��Ǹ�������յ���Ѵ����Ѿ����꣬���ܼ�������齱��'
			RETURN 3
		END
		ELSE
		BEGIN
			SET @nUserChargeFee=0
		END
	END
	ELSE -- �����ѳ齱
	BEGIN		
		IF @nAlreadyCount>=@nFreeCount SET @nUserChargeFee=@nChargeFee
		ELSE SET @nUserChargeFee=0
	END

	-- ��Ϸ��
	SELECT @Score=Score FROM GameScoreInfo WHERE UserID=@dwUserID
	IF @Score IS NULL SET @Score=0
	IF @nUserChargeFee>@Score
	BEGIN
		SET @strErrorDescribe=N'��Ǹ��������Ϸ�Ҳ��������ܲ���齱�����ֵ���ٴγ��ԣ�'
		RETURN 3
	END

	-- ��������
	SELECT @nItemCount=Count(*) FROM LotteryItem

	----------------------------------------------------------------------------------------------------
	-- ȫ�ֱ�����ʼ��
	SET @nWined=0
	SET @nWinItemIndex=0
	SET @nWinItemType=0
	SET @nWinItemQuota=0

	-- ��ʱ����
	DECLARE @nItemIndex INT
	DECLARE @nItemType INT
	DECLARE @nItemQuota INT
	DECLARE @nItemRate INT
	DECLARE @nTotalRate INT
	DECLARE @nRandData INT
	
	-- ��ʱ������ʼ��
	SET @nItemIndex=0
	SET @nItemType=0
	SET @nItemQuota=0
	SET @nItemRate=0
	SET @nTotalRate=0
	SET @nRandData=CAST(FLOOR(RAND()*100) AS INT)

	IF @nItemCount>0
	BEGIN
		-- ��ʱ����
		DECLARE @nIndex INT
		SET @nIndex=1

		-- ѭ���ж��н���
		WHILE @nIndex<=@nItemCount
		BEGIN
			SELECT @nItemIndex=ItemIndex, @nItemType=ItemType, @nItemQuota=ItemQuota, @nItemRate=ItemRate FROM LotteryItem WHERE ItemIndex=@nIndex
				
			IF @nItemType IS NULL BREAK

			IF @nRandData>=@nTotalRate AND @nRandData<@nTotalRate+@nItemRate
			BEGIN
				SET @nWinItemIndex=@nItemIndex
				SET @nWinItemType=@nItemType
				SET @nWinItemQuota=@nItemQuota
				BREAK		
			END
			ELSE
			BEGIN
				SET @nTotalRate=@nTotalRate+@nItemRate
				SET @nIndex=@nIndex+1
			END
		END
	END
	----------------------------------------------------------------------------------------------------

	-- ����н�
	IF @nWinItemIndex>0
	BEGIN
		SET @nWined=1

		-- �۳��齱����
		IF @nUserChargeFee>0
		BEGIN
			SET @Score=@Score-@nUserChargeFee;
		END

		-- ��������
		IF @nWinItemQuota>0
		BEGIN
			-- ˢ����Ϸ��
			IF @nWinItemType=0
			BEGIN
				UPDATE GameScoreInfo SET Score=@Score+@nWinItemQuota WHERE UserID=@dwUserID
				IF @@ROWCOUNT=0
				BEGIN
					INSERT INTO GameScoreInfo(UserID,Score,LastLogonIP,RegisterIP)
					VALUES(@dwUserID,@nWinItemQuota,@strClientIP,@strClientIP)
				END
			END
			
			-- ˢ����Ϸ��
			IF @nWinItemType=1
			BEGIN
				UPDATE UserCurrencyInfo SET Currency=Currency+@nWinItemQuota WHERE UserID=@dwUserID
				IF @@ROWCOUNT=0
				BEGIN
					INSERT INTO UserCurrencyInfo(UserID,Currency)
					VALUES (@dwUserID,@nWinItemQuota)
				END
			END
		END

		-- �齱��¼
		INSERT INTO RYRecordDBLink.RYRecordDB.dbo.RecordLottery(UserID,ChargeFee,ItemIndex,ItemType,ItemQuota)
		VALUES (@dwUserID,@nUserChargeFee,@nWinItemIndex,@nWinItemType,@nWinItemQuota)
	END

	-- ˢ�²Ƹ�
	SELECT @Score=Score FROM GameScoreInfo WHERE UserID=@dwUserID
	SELECT @Currency=Currency FROM UserCurrencyInfo WHERE UserID=@dwUserID

	-- ��ѯ����
	SELECT @nWined AS Wined, @nWinItemIndex AS ItemIndex, @nWinItemType AS ItemType, @nWinItemQuota AS ItemQuota, 
			@Score AS Score, @Currency AS Currency

END

RETURN 0

GO

----------------------------------------------------------------------------------------------------