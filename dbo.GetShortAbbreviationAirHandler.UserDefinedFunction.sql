USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortAbbreviationAirHandler]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the short Air Handler Abbreviation  
-- =============================================
CREATE FUNCTION [dbo].[GetShortAbbreviationAirHandler]
(
	-- Add the parameters for the function here
	@AirHandlerAbbreviationGUID uniqueidentifier
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @AirHandlerAbbreviation nvarchar(50) /* Air Handler Abbreviation GUID */
			
	
	/* Search for @IndoorAbbreviationGUID, get @AirHandlerAbbreviation */
	Set @AirHandlerAbbreviation = (SELECT [Abbreviation]
								   FROM [dbo].[Abbreviations]
								   Where [AbbreviationGUID] = @AirHandlerAbbreviationGUID)

	If @AirHandlerAbbreviation <> 'Empty Abbreviation'
	Begin
		If @AirHandlerAbbreviation is NULL Set @AirHandlerAbbreviation = 'Empty Abbreviation'

		/* Trim to short AH abbreviation */
		Set @AirHandlerAbbreviation =
		
			(Case
				When @AirHandlerAbbreviation IS NULL
					Then 'Empty Abbreviation'
				When isNumeric(substring(@AirHandlerAbbreviation,3,1)) = 1
					Then LEFT(@AirHandlerAbbreviation,2) 
				When isNumeric(substring(@AirHandlerAbbreviation,4,1)) = 1
					Then LEFT(@AirHandlerAbbreviation,3)
				When isNumeric(substring(@AirHandlerAbbreviation,5,1)) = 1
					Then LEFT(@AirHandlerAbbreviation,4)
				End)
	End
	-- Return the short Air Handler Abbreviation 
	RETURN @AirHandlerAbbreviation

END



GO
