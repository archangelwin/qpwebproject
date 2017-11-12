----------------------------------------------------------------------
-- ��Ȩ��2011
-- ʱ�䣺2011-09-1
-- ��;��ʵ����ֵ
----------------------------------------------------------------------

USE [RYTreasureDB]
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_FilledLivcard') AND OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_FilledLivcard
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------
-- ʵ����ֵ
CREATE PROC NET_PW_FilledLivcard
	@dwOperUserID		INT,						--	�����û�

	@strSerialID		NVARCHAR(32),				--	��Ա����
	@strPassword		NCHAR(32),					--	��Ա����	
	@strAccounts		NVARCHAR(31),				--	��ֵ����ʺ�

	@strClientIP		NVARCHAR(15),				--	��ֵ��ַ
	@strErrorDescribe	NVARCHAR(127) OUTPUT		--	�����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ʵ����Ϣ
DECLARE @CardID INT
DECLARE @SerialID NVARCHAR(15)
DECLARE @Password NCHAR(32)
DECLARE @CardTypeID INT
DECLARE @CardPrice DECIMAL(18,2)
DECLARE @Currency INT
DECLARE @ValidDate DATETIME
DECLARE @ApplyDate DATETIME
DECLARE @UseRange INT

-- �ʺ�����
DECLARE @Accounts NVARCHAR(31)
DECLARE @GameID INT
DECLARE @UserID INT
DECLARE @SpreaderID INT
DECLARE @Nullity TINYINT
DECLARE @StunDown TINYINT
DECLARE @WebLogonTimes INT
DECLARE @GameLogonTimes INT
DECLARE @BeforeCurrency DECIMAL(18,2)

