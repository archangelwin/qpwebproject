----------------------------------------------------------------------
-- ʱ�䣺2011-09-26
-- ��;����Ʒ����ɾ��
----------------------------------------------------------------------
USE RYNativeWebDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_DeleteAwardType]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_DeleteAwardType]
GO
-----------------------------------------------------------------------
CREATE PROC [WSP_PM_DeleteAwardType]
	@TypeID INT,										-- ��Ʒ���ͱ�ʶ
	@strErrorDescribe NVARCHAR(127) OUTPUT			-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ִ���߼�
BEGIN	
	----�ж�ɾ���������Ƿ����������
	IF EXISTS(SELECT * FROM AwardType WHERE ParentID=@TypeID)
	BEGIN
		SET @strErrorDescribe=N'����Ʒ�����д���������,�޷�ɾ��';
		RETURN 1;
	END
	
	----�ж�ɾ���������Ƿ������Ʒ
	IF EXISTS(SELECT * FROM AwardInfo WHERE TypeID=@TypeID)
	BEGIN
		SET @strErrorDescribe=N'����Ʒ�����д�����Ʒ,�޷�ɾ��';
		RETURN 1;
	END
	
	----ִ��ɾ������
	DELETE FROM AwardType WHERE TypeID=@TypeID;
	RETURN 0;
END

GO

