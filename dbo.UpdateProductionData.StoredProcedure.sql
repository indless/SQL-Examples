USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[UpdateProductionData]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateProductionData] 
	
AS
BEGIN
	
	EXEC UpdateCoolingPerformance
	EXEC UpdateMatchingSystemsMatchWidth
	EXEC  UpdateMatchingSystemsSEERAndEER
	EXEC UpdateMatchingSystemsSEERAndEERNoVS
	EXEC UpdateMatchingSystemsMissingSEERAndEER
	EXEC UpdateMatchingSystemsVSNoAFUE
	EXEC UpdateMatchingSystemsRegions
	EXEC UpdateMatchingSystemsRegionsNoVS
	EXEC SetSpecialREgions
	EXEC UpdateMatchingSystemsTXV
	EXEC UpdateMatchingSystemsTXVNoVS
	EXEC UpdateMismatchedTXVValues

	
END

GO
