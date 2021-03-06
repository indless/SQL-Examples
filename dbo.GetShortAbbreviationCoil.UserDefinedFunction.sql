USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortAbbreviationCoil]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Coil Abbreviation GUID 
-- =============================================
CREATE FUNCTION [dbo].[GetShortAbbreviationCoil]
(
	-- Add the parameters for the function here
	@CoilAbbreviationGUID uniqueidentifier
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @CoilAbbreviation nvarchar(50)
			,@numOfCoilAbbreviations int
			,@hasDash bit
	
	/* Search for abbreviation, get AbbreviationGUID */
	Set @CoilAbbreviation = (SELECT [Abbreviation]
						     FROM [dbo].[Abbreviations]
						     Where [AbbreviationGUID] = @CoilAbbreviationGUID)

	If CharIndex('/',@CoilAbbreviation,1) > 0 Set @hasDash = 1 -- 'TRUE'
	Else Set @hasDash = 0 --'FALSE'
	
	If @hasDash = 1
	Begin
		Set @numOfCoilAbbreviations = ((select dbo.NthCharindex(5,'/',@CoilAbbreviation)) / CharIndex('/',@CoilAbbreviation,1)) + 1 
		Set @CoilAbbreviation = Left(@CoilAbbreviation,((CharIndex('/',@CoilAbbreviation,1) * @numOfCoilAbbreviations)-1))
	End
	Else
	Begin
		Set @CoilAbbreviation = 
		
					(Case
						When @CoilAbbreviation IS NULL
							Then 'Empty Abbreviation'
						When isNumeric(substring(@CoilAbbreviation,3,1)) = 1
							Then LEFT(@CoilAbbreviation,2) 
						When isNumeric(substring(@CoilAbbreviation,4,1)) = 1
							Then LEFT(@CoilAbbreviation,3)
						When isNumeric(substring(@CoilAbbreviation,5,1)) = 1
							Then LEFT(@CoilAbbreviation,4)
						End)
	End

	 --Return the short Coil Abbreviation 
	RETURN @CoilAbbreviation

END



GO
