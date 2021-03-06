USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AbbreviationGUIDUpdateOutdoor]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the AbbreviationGUIDOutdoor for a given Outdoor abbreviation
-- =============================================
CREATE PROCEDURE [dbo].[AbbreviationGUIDUpdateOutdoor]
(
	-- Add the parameters for the function here
	@OutdoorAbbreviation nvarchar(50)
	--,@ResultGUID uniqueidentifier OUTPUT /* Outdoor Abbreviation GUID */
)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultGUID uniqueidentifier
			,@numOfMaterialsMatchingOutdoorAbbrev as int /* number of materials matching the @thisOutdoorAbbreviation  */
			,@counterM as int /* count for the number of times material loop runs */ 
			,@thisMaterialMasterGUID as uniqueidentifier /* MaterialMasterGUID for one material number */
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	Set @numOfMaterialsMatchingOutdoorAbbrev = 1

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @OutdoorAbbreviation <> '' and @OutdoorAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @OutdoorAbbreviation)
						  
		If @ResultGUID is NULL /* If abbreviation does not exist */
		Begin
			Set @ResultGUID = NEWID() /* create new AbbreviationGUID */
		End  
		
		Execute dbo.CreateNewRow_Abbreviations @ResultGUID,@OutdoorAbbreviation;
		
		/* determines the number of materials that match this @OutdoorAbbreviation */
		Set @numOfMaterialsMatchingOutdoorAbbrev = (SELECT Count(*)
													FROM [dbo].[MaterialMaster]
													WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														MaterialNumber like @OutdoorAbbreviation + '%'
												   )
		Set @counterM = 0
		
		/* While @counterM < @numOfMaterialsMatchingOutdoorAbbrev */ 
		While @counterM < @numOfMaterialsMatchingOutdoorAbbrev
		Begin
			/* search [dbo].[MaterialMaster_Abbreviation] for materials that should be mapped to abbreviation, add them if needed */
			Set @thisMaterialMasterGUID = (SELECT mmGUID.[MaterialMasterGUID] FROM 
												(SELECT [MaterialMasterGUID]
													   ,[MaterialNumber]
													   ,ROW_NUMBER() Over(Order by MaterialNumber) as 'RowNum'
												  FROM [dbo].[MaterialMaster]
												  WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														MaterialNumber like @OutdoorAbbreviation + '%'
												  Group by [MaterialMasterGUID],[MaterialNumber]) as mmGUID
											WHERE RowNum = @numOfMaterialsMatchingOutdoorAbbrev - @counterM)
			
			/* Insert new records here if they don't exist */ 	
			Execute dbo.CreateNewRow_MaterialMaster_Abbreviation @thisMaterialMasterGUID, @ResultGUID;
			
			Set @counterM = @counterM + 1
		End
	End
	
	-- Return the Outdoor Abbreviation GUID
	--RETURN 

END

GO
