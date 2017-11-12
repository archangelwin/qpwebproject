USE RYTreasureDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[WSP_PM_LivcardAdd]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[WSP_PM_LivcardAdd]
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

----------------------------------------------------------------------
-- ʱ�䣺2010-03-16
-- ��;��ʵ�����
----------------------------------------------------------------------
CREATE PROCEDURE WSP_PM_LivcardAdd
	@SerialID nvarchar(3300),	-- ʵ������
	@Password nvarchar(3400),	-- ʵ������
	@BuildID int,				-- ���ɱ�ʶ
	@CardTypeID int,			-- ʵ������
	@CardPrice decimal(18,2),	-- ʵ���۸�	
	@Currency decimal(18,2),	-- ʵ�����
	@UseRange int,				-- ʹ�÷�Χ
	@SalesPerson nvarchar(31),	-- ������
	@ValidDate datetime			-- ��Ч����	
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ִ���߼�
BEGIN
	INSERT INTO LivcardAssociator(
		SerialID,[Password],BuildID,CardTypeID,CardPrice,Currency,UseRange,SalesPerson,ValidDate)
	SELECT A.rs AS SerialID,B.rs AS [Password],
		@BuildID,@CardTypeID,@CardPrice,@Currency,@UseRange,@SalesPerson,@ValidDate
	FROM WF_Split(@SerialID,',') AS A INNER JOIN WF_Split(@Password,',') AS B ON A.id=B.id
END
RETURN 0

