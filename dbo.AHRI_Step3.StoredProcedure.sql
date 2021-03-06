USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step3]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 3 of AHRI load process, Create/Update Abbreviations & MaterialMaster Mappings
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step3]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @count as int
			,@max as int
			,@Abbreviation nvarchar(50)
	
	Set @count = 1
	Set @max = (Select Count(*) From [dbo].[temp_AHRI_Outdoor])
	
	While @count <= @max
	Begin
		Set @Abbreviation = (Select Abbreviation From [dbo].[temp_AHRI_Outdoor] Where ID = @count)
		Execute dbo.AbbreviationGUIDUpdateOutdoor @Abbreviation
		Set @count = @count + 1
	End
	
	
	Set @count = 1
	Set @max = (Select Count(*) From [dbo].[temp_AHRI_Coil])
	
	While @count <= @max
	Begin
		Set @Abbreviation = (Select Abbreviation From [dbo].[temp_AHRI_Coil] Where ID = @count)
		Execute dbo.AbbreviationGUIDUpdateCoil @Abbreviation
		Set @count = @count + 1
	End
	
	
	Set @count = 1
	Set @max = (Select Count(*) From [dbo].[temp_AHRI_AirHandler])
	
	While @count <= @max
	Begin
		Set @Abbreviation = (Select Abbreviation From [dbo].[temp_AHRI_AirHandler] Where ID = @count)
		Execute dbo.AbbreviationGUIDUpdateAirHandler @Abbreviation
		Set @count = @count + 1
	End
	
	
	Set @count = 1
	Set @max = (Select Count(*) From [dbo].[temp_AHRI_Furnace])
	
	While @count <= @max
	Begin
		Set @Abbreviation = (Select Abbreviation From [dbo].[temp_AHRI_Furnace] Where ID = @count)
		Execute dbo.AbbreviationGUIDUpdateFurnace @Abbreviation
		Set @count = @count + 1
	End	


	/* Drop Temp tables */
	DROP TABLE temp_AHRI_Outdoor
	DROP TABLE temp_AHRI_Coil
	DROP TABLE temp_AHRI_AirHandler
	DROP TABLE temp_AHRI_Furnace

END

GO
