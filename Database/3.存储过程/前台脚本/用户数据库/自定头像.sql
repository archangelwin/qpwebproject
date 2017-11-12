----------------------------------------------------------------------------------------------------
-- ��;������Զ���ͷ��
----------------------------------------------------------------------------------------------------

USE RYAccountsDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_InsertCustomFace') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_InsertCustomFace
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------

-- ����Զ���ͷ��
CREATE PROCEDURE NET_PW_InsertCustomFace
	@dwUserID INT,								-- �û� I D
	@imgCustomFace IMAGE,						-- ͷ������
	@strClientIP NVARCHAR(15),					-- �ͻ���IP
	@strMachineID NVARCHAR(32),					-- ������
	@strErrorDescribe NVARCHAR(127) OUTPUT		-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �˻���Ϣ
DECLARE @UserID INT
DECLARE @StunDown BIT
DECLARE @Nullity BIT
DECLARE @CustomID INT
DECLARE @FaceID INT

-- ִ���߼�
BEGIN
	-- ��ѯ�û�
	SELECT @UserID=UserID,@FaceID=FaceID,@Nullity=Nullity,@StunDown=StunDown FROM AccountsInfo(NOLOCK) WHERE UserID=@dwUserID

	-- ��ѯ�û�
	IF @UserID IS NULL 
	BEGIN
		SET @strErrorDescribe=N'�����ʺŲ����ڻ������������������֤���ٴγ��ԣ�'
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

	-- ����ͷ��
	INSERT INTO AccountsFace(UserID,CustomFace,InsertAddr,InsertMachine) VALUES(@dwUserID,@imgCustomFace,@strClientIP,@strMachineID)
	SELECT @CustomID=@@IDENTITY
	UPDATE AccountsInfo SET CustomID=@CustomID WHERE UserID=@dwUserID
	SET @strErrorDescribe=N'�ϴ�ͷ��ɹ�'
	
	SELECT @UserID AS UserID,@CustomID AS CustomID,@FaceID AS FaceID
END

RETURN 0
GO