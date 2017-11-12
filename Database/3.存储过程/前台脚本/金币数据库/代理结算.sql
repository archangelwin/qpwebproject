----------------------------------------------------------------------
-- ��Ȩ��2015
-- ʱ�䣺2015-12-20
-- ��;���������
----------------------------------------------------------------------

USE [RYTreasureDB]
GO

-- �������
IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_AgentBalance') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_AgentBalance
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

----------------------------------------------------------------------------------------------------------------
-- �������
CREATE PROCEDURE NET_PW_AgentBalance
	@dwUserID			INT,					-- �û���ʶ

	@dwBalance			INT,					-- ������

	@strClientIP		NVARCHAR(15),			-- ������ַ
	@strErrorDescribe	NVARCHAR(127) OUTPUT	-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ������Ϣ
DECLARE @UserID				INT
DECLARE @GameID				INT
DECLARE @Accounts			NVARCHAR(31)
DECLARE @SpreaderID			INT

-- �ʺ�״̬
DECLARE @Nullity BIT
DECLARE @StunDown BIT

-- ������Ϣ
DECLARE @MinBalanceScore BIGINT   -- ��ͽ�����

-- ִ���߼�
BEGIN
	-- �û�����
	SELECT	@UserID=UserID,@GameID=GameID,@Accounts=Accounts,@Nullity=Nullity,@StunDown=StunDown,@SpreaderID=SpreaderID
	FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo
	WHERE UserID=@dwUserID

	-- ��ѯ�û�
	IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe= N'�����ʺŲ����ڻ������������������֤���ٴγ��Ե�¼��'
		RETURN 1
	END

	-- �ʺŽ�ֹ
	IF @Nullity<>0
	BEGIN
		SET @strErrorDescribe=N'�����ʺ���ʱ���ڶ���״̬������ϵ�ͻ����������˽���ϸ�����'
		RETURN 2
	END	

	-- �ʺŹر�
	IF @StunDown<>0
	BEGIN
		SET @strErrorDescribe=N'�����ʺ�ʹ���˰�ȫ�رչ��ܣ��������¿�ͨ����ܼ���ʹ�ã�'
		RETURN 3
	END	

	-- ��С������
	SELECT @MinBalanceScore=StatusValue FROM RYAccountsDBLink.RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='AgentBalance'
	IF @MinBalanceScore IS NULL
	BEGIN
		SET @MinBalanceScore=200000
	END
	IF @dwBalance < @MinBalanceScore
	BEGIN
		SET @strErrorDescribe=N'�ǳ���Ǹ,��ÿ�ʽ������Ŀ�������' + Convert(NVARCHAR(30), @MinBalanceScore) + '��ң�'
		RETURN 4
	END

	-- ��ѯ�������
	DECLARE @AgentRevenue BIGINT -- ˰�շֳ�
	DECLARE @AgentPayInfo BIGINT -- ��ֵ�ֳ�
	DECLARE @AgentBalance BIGINT -- �������
	SELECT @AgentRevenue=ISNULL(SUM(AgentRevenue),0) FROM RecordUserRevenue WHERE AgentUserID=@dwUserID
	SELECT @AgentPayInfo=ISNULL(SUM(Score),0) FROM RecordAgentInfo WHERE UserID=@dwUserID
	SET @AgentBalance=@AgentRevenue+@AgentPayInfo
	IF @AgentBalance<0 OR @dwBalance>@AgentBalance
	BEGIN
		SET @strErrorDescribe=N'�ǳ���Ǹ,����ǰ��������!'
		RETURN 5
	END

	-- ��ѯ���н��
	DECLARE @InsureScore BIGINT
	SELECT @InsureScore=InsureScore FROM GameScoreInfo(NOLOCK) WHERE UserID = @dwUserID
	IF @InsureScore IS NULL
	BEGIN
		SET @InsureScore=0
	END

	-- �����¼
	INSERT INTO RecordAgentInfo(UserID,TypeID,Score,InsureScore,CollectIP) VALUES(@dwUserID,3,-@dwBalance,@InsureScore,@strClientIP)

	-- �������н��
	UPDATE GameScoreInfo SET InsureScore = InsureScore+@dwBalance
	WHERE UserID = @UserID
	IF @@ROWCOUNT = 0 
	BEGIN
		INSERT INTO GameScoreInfo(UserID,InsureScore,RegisterIP,LastLogonIP)
		VALUES(@UserID,@dwBalance,@strClientIP,@strClientIP)
	END
END
RETURN 0
GO
