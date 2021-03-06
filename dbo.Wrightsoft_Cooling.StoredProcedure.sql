USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_Cooling]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* Cooling Performance Data */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_Cooling]
	-- Add the parameters for the stored procedure here
	@MDM_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Cooling Performance data */
	SELECT distinct
	  bmid.BaseModelID as "BaseModelID"
	  --,mma.MaterialNumber as "MaterialNumber"
	  ,Case 
			When ustactiveod.BrandDescription = 'York' Then 'YRK'
			When ustactiveod.BrandDescription = 'Coleman' Then 'COLU'
			When ustactiveod.BrandDescription = 'Luxaire' Then 'LUXA'
			When ustactiveod.BrandDescription = 'Champion' Then 'CHA'
			When ustactiveod.BrandDescription = 'Evcon' Then 'EVCN'
			When ustactiveod.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When ustactiveod.BrandDescription = 'Guardian' Then 'GUAR'
			End as "MfrCode"
	  ,cp.[OutdoorTemperature] as "ODB"
	  ,cp.[IndoorWetBulb] as "EWB"
	  ,cp.[IndoorDryBulb] as "EDB"
	  ,cp.[IndoorCFM] as "FanAVF"
	  ,cp.[TotalCapacity] * 1000 as "TotCap"
	  ,cp.[SensibleCapacity] * 1000 as "SensCapl"
	  ,cp.[KW] as "InputPwr"
	FROM [ResidentialSplitsNewQA2].[dbo].[CoolingPerformance] as cp
	inner join [ResidentialSplitsNewQA2].[dbo].[CoolingPerformanceGroups] as cpg on cpg.CoolingPerformanceGroupGUID = cp.CoolingPerformanceGroupGUID
	inner join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.AbbreviationGUID = cpg.OutdoorUnitAbbrevGuid
	Join [ResidentialSplitsNewQA2].[dbo].[vwUSTActiveOutdoorUnits] as ustactiveod on ustactiveod.MaterialNumber = mma.MaterialNumber
	Join [ResidentialSplitsNewQA2].[dbo].[BaseModelId] as bmid on bmid.Model = mma.MaterialNumber
	where ustactiveod.ProductionStatus <> 'P4' and ustactiveod.BrandDescription = @MDM_Brand
	order by "BaseModelID", MfrCode, OutdoorTemperature, IndoorWetBulb, IndoorCFM asc
END

GO