-- ִ���߼�
BEGIN
	DECLARE @ShareID INT
	SET @ShareID=1		-- 1 ʵ��
	
	-- ���Ų�ѯ
	SELECT	@CardID=CardID,@SerialID=SerialID,@Password=[Password],@CardTypeID=CardTypeID,
			@CardPrice=CardPrice,@Currency=Currency,@ValidDate=ValidDate,@ApplyDate=ApplyDate,
			@UseRange=UseRange,@Nullity=Nullity
	FROM LivcardAssociator WHERE SerialID = @strSerialID

	-- ��֤����Ϣ
	IF @CardID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ�Ŀ��Ų����ڡ�������������ϵ�ͷ����ġ�'
		RETURN 101
	END	

	IF @strPassword=N'' OR @strPassword IS NULL OR @Password<>@strPassword
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����ֵʧ�ܣ����鿨�Ż������Ƿ���д��ȷ��������������ϵ�ͷ����ġ�'
		RETURN 102
	END

	IF @ApplyDate IS NOT NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ���ó�ֵ���ѱ�ʹ�ã��뻻һ�����ԡ�������������ϵ�ͷ����ġ�'
		RETURN 103
	END

	IF @Nullity=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ���û�Ա���ѱ����á�'
		RETURN 104
	END

	IF @ValidDate < GETDATE()
	BEGIN
		SET @strErrorDescribe=N'��Ǹ���û�Ա���Ѿ����ڡ�'
		RETURN 105
	END
	
	-- ��֤�û�
	SELECT @UserID=UserID,@GameID=GameID,@Accounts=Accounts,@Nullity=Nullity,@StunDown=StunDown,@SpreaderID=SpreaderID,
		   @WebLogonTimes=WebLogonTimes,@GameLogonTimes=GameLogonTimes
	FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo
	WHERE Accounts=@strAccounts

	IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ���û��˺Ų����ڡ�'
		RETURN 201
	END

	IF @Nullity=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ���û��˺���ʱ���ڶ���״̬������ϵ�ͻ����������˽���ϸ�����'
		RETURN 202
	END

	IF @StunDown<>0
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ���û��˺�ʹ���˰�ȫ�رչ��ܣ��������¿�ͨ����ܼ���ʹ�á�'
		RETURN 203
	END

	-- ʵ��ʹ�÷�Χ
	-- ��ע���û�
	IF @UseRange = 1
	BEGIN
		IF @WebLogonTimes+@GameLogonTimes>1
		BEGIN
			SET @strErrorDescribe=N'��Ǹ���û�Ա��ֻ�ʺ���ע����û�ʹ�á�'
			RETURN 301
		END 
	END
	-- ��һ�γ�ֵ�û�
	IF @UseRange = 2
	BEGIN
		DECLARE @FILLCOUNT INT
		SELECT @FillCount=COUNT(USERID) FROM ShareDetailInfo WHERE UserID=@UserID
		IF @FillCount>0
		BEGIN
			SET @strErrorDescribe=N'��Ǹ���û�Ա��ֻ�ʺϵ�һ�γ�ֵ���û�ʹ�á�'
			RETURN 302
		END
	END

	-- ��ֵ����
	SELECT @BeforeCurrency=Currency FROM UserCurrencyInfo WHERE UserID=@UserID
	IF @BeforeCurrency IS NULL
		SET @BeforeCurrency=0

	UPDATE UserCurrencyInfo SET Currency=Currency+@Currency WHERE UserID=@UserID
	IF @@ROWCOUNT=0
	BEGIN
		INSERT UserCurrencyInfo(UserID,Currency) VALUES(@UserID,@Currency)
	END
	--------------------------------------------------------------------------------

	-- �ƹ�ϵͳ&����ϵͳ
	IF @SpreaderID<>0
	BEGIN
		-- �������ҵĻ���
		DECLARE @GoldRate INT
		SELECT @GoldRate=StatusValue FROM RYAccountsDBLink.RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='RateGold'
		IF @GoldRate=0 OR @GoldRate IS NULL
			SET @GoldRate=1

		-- ����ϵͳ
		DECLARE @AgentUserID INT
		DECLARE @AgentType INT
		DECLARE @AgentScale DECIMAL(18,3)
		DECLARE @PayScore BIGINT
		DECLARE @AgentScore BIGINT
		DECLARE @AgentDateID INT	
		SELECT @AgentUserID=UserID,@AgentType=AgentType,@AgentScale=AgentScale FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsAgent WHERE UserID=@SpreaderID AND Nullity=0
		IF @AgentUserID IS NOT NULL
		BEGIN
			IF @AgentType=1 -- ��ֵ�ֳ�
			BEGIN
				-- ��ֵ��Ҽ���
				SET @PayScore=@Currency*@GoldRate
				SET @AgentScore=@PayScore*@AgentScale
				SET @AgentDateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)	
				-- �����ֳɼ�¼
				INSERT INTO RecordAgentInfo(DateID,UserID,AgentScale,TypeID,PayScore,Score,ChildrenID,CollectIP) VALUES(@AgentDateID,@AgentUserID,@AgentScale,1,@PayScore,@AgentScore,@UserID,@strClientIP)
				-- ������ͳ��
				UPDATE StreamAgentPayInfo SET PayAmount=PayAmount+@CardPrice,Currency=Currency+@Currency,PayScore=PayScore+@PayScore,LastCollectDate=GETDATE() WHERE DateID=@AgentDateID AND UserID=@AgentUserID
				IF @@ROWCOUNT=0
				BEGIN
					INSERT INTO StreamAgentPayInfo(DateID,UserID,PayAmount,Currency,PayScore) VALUES(@AgentDateID,@AgentUserID,@CardPrice,@Currency,@PayScore)
				END
			END
		END
		ELSE
		BEGIN
			-- �ƹ�ϵͳ
			DECLARE @Rate DECIMAL(18,2)
			DECLARE @GrantScore BIGINT
			DECLARE @Note NVARCHAR(512)
			SELECT @Rate=FillGrantRate FROM GlobalSpreadInfo
			IF @Rate IS NULL
			BEGIN
				SET @Rate=0.1
			END		

			SET @GrantScore = @Currency*@Rate*@GoldRate
			SET @Note = N'��ֵ'+LTRIM(STR(@CardPrice))+'Ԫ'
			INSERT INTO RecordSpreadInfo(
				UserID,Score,TypeID,ChildrenID,CollectNote)
			VALUES(@SpreaderID,@GrantScore,3,@UserID,@Note)		
		END
	END

	-- ���ÿ���ʹ��
	UPDATE LivcardAssociator SET ApplyDate=GETDATE() WHERE CardID=@CardID

	-- д����ֵ��¼
	INSERT INTO ShareDetailInfo(
		OperUserID,ShareID,UserID,GameID,Accounts,SerialID,CardTypeID,OrderAmount,Currency,BeforeCurrency,PayAmount,IPAddress,ApplyDate)
	VALUES(@dwOperUserID,@ShareID,@UserID,@GameID,@Accounts,@SerialID,@CardTypeID,@CardPrice,@Currency,@BeforeCurrency,@CardPrice,@strClientIP,GETDATE())

	-- ��¼��־
	DECLARE @DateID INT
	SET @DateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)	
	
	UPDATE StreamShareInfo
	SET ShareTotals=ShareTotals+1
	WHERE DateID=@DateID AND ShareID=@ShareID

	IF @@ROWCOUNT=0
	BEGIN
		INSERT StreamShareInfo(DateID,ShareID,ShareTotals)
		VALUES (@DateID,@ShareID,1)
	END	 

	SET @strErrorDescribe=N'ʵ����ֵ�ɹ���'
END 

RETURN 0
GO



