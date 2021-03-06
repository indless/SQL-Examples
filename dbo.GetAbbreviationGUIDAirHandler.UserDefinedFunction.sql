USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAbbreviationGUIDAirHandler]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Air Handler Abbreviation GUID 
-- =============================================
CREATE FUNCTION [dbo].[GetAbbreviationGUIDAirHandler]
(
	-- Add the parameters for the function here
	@IndoorAbbreviation nvarchar(50)
)
RETURNS uniqueidentifier
AS
BEGIN

	Declare @ResultGUID uniqueidentifier /* Air Handler Abbreviation GUID */
			,@AirHandlerAbbreviation nvarchar(50)
	
	Set @ResultGUID = '00000000-0000-0000-0000-000000000000'

	/* Parse Indoor and return Air Handler abbreviation */
	Set @AirHandlerAbbreviation = 
	
		(Case
			When LEFT(@IndoorAbbreviation,2) not in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation does not have separate Coil */
			Then Case 
					When Charindex('+',@IndoorAbbreviation,1) > 0 /* checks for + for what should be a +TXV */
					/* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					/* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					/* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					/* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					/* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					Then Left(@IndoorAbbreviation,Charindex('+',@IndoorAbbreviation,1)-1) /* remove +TXV ****** Should parse back to the width character (this will allow all factory installed TXV coils to show) ******* */
					Else @IndoorAbbreviation /* Air Handler only abbreviation */
					End 
			Else Case	
					When Charindex('+',@IndoorAbbreviation,1) > 0 /* Abbreviation starts with Coil & + Air Handler */
						and Charindex('+',@IndoorAbbreviation,1) <> Charindex('+TXV',@IndoorAbbreviation,1)
					Then Case 
							When Charindex('+TXV',@IndoorAbbreviation,1) > 0 /* has +TXV */
							Then SUBSTRING(@IndoorAbbreviation
									,Charindex('+',@IndoorAbbreviation,1)+1
									,Charindex('+TXV',@IndoorAbbreviation,1)-1 - Charindex('+',@IndoorAbbreviation,1)) /* take the Air Handler abbreviation between first + and +TXV */
							Else SUBSTRING(@IndoorAbbreviation
									,Charindex('+',@IndoorAbbreviation,1)+1
									,Len(@IndoorAbbreviation) - Charindex('+',@IndoorAbbreviation,1)) /* take the Air Handler abbreviation after + */
							End
					Else '' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
					End
			End) 

	/* IF the abbreviation is blank or null, leave it set to default 000.. value */
	If @AirHandlerAbbreviation <> '' and @AirHandlerAbbreviation is not NULL
	Begin
		/* Search for abbreviation, get AbbreviationGUID */
		Set @ResultGUID = (SELECT [AbbreviationGUID]
						   FROM [dbo].[Abbreviations]
						   Where Abbreviation = @AirHandlerAbbreviation)
	End
	
	If @ResultGUID is NULL Set @ResultGUID = '00000000-0000-0000-0000-000000000000'
	
	-- Return the Air Handler Abbreviation GUID
	RETURN @ResultGUID

END



GO
