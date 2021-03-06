USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortAirHandler]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the short Air Handler   
-- =============================================
CREATE FUNCTION [dbo].[GetShortAirHandler]
(
	-- Add the parameters for the function here
	@AirHandlerModel nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @ShortAirHandler nvarchar(50) 
	
	/* Trim to short AH abbreviation */
	Set @ShortAirHandler =
	
		(Case
			When @AirHandlerModel IS NULL
				Then 'Empty'
			When isNumeric(substring(@AirHandlerModel,3,1)) = 1
				Then LEFT(@AirHandlerModel,2) 
			When isNumeric(substring(@AirHandlerModel,4,1)) = 1
				Then LEFT(@AirHandlerModel,3)
			When isNumeric(substring(@AirHandlerModel,5,1)) = 1
				Then LEFT(@AirHandlerModel,4)
			Else @AirHandlerModel
			End)

	-- Return the short Air Handler  
	RETURN @ShortAirHandler

END



GO
