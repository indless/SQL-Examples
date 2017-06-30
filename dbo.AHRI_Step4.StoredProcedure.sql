USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step4]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 4 of AHRI load process, populate CoolingCapacity & HeatingCapacity tables
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step4]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Truncate Table CoolingCapacity
	Truncate Table HeatingCapacity
	--Truncate Table CoolingCapacity_test
	--Truncate Table HeatingCapacity_test
	
	/* Delete Thermo & Style OEMName and ResPac Outdoor Models from AHRI_AC_MarketingReport & AHRI_HP_MarketingReport */
	/* Delete DoNotPublish ModelStatus from AHRI_AC_MarketingReport & AHRI_HP_MarketingReport */
	Delete From AHRI_AC_MarketingReport
	Where OEMName like 'Thermo%' or ModelStatus = 'DoNotPublish' or OEMName like 'Style%'
	or [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] is null
	
	Delete From AHRI_HP_MarketingReport
	Where OEMName like 'Thermo%' or ModelStatus = 'DoNotPublish'
	or [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] is null
	
	
	/****************************************/
	/* Add Brand varchar(50) to CC & HP */
	/****************************************/
	--Select dbo.GetAbbreviationGUIDFurnace('TM8X080C16MP11')
	
	
	/* Add a record for each AC & HP matchup into CoolingCapacity */
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,Cast((Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as decimal(8, 2)) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_AC_MarketingReport]
	
	--Union 
	
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,(Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_HP_MarketingReport]
	
	
	/* Add a record for each HP matchup into HeatingCapacity */
	--Insert Into [dbo].[HeatingCapacity_test]
	Insert Into [dbo].[HeatingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,'2' as 'Stage'
			,47 as 'ODTemp'
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/1000 as 'MBH'
			,[Heat COP (H1-2) - Single or High Stage (47F)] as 'COP'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/([Heat COP (H1-2) - Single or High Stage (47F)]*3.41*1000) as 'KW'
			,[HSPF (Region IV)] as 'HSPF'
			,1 as 'ARI'
			,[DEG COEF HEAT] as 'DegCoefHeat'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand'
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGuid'
	From [dbo].[AHRI_HP_MarketingReport]	
	
	
	/* Create TG*S Furnace Matchups *********************************************************************************************************************************************************************************/
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace('TG*S')) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,Cast((Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as decimal(8, 2)) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace('TG*S'))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_AC_MarketingReport]
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null	
		
	
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace('TG*S')) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,(Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace('TG*S'))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_HP_MarketingReport]
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null	
	
	
	--Insert Into [dbo].[HeatingCapacity_test]
	Insert Into [dbo].[HeatingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace('TG*S')) as 'VSFurnaceAbbrevGuid'
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace('TG*S'))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace('TG*S')) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,'2' as 'Stage'
			,47 as 'ODTemp'
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/1000 as 'MBH'
			,[Heat COP (H1-2) - Single or High Stage (47F)] as 'COP'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/([Heat COP (H1-2) - Single or High Stage (47F)]*3.41*1000) as 'KW'
			,[HSPF (Region IV)] as 'HSPF'
			,1 as 'ARI'
			,[DEG COEF HEAT] as 'DegCoefHeat'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand'
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGuid'
	From [dbo].[AHRI_HP_MarketingReport]	
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null	
		
	
	
	/* Create MP Air Handler Matchups *********************************************************************************************************************************************************************************/
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler('MP*')) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,Cast((Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as decimal(8, 2)) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler('MP*'))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_AC_MarketingReport]
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null	
		
	
	--Insert Into [dbo].[CoolingCapacity_test]
	Insert Into [dbo].[CoolingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler('MP*')) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,'2' as 'Stage'
			,Cast((Select dbo.GetMinCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as decimal(8, 2)) as 'MinCFM'/* 'Outdoor CoolingPerformance Min CFM' */
			,(Select dbo.GetMaxCFM_FromPerformance((Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])),'Cooling')) as 'MaxCFM' /* 'Outdoor CoolingPerformance Max CFM' */
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler('MP*'))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,Case
				When Right([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4)='+TXV'
				Then 1
				Else 0
				End as 'TXV'
			,'1' as 'TDR'
			,[DEG COEF COOL] as 'DegCOOfCool'
			,[Cool Cap (A2) - Single or High Stage (95F)] / 1000 as 'TotalNetMBH'
			,'0' as 'SensibleNetMBH'
			,[SEER] as 'SEER'
			,[EER (A2) - Single or High Stage (95F)] as 'EER'
			,[Cool Cap (B2) - Single or High Stage (82F)]/1000 as 'Cap_BPoint'
			,[EER (B2) - Single or High Stage (82F)] as 'EER_BPoint'
			,[Cool Cap (A2) - Single or High Stage (95F)]/1000 as 'Cap_95'
			,[EER (A2) - Single or High Stage (95F)] as 'EER_95'
			,NULL as 'Cap_105'
			,NULL as 'EER_105'
			,NULL as 'Cap_115'
			,NULL as 'EER_115'
			,'' as 'ElectricHeatKW'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand' 
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGUID'
	From [dbo].[AHRI_HP_MarketingReport]
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null	
	
	
	--Insert Into [dbo].[HeatingCapacity_test]
	Insert Into [dbo].[HeatingCapacity]
	Select Distinct NEWID() as 'RowGUID'
			,Case
				When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
				Then 'VSFurnace'
				Else Case
						When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
						Then 'Air Handler'
						Else 'Coil'
						End
				End as 'MatchupType'
			,(Select dbo.GetAbbreviationGUIDOutdoor([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])) as 'OutdoorUnitAbbrevGUID'
			,(Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) as 'CoilAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDAirHandler('MP*')) as 'AirHandlerAbbrevGuid'
			,(Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) as 'VSFurnaceAbbrevGuid'
			,(Select dbo.GetMatchWidthFromAbbrevGUID(Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then Null
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL]))
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then (Select dbo.GetAbbreviationGUIDAirHandler('MP*'))
																Else (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]))
																End
														End,
													 Case
														When (Select dbo.GetAbbreviationGUIDCoil([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)])) = '00000000-0000-0000-0000-000000000000' Then 'C'
														When (Select dbo.GetAbbreviationGUIDFurnace([FURNACE MODEL])) <> '00000000-0000-0000-0000-000000000000'
														Then 'F'
														Else Case
																When (Select dbo.GetAbbreviationGUIDAirHandler('MP*')) <> '00000000-0000-0000-0000-000000000000'
																Then 'AH'
																Else 'C'
																End
														End
														)) as 'Width' /* Indoor Model Width */
			,'2' as 'Stage'
			,47 as 'ODTemp'
			,[INDOOR FULL-LOAD AIR VOLUME RATE (A2 SCFM)] as 'RatedCFM'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/1000 as 'MBH'
			,[Heat COP (H1-2) - Single or High Stage (47F)] as 'COP'
			,[Heat Cap (H1-2) - Single or High Stage (47F)]/([Heat COP (H1-2) - Single or High Stage (47F)]*3.41*1000) as 'KW'
			,[HSPF (Region IV)] as 'HSPF'
			,1 as 'ARI'
			,[DEG COEF HEAT] as 'DegCoefHeat'
			,Left([OEMName],CHARINDEX(' ',[OEMName],1)-1) as 'Brand'
			,[AHRIRefNumber] as 'ARIRefNumber'
			,NULL as 'NoteGuid'
	From [dbo].[AHRI_HP_MarketingReport]	
	Where (Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC','HD') /* When the abbreviation has separate Coil */
			And (Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <= 0 /* Abbreviation starts with Coil & + TXV or not + */
				 or Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) = Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1))
			Then 'No Air Handler' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
			Else 'Air Handler'
			End)  = 'No Air Handler'
		And [FURNACE MODEL] is Null		
	
	
END

GO
