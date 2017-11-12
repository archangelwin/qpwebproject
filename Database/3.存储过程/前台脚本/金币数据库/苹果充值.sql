----------------------------------------------------------------------
-- ��Ȩ��2011
-- ʱ�䣺2011-09-1
-- ��;�����߳�ֵ
----------------------------------------------------------------------

USE [RYTreasureDB]
GO

-- ���߳�ֵ
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_FilledApp') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_FilledApp
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

---------------------------------------------------------------------------------------
-- ���߳�ֵ
CREATE PROCEDURE NET_PW_FilledApp
	@dwUserID			INT,					-- �û���ʶ
	@strOrdersID		NVARCHAR(50),			-- �������
	@PayAmount			DECIMAL(18,2),			-- ������
	@strProductID		NVARCHAR(100),			-- APP��Ʒ��ʶ
	@dwShareID			INT,					-- �����ʶ
	@strErrorDescribe	NVARCHAR(127) OUTPUT	-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ������Ϣ
DECLARE @UserID INT
DECLARE @Accounts NVARCHAR(31)
DECLARE @GameID INT
DECLARE @Nullity TINYINT

-- ��Ʒ��Ϣ
DECLARE @ProductID NVARCHAR(100)
DECLARE @Price DECIMAL(18,2)
DECLARE @AttachCurrency DECIMAL(18,2)

-- �����Ϣ
DECLARE @Score BIGINT

-- ִ���߼�
BEGIN	
	-- �����ظ�
	IF EXISTS(SELECT OrderID FROM ShareDetailInfo(NOLOCK) WHERE OrderID=@strOrdersID) 
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����ֵ�����ظ���'
		RETURN 1
	END

	-- ��֤�û�
	SELECT @UserID=UserID,@GameID=GameID,@Accounts=Accounts,@Nullity=Nullity
	FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo
	WHERE UserID=@dwUserID

	IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ���û��˺Ų����ڡ�'
		RETURN 2
	END

	IF @Nullity=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ҫ��ֵ���û��˺���ʱ���ڶ���״̬������ϵ�ͻ����������˽���ϸ�����'
		RETURN 3
	END	

	-- ��ѯAPP��Ʒ��Ϣ
	SELECT @ProductID=ProductID,@Price=Price,@AttachCurrency=AttachCurrency FROM GlobalAppInfo(NOLOCK) WHERE ProductID=@strProductID
	IF @ProductID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ����Ʒ��Ϣ�����ڡ�'
		RETURN 4
	END

	IF @PayAmount<>@Price
	BEGIN
		SET @strErrorDescribe=N'��Ǹ��֧��������'
		RETURN 4
	END

	-- ���һ���
	DECLARE @Rate INT
	SELECT @Rate=StatusValue FROM RYAccountsDBLink.RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='RateCurrency'
	IF @Rate=0 OR @Rate IS NULL
		SET @Rate=1

	-- ���Ҳ�ѯ
	DECLARE @BeforeCurrency DECIMAL(18,2)
	SELECT @BeforeCurrency=Currency FROM UserCurrencyInfo WHERE UserID=@UserID
	IF @BeforeCurrency IS NULL
		SET @BeforeCurrency=0

	-- ��ֵ����	
	DECLARE @Currency DECIMAL(18,2)
	DECLARE @PresentCurrency DECIMAL(18,2)
	SET @Currency = @PayAmount*@Rate
	SET @PresentCurrency=@Currency

	-- �׳佱��
	IF @AttachCurrency<>0
	BEGIN
		IF NOT EXISTS (SELECT OrderID FROM ShareDetailInfo(NOLOCK) WHERE UserID=@UserID AND DATEDIFF(d,ApplyDate,GETDATE())=0)
		BEGIN
			SET @PresentCurrency=@Currency+@AttachCurrency
		END
	END

	UPDATE UserCurrencyInfo SET Currency=Currency+@PresentCurrency WHERE UserID=@UserID
	IF @@ROWCOUNT=0
	BEGIN
		INSERT UserCurrencyInfo(UserID,Currency) VALUES(@UserID,@PresentCurrency)
	END
	
	-- ������¼
	INSERT INTO ShareDetailInfo(
		OperUserID,ShareID,UserID,GameID,Accounts,OrderID,OrderAmount,DiscountScale,PayAmount,
		Currency,BeforeCurrency,IPAddress)
	VALUES(
		0,@dwShareID,@UserID,@GameID,@Accounts,@strOrdersID,@PayAmount,0,@PayAmount,
		@PresentCurrency,@BeforeCurrency,'0.0.0.0')

	--------------------------------------------------------------------------------
	-- �ƹ�ϵͳ&����ϵͳ
	DECLARE @SpreaderID INT	
	SELECT @SpreaderID=SpreaderID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo
	WHERE UserID = @UserID
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
				INSERT INTO RecordAgentInfo(DateID,UserID,AgentScale,TypeID,PayScore,Score,ChildrenID,CollectIP) VALUES(@AgentDateID,@AgentUserID,@AgentScale,1,@PayScore,@AgentScore,@UserID,'')
				-- ������ͳ��
				UPDATE StreamAgentPayInfo SET PayAmount=PayAmount+@PayAmount,Currency=Currency+@Currency,PayScore=PayScore+@PayScore,LastCollectDate=GETDATE() WHERE DateID=@AgentDateID AND UserID=@AgentUserID
				IF @@ROWCOUNT=0
				BEGIN
					INSERT INTO StreamAgentPayInfo(DateID,UserID,PayAmount,Currency,PayScore) VALUES(@AgentDateID,@AgentUserID,@PayAmount,@Currency,@PayScore)
				END
			END
		END
		ELSE
		BEGIN
			DECLARE @SpreadRate DECIMAL(18,2)
			DECLARE @GrantScore BIGINT
			DECLARE @Note NVARCHAR(512)
			-- �ƹ�ֳ�
			SELECT @SpreadRate=FillGrantRate FROM GlobalSpreadInfo
			IF @SpreadRate IS NULL
			BEGIN
				SET @SpreadRate=0.1
			END
			
			SET @GrantScore = @Currency*@GoldRate*@SpreadRate
			SET @Note = N'��ֵ'+LTRIM(STR(@PayAmount))+'Ԫ'
			INSERT INTO RecordSpreadInfo(UserID,Score,TypeID,ChildrenID,CollectNote)
			VALUES(@SpreaderID,@GrantScore,3,@UserID,@Note)		
		END
	END

	-- ��¼��־
	DECLARE @DateID INT
	SET @DateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)

	UPDATE StreamShareInfo
	SET ShareTotals=ShareTotals+1
	WHERE DateID=@DateID AND ShareID=@dwShareID

	IF @@ROWCOUNT=0
	BEGIN
		INSERT StreamShareInfo(DateID,ShareID,ShareTotals)
		VALUES (@DateID,@dwShareID,1)
	END	 
	
END 
RETURN 0
GO



