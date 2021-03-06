USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAbbreviationGUIDOutdoor]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Outdoor Abbreviation GUID 
-- =============================================
CREATE FUNCTION [dbo].[GetAbbreviationGUIDOutdoor]
(
	-- Add the parameters for the function here
	@OutdoorModelAbbreviation nvarchar(50)
)
RETURNS uniqueidentifier
AS
BEGIN

	Declare @ResultGUID uniqueidentifier /* Outdoor Abbreviation GUID */
			,@OutdoorAbbreviation nvarchar(50)
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'

	/* Parse Indoor and return Outdoor abbreviation */
	Set @OutdoorAbbreviation = 
	
		(Case
			When isNumeric(substring(@OutdoorModelAbbreviation,LEN(@OutdoorModelAbbreviation),1)) = 0
			Then Case
					When isNumeric(substring(@OutdoorModelAbbreviation,LEN(@OutdoorModelAbbreviation)-1,1)) = 0
					Then Case
							When isNumeric(substring(@OutdoorModelAbbreviation,LEN(@OutdoorModelAbbreviation)-2,1)) = 0
							Then LEFT(@OutdoorModelAbbreviation,len(@OutdoorModelAbbreviation)-3)
							Else LEFT(@OutdoorModelAbbreviation,len(@OutdoorModelAbbreviation)-2)
							End
					Else LEFT(@OutdoorModelAbbreviation,len(@OutdoorModelAbbreviation)-1)
					End
			Else @OutdoorModelAbbreviation
		End) 

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @OutdoorAbbreviation <> '' and @OutdoorAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @OutdoorAbbreviation)
	End
	 --Return the Outdoor Abbreviation GUID
	If @ResultGUID is NULL Set @ResultGUID = '00000000-0000-0000-0000-000000000000' 
	
	RETURN @ResultGUID

END



GO
