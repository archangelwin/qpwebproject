----------------------------------------------------------------------
-- ʱ�䣺2011-09-29
-- ��;����̨����Ա����û���Ϣ
----------------------------------------------------------------------
USE RYAccountsDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PM_UpdateAccountInfo]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PM_UpdateAccountInfo]
GO

----------------------------------------------------------------------
CREATE PROC [NET_PM_UpdateAccountInfo]
(
	@dwUserID			INT,					--�û���ʶ
	@strAccounts		NVARCHAR(31),			--�û��ʺ�
	@strNickName		NVARCHAR(31)=N'',		--�û��ǳ�
	@strLogonPass		NCHAR(32),				--��¼����
	@strInsurePass		NCHAR(32),				--��ȫ����
	@strUnderWrite		NVARCHAR(63)=N'',		--����ǩ��
	
	@dwExperience		INT	= 0,				--������ֵ
	@dwPresent			INT	= 0,				--������ֵ
	@dwLoveLiness		INT	= 0,				--����ֵ��
	@dwGender			TINYINT = 1,			--�û��Ա�
	@dwFaceID			SMALLINT ,				--���ͷ��	
	@dwCustomID			INT ,					--����Զ���ͷ��	
	
	@dwStunDown			TINYINT = 0,			--�رձ�־
	@dwNullity			TINYINT = 0,			--��ֹ����
	@dwMoorMachine		TINYINT = 0,			--�̶����� 
	@dwIsAndroid		TINYINT,				--�Ƿ������
	@dwUserRight		INT	= 0,				--�û�Ȩ��
	@dwMasterRight		INT	= 0,				--����Ȩ��
	@dwMasterOrder		TINYINT	= 0,			--����ȼ�

	@dwMasterID			INT = 0,				--��������Ա
	@strClientIP		NVARCHAR(15),			--������ַ
	
	@strErrorDescribe NVARCHAR(127) OUTPUT		--�����Ϣ
)
			
WITH ENCRYPTION AS

DECLARE @UserID INT
DECLARE @OldAccounts NVARCHAR(31)
DECLARE @OldNickName NVARCHAR(31)
DECLARE @OldLogonPass NVARCHAR(32)
DECLARE @OldInsurePass NVARCHAR(32)

BEGIN
	--��������
	SET NOCOUNT ON
	
	-- ��ѯ�û���Ϣ
	SELECT @UserID=UserID,@OldAccounts=Accounts,@OldNickName=NickName,@OldLogonPass=logonPass,@OldInsurePass=InsurePass 
	FROM AccountsInfo WHERE UserID=@dwUserID

	-- ��֤�˺�
	IF @OldAccounts<>@strAccounts
	BEGIN	
		IF EXISTS(SELECT UserID FROM AccountsInfo WHERE (Accounts=@strAccounts OR RegAccounts=@strAccounts) AND UserID!=@UserID)
		BEGIN
			SET @strErrorDescribe='�ʺ��Ѵ��ڣ����������룡'
			RETURN -1;	
		END
		IF EXISTS(SELECT [String] FROM ConfineContent(NOLOCK) WHERE (EnjoinOverDate IS NULL  OR EnjoinOverDate>=GETDATE()) AND CHARINDEX(String,@strAccounts)>0)
		BEGIN	
			SET @strErrorDescribe='����������ʺ������������ַ�����'
			RETURN -2;
		END
	END

	-- ��֤�ǳ�
	IF @OldNickName<>@strNickName
	BEGIN
		IF EXISTS(SELECT UserID FROM AccountsInfo WHERE NickName=@strNickName)
		BEGIN
			SET @strErrorDescribe='�ǳ��Ѵ��ڣ����������룡'
			RETURN -4;
		END	
	END
	
	-- ������Ϣ
	UPDATE AccountsInfo SET Accounts=@strAccounts,NickName=@strNickName,LogonPass=@strLogonPass,InsurePass=@strInsurePass,
		UnderWrite=@strUnderWrite,Experience=@dwExperience,Present=@dwPresent,LoveLiness=@dwLoveLiness,
		Gender=@dwGender,FaceID=@dwFaceID,CustomID=@dwCustomID,StunDown=@dwStunDown,Nullity=@dwNullity,MoorMachine=@dwMoorMachine,IsAndroid=@dwIsAndroid,
		UserRight=@dwUserRight,MasterOrder=@dwMasterOrder,MasterRight=@dwMasterRight 
	WHERE UserID=@UserID 

	-- ����������
	IF @dwIsAndroid=1
	BEGIN
		IF NOT EXISTS(SELECT UserID From AndroidLockInfo WHERE UserID=@UserID)
			INSERT INTO AndroidLockInfo(UserID,AndroidStatus,ServerID,BatchID,LockDateTime) VALUES(@UserID,0,0,0,Getdate());	
	END
	ELSE
		DELETE AndroidLockInfo WHERE UserID=@UserID;
	
	-- �޸��˺���־
	IF @OldAccounts<>@strAccounts
	BEGIN
		INSERT INTO RYRecordDBLink.RYRecordDB.DBO.RecordAccountsExpend(OperMasterID,UserID,ReAccounts,[Type],ClientIP,CollectDate)
		VALUES(@dwMasterID,@UserID,@OldAccounts,0,@strClientIP,GETDATE())
	END

	-- �޸��ǳ���־
	IF @OldNickName<>@strNickName
	BEGIN
		INSERT INTO RYRecordDBLink.RYRecordDB.DBO.RecordAccountsExpend(OperMasterID,UserID,ReAccounts,[Type],ClientIP,CollectDate)
		VALUES(@dwMasterID,@UserID,@OldNickName,1,@strClientIP,GETDATE())
	END

	-- �޸�������־
	IF @OldLogonPass=@strLogonPass
	BEGIN
		SET @OldLogonPass=''
	END
	IF @OldInsurePass=@strInsurePass
	BEGIN
		SET @OldInsurePass=''
	END
	IF @OldLogonPass<>'' OR @OldInsurePass<>''
	BEGIN
		INSERT INTO RYRecordDBLink.RYRecordDB.DBO.RecordPasswdExpend(OperMasterID,UserID,ReLogonPasswd,ReInsurePasswd,ClientIP,CollectDate)
		VALUES(@dwMasterID,@UserID,@OldLogonPass,@OldInsurePass,@strClientIP,GETDATE())
	END
	SET @strErrorDescribe='�޸��û���Ϣ�ɹ���'
	RETURN 0;
END
GO