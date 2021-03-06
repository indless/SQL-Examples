USE [MasterDataManagement]
GO
/****** Object:  UserDefinedFunction [dbo].[NthCharindex]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-10-28
-- Description:	Return the index location of the nth or last appearance of @searchChar 
-- =============================================
CREATE FUNCTION [dbo].[NthCharindex]
(
	-- Add the parameters for the function here
	@nth int, 
	@searchChar nvarchar(50),
	@searchExpression nvarchar(50)
	
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultIndex int,
			@thisIndex int
	
	Set @thisIndex = 0
	
	While (CHARINDEX(@searchChar,@searchExpression,@thisIndex +1) > 0 and @nth > 0)
	Begin
		Set @thisIndex = CHARINDEX(@searchChar,@searchExpression,@thisIndex +1)
		Set @nth = @nth -1
	End
	
	-- Add the T-SQL statements to compute the return value here
	SELECT @ResultIndex = @thisIndex

	-- Return the result of the function
	RETURN @ResultIndex

END

GO
