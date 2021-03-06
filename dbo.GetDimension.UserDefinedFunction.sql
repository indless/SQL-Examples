USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDimension]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the specifiied dimension (L,W,H) from the provided @dimensionString (returns NULL if @dimensionString is not in a semi standard format) 
-- =============================================
CREATE FUNCTION [dbo].[GetDimension]
(
	-- Add the parameters for the function here 
	@dimensionString nvarchar(100),
	@dimensionType nvarchar(50)
	
)
RETURNS decimal(8,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @return nvarchar(25)--decimal(8,2)
			,@index int
	
	Set @return = ''
	
	IF CharIndex('L',@dimensionString,1) < CharIndex('W',@dimensionString,1) 
		and CharIndex('W',@dimensionString,1) < CharIndex('H',@dimensionString,1) 
		and CharIndex(@dimensionType,@dimensionString,1) > 0
	Begin 
		Set @index = CharIndex(@dimensionType,@dimensionString,1)+1
		
		While (ISNumeric(SubString(@dimensionString,@index,1))> 0 OR SubString(@dimensionString,@index,1) in (' ','.',':',';')) 
				And SubString(@dimensionString,@index,1) not in (CHAR(45),CHAR(151)) /* short and long dash characters */
				And @index <= LEN(@dimensionString)
		Begin
			If ISNumeric(SubString(@dimensionString,@index,1))> 0 OR SubString(@dimensionString,@index,1) = '.'
			Begin
				Set @return = @return + SubString(@dimensionString,@index,1)		
			End
			Set @index = @index + 1
		End
	End
	Else
	Begin
		Set @return = '0'
	End			   
					   
	-- Return the result of the function
	RETURN Cast(@return as decimal(8,2))

END


GO
