USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[CFM_Overlap]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-4
-- Description:	Return IndoorGUID if CFM range overlaps with Outdoor
-- =============================================
CREATE FUNCTION [dbo].[CFM_Overlap]
(
	-- Add the parameters for the function here
	@Indoor nvarchar(50)
	,@Outdoor nvarchar(50)

)
RETURNS uniqueidentifier
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ThisIndoorGUID uniqueidentifier 
			,@ThisOutdoorGUID uniqueidentifier
			,@ThisIndoorMinCFM as int
			,@ThisIndoorMaxCFM as int
			,@ThisOutdoorMinCFM as int
			,@ThisOutdoorMaxCFM as int
	
	Set @ThisIndoorGUID = '00000000-0000-0000-0000-000000000000'
	Set @ThisIndoorGUID = (Select dbo.GetAbbreviationGUIDAirHandler(@Indoor)) 
	Set @ThisOutdoorGUID = (Select dbo.GetAbbreviationGUIDOutdoor(@Outdoor))
	
	Set @ThisIndoorMinCFM = (Select dbo.GetMinCFM_FromPerformance_Indoor(@ThisIndoorGUID)) 
	Set @ThisIndoorMaxCFM = (Select dbo.GetMaxCFM_FromPerformance_Indoor(@ThisIndoorGUID)) 
	
	Set @ThisOutdoorMinCFM = (Select dbo.GetMinCFM_FromPerformance(@ThisOutdoorGUID,'Cooling'))
	Set @ThisOutdoorMaxCFM = (Select dbo.GetMaxCFM_FromPerformance(@ThisOutdoorGUID,'Cooling'))

	--If @PerformanceType = 'Cooling'
	Begin
		Set @ThisIndoorGUID = 
			Case
				When (@ThisIndoorMinCFM >= @ThisOutdoorMinCFM)
						And (@ThisIndoorMinCFM <= @ThisOutdoorMaxCFM)
				Then @ThisIndoorGUID 
				
				When (@ThisIndoorMaxCFM >= @ThisOutdoorMinCFM)
						And (@ThisIndoorMaxCFM <= @ThisOutdoorMaxCFM)
				Then @ThisIndoorGUID 
				
				When (@ThisIndoorMinCFM <= @ThisOutdoorMinCFM)
						And (@ThisIndoorMaxCFM >= @ThisOutdoorMaxCFM)
				Then @ThisIndoorGUID 
				 
				Else '00000000-0000-0000-0000-000000000000'
				End
	End
	--Else If @PerformanceType = 'Heating'
	--Begin
	--End

	If @ThisIndoorGUID is NULL Set @ThisIndoorGUID = '00000000-0000-0000-0000-000000000000'
	-- Return the IndoorGUID if CFM range overlaps with Outdoor
	RETURN @ThisIndoorGUID	

END



GO
