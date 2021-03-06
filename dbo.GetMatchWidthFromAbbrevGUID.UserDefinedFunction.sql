USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMatchWidthFromAbbrevGUID]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-4
-- Description:	Return @MatchWidth
-- =============================================
CREATE FUNCTION [dbo].[GetMatchWidthFromAbbrevGUID]
(
	-- Add the parameters for the function here
	@GUID uniqueidentifier
	,@GUIDType nvarchar(50)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MatchWidth int
			,@Abbreviation nvarchar(50)
	
	Set @Abbreviation = (Select Abbreviation
						 From [dbo].[Abbreviations]
						 Where AbbreviationGUID = @GUID)
						 
	Set @MatchWidth = 0
						 
	If @GUIDType = 'AH'
	Begin
		/* Air Handler */
		Set @MatchWidth = 
		(case when substring(@Abbreviation,5,1) = 'A' OR 
				(substring(@Abbreviation,6,1) = 'A' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'A' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 14 --14.5 
			when substring(@Abbreviation,5,1) = 'B' OR 
				(substring(@Abbreviation,6,1) = 'B' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'B' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 17 --17.5 
			when substring(@Abbreviation,5,1) = 'C' OR 
				(substring(@Abbreviation,6,1) = 'C' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'C' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 21 
			when substring(@Abbreviation,5,1) = 'D' OR 
				(substring(@Abbreviation,6,1) = 'D' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'D' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 24 --24.5
			Else 0 end) 
	End
	
	If @GUIDType = 'F'
	Begin
		/* Furnace */
		If CHARINDEX(')',@Abbreviation,1) > 0
		Begin
			Set @Abbreviation = Left(@Abbreviation,CHARINDEX('(',@Abbreviation,1)-1) + 
								Substring(@Abbreviation,CHARINDEX('(',@Abbreviation,1)+1,1) + 
								RIGHT(@Abbreviation,LEN(@Abbreviation)-CHARINDEX(')',@Abbreviation,1))
		End
		
		Set @MatchWidth = 
		(case when substring(@Abbreviation,8,1) = 'A' OR (substring(@Abbreviation,9,1) = 'A' and isNumeric(substring(@Abbreviation,8,1)) = 1) then 14 
			 when substring(@Abbreviation,8,1) = 'B' OR (substring(@Abbreviation,9,1) = 'B' and isNumeric(substring(@Abbreviation,8,1)) = 1) then 17 
			 when substring(@Abbreviation,8,1) = 'C' OR (substring(@Abbreviation,9,1) = 'C' and isNumeric(substring(@Abbreviation,8,1)) = 1) then 21 
			 when substring(@Abbreviation,8,1) = 'D' OR (substring(@Abbreviation,9,1) = 'D' and isNumeric(substring(@Abbreviation,8,1)) = 1) then 24
			 when SUBSTRING(@Abbreviation,6,1) = 'A' then 14 --'L*9C*C16'
			 when SUBSTRING(@Abbreviation,6,1) = 'B' then 17 
			 when SUBSTRING(@Abbreviation,6,1) = 'C' then 21 
			 when SUBSTRING(@Abbreviation,6,1) = 'D' then 24 
			 Else 0 end)
	End

	If @GUIDType = 'C'
	Begin
		/* Coil */
		If dbo.NthCharindex(5,'/',@Abbreviation) > 0
		Begin
			Set @Abbreviation = RIGHT(@Abbreviation,LEN(@Abbreviation)- dbo.NthCharindex(5,'/',@Abbreviation))
		End
		
		Set @MatchWidth = 
		(case when SUBSTRING(@Abbreviation,1,2) = 'HD' then 0
			when substring(@Abbreviation,5,1) = 'A' OR 
				(substring(@Abbreviation,6,1) = 'A' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'A' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 14 
			when substring(@Abbreviation,5,1) = 'B' OR 
				(substring(@Abbreviation,6,1) = 'B' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'B' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 17 
			when substring(@Abbreviation,5,1) = 'C' OR 
				(substring(@Abbreviation,6,1) = 'C' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'C' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 21 
			when substring(@Abbreviation,5,1) = 'D' OR 
				(substring(@Abbreviation,6,1) = 'D' and isNumeric(substring(@Abbreviation,5,1)) = 1) OR 
				(substring(@Abbreviation,7,1) = 'D' and isNumeric(substring(@Abbreviation,6,1)) = 1) then 24 
			Else 0 end)
	End

	-- Return the @MatchWidth 
	RETURN @MatchWidth

END

GO
