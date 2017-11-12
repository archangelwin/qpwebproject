----------------------------------------------------------------------------------------------------
-- ��Ȩ��2013
-- ʱ�䣺2013-07-31
-- ��;�����ⷴ��
----------------------------------------------------------------------------------------------------
USE RYNativeWebDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].WSP_PW_BuyAward') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].WSP_PW_BuyAward
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------------------------------------
-- ���ⷴ��
CREATE PROCEDURE WSP_PW_BuyAward
	@UserID	INT,					-- �û���ʶ
	@AwardID INT,					-- ��Ʒ��ʶ
	@AwardPrice INT,				-- ��Ʒ�۸�
	@AwardCount INT,				-- ��������
	@TotalAmount INT,				-- �ܽ��
	@Compellation NVARCHAR(16),		-- ��ʵ����
	@MobilePhone NVARCHAR(16),		-- �ֻ�����
	@QQ NVARCHAR(32),				-- QQ����
	@Province INT,					-- ʡ��
	@City INT,						-- ����
	@Area INT,						-- ����
	@DwellingPlace NVARCHAR(128),	-- ��ϸ��ַ
	@PostalCode	NVARCHAR(8),		-- �ʱ����
	@BuyIP NVARCHAR(15),			-- ����IP                     
	@OrderID INT OUTPUT,			-- ��������	
	@strErrorDescribe NVARCHAR(127) OUTPUT	-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- �˻���Ϣ
DECLARE @UserMedal INT

-- ִ���߼�
BEGIN
	-- ��֤�û�
	SELECT @UserMedal=UserMedal,@UserID=UserID FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo 
	WHERE UserID=@UserID
	IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe='�û�������'
		RETURN 101
	END

	-- ��֤����
	IF @TotalAmount>@UserMedal
	BEGIN
		SET @strErrorDescribe='�һ�ʧ�ܣ�����������'
		RETURN 101
	END
	
	-- ���½���
	--BEGIN TRAN
	UPDATE RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo SET UserMedal=UserMedal-@TotalAmount
	WHERE UserID=@UserID
	
	-- ���붩��
	INSERT INTO AwardOrder(UserID,AwardID,AwardPrice,AwardCount,TotalAmount,Compellation,
		MobilePhone,QQ,Province,City,Area,DwellingPlace,PostalCode,BuyIP)
	VALUES(@UserID,@AwardID,@AwardPrice,@AwardCount,@TotalAmount,@Compellation,
		@MobilePhone,@QQ,@Province,@City,@Area,@DwellingPlace,@PostalCode,@BuyIP)

	SET @OrderID=@@IDENTITY 
	SELECT @OrderID AS OrderID
		
	--���½�Ʒ
	UPDATE AwardInfo SET BuyCount=BuyCount+1,Inventory=Inventory-@AwardCount WHERE AwardID=@AwardID
	--COMMIT TRAN
	
	RETURN 0
END
RETURN 0
GO