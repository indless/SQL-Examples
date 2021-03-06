USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step5]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2017-4-19
-- Description:	Step 5 of AHRI load process, delete duplicates from CoolingCapacity & HeatingCapacity tables
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step5]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	With n as
	(
	  SELECT [MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Brand]
		  ,[ARIRefNumber],
		 row_number() OVER(PARTITION BY [MatchupType]
										  ,[OutdoorUnitAbbrevGUID]
										  ,[CoilAbbrevGuid]
										  ,[AirHandlerAbbrevGuid]
										  ,[VSFurnaceAbbrevGuid]
										  ,[Brand]
										  ,[ARIRefNumber] ORDER BY [ARIRefNumber]) AS rn
	  FROM [dbo].[CoolingCapacity]
	) 
	Delete From n
	where rn > 1

	With n as
	(
	  SELECT [MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Brand]
		  ,[ARIRefNumber],
		 row_number() OVER(PARTITION BY [MatchupType]
										  ,[OutdoorUnitAbbrevGUID]
										  ,[CoilAbbrevGuid]
										  ,[AirHandlerAbbrevGuid]
										  ,[VSFurnaceAbbrevGuid]
										  ,[Brand]
										  ,[ARIRefNumber] ORDER BY [ARIRefNumber]) AS rn
	  FROM [dbo].[HeatingCapacity]
	) 
	Delete From n
	where rn > 1




END


GO
