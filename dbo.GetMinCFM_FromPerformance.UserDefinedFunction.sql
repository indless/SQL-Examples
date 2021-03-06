USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMinCFM_FromPerformance]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-4
-- Description:	Return Min CFM
-- =============================================
CREATE FUNCTION [dbo].[GetMinCFM_FromPerformance]
(
	-- Add the parameters for the function here
	@OutdoorGUID uniqueidentifier
	,@PerformanceType nvarchar(50)
)
RETURNS decimal(8, 2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MinCFM decimal(8, 2)
	
	Set @MinCFM = 1

	If @PerformanceType = 'Cooling'
	Begin
		Set @MinCFM = (Select Min([IndoorCFM])
					   From [MasterDataManagement].[dbo].[CoolingPerformance]
					   Where CoolingPerformanceGroupGUID = (Select distinct top 1 cpg.CoolingPerformanceGroupGUID
															From [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma
															inner join [MasterDataManagement].[dbo].[CoolingPerformanceGroups] as cpg on cpg.OutdoorUnitAbbrevGuid = mma.AbbreviationGUID
															join [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma2 on mma2.MaterialNumber = mma.MaterialNumber
															Where mma2.AbbreviationGUID = @OutdoorGUID))
	End
	Else If @PerformanceType = 'Heating'
	Begin
		Set @MinCFM = (Select Min([IndoorCFM])
					   From [MasterDataManagement].[dbo].[HeatingPerformance]
					   Where HeatingPerformanceGroupGUID = (Select distinct top 1 cpg.HeatingPerformanceGroupGUID
															From [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma
															inner join [MasterDataManagement].[dbo].[HeatingPerformanceGroups] as cpg on cpg.OutdoorUnitAbbrevGuid = mma.AbbreviationGUID
															join [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma2 on mma2.MaterialNumber = mma.MaterialNumber
															Where mma2.AbbreviationGUID = @OutdoorGUID))
	End

	If @MinCFM is NULL or @MinCFM < 1 Set @MinCFM = 1
	-- Return the MinCFM for the OutdoorGUID & PerformanceType specified
	RETURN @MinCFM

END

GO
