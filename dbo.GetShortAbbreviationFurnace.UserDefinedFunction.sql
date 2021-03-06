USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortAbbreviationFurnace]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the short Furnace Abbreviation  
-- =============================================
Create FUNCTION [dbo].[GetShortAbbreviationFurnace]
(
	-- Add the parameters for the function here
	@FurnaceAbbreviationGUID uniqueidentifier
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @FurnaceAbbreviation nvarchar(50) /* Furnace Abbreviation GUID */
			
	/* Search for @FurnaceAbbreviationGUID, get @FurnaceAbbreviation */
	Set @FurnaceAbbreviation = (SELECT [Abbreviation]
								   FROM [dbo].[Abbreviations]
								   Where [AbbreviationGUID] = @FurnaceAbbreviationGUID)

	If @FurnaceAbbreviation <> 'Empty Abbreviation'
	Begin
		If @FurnaceAbbreviation is NULL Set @FurnaceAbbreviation = 'Empty Abbreviation'

		/* Trim to short Furnace abbreviation */
		Set @FurnaceAbbreviation =
		
			(Case
				When @FurnaceAbbreviation IS NULL
					Then 'Empty Abbreviation'
				When LEFT(@FurnaceAbbreviation,3) = 'RGF'
					Then LEFT(@FurnaceAbbreviation,5)
				When isNumeric(substring(@FurnaceAbbreviation,5,1)) = 1
					Then LEFT(@FurnaceAbbreviation,4)
				End)
	End
	-- Return the short Furnace Abbreviation 
	RETURN @FurnaceAbbreviation

END



GO
