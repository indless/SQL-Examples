USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAbbreviationGUIDCoil]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Coil Abbreviation GUID 
-- =============================================
CREATE FUNCTION [dbo].[GetAbbreviationGUIDCoil]
(
	-- Add the parameters for the function here
	@IndoorAbbreviation nvarchar(50)
)
RETURNS uniqueidentifier
AS
BEGIN

	Declare @ResultGUID uniqueidentifier /* Coil Abbreviation GUID */
			,@CoilAbbreviation nvarchar(50)
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'

	/* Parse Indoor and return Coil abbreviation */
	Set @CoilAbbreviation = 
	
		(Case
			When LEFT(@IndoorAbbreviation,2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			Then Case 
					When Charindex('+',@IndoorAbbreviation,1) > 0 /* When there's a + Air Handler or +TXV */
					Then Left(@IndoorAbbreviation,Charindex('+',@IndoorAbbreviation,1)-1) /* take left of first + for Coil abbreviation */
					Else @IndoorAbbreviation /* Loose Coil only Abbreviation */
					End 
			Else ''
		End) 

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @CoilAbbreviation <> '' and @CoilAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @CoilAbbreviation)
	End
	 --Return the Coil Abbreviation GUID
	RETURN @ResultGUID

END



GO
