----------------------------------------------------------------------
-- ʱ�䣺2015-10-10
-- ��;����̨����Ա��Ӵ����û�
----------------------------------------------------------------------
USE RYAccountsDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_AddAgent]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_AddAgent]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_AddAgent]
(
	@dwUserID			INT,					--�û���ʶ
	@strCompellation	NVARCHAR(16),			--��������
	@strDomain			NCHAR(50),				--��������
	@dwAgentType		INT,					--�ֳ�����
	@dcAgentScale		DECIMAL(18,3),			--�ֳɱ���
	@dwPayBackScore		BIGINT ,				--���ۼƳ�ֵ����
	@dcPayBackScale		DECIMAL(18,3),			--���ֱ���
	@strMobilePhone		NVARCHAR(16),			--��ϵ�绰
	@strEMail			NVARCHAR(32),			--��������
	@strDwellingPlace	NVARCHAR(128),			--��ϸ��ַ
	@dwNullity			TINYINT,				--����״̬
	@strAgentNote		NVARCHAR(200),			--��ע

	@strErrorDescribe NVARCHAR(127) OUTPUT		--�����Ϣ
)

WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �û���Ϣ
DECLARE @UserID INT
DECLARE @Nullity TINYINT

BEGIN
	-- ��ѯ�û�	
	SELECT @UserID=UserID,@Nullity=Nullity FROM AccountsInfo(NOLOCK) WHERE UserID=@dwUserID

	-- �û�����
	IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe=N'�����ʺŲ����ڣ����֤���ٴγ��ԣ�'
		RETURN 100
	END	

	-- �ʺŽ�ֹ
	IF @Nullity<>0
	BEGIN
		SET @strErrorDescribe=N'�����ʺ���ʱ���ڶ���״̬������ϵ�ͷ������˽���ϸ�����'
		RETURN 101
	END	

	-- ��ѯ�����ظ���Ϣ
	IF EXISTS(SELECT AgentID FROM AccountsAgent WHERE UserID=@dwUserID)
	BEGIN
		SET @strErrorDescribe=N'�����Ѵ��ڣ������ظ���ӣ�'
		RETURN 102
	END

	-- ��ѯ���������ظ���Ϣ
	IF EXISTS(SELECT AgentID FROM AccountsAgent WHERE Domain=@strDomain)
	BEGIN
		SET @strErrorDescribe=N'���������Ѵ��ڣ������ظ���ӣ�'
		RETURN 103
	END

	-- ������Ϣ
	INSERT INTO AccountsAgent(UserID,Compellation,Domain,AgentType,AgentScale,PayBackScore,PayBackScale,MobilePhone,EMail,DwellingPlace,Nullity,AgentNote)
	VALUES(@dwUserID,@strCompellation,@strDomain,@dwAgentType,@dcAgentScale,@dwPayBackScore,@dcPayBackScale,@strMobilePhone,@strEMail,@strDwellingPlace,@dwNullity,@strAgentNote)

	-- �����û�
	IF @@ERROR=0 
	BEGIN
		UPDATE AccountsInfo SET AgentID=SCOPE_IDENTITY() WHERE UserID = @dwUserID
		SET @strErrorDescribe=N'��ϲ���������û������ɹ���'
		RETURN 0
	END
	ELSE
	BEGIN
		SET @strErrorDescribe=N'�����û�����ʧ�ܡ�'
		RETURN 112
	END
END
