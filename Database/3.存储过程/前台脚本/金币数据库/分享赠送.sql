----------------------------------------------------------------------------------------------------
-- ��Ȩ��2015
-- ʱ�䣺2015-01-20
-- ��;����������
----------------------------------------------------------------------------------------------------
USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_SharePresent') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_SharePresent
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------
-- ��������
CREATE PROCEDURE NET_PW_SharePresent
	@dwUserID	INT,						-- �û���ʶ
	@strPassword NCHAR(32),					-- �û�����
	@strMachineID NVARCHAR(32),				-- ������         
	@strClientIP NVARCHAR(15),				-- ���ӵ�ַ                 
	@strErrorDescribe NVARCHAR(127) OUTPUT	-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �˻���Ϣ
DECLARE @UserID INT
DECLARE @Nullity TINYINT
DECLARE @LogonPass AS NCHAR(32)

-- �����Ϣ
DECLARE @Score BIGINT
DECLARE @InsureScore BIGINT

-- ִ���߼�
BEGIN
	-- ��֤�û�
	SELECT @UserID=UserID,@Nullity=Nullity,@LogonPass=LogonPass FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo WHERE UserID=@dwUserID
	
	-- �û�����
	IF @UserID IS NULL OR @LogonPass<>@strPassword
	BEGIN
		SET @strErrorDescribe=N'�����ʺŲ����ڻ������������������֤���ٴγ��Ե�¼��'
		RETURN 100
	END	

	-- �ʺŽ�ֹ
	IF @Nullity<>0
	BEGIN
		SET @strErrorDescribe=N'�����ʺ���ʱ���ڶ���״̬������ϵ�ͻ����������˽���ϸ�����'
		RETURN 101
	END

	-- ��ѯ���
	SELECT @Score=Score,@InsureScore=InsureScore FROM GameScoreInfo WHERE UserID=@dwUserID
	IF @Score IS NULL
	BEGIN
		SET @Score=0
		SET @InsureScore=0
	END

	-- ��������
	DECLARE @DateID INT
	DECLARE @PresentScore INT
	DECLARE @IsPresent bit
	SET @DateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)
	SELECT @PresentScore = StatusValue FROM RYAccountsDBLink.RYAccountsDB.dbo.SystemStatusInfo WHERE StatusName='SharePresent'
	IF @PresentScore IS NULL
	BEGIN
		SET @PresentScore=1000
	END	
	SET @IsPresent=0

	IF @PresentScore>0
	BEGIN
		IF NOT EXISTS (SELECT MachineID FROM RecordSharePresent WHERE DateID=@DateID AND UserID=@dwUserID)
		BEGIN
			-- ���ñ�ʶ
			SET @IsPresent=1

			-- д����Ϣ
			UPDATE GameScoreInfo SET Score=Score+@PresentScore WHERE UserID=@dwUserID
			IF @@ROWCOUNT=0
			BEGIN
				INSERT INTO GameScoreInfo(UserID,Score,LastLogonIP,RegisterIP) VALUES(@dwUserID,@PresentScore,@strClientIP,@strClientIP)
			END

			-- д���¼
			INSERT INTO RecordSharePresent(DateID,UserID,MachineID,PresentScore) VALUES(@DateID,@dwUserID,@strMachineID,@PresentScore)

			SET @strErrorDescribe=N'��ϲ���������״η���ɹ����������'+LTRIM(STR(@PresentScore))
		END		
	END

	-- ����ͳ��
	IF @IsPresent=1
	BEGIN
		DECLARE @TypeID INT
		SET @TypeID=12
		-- ��ˮ��
		INSERT INTO RecordPresentInfo(UserID,PreScore,PreInsureScore,PresentScore,TypeID,IPAddress)
		VALUES(@dwUserID,@Score,@InsureScore,@PresentScore,@TypeID,@strClientIP)
		-- ��ͳ��
		UPDATE StreamPresentInfo SET PresentCount=PresentCount+1,PresentScore=PresentScore+@PresentScore,LastDate=GETDATE()
		WHERE DateID=@DateID AND UserID=@dwUserID AND TypeID=@TypeID 
		IF @@ROWCOUNT=0
		BEGIN
			INSERT INTO StreamPresentInfo(DateID,UserID,TypeID,PresentCount,PresentScore,FirstDate,LastDate)
			VALUES(@DateID,@dwUserID,@TypeID,1,@PresentScore,GETDATE(),GETDATE())
		END		
	END
END
RETURN 0
GO