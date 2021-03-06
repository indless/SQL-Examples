USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_AC_Performance]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* AC Explicit Matchups & Detailed Performance Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_AC_Performance]
	-- Add the parameters for the stored procedure here
	@Wrightsoft_Brand nvarchar(30)
	,@Short_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* York Air Conditioner matchups */
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
	  ,pwr.UnitType
	  ,pwr.PwrRtd * Case When perfCF.KilowattsMultiplier is Not Null Then perfCF.KilowattsMultiplier Else 1 End as "PwrRtd"
	  ,pwr.PowerCorr 
	  ,pwr.ESPRtd
	  ,m.[TotalCapacity] as "Cap95"
	  ,pwr.CoolCapCorr
	  ,pwr.SensCapCorr
	  ,m.[EER] as "EER95"
	  ,m.[SEER] as "SEER"
	  ,m.[Airflow] as "AVF"
	  ,pwr.Voltage
	  ,pwr.Phase
	FROM [dbo].[MatchingSystemsWrightsoft] as m
	Right Join [dbo].[AHRI_AC] as ac on ac.AHRIRefNumber = m.ARIRefNumber
	Right Join [dbo].[OutdoorUnits] as o on o.ModelNumber = m.OutdoorModelNumber and o.BrandCode = m.BrandCode
	Join (
		/* Outdoor AC base performance data */
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
			,mma2.MaterialNumber as "CondenserModel"
			,'' as "CoilModel"
			,'' as "FurnModel"
			,'1' as "UnitType"
			,cp.[KW] as "PwrRtd"
			,'1' as "PowerCorr"
			,'0.28' as "ESPRtd"
			,'1' as "CoolCapCorr"
			,'1' as "SensCapCorr"
			,(Case 
				When Substring(sv.Description,4,1) = '/' Then LEFT(sv.Description,7)
				Else LEFT(sv.Description,3)
				End
				) as "Voltage"
			,sv.Phase as "Phase"
		From
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
			) as cp
			inner join [ResidentialSplitsNewQA2].[dbo].[CoolingPerformanceGroups] as cpg on cpg.CoolingPerformanceGroupGUID = cp.CoolingPerformanceGroupGUID
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.AbbreviationGUID = cpg.OutdoorUnitAbbrevGuid
			inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma2 on mma2.MaterialNumber = mma.MaterialNumber
			Left join [ResidentialSplitsNewQA2].[dbo].[PhysicalandElectricalData] as pe on pe.ModelAbbreviationGuid = mma2.AbbreviationGUID
			Left join [ResidentialSplitsNewQA2].[dbo].[ServiceVoltages] as sv on sv.ServiceVoltageGUID = pe.UnitSupplyVoltage
			Left join [ResidentialSplitsNewQA2].[dbo].[vwUSTActiveOutdoorUnits] as ustactiveod on ustactiveod.MaterialNumber = mma.MaterialNumber
		where ustactiveod.ProductionStatus <> 'P4' and ustactiveod.ProductClassDescription = 'Air Conditioner' and sv.Phase is not null
		) as pwr on pwr.CondenserModel = m.OutdoorModelNumber 
	Left Join	(
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
	Join [ResidentialSplitsNewQA2].[dbo].[BaseModelId] as bmid on bmid.Model = m.OutdoorModelNumber
	where m.BrandCode = @Short_Brand and o.MatchupType = 'AirConditioner' and m.[AirHandlerModelNumber] is Null
	Order By m.ARIRefNumber, "Coil Model", "Furn Model", "Condenser Model" asc
END

GO
