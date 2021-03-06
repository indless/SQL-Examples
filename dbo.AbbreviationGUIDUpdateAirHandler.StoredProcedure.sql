USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AbbreviationGUIDUpdateAirHandler]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the AbbreviationGUIDAirHandler for a given Air Handler abbreviation
-- =============================================
CREATE PROCEDURE [dbo].[AbbreviationGUIDUpdateAirHandler]
(
	-- Add the parameters for the function here
	@AirHandlerAbbreviation nvarchar(50)
	--,@ResultGUID uniqueidentifier OUTPUT /* Air Handler Abbreviation GUID */
)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @AirHandlerAbbreviation_A as nvarchar(50) /* Primary abbreviation or First variant abbreviation for (a,b) type abbreviations */
			,@AirHandlerAbbreviation_B as nvarchar(50) /* Secondary abbreviation for (a,b) type abbreviations */
			,@numOfMaterialsMatchingAirHandlerAbbrev as int /* number of materials matching the @thisAirHandlerAbbreviation  */
			,@counterM as int /* count for the number of times material loop runs */ 
			,@thisMaterialMasterGUID as uniqueidentifier /* MaterialMasterGUID for one material number */
			,@ResultGUID uniqueidentifier
	
	Set @AirHandlerAbbreviation_A = 'ZZZZZZZZZZZZZZ'
	Set @AirHandlerAbbreviation_B = 'ZZZZZZZZZZZZZZ'
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	Set @numOfMaterialsMatchingAirHandlerAbbrev = 1

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @AirHandlerAbbreviation <> '' and @AirHandlerAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @AirHandlerAbbreviation)
		
						  
		If @ResultGUID is NULL /* If abbreviation does not exist */
		Begin
			Set @ResultGUID = NEWID() /* create new AbbreviationGUID */
		End  
		
		Execute dbo.CreateNewRow_Abbreviations @ResultGUID,@AirHandlerAbbreviation;
		
		/* Create 2 abbreviations for each variable in (a,b) type abbreviations */
		If CHARINDEX('(',@AirHandlerAbbreviation,1) > 0
		Begin
			Set @AirHandlerAbbreviation_A = LEFT(@AirHandlerAbbreviation,CHARINDEX('(',@AirHandlerAbbreviation,1)-1)
											+SUBSTRING(@AirHandlerAbbreviation,CHARINDEX('(',@AirHandlerAbbreviation,1)+1,1)
											+RIGHT(@AirHandlerAbbreviation,len(@AirHandlerAbbreviation)-CHARINDEX(')',@AirHandlerAbbreviation,1))
			
			Set @AirHandlerAbbreviation_B = LEFT(@AirHandlerAbbreviation,CHARINDEX('(',@AirHandlerAbbreviation,1)-1)
											+SUBSTRING(@AirHandlerAbbreviation,CHARINDEX('(',@AirHandlerAbbreviation,1)+3,1)
											+RIGHT(@AirHandlerAbbreviation,len(@AirHandlerAbbreviation)-CHARINDEX(')',@AirHandlerAbbreviation,1))
		End
		
		/* determines the number of materials that match this @AirHandlerAbbreviation */
		Set @numOfMaterialsMatchingAirHandlerAbbrev = (SELECT Count(*)
													   FROM [dbo].[MaterialMaster]
													   WHERE werks = '1002' and 
															--ProductionStatus <> 'P4' and 
															(MaterialNumber like @AirHandlerAbbreviation + '%' or
															MaterialNumber like @AirHandlerAbbreviation_A + '%' or
															MaterialNumber like @AirHandlerAbbreviation_B + '%')
													  )
		Set @counterM = 0
		
		/* While @counterM < @numOfMaterialsMatchingAirHandlerAbbrev */ 
		While @counterM < @numOfMaterialsMatchingAirHandlerAbbrev
		Begin
			/* search [dbo].[MaterialMaster_Abbreviation] for materials that should be mapped to abbreviation, add them if needed */
			Set @thisMaterialMasterGUID = (SELECT mmGUID.[MaterialMasterGUID] FROM 
												(SELECT [MaterialMasterGUID]
													   ,[MaterialNumber]
													   ,ROW_NUMBER() Over(Order by MaterialNumber) as 'RowNum'
												  FROM [dbo].[MaterialMaster]
												  WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														(MaterialNumber like @AirHandlerAbbreviation + '%' or
														MaterialNumber like @AirHandlerAbbreviation_A + '%' or
														MaterialNumber like @AirHandlerAbbreviation_B + '%')
												  Group by [MaterialMasterGUID],[MaterialNumber]) as mmGUID
											WHERE RowNum = @numOfMaterialsMatchingAirHandlerAbbrev - @counterM)
			
			/* Insert new records here if they don't exist */ 	
			Execute dbo.CreateNewRow_MaterialMaster_Abbreviation @thisMaterialMasterGUID, @ResultGUID;
			
			Set @counterM = @counterM + 1
		End
	End
	
	-- Return the Air Handler Abbreviation GUID
	--RETURN 

END

GO
