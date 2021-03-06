USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortCoil]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the Coil Abbreviation GUID 
-- =============================================
Create FUNCTION [dbo].[GetShortCoil]
(
	-- Add the parameters for the function here
	@CoilModel nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @ShortCoil nvarchar(50)
	

	Set @ShortCoil = 
	
				(Case
					When @CoilModel IS NULL
						Then 'Empty'
					When isNumeric(substring(@CoilModel,3,1)) = 1
						Then LEFT(@CoilModel,2) 
					When isNumeric(substring(@CoilModel,4,1)) = 1
						Then LEFT(@CoilModel,3)
					When isNumeric(substring(@CoilModel,5,1)) = 1
						Then LEFT(@CoilModel,4)
					End)

	 --Return the short Coil  
	RETURN @ShortCoil

END



GO
