USE RYGameMatchDB

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[NET_PW_GetMatchHistoryGroup]') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[NET_PW_GetMatchHistoryGroup]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON 
GO


CREATE PROCEDURE dbo.NET_PW_GetMatchHistoryGroup 
	@MatchType		TINYINT=0,				-- ��������
	@PageSize		INT=10,					-- ÿҳ��¼
	@PageIndex		INT=1,					-- ��ǰҳ��
	@Where			NVARCHAR(1000) = '',	-- ��ѯ����
	@OrderBy		NVARCHAR(1000),			-- �����ֶ�
	@PageCount		INT OUTPUT,				-- ҳ������
	@RecordCount	INT OUTPUT	        	-- ��¼����
WITH ENCRYPTION AS

--��������
SET NOCOUNT ON

-- ��������
DECLARE @TotalRecord INT
DECLARE @TotalPage INT
DECLARE @CurrentPageSize INT
DECLARE @TotalRecordForPageIndex INT
DECLARE @countSql NVARCHAR(4000)
DECLARE @Table NVARCHAR(1000)

BEGIN
	-- ����Դ
	IF @Where IS NULL SET @Where=N''
	IF @MatchType=0
	BEGIN
		SET @Table='(SELECT A.MatchID,A.MatchNo,A.ServerID,B.ServerName,C.MatchName,CONVERT(VARCHAR(100),MatchStartTime,20) AS MatchStartTime,CONVERT(VARCHAR(100),MatchEndTime,20) AS MatchEndTime
					FROM StreamMatchHistory AS A LEFT JOIN RYPlatformDB.dbo.GameRoomInfo AS B ON A.ServerID=B.ServerID LEFT JOIN MatchPublic AS C ON A.MatchID=C.MatchID
					WHERE A.MatchType=0
					GROUP BY A.MatchID,A.MatchNo,A.ServerID,B.ServerName,C.MatchName,CONVERT(VARCHAR(100),MatchStartTime,20),CONVERT(VARCHAR(100),MatchEndTime,20)) AS D'+@Where
	END
	ELSE
	BEGIN
		SET @Table='(SELECT A.MatchID,A.MatchNo,A.ServerID,B.ServerName,C.MatchName,CONVERT(VARCHAR(100),MatchStartTime,20) AS MatchStartTime,CONVERT(VARCHAR(100),MatchEndTime,20) AS MatchEndTime
					FROM StreamMatchHistory AS A LEFT JOIN RYPlatformDB.dbo.GameRoomInfo AS B ON A.ServerID=B.ServerID LEFT JOIN MatchPublic AS C ON A.MatchID=C.MatchID
					WHERE A.MatchType=1
					GROUP BY A.MatchID,A.MatchNo,A.ServerID,B.ServerName,C.MatchName,CONVERT(VARCHAR(100),MatchStartTime,20),CONVERT(VARCHAR(100),MatchEndTime,20)) AS D'+@Where
	END
		
	-- ��¼��
	IF @RecordCount IS NULL
	BEGIN
		SET @countSql='SELECT @TotalRecord=COUNT(*) FROM '+@Table;
		EXECUTE sp_executesql @countSql,N'@TotalRecord INT OUT',@TotalRecord OUT;
	END
	ELSE
	BEGIN
		SET @TotalRecord=@RecordCount
	END
		
	-- ������ֵ
	SET @TotalPage=(@TotalRecord-1)/@PageSize+1
	SET @CurrentPageSize=(@PageIndex-1)*@PageSize
	SET @PageCount=@TotalPage
	SET @RecordCount=@TotalRecord
	
	-- ���ؼ�¼
	SET @TotalRecordForPageIndex=@PageIndex*@PageSize
	EXEC('SELECT * FROM (SELECT TOP '+@TotalRecordForPageIndex+' ROW_NUMBER() OVER ('+@OrderBy+') AS PageView_RowNo,*
		FROM '+@Table+' ) AS TempPageViewTable
		WHERE TempPageViewTable.PageView_RowNo > '+@CurrentPageSize)
END
RETURN 0
GO
			

