USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_HP_Performance]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* HP Explicit Matchups & Detailed Performance Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_HP_Performance]
	-- Add the parameters for the stored procedure here
	@Wrightsoft_Brand nvarchar(30)
	,@Short_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* York Heat Pump matchups */
	SELECT distinct
	  bmid.BaseModelID as "BaseModelID"
	  ,@Wrightsoft_Brand as "MfrCode"
	  ,m.[ARIRefNumber]
	  ,m.[OutdoorModelNumber] as "Condenser Model"
	  ,Case When m.[CoilModelNumber] is NULL Then ''
			Else m.[CoilModelNumber] End as "Coil Model"
	  ,Case When m.[FurnaceModelNumber] is NULL Then ''
			Else m.[FurnaceModelNumber] End as "Furn Model"
	  ,m.[TXV] as "AccCode"
	  ,'1' as "UnitType"
	  ,pwr.PwrRtd * Case When perfCF.KilowattsMultiplier is Not Null Then perfCF.KilowattsMultiplier Else 1 End as "PwrRtd"
	  ,'1' as "PowerCorr"
	  ,'0.28' as "ESPRtd"
	  ,m.[TotalCapacity] as "Cap95"
	  ,'1' as "CoolCapCorr"
	  ,'1' as "SensCapCorr"
	  ,m.[EER] as "EER95"
	  ,m.[SEER] as "SEER/EER"
	  ,hp.[Heat_Cap_H1_2_Single_or_High_Stage_47F] as "Cap47"
	  ,'1' as "HeatCapCorr"
	  ,hp.[Heat_COP_H1_2_Single_or_High_Stage_47F] as "COP47"
	  ,m.[HSPF] as "HSPF"
	  ,pwr.HtgPower * Case When perfHF.KWMultiplier is Not Null Then perfHF.KWMultiplier Else 1 End as "HtgPower"
	  ,'1' as "HtgPowerCorr"
	  ,m.[Airflow] as "AVF"
	  ,pwr.Voltage
	  ,pwr.Phase
	FROM [dbo].[MatchingSystemsWrightsoft] as m
	Right Join [dbo].[AHRI_HP] as hp on hp.AHRIRefNumber = m.ARIRefNumber
	Right Join [dbo].[OutdoorUnits] as o on o.ModelNumber = m.OutdoorModelNumber and o.BrandCode = m.BrandCode
	Join [ResidentialSplitsNewQA2].[dbo].[BaseModelId] as bmid on bmid.Model = m.OutdoorModelNumber
	Join (
		/* Outdoor HP base performance data */
		Select distinct 
			Case 
				When ustactiveod.BrandDescription = 'York' Then 'YRK'
				When ustactiveod.BrandDescription = 'Coleman' Then 'COLU'
				When ustactiveod.BrandDescription = 'Luxaire' Then 'LUXA'
				When ustactiveod.BrandDescription = 'Champion' Then 'CHA'
				When ustactiveod.BrandDescription = 'Evcon' Then 'EVCN'
				When ustactiveod.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
				When ustactiveod.BrandDescription = 'Guardian' Then 'GUAR'
				End as "MfrCode"
			,mma.MaterialNumber as "CondenserModel"
			,'' as "CoilModel"
			,'' as "FurnModel"
			,'1' as "UnitType"
			,cp.[KW] as "PwrRtd"
			,'1' as "PowerCorr"
			,'0.28' as "ESPRtd"
			,'1' as "CoolCapCorr"
			,'1' as "SensCapCorr"
			,hp.[COP] as "COP47"
			,'' as "HSPF"
			,hp.[KW] as "HtgPower"
			,'1' as "HtgPowerCorr"
			,(Case 
				When Substring(sv.[Description],4,1) = '/' Then LEFT(sv.[Description],7)
				Else LEFT(sv.[Description],3)
				End
				) as "Voltage"
			,sv.[Phase] as "Phase"
		From
			[ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma
			inner join [ResidentialSplitsNewQA2].[dbo].[CoolingPerformanceGroups] as cpg on cpg.OutdoorUnitAbbrevGuid = mma.AbbreviationGUID
				inner join 	
					(	
						select * from (
							Select *, ROW_NUMBER() OVER (ORDER BY CoolingPerformanceGroupGUID, OutdoorTemperature, IndoorDryBulb, IndoorWetBulb, IndoorCFM) AS "RowNumber"
							From
								(
								Select top 5000000 *
								From [ResidentialSplitsNewQA2].[dbo].[CoolingPerformance]
								where [OutdoorTemperature] = 95 and [IndoorDryBulb] = 80 and [IndoorWetBulb] = 67
								order by CoolingPerformanceGroupGUID, OutdoorTemperature, IndoorDryBulb, IndoorWetBulb, IndoorCFM asc
								) as cp1
								) as cp2
							where (RowNumber + 1) %3 = 0
						) as cp on cp.CoolingPerformanceGroupGUID = cpg.CoolingPerformanceGroupGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[HeatingPerformanceGroups] as hpg on hpg.OutdoorUnitAbbrevGUID = mma.AbbreviationGUID
				inner join 
					(	
						select * from (
							Select *, ROW_NUMBER() OVER (ORDER BY HeatingPerformanceGroupGUID, OutdoorTemp, IndoorTemp, IndoorCFM) AS "RowNumber"
							From
								(
								Select top 5000000 *
								From [ResidentialSplitsNewQA2].[dbo].[HeatingPerformance]
								where [OutdoorTemp] = 47 and [IndoorTemp] = 70 
								order by HeatingPerformanceGroupGUID, OutdoorTemp, IndoorTemp, IndoorCFM asc
								) as hp1
								) as hp2
							where (RowNumber + 1) %3 = 0
						) as hp on hp.HeatingPerformanceGroupGUID = hpg.HeatingPerformanceGroupGUID
			join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma2 on mma2.MaterialNumber = mma.MaterialNumber
			join [ResidentialSplitsNewQA2].[dbo].[PhysicalandElectricalData] as pe on pe.ModelAbbreviationGuid = mma2.AbbreviationGUID and pe.UnitSupplyVoltage is not NULL
			inner join [ResidentialSplitsNewQA2].[dbo].[ServiceVoltages] as sv on sv.ServiceVoltageGUID = pe.UnitSupplyVoltage
			Left join [ResidentialSplitsNewQA2].[dbo].[vwUSTActiveOutdoorUnits] as ustactiveod on ustactiveod.MaterialNumber = mma.MaterialNumber
			where ustactiveod.ProductionStatus <> 'P4' and ustactiveod.ProductClassDescription = 'Heat Pump'
		) as pwr on pwr.CondenserModel = m.OutdoorModelNumber 
	Left Join (
			/* CoolingPerformanceMultipliers */ 
			Select distinct 
				'Cooling' as "Type"
				,abrev3.MaterialNumber as "CondenserModel"
				,abrev.MaterialNumber as "FurnModel"
				,abrev2.MaterialNumber as "CoilModel"
				,cpm.TotalCapacityMultiplier
				,cpm.SensibleCapacityMultiplier
				,cpm.KilowattsMultiplier
			From [ResidentialSplitsNewQA2].[dbo].[CoolingPerformanceMultipliers] as cpm
			inner join [ResidentialSplitsNewQA2].[dbo].[CoolingPerformanceGroups] as cpg on cpg.CoolingPerformanceGroupGUID = cpm.CoolingPerformanceGroupGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev on abrev.AbbreviationGUID = cpm.IndoorUnitAbbrevGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev2 on abrev2.AbbreviationGUID = cpm.IndoorCoilAbbrevGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev3 on abrev3.AbbreviationGUID = cpg.OutdoorUnitAbbrevGUID
			) as perfCF on perfCF.CondenserModel = m.OutdoorModelNumber and perfCF.CoilModel = m.CoilModelNumber and perfCF.FurnModel = m.FurnaceModelNumber
	Left Join (
			/* HeatingPerformanceMultipliers */ 
			Select distinct 
				'Heating' as "Type"
				,abrev3.MaterialNumber as "CondenserModel"
				,abrev.MaterialNumber as "FurnModel"
				,abrev2.MaterialNumber as "CoilModel"
				,hpm.MBHMultiplier
				,hpm.KWMultiplier
				,hpm.COPMultiplier
			From [ResidentialSplitsNewQA2].[dbo].[HeatingPerformanceMultipliers] as hpm
			inner join [ResidentialSplitsNewQA2].[dbo].[HeatingPerformanceGroups] as hpg on hpg.HeatingPerformanceGroupGUID = hpm.HeatingPerformanceGroupGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev on abrev.AbbreviationGUID = hpm.IndoorUnitAbbrevGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev2 on abrev2.AbbreviationGUID = hpm.IndoorCoilAbbrevGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as abrev3 on abrev3.AbbreviationGUID = hpg.OutdoorUnitAbbrevGUID
			) as perfHF on perfHF.CondenserModel = m.OutdoorModelNumber and perfHF.CoilModel = m.CoilModelNumber and perfHF.FurnModel = m.FurnaceModelNumber
	where m.BrandCode = @Short_Brand and o.MatchupType = 'HeatPump'  and m.[AirHandlerModelNumber] is Null
	Order By m.ARIRefNumber, "Coil Model", "Furn Model" asc  
END

GO
