USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_AHInfo]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* Air Handler Dimensions, Weight Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_AHInfo]  
	-- Add the parameters for the stored procedure here
	@MDM_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* AH Info */
	(
	SELECT Distinct
	   Case 
			When ustactiveah.BrandDescription = 'York' Then 'YRK'
			When ustactiveah.BrandDescription = 'Coleman' Then 'COLU'
			When ustactiveah.BrandDescription = 'Luxaire' Then 'LUXA'
			When ustactiveah.BrandDescription = 'Champion' Then 'CHA'
			When ustactiveah.BrandDescription = 'Evcon' Then 'EVCN'
			When ustactiveah.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When ustactiveah.BrandDescription = 'Guardian' Then 'GUAR'
			End as "WrightsoftBrand"
	   ,mm.MaterialNumber
	   ,(Case When mmatr.ActualHeightInches is NOT NULL then mmatr.ActualHeightInches 
			Else mm.height end) as "HeightNom"
		,(Case When mmatr.ActualWidthInches is NOT NULL then mmatr.ActualWidthInches 
			Else mm.width end) as "WidthNom"
		,(Case When mmatr.ActualLengthInches is NOT NULL then mmatr.ActualLengthInches 
			Else mm.length end) as "DepthNom"
		,(Case When mmatr.NetWeightPounds is NOT NULL then mmatr.NetWeightPounds 
			Else mm.ntgew end) as "WeightOpr"
	  ,sv.[Description] as "PowerSupply"
	  ,ahedc.[MaxOCPAmps] as "MaxOCPAmps"
	  ,ahedc.[MinCircuitAmpacity] as "MinCircuitAmpacity"
	  ,'' as "PowerNoBlower"
	  ,'R22' as "Refrigerant"
	  ,'' as "MeteringDevice"
	  ,(Case When Left(mm.MaterialNumber,2) = 'MA' then 'Standard' 
			When Left(mm.MaterialNumber,3) = 'AHR' then 'Standard' 
			Else 'High Efficiency' end) as "BlowerSpeed"
	FROM [MasterDataManagement].[dbo].[AHElectricalDataCooling] as ahedc
	join [MasterDataManagement].[dbo].[ServiceVoltages] as sv on sv.ServiceVoltageGUID = ahedc.ServiceVoltageGUID
	Join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma on mma.AbbreviationGUID = ahedc.AirHandlerAbbrevGUID
	Join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Join [MasterDataManagement].[dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = mm.MaterialNumber
	Join [MasterDataManagement].[dbo].[vwUSTActiveAirHandlersWithMaterialDescription] as ustactiveah on ustactiveah.MaterialMasterGUID = mm.MaterialMasterGUID
	Where mm.ProductionStatus <> 'P4'
	and ustactiveah.BrandDescription = @MDM_Brand

	Union 

	SELECT Distinct
	   Case 
			When ustactiveah.BrandDescription = 'York' Then 'YRK'
			When ustactiveah.BrandDescription = 'Coleman' Then 'COLU'
			When ustactiveah.BrandDescription = 'Luxaire' Then 'LUXA'
			When ustactiveah.BrandDescription = 'Champion' Then 'CHA'
			When ustactiveah.BrandDescription = 'Evcon' Then 'EVCN'
			When ustactiveah.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When ustactiveah.BrandDescription = 'Guardian' Then 'GUAR'
			End as "WrightsoftBrand"
	   ,mm.MaterialNumber
	   ,(Case When mmatr.ActualHeightInches is NOT NULL then mmatr.ActualHeightInches 
			Else mm.height end) as "HeightNom"
		,(Case When mmatr.ActualWidthInches is NOT NULL then mmatr.ActualWidthInches 
			Else mm.width end) as "WidthNom"
		,(Case When mmatr.ActualLengthInches is NOT NULL then mmatr.ActualLengthInches 
			Else mm.length end) as "DepthNom"
		,(Case When mmatr.NetWeightPounds is NOT NULL then mmatr.NetWeightPounds 
			Else mm.ntgew end) as "WeightOpr"
	  ,sv.[Description] as "PowerSupply"
	  ,ahedc.[MaxOCPAmps] as "MaxOCPAmps"
	  ,ahedc.[MinCircuitAmpacity] as "MinCircuitAmpacity"
	  ,'' as "PowerNoBlower"
	  ,'R-410A' as "Refrigerant"
	  ,'' as "MeteringDevice"
	  ,(Case When Left(mm.MaterialNumber,2) = 'MA' then 'Standard' 
			When Left(mm.MaterialNumber,3) = 'AHR' then 'Standard' 
			Else 'High Efficiency' end) as "BlowerSpeed"
	FROM [MasterDataManagement].[dbo].[AHElectricalDataCooling] as ahedc
	join [MasterDataManagement].[dbo].[ServiceVoltages] as sv on sv.ServiceVoltageGUID = ahedc.ServiceVoltageGUID
	Join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma on mma.AbbreviationGUID = ahedc.AirHandlerAbbrevGUID
	Join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Join [MasterDataManagement].[dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = mm.MaterialNumber
	Join [MasterDataManagement].[dbo].[vwUSTActiveAirHandlersWithMaterialDescription] as ustactiveah on ustactiveah.MaterialMasterGUID = mm.MaterialMasterGUID
	Where mm.ProductionStatus <> 'P4'
	and ustactiveah.BrandDescription = @MDM_Brand
	)
	Order by WrightsoftBrand, mm.MaterialNumber asc
END

GO
