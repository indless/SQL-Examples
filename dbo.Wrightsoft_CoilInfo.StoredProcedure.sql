USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_CoilInfo]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* Coil Dimensions, Weight Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_CoilInfo]  
	-- Add the parameters for the stored procedure here
	@MDM_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Coil Info */
	(
	SELECT Distinct 
		Case 
			When ustactivecoil.BrandDescription = 'York' Then 'YRK'
			When ustactivecoil.BrandDescription = 'Coleman' Then 'COLU'
			When ustactivecoil.BrandDescription = 'Luxaire' Then 'LUXA'
			When ustactivecoil.BrandDescription = 'Champion' Then 'CHA'
			When ustactivecoil.BrandDescription = 'Evcon' Then 'EVCN'
			When ustactivecoil.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When ustactivecoil.BrandDescription = 'Guardian' Then 'GUAR'
			End as "WrightsoftBrand"
		,mm.[MaterialNumber] as "MaterialNumber"
		,(Case When mmatr.ActualHeightInches is NOT NULL then mmatr.ActualHeightInches 
			Else mm.height end) as "ActualHeightInches"
		,(Case When mmatr.ActualWidthInches is NOT NULL then mmatr.ActualWidthInches 
			Else mm.width end) as "ActualWidthInches"
		,(Case When mmatr.ActualLengthInches is NOT NULL then mmatr.ActualLengthInches 
			Else mm.length end) as "ActualLengthInches"
		,(Case When mmatr.NetWeightPounds is NOT NULL then mmatr.NetWeightPounds 
			Else mm.ntgew end) as "NetWeightPounds"
		,'R-410A' as "Refrigerant"
	FROM [MasterDataManagement].[dbo].[vwUSTActiveCoils] as ustactivecoil
	Join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialNumber = ustactivecoil.MaterialNumber
	Join [MasterDataManagement].[dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = mm.MaterialNumber
	Where mm.ProductionStatus <> 'P4' and LEN(mm.MaterialNumber) <11
	and ustactivecoil.BrandDescription = @MDM_Brand

	Union 

	SELECT Distinct 
		Case 
			When ustactivecoil.BrandDescription = 'York' Then 'YRK'
			When ustactivecoil.BrandDescription = 'Coleman' Then 'COLU'
			When ustactivecoil.BrandDescription = 'Luxaire' Then 'LUXA'
			When ustactivecoil.BrandDescription = 'Champion' Then 'CHA'
			When ustactivecoil.BrandDescription = 'Evcon' Then 'EVCN'
			When ustactivecoil.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When ustactivecoil.BrandDescription = 'Guardian' Then 'GUAR'
			End as "WrightsoftBrand"
		,mm.[MaterialNumber] as "MaterialNumber"
		,(Case When mmatr.ActualHeightInches is NOT NULL then mmatr.ActualHeightInches 
			Else mm.height end) as "ActualHeightInches"
		,(Case When mmatr.ActualWidthInches is NOT NULL then mmatr.ActualWidthInches 
			Else mm.width end) as "ActualWidthInches"
		,(Case When mmatr.ActualLengthInches is NOT NULL then mmatr.ActualLengthInches 
			Else mm.length end) as "ActualLengthInches"
		,(Case When mmatr.NetWeightPounds is NOT NULL then mmatr.NetWeightPounds 
			Else mm.ntgew end) as "NetWeightPounds"
		,'R-22' as "Refrigerant"
	FROM [MasterDataManagement].[dbo].[vwUSTActiveCoils] as ustactivecoil
	Join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialNumber = ustactivecoil.MaterialNumber
	Join [MasterDataManagement].[dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = mm.MaterialNumber
	Where mm.ProductionStatus <> 'P4' and LEN(mm.MaterialNumber) <11 and LEFT(mm.MaterialNumber,1) <> 'C'
	and ustactivecoil.BrandDescription = @MDM_Brand
	)
	Order by WrightsoftBrand, MaterialNumber, Refrigerant asc
END

GO
