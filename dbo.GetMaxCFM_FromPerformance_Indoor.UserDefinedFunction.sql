USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMaxCFM_FromPerformance_Indoor]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-4
-- Description:	Return Max CFM
-- =============================================
CREATE FUNCTION [dbo].[GetMaxCFM_FromPerformance_Indoor]
(
	-- Add the parameters for the function here
	@IndoorGUID uniqueidentifier
	--,@PerformanceType nvarchar(50)
)
RETURNS decimal(8, 2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MaxCFM decimal(8, 2)
	
	Set @MaxCFM = 1

	--If @PerformanceType = 'Cooling'
	Begin
		Set @MaxCFM = (Select Max([CFM])
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

	If @MaxCFM is NULL or @MaxCFM < 1 Set @MaxCFM = 1
	-- Return the MaxCFM for the OutdoorGUID & PerformanceType specified
	RETURN @MaxCFM

END


GO
