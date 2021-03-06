USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_HPCondInfo]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* HP Dimensions, Weight and Electrical Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_HPCondInfo]  
	-- Add the parameters for the stored procedure here
	@Short_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* HP Dimensions, Weight and Electrical Info */  
	Select	Distinct 
			Case 
				When m.BrandCode = 'YOR' Then 'YRK'
				When m.BrandCode = 'COL' Then 'COLU'
				When m.BrandCode = 'LUX' Then 'LUXA'
				When m.BrandCode = 'CHA' Then 'CHA'
				When m.BrandCode = 'EVC' Then 'EVCN'
				When m.BrandCode = 'FRJ' Then 'FRAS'
				When m.BrandCode = 'GRD' Then 'GUAR'
				End as "Manufacturer"
			,mm.MaterialNumber as "Model"
			,(Case When mmatr.ActualHeightInches is NOT NULL then mmatr.ActualHeightInches 
				Else mm.height end) as "HeightNom"
			,(Case When mmatr.ActualWidthInches is NOT NULL then mmatr.ActualWidthInches 
				Else mm.width end) as "WidthNom"
			,(Case When mmatr.ActualLengthInches is NOT NULL then mmatr.ActualLengthInches 
				Else mm.length end) as "DepthNom"
			,(Case When mmatr.NetWeightPounds is NOT NULL then mmatr.NetWeightPounds 
				Else mm.ntgew end) as "WeightOpr"
			,electrical.PowerSupply as "PowerSupply"
			,electrical.MaxOCP as "MaxOCP"
			,electrical.MinAmpacity as "MinAmpacity"
			,'' as "PowerNoBlower" --leave blank
			,'R-410A' as "Refrigerant"
	From (Select Distinct [OutdoorModelNumber], [ARIRefNumber], [BrandCode] From [dbo].[RWS_MatchingSystems]) as m
	left join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialNumber = m.OutdoorModelNumber
	Left join [MasterDataManagement].[dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = mm.MaterialNumber
	Join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma on mma.MaterialMasterGUID = mm.MaterialMasterGUID
	Join [dbo].[AHRI_HP_MarketingReport] as hp on hp.AHRIRefNumber = m.[ARIRefNumber]
	--Join [MasterDataManagement].[dbo].[vwUSTActiveOutdoorUnits] as ustactiveod on ustactiveod.MaterialNumber = mm.MaterialNumber
	Join (
		SELECT Distinct		
			dbo.MaterialMaster.MaterialNumber as "Model",
			dbo.ServiceVoltages.Description as "PowerSupply", 
			dbo.PhysicalandElectricalData.MaxOverCurrentDeviceAmps as "MaxOCP", 
			dbo.PhysicalandElectricalData.MinCircuitCurrentCapacity as "MinAmpacity"
		FROM         
			dbo.MaterialMaster_Abbreviation 
			INNER JOIN dbo.Abbreviations ON dbo.MaterialMaster_Abbreviation.AbbreviationGUID = dbo.Abbreviations.AbbreviationGUID 
			INNER JOIN dbo.CompressorTypes 
			INNER JOIN dbo.PhysicalandElectricalData 
			INNER JOIN dbo.ServiceVoltages ON dbo.PhysicalandElectricalData.UnitSupplyVoltage = dbo.ServiceVoltages.ServiceVoltageGUID ON 
			dbo.CompressorTypes.CompressorTypeGUID = dbo.PhysicalandElectricalData.CompressorTypeGUID ON 
			dbo.Abbreviations.MasterAbbreviationGuid = dbo.PhysicalandElectricalData.ModelAbbreviationGuid 
			INNER JOIN dbo.MaterialMaster ON dbo.MaterialMaster_Abbreviation.MaterialMasterGUID = dbo.MaterialMaster.MaterialMasterGUID
		Where dbo.MaterialMaster.ProductionStatus <> 'P4'
		) As electrical On electrical.Model = mm.MaterialNumber
	Where mm.werks = '1002' and mm.ProductionStatus <> 'P4' and ISNUMERIC(LEFT(mm.MaterialNumber,1)) = 0  --and ustactiveod.ProductClassDescription = 'Heat Pump'
	and m.BrandCode = @Short_Brand --and ustactiveod.BrandDescription = @MDM_Brand
	Order by Manufacturer, Model asc
END

GO
