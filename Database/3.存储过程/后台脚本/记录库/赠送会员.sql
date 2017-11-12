----------------------------------------------------------------------
-- ��Ȩ��2009
-- ʱ�䣺2010-03-16
-- ��;�����ͻ�Ա
----------------------------------------------------------------------------------------------------

USE RYRecordDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_GrantMember]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_GrantMember]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO
----------------------------------------------------------------------
CREATE PROCEDURE WSP_PM_GrantMember
	@MasterID INT,					-- ����Ա��ʶ
	@ClientIP VARCHAR(15),			-- ���͵�ַ
	@UserID INT,					-- �û���ʶ
	@MemberOrder INT,				-- ���ͻ�Ա��ʶ
	@Reason NVARCHAR(32),			-- ����ԭ��
	@MemberDays INT					-- ���ͻ�Ա����
	
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ��Ա����
DECLARE @MaxMemberOrder INT
DECLARE @MaxUserRight INT
DECLARE @MemberOverDate DATETIME
DECLARE @MemberSwitchDate DATETIME
DECLARE @UserRight INT

-- ִ���߼�
BEGIN
	-- ������¼��Ϣ
	INSERT INTO	RecordGrantMember(MasterID,ClientIP,UserID,GrantCardType,Reason,MemberDays)
	VALUES(@MasterID,@ClientIP,@UserID,@MemberOrder,@Reason,@MemberDays)

	-- ��ѯȨ��
	SELECT @UserRight=UserRight FROM RYAccountsDBLink.RYAccountsDB.dbo.MemberProperty WHERE MemberOrder=@MemberOrder
	
	-- ���»�Ա
	UPDATE RYAccountsDBLink.RYAccountsDB.dbo.AccountsMember SET MemberOverDate=MemberOverDate+@MemberDays,UserRight=@UserRight
	WHERE UserID=@UserID AND MemberOrder=@MemberOrder
	
	IF @@ROWCOUNT=0
	BEGIN
		INSERT INTO RYAccountsDBLink.RYAccountsDB.dbo.AccountsMember(UserID,MemberOrder,UserRight,MemberOverDate)
		VALUES(@UserID,@MemberOrder,@UserRight,GETDATE()+@MemberDays)
	END

	-- �󶨻�Ա,(��Ա�������л�ʱ��)
	SELECT @MaxMemberOrder = MAX(MemberOrder),@MemberOverDate = MAX(MemberOverDate),@MemberSwitchDate=MIN(MemberOverDate)
	FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsMember WHERE UserID = @UserID
	
	-- ��ԱȨ��
	SELECT @MaxUserRight = UserRight FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsMember
	WHERE UserID = @UserID AND MemberOrder = @MaxMemberOrder

	-- ���ӻ�Ա����Ϣ
	UPDATE RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	SET MemberOrder=@MaxMemberOrder,UserRight=@MaxUserRight,MemberOverDate=@MemberOverDate,MemberSwitchDate=@MemberSwitchDate
	WHERE UserID = @UserID

	-- �޸Ļ����˵Ļ�Ա�ȼ�
	UPDATE RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo SET MemberOrder=@MaxMemberOrder WHERE UserID = @UserID
END
RETURN 0
	