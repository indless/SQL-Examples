USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AbbreviationGUIDUpdateCoil]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the CoilAbbreviationGUID for a given Coil abbreviation
-- =============================================
CREATE PROCEDURE [dbo].[AbbreviationGUIDUpdateCoil]
(
	-- Add the parameters for the function here
	@coilAbbreviation nvarchar(50)
	--,@ResultGUID uniqueidentifier OUTPUT /* Coil Abbreviation GUID */
)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @thisCoilAbbreviation nvarchar(50) /* copy of @coilAbbreviation input parameter */
			,@thisCoilType nvarchar(50) /* tyepe of coil [fc,mc,pc,uc,cf,cm,cu] */
			,@thisCoilSize nvarchar(50) /* coil tonnage & optional width [30,30B] */
			,@numOfCoilAbbreviations int /* the number of coil types in the abbreviation */
			,@numOfMaterialsMatchingCoilAbbrev int /* number of materials matching the @thisCoilType + @thisCoilSize  */
			,@counterM int /* count for the number of times material loop runs */ 
			,@counterT int /* count for the number of times CoilType loop runs */
			,@thisMaterialMasterGUID uniqueidentifier /* MaterialMasterGUID for one material number */
			,@hasDash bit
			,@ResultGUID uniqueidentifier
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	Set @thisCoilAbbreviation = @coilAbbreviation
	Set @numOfCoilAbbreviations = 1
	Set @numOfMaterialsMatchingCoilAbbrev = 1
	If CharIndex('/',@thisCoilAbbreviation,1) > 0 Set @hasDash = 1 -- 'TRUE'
	Else Set @hasDash = 0 --'FALSE'
	
	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @coilAbbreviation <> '' and @coilAbbreviation is not NULL
	Begin	
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @coilAbbreviation)			
						  
		If @ResultGUID is NULL /* If abbreviation does not exist */
		Begin
			Set @ResultGUID = NEWID() /* create new AbbreviationGUID */
		End  

		Execute dbo.CreateNewRow_Abbreviations @ResultGUID,@coilAbbreviation;
						
		/* find @numOfCoilAbbreviations (@numOfCoilAbbreviations = 1 + # of '/' characters in the abbreviation */
		If @hasDash = 1
		Begin
			Set @numOfCoilAbbreviations = ((select dbo.NthCharindex(5,'/',@thisCoilAbbreviation)) / CharIndex('/',@thisCoilAbbreviation,1)) + 1  --May need to add IF CharIndex('/',@thisCoilAbbreviation,1) > 0 (in case the character is not found)
			Set @thisCoilSize = Right(@thisCoilAbbreviation,len(@thisCoilAbbreviation)-((CharIndex('/',@thisCoilAbbreviation,1) * @numOfCoilAbbreviations)-1))
		End
		Else
		Begin
			Set @numOfCoilAbbreviations = 1
		End
		
		Set @counterT = 1
		
		While @counterT <= @numOfCoilAbbreviations 
		Begin
			/* For Each Coil type  */
			If @hasDash = 1
			Begin
				Set @thisCoilType = Right(Left(@thisCoilAbbreviation,(CharIndex('/',@thisCoilAbbreviation,1) * @counterT)-1),CharIndex('/',@thisCoilAbbreviation,1)-1)
			End
			Else
			Begin
				Set @thisCoilType = @coilAbbreviation
			End
			
			/* determines the number of materials that match this CoilType + CoilSize */
			Set @numOfMaterialsMatchingCoilAbbrev = ( SELECT Count(*)
													  FROM [dbo].[MaterialMaster]
													  WHERE werks = '1002' and 
															--ProductionStatus <> 'P4' and 
															MaterialNumber like 
															(Case When @hasDash = 1 Then @thisCoilType + @thisCoilSize + '%' 
															Else @thisCoilType + '%' End)
													 )
			
			Set @counterM = 0
			
			/* While @counterM < @numOfMaterialsMatchingCoilAbbrev (@numOfMaterialsMatchingCoilAbbrev = 1, @numOfMaterialsMatchingCoilAbbrev = # of matching material numbers) */ 
			While @counterM < @numOfMaterialsMatchingCoilAbbrev
			Begin
				/* search [dbo].[MaterialMaster_Abbreviation] for materials that should be mapped to abbreviation, add them if needed */
				Set @thisMaterialMasterGUID = (SELECT mmGUID.[MaterialMasterGUID] FROM 
												(SELECT [MaterialMasterGUID]
													   ,[MaterialNumber]
													   ,ROW_NUMBER() Over(Order by MaterialNumber) as 'RowNum'
												  FROM [dbo].[MaterialMaster]
												  WHERE werks = '1002' and 
														--ProductionStatus <> 'P4' and 
														MaterialNumber like 
														(Case When @hasDash = 1 Then @thisCoilType + @thisCoilSize + '%' 
														Else @thisCoilType + '%' End)
												  Group by [MaterialMasterGUID],[MaterialNumber]) as mmGUID
											WHERE RowNum = @numOfMaterialsMatchingCoilAbbrev - @counterM)
				
				/* Insert new records here if they don't exist */ 	
				Execute dbo.CreateNewRow_MaterialMaster_Abbreviation @thisMaterialMasterGUID, @ResultGUID;
				
				Set @counterM = @counterM + 1
			End
			
			Set @counterT = @counterT + 1
		
		End
	End

	
	-- Return the Coil Abbreviation GUID
	--RETURN 

END

GO
