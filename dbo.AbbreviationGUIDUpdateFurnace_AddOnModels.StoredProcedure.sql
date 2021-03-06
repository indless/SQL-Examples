USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AbbreviationGUIDUpdateFurnace_AddOnModels]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the AbbreviationGUIDFurnace for a given Furnace abbreviation
-- =============================================
CREATE PROCEDURE [dbo].[AbbreviationGUIDUpdateFurnace_AddOnModels]
(
	-- Add the parameters for the function here
	@FurnaceAbbreviation nvarchar(50)
	--,@ResultGUID uniqueidentifier = NULL OUTPUT /* Furnace Abbreviation GUID */
)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @furnaceAbbreviation_A as nvarchar(50) /* Primary abbreviation or First variant abbreviation for (8,L,9) type abbreviations */
			,@furnaceAbbreviation_B as nvarchar(50) /* Secondary abbreviation for (8,L,9) type abbreviations */
			,@furnaceAbbreviation_C as nvarchar(50) /* Third abbreviation for (8,L,9) type abbreviations */
			,@numOfMaterialsMatchingFurnaceAbbrev as int /* number of materials matching the @thisFurnaceAbbreviation  */
			,@counterM as int /* count for the number of times material loop runs */ 
			,@thisMaterialMasterGUID as uniqueidentifier /* MaterialMasterGUID for one material number */
			,@ResultGUID uniqueidentifier
			,@len1 as int
			,@position2 as int
	
	Set @furnaceAbbreviation_A = 'ZZZZZZZZZZZZZZ'
	Set @furnaceAbbreviation_B = 'ZZZZZZZZZZZZZZ'
	Set @furnaceAbbreviation_C = 'ZZZZZZZZZZZZZZ'
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	Set @numOfMaterialsMatchingFurnaceAbbrev = 1

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @FurnaceAbbreviation <> '' and @FurnaceAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @FurnaceAbbreviation)
		
						  
		If @ResultGUID is NULL /* If abbreviation does not exist */
		Begin
			Set @ResultGUID = NEWID() /* create new AbbreviationGUID */
		End  
		
		Execute dbo.CreateNewRow_Abbreviations @ResultGUID,@FurnaceAbbreviation;
		
		Set @len1 = CHARINDEX('*',@FurnaceAbbreviation,1)-1

		/* Replace * with % in the abbreviation */
		If Left(@FurnaceAbbreviation,1) <> 'R'
		Begin
			Set @position2 = 4
			--Set @FurnaceAbbreviation = LEFT(@FurnaceAbbreviation,CHARINDEX('*',@FurnaceAbbreviation,1)-1) + '8' + Right(@FurnaceAbbreviation,Len(@FurnaceAbbreviation)-CHARINDEX('*',@FurnaceAbbreviation,1))
			Set @furnaceAbbreviation_A = LEFT(@FurnaceAbbreviation,CHARINDEX('*',@FurnaceAbbreviation,1)-1) + '8' + Right(@FurnaceAbbreviation,Len(@FurnaceAbbreviation)-CHARINDEX('*',@FurnaceAbbreviation,1))
			Set @furnaceAbbreviation_B = LEFT(@FurnaceAbbreviation,CHARINDEX('*',@FurnaceAbbreviation,1)-1) + 'L' + Right(@FurnaceAbbreviation,Len(@FurnaceAbbreviation)-CHARINDEX('*',@FurnaceAbbreviation,1))
			Set @furnaceAbbreviation_C = LEFT(@FurnaceAbbreviation,CHARINDEX('*',@FurnaceAbbreviation,1)-1) + '9' + Right(@FurnaceAbbreviation,Len(@FurnaceAbbreviation)-CHARINDEX('*',@FurnaceAbbreviation,1))
		End
		Else
		Begin
			/* this will only work for RGF*P or first 3 charater with 10th as required */
			Set @position2 = 10
			Set @furnaceAbbreviation_A = LEFT(@FurnaceAbbreviation,CHARINDEX('*',@FurnaceAbbreviation,1)-1) + '%%%%%%' + Right(@FurnaceAbbreviation,Len(@FurnaceAbbreviation)-CHARINDEX('*',@FurnaceAbbreviation,1))
		End

		/* determines the number of materials that match this @FurnaceAbbreviation */
		Set @numOfMaterialsMatchingFurnaceAbbrev = (SELECT Count(*)
													FROM [dbo].[MaterialMaster]
													WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														(MaterialNumber like @furnaceAbbreviation_A + '%' or
														MaterialNumber like @furnaceAbbreviation_B + '%' or
														MaterialNumber like @furnaceAbbreviation_C + '%')
														and Left(MaterialNumber,@len1) = Left(@FurnaceAbbreviation,@len1)
														and SUBSTRING(MaterialNumber,@position2,1) = Right(@FurnaceAbbreviation,1)
												   )

		Set @counterM = 0
		
		/* While @counterM < @numOfMaterialsMatchingFurnaceAbbrev */ 
		While @counterM < @numOfMaterialsMatchingFurnaceAbbrev
		Begin
			/* search [dbo].[MaterialMaster_Abbreviation] for materials that should be mapped to abbreviation, add them if needed */
			Set @thisMaterialMasterGUID = (SELECT mmGUID.[MaterialMasterGUID] FROM 
												(SELECT [MaterialMasterGUID]
													   ,[MaterialNumber]
													   ,ROW_NUMBER() Over(Order by MaterialNumber) as 'RowNum'
												  FROM [dbo].[MaterialMaster]
												  WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														(MaterialNumber like @furnaceAbbreviation_A + '%' or
														MaterialNumber like @furnaceAbbreviation_B + '%' or
														MaterialNumber like @furnaceAbbreviation_C + '%')
														and Left(MaterialNumber,@len1) = Left(@FurnaceAbbreviation,@len1)
														and SUBSTRING(MaterialNumber,@position2,1) = Right(@FurnaceAbbreviation,1)
												  Group by [MaterialMasterGUID],[MaterialNumber]) as mmGUID
											WHERE RowNum = @numOfMaterialsMatchingFurnaceAbbrev - @counterM)
			
			/* Insert new records here if they don't exist */ 	
			Execute dbo.CreateNewRow_MaterialMaster_Abbreviation @thisMaterialMasterGUID, @ResultGUID;
			
			Set @counterM = @counterM + 1
		End
	End
	
	-- Return the Furnace Abbreviation GUID
	--RETURN 

END


GO
