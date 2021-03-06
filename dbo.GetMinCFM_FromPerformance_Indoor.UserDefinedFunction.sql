USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMinCFM_FromPerformance_Indoor]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-4
-- Description:	Return Min CFM
-- =============================================
CREATE FUNCTION [dbo].[GetMinCFM_FromPerformance_Indoor]
(
	-- Add the parameters for the function here
	@IndoorGUID uniqueidentifier
	--,@PerformanceType nvarchar(50)
)
RETURNS decimal(8, 2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MinCFM decimal(8, 2)
	
	Set @MinCFM = 1

	--If @PerformanceType = 'Cooling'
	Begin
		Set @MinCFM = (Select Min([CFM])
					   From [MasterDataManagement].[dbo].[BlowerPerformance]
					   Where [BlowerAbbreviationGUID] = (Select distinct top 1 bp.[BlowerAbbreviationGUID]
															From [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma
															inner join [MasterDataManagement].[dbo].[BlowerPerformance] as bp on bp.[BlowerAbbreviationGUID] = mma.AbbreviationGUID
															join [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster] as mma2 on mma2.MaterialNumber = mma.MaterialNumber
															Where mma2.AbbreviationGUID = @IndoorGUID))
	End
	--Else If @PerformanceType = 'Heating'
	--Begin
	--End

	If @MinCFM is NULL or @MinCFM < 1 Set @MinCFM = 1
	-- Return the MinCFM for the OutdoorGUID & PerformanceType specified
	RETURN @MinCFM

END


GO
