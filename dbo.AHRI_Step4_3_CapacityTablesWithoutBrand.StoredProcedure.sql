USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step4_3_CapacityTablesWithoutBrand]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 4_3 of AHRI load process, Truncate Table CoolingCapacity & HeatingCapacity, Load using CoolingCapacity_test & HeatingCapacity_test (will not contain brand, loses unique AHRI#'s per brand)
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step4_3_CapacityTablesWithoutBrand]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Truncate table dbo.CoolingCapacity

	Insert into [dbo].[CoolingCapacity]
	Select distinct	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'York' 
	   

	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'Coleman' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Coleman')

													 
	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'Luxaire' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Luxaire')
			
			
	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'Champion' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Champion')


	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand like 'FR%' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand like 'FR%')


	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'Guardian' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Guardian')

			   
	Insert into [dbo].[CoolingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGUID]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Stage]
		  ,[MinCFM]
		  ,[MaxCFM]
		  ,[Width]
		  ,[RatedCFM]
		  ,[TXV]
		  ,[TDR]
		  ,[DegCOOfCool]
		  ,[TotalNetMBH]
		  ,[SensibleNetMBH]
		  ,[SEER]
		  ,[EER]
		  ,[Cap_BPoint]
		  ,[EER_BPoint]
		  ,[Cap_95]
		  ,[EER_95]
		  ,[Cap_105]
		  ,[EER_105]
		  ,[Cap_115]
		  ,[EER_115]
		  ,[ElectricHeatKW]
		  ,[ARIRefNumber]
		  ,[NoteGUID]
	   FROM [dbo].[CoolingCapacity_test]
	   Where Brand = 'Evcon' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[CoolingCapacity_test] as cct
													 join [dbo].[CoolingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Evcon')
			
	   
	Delete from [dbo].[CoolingCapacity]
	where OutdoorUnitAbbrevGUID = '00000000-0000-0000-0000-000000000000' 


	/*************************************************************************************************************************************************************************/


	Truncate table dbo.HeatingCapacity

	Insert into [dbo].[HeatingCapacity]
	Select distinct	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'York' 

	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'Coleman' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Coleman')

													 
	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'Luxaire' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Luxaire')
			
			
	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'Champion' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Champion')


	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand like 'FR%' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand like 'FR%')


	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'Guardian' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Guardian')
		   
	
	Insert into [dbo].[HeatingCapacity]
	Select	
		   [RowGuid]
		  ,[MatchupType]
		  ,[OutdoorUnitAbbrevGuid]
		  ,[CoilAbbrevGuid]
		  ,[AirHandlerAbbrevGuid]
		  ,[VSFurnaceAbbrevGuid]
		  ,[Width]
		  ,[Stage]
		  ,[ODTemp]
		  ,[RatedCFM]
		  ,[MBH]
		  ,[COP]
		  ,[KW]
		  ,[HSPF]
		  ,[ARI]
		  ,[DegCoefHeat]
		  ,[ARIRefNumber]
		  ,[NoteGuid]
	   FROM [dbo].[HeatingCapacity_test]
	   Where Brand = 'Evcon' and [RowGuid] not in (Select cct.[RowGuid] 
													 From [dbo].[HeatingCapacity_test] as cct
													 join [dbo].[HeatingCapacity] as cc on 
													 cc.OutdoorUnitAbbrevGUID = cct.OutdoorUnitAbbrevGUID and 
													 cc.CoilAbbrevGuid = cct.CoilAbbrevGuid and 
													 cc.AirHandlerAbbrevGuid = cct.AirHandlerAbbrevGuid and 
													 cc.VSFurnaceAbbrevGuid = cct.VSFurnaceAbbrevGuid
													 Where Brand = 'Evcon')

	   
	Delete from [dbo].[HeatingCapacity]
	where OutdoorUnitAbbrevGUID = '00000000-0000-0000-0000-000000000000' 

END


GO
