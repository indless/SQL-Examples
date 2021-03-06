USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetShortFurnace]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the short Furnace   
-- =============================================
CREATE FUNCTION [dbo].[GetShortFurnace]
(
	-- Add the parameters for the function here
	@FurnaceModel nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN

	Declare @ShortFurnace nvarchar(50) /* Furnace Abbreviation GUID */
			
	/* Trim to short Furnace */
	Set @ShortFurnace =
	
			(Case
				When @FurnaceModel IS NULL
					Then 'Empty'
				When LEFT(@FurnaceModel,3) = 'RGF'
					Then LEFT(@FurnaceModel,5)
				When isNumeric(substring(@FurnaceModel,5,1)) = 1
					Then LEFT(@FurnaceModel,4)
				Else @FurnaceModel
				End)

	-- Return the short Furnace  
	RETURN @ShortFurnace

END



GO
