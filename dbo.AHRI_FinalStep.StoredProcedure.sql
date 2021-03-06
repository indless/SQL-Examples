USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_FinalStep]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Final Step of AHRI load process
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_FinalStep]
	
AS
BEGIN

	SET NOCOUNT ON;
	
	EXEC AHRI_Step2
	EXEC AHRI_Step3
	
	/* Use this code if not running AHRI_Step4 */
	Truncate Table CoolingCapacity
	Truncate Table HeatingCapacity
	Truncate Table CoolingCapacity_test
	Truncate Table HeatingCapacity_test
	
	/* Delete Thermo & Style OEMName and ResPac Outdoor Models from AHRI_AC_MarketingReport & AHRI_HP_MarketingReport */
	/* Delete DoNotPublish ModelStatus from AHRI_AC_MarketingReport & AHRI_HP_MarketingReport */
	Delete From AHRI_AC_MarketingReport
	Where OEMName like 'Thermo%' or ModelStatus = 'DoNotPublish' or OEMName like 'Style%' or [OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)] like 'gaw%'
	or [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] is null
	
	Delete From AHRI_HP_MarketingReport
	Where OEMName like 'Thermo%' or ModelStatus = 'DoNotPublish' or OEMName like 'Style%' or [OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)] like 'gaw%'
	or [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] is null
	
	/* Loads AHRI Matchups */
	EXEC AHRI_Specific_Matchups NULL,NULL
	
	/* Update manual abbreviations with any new materials */
	--'TG*S'
	EXEC dbo.AbbreviationGUIDUpdateFurnace_AddOnModels 'TG*S'
	--'TM*M'
	EXEC dbo.AbbreviationGUIDUpdateFurnace_AddOnModels 'TM*M'
	--'TM*T'
	EXEC dbo.AbbreviationGUIDUpdateFurnace_AddOnModels 'TM*T'
	--'RGF*P'
	EXEC dbo.AbbreviationGUIDUpdateFurnace_AddOnModels 'RGF*P'
	--'MP08'
	EXEC dbo.AbbreviationGUIDUpdateAirHandler 'MP08'
	--'MP12'
	EXEC dbo.AbbreviationGUIDUpdateAirHandler 'MP12'
	--'MP14'
	EXEC dbo.AbbreviationGUIDUpdateAirHandler 'MP14'
	--'MP16'
	EXEC dbo.AbbreviationGUIDUpdateAirHandler 'MP16'
	--'MP20'
	EXEC dbo.AbbreviationGUIDUpdateAirHandler 'MP20'
	
	
	/* Loads TG*S furnace matchups using AHRI Loose Coil matchups */
	EXEC AHRI_Specific_Matchups NULL,'TG*S'
	EXEC AHRI_Specific_Matchups NULL,'TM*M' 
	EXEC AHRI_Specific_Matchups NULL,'TM*T' 
	EXEC AHRI_Specific_Matchups NULL,'RGF*P'
	
	/* Loads MP air handler matchups using AHRI Loose Coil matchups */
	EXEC AHRI_Specific_Matchups 'MP08',NULL
	EXEC AHRI_Specific_Matchups 'MP12',NULL
	EXEC AHRI_Specific_Matchups 'MP14',NULL
	EXEC AHRI_Specific_Matchups 'MP16',NULL
	EXEC AHRI_Specific_Matchups 'MP20',NULL
	
	/* Removes duplicates from CoolingCapacity & HeatingCapacity */
	EXEC AHRI_Step5

	/* Copies CoolingCapacity & HeatingCapacity tables for use by Res Split Web load process */
	Insert Into [dbo].[CoolingCapacity_test]
	Select * From [dbo].[CoolingCapacity]
	
	Insert Into [dbo].[HeatingCapacity_test]
	Select * From [dbo].[HeatingCapacity]
	
	--EXEC AHRI_Step4 
	--EXEC AHRI_Step4_ResSplitWeb /* Populates CoolingCapacity_test & HeatingCapacity_test */
	--EXEC AHRI_Step4_3_CapacityTablesWithoutBrand /* Populates CoolingCapacity & HeatingCapacity WITHOUT Brand */ /* No Longer necessary */


END


GO
