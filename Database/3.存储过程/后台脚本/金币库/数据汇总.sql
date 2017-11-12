----------------------------------------------------------------------
-- ʱ�䣺2011-10-20
-- ��;�����ݻ���ͳ�ơ�
----------------------------------------------------------------------
USE RYTreasureDB
GO

SET QUOTED_IDENTIFIER ON 
GO

SET ANSI_NULLS ON 
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PM_StatInfo') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PM_StatInfo
GO

----------------------------------------------------------------------
CREATE PROC NET_PM_StatInfo
			
WITH ENCRYPTION AS

BEGIN
	-- ��������
	SET NOCOUNT ON;	
	--�û�ͳ��
	DECLARE @OnLineCount INT		--��������
	DECLARE @DisenableCount INT		--ͣȨ�û�
	DECLARE @AllCount INT			--ע��������
	SELECT  TOP 1 @OnLineCount=ISNULL(OnLineCountSum,0) FROM RYPlatformDBLink.RYPlatformDB.dbo.OnLineStreamInfo ORDER BY InsertDateTime DESC
	SELECT  @DisenableCount=COUNT(UserID) FROM RYAccountsDB.dbo.AccountsInfo(NOLOCK) WHERE Nullity = 1
	SELECT  @AllCount=COUNT(UserID) FROM RYAccountsDB.dbo.AccountsInfo(NOLOCK)

	--���ͳ��
	DECLARE @Score BIGINT		--���Ͻ������
	DECLARE @InsureScore BIGINT	--��������
	DECLARE @AllScore BIGINT
	SELECT  @Score=ISNULL(SUM(Score),0),@InsureScore=ISNULL(SUM(InsureScore),0),@AllScore=ISNULL(SUM(Score+InsureScore),0) 
	FROM GameScoreInfo(NOLOCK)
	
	--����ͳ��
	DECLARE @RegPresent BIGINT				--ע������(1)
	DECLARE @AgentRegPresent BIGINT			--����ע������(13)
	DECLARE @DBPresent BIGINT				--�ͱ�����(2)
	DECLARE @QDPresent BIGINT				--ǩ������(3)
	DECLARE @YBPresent BIGINT				--Ԫ���һ�(4)
	DECLARE @MLPresent BIGINT				--�����һ�(5)
	DECLARE @OnlinePresent BIGINT			--����ʱ������(6)
	DECLARE @RWPresent BIGINT				--������(7)
	DECLARE @SMPresent BIGINT				--ʵ����֤(8)
	DECLARE @DayPresent BIGINT				--��Աÿ���ͽ�(9)
	DECLARE @MatchPresent BIGINT			--��������(10)
	DECLARE @DJPresent BIGINT				--�ȼ�����(11)
	DECLARE @SharePresent BIGINT			--��������(12)
	DECLARE @LotteryPresent BIGINT			--ת������(14)
	DECLARE @WebPresent BIGINT				--��̨����
	SELECT @RegPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=1
	SELECT @AgentRegPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=13
	SELECT @DBPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=2
	SELECT @QDPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=3
	SELECT @YBPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=4
	SELECT @MLPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=5
	SELECT @OnlinePresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=6
	SELECT @RWPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=7
	SELECT @SMPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=8
	SELECT @DayPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=9
	SELECT @MatchPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=10
	SELECT @DJPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=11
	SELECT @SharePresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=12
	SELECT @LotteryPresent=ISNULL(SUM([PresentScore]),0) FROM [dbo].[StreamPresentInfo](NOLOCK) WHERE [TypeID]=14
	SELECT @WebPresent=ISNULL(SUM(CONVERT(BIGINT,AddGold)),0) FROM RYRecordDBLink.RYRecordDB.dbo.RecordGrantTreasure
	
	--����ͳ��
	DECLARE @LoveLiness BIGINT		--��������
	DECLARE @Present BIGINT			--�Ѷһ���������
	DECLARE @ConvertPresent BIGINT	--�Ѷһ������
	SELECT @LoveLiness=SUM(CONVERT(BIGINT,LoveLiness)),@Present=SUM(CONVERT(BIGINT,Present)) FROM RYAccountsDBLink.RYAccountsDB.dbo.AccountsInfo
	SELECT @ConvertPresent=SUM(CONVERT(BIGINT,ConvertPresent)*ConvertRate) FROM RYRecordDBLink.RYRecordDB.dbo.RecordConvertPresent

	--˰��ͳ��
	DECLARE @Revenue BIGINT			--˰������
	DECLARE @TransferRevenue BIGINT	--ת��˰��
	SELECT @Revenue=ISNULL(SUM(Revenue),0) FROM GameScoreInfo(NOLOCK)
	SELECT @TransferRevenue=ISNULL(SUM(Revenue),0) FROM RecordInsure(NOLOCK)

	--���ͳ��
	DECLARE @Waste BIGINT   --�������
	SELECT @Waste=ISNULL(SUM(Waste),0) FROM RYRecordDBLink.RYRecordDB.dbo.RecordEveryDayData

	--�㿨ͳ��
	DECLARE @CardCount INT			--��������
	DECLARE @CardGold BIGINT		--�������
	DECLARE @CardPrice DECIMAL(18,2)--�������
	SELECT  @CardCount=COUNT(CardID),@CardGold=ISNULL(SUM(Currency),0),@CardPrice=SUM(CardPrice) FROM LivcardAssociator(NOLOCK)

	DECLARE @CardPayCount INT 		--��ֵ����
	DECLARE @CardPayGold BIGINT		--��ֵ���
	DECLARE @CardPayPrice DECIMAL(18,2)--��ֵ���������
	SELECT @CardPayCount=COUNT(CardID),@CardPayGold=ISNULL(SUM(Currency),0),@CardPayPrice=SUM(CardPrice) FROM LivcardAssociator(NOLOCK) WHERE ApplyDate IS NOT NULL 

	DECLARE @MemberCardCount INT	--ʵ������
	SELECT @MemberCardCount=COUNT(CardID) FROM LivcardAssociator(NOLOCK)

	--����
	SELECT  @OnLineCount AS	OnLineCount,				--��������
			@DisenableCount AS DisenableCount,			--ͣȨ�û�
			@AllCount AS AllCount,						--ע��������
			@Score AS Score,							--���Ͻ������
			@InsureScore AS InsureScore,				--��������
			@AllScore AS AllScore,						--�������
			
			@RegPresent AS RegPresent,					--ע������
			@AgentRegPresent AS AgentRegPresent,		--����ע������
			@DBPresent AS DBPresent,					--�ͱ�����
			@QDPresent AS QDPresent,					--ǩ������
			@YBPresent AS YBPresent,					--Ԫ���һ�
			@MLPresent AS MLPresent,					--�����һ�
			@OnlinePresent AS OnlinePresent,			--����ʱ������
			@RWPresent AS RWPresent,					--������
			@SMPresent AS SMPresent,					--ʵ����֤
			@DayPresent AS DayPresent,					--��Աÿ���ͽ�
			@MatchPresent AS MatchPresent,				--��������
			@DJPresent AS DJPresent,					--�ȼ�����
			@SharePresent AS SharePresent,				--��������
			@LotteryPresent AS LotteryPresent,			--ת������
			@WebPresent AS WebPresent,					--��̨����

			@LoveLiness AS LoveLiness,					--��������
			@Present AS Present,						--�Ѷһ���������
			(@LoveLiness-@Present) AS RemainLove,		--δ�һ���������
			@ConvertPresent AS ConvertPresent,			--�Ѷһ������
			@Revenue AS Revenue,						--˰������
			@TransferRevenue AS TransferRevenue,		--ת��˰��	
			@Waste AS Waste,							--�������
	
			@CardCount AS CardCount,					--��������
			@CardGold AS CardGold,						--�������
			@CardPrice AS CardPrice,					--�������
			@CardPayCount AS CardPayCount, 				--��ֵ����
			@CardPayGold AS CardPayGold,				--��ֵ���
			@CardPayPrice AS CardPayPrice,				--��ֵ���������
			@MemberCardCount AS MemberCardCount			--��Ա������
END































