USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAbbreviationGUIDFurnace]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Furnace Abbreviation GUID 
-- =============================================
CREATE FUNCTION [dbo].[GetAbbreviationGUIDFurnace]
(
	-- Add the parameters for the function here
	@FurnaceModelAbbreviation nvarchar(50)
)
RETURNS uniqueidentifier
AS
BEGIN

	Declare @ResultGUID uniqueidentifier /* Furnace Abbreviation GUID */
			,@FurnaceAbbreviation nvarchar(50)
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'

	/* Parse Indoor and return Furnace abbreviation */
	Set @FurnaceAbbreviation = 
	
		(Case
			When @FurnaceModelAbbreviation IS NULL
			Then ''
			Else Case
					When isNumeric(substring(@FurnaceModelAbbreviation,LEN(@FurnaceModelAbbreviation),1)) = 0
					Then Case
							When isNumeric(substring(@FurnaceModelAbbreviation,LEN(@FurnaceModelAbbreviation)-1,1)) = 0
							Then Case
									When isNumeric(substring(@FurnaceModelAbbreviation,LEN(@FurnaceModelAbbreviation)-2,1)) = 0
									Then LEFT(@FurnaceModelAbbreviation,len(@FurnaceModelAbbreviation)-3)
									Else LEFT(@FurnaceModelAbbreviation,len(@FurnaceModelAbbreviation)-2)
									End
							Else LEFT(@FurnaceModelAbbreviation,len(@FurnaceModelAbbreviation)-1)
							End
					Else @FurnaceModelAbbreviation
					End
		End) 
	
	If CHARINDEX('*',@FurnaceModelAbbreviation,1) > 0 Set @FurnaceAbbreviation = @FurnaceModelAbbreviation

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @FurnaceAbbreviation <> '' and @FurnaceAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @FurnaceAbbreviation)
	End
	
	If @ResultGUID is Null Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	 --Return the Furnace Abbreviation GUID
	RETURN @ResultGUID

END




GO
