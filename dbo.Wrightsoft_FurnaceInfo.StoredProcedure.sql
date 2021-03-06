USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_FurnaceInfo]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* Furnace Dimensions, Weight Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_FurnaceInfo]  
	-- Add the parameters for the stored procedure here
	@MDM_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Furnace Info */
	SELECT Distinct 
		Case 
			When b.BrandDescription = 'York' Then 'YRK'
			When b.BrandDescription = 'Coleman' Then 'COLU'
			When b.BrandDescription = 'Luxaire' Then 'LUXA'
			When b.BrandDescription = 'Champion' Then 'CHA'
			When b.BrandDescription = 'Evcon' Then 'EVCN'
			When b.BrandDescription = 'Fraser-Johnston' Then 'FRAS'
			When b.BrandDescription = 'Guardian' Then 'GUAR'
			End as 'Manufacturer'
		  ,c.[MaterialNumber]
		  ,'UDH' as 'Classification'
		  ,psf.FamilyName as 'Trade Name'

		  ,Case When (SUBSTRING(c.MaterialNumber,8,1) = 'A' and SUBSTRING(c.MaterialNumber,1,1) <> 'R') or (SUBSTRING(c.MaterialNumber,9,1) = 'A' and SUBSTRING(c.MaterialNumber,1,1) = 'R')
				Then 14.5
				When (SUBSTRING(c.MaterialNumber,8,1) = 'B' and SUBSTRING(c.MaterialNumber,1,1) <> 'R') or (SUBSTRING(c.MaterialNumber,9,1) = 'B' and SUBSTRING(c.MaterialNumber,1,1) = 'R')
				Then 17.5
				When (SUBSTRING(c.MaterialNumber,8,1) = 'C' and SUBSTRING(c.MaterialNumber,1,1) <> 'R') or (SUBSTRING(c.MaterialNumber,9,1) = 'C' and SUBSTRING(c.MaterialNumber,1,1) = 'R')
				Then 21
				When (SUBSTRING(c.MaterialNumber,8,1) = 'D' and SUBSTRING(c.MaterialNumber,1,1) <> 'R') or (SUBSTRING(c.MaterialNumber,9,1) = 'D' and SUBSTRING(c.MaterialNumber,1,1) = 'R')
				Then 24.5
				End as 'Width'

		  ,Case When (MaterialDescription like '%2s%' or MaterialDescription like '%2 stage%')
				Then 2
				Else 1
				End as 'Stages'
		  ,1 as 'HtgFuel'
		  ,[AFUE]
		  ,Case When (SUBSTRING(c.MaterialNumber,1,1) = 'R' and IsNumeric(SUBSTRING(c.MaterialNumber,6,3))=1 and SUBSTRING(c.MaterialNumber,6,1) <> 0) 
				Then SUBSTRING(c.MaterialNumber,6,3)
				When (SUBSTRING(c.MaterialNumber,1,1) = 'R' and IsNumeric(SUBSTRING(c.MaterialNumber,6,3))=1 and SUBSTRING(c.MaterialNumber,6,1) = 0)  
				Then SUBSTRING(c.MaterialNumber,7,2)
				When (SUBSTRING(c.MaterialNumber,1,1) <> 'R' and IsNumeric(SUBSTRING(c.MaterialNumber,5,3))=1 and SUBSTRING(c.MaterialNumber,5,1) <> 0)
				Then SUBSTRING(c.MaterialNumber,5,3) 
				When (SUBSTRING(c.MaterialNumber,1,1) <> 'R' and IsNumeric(SUBSTRING(c.MaterialNumber,5,3))=1 and SUBSTRING(c.MaterialNumber,5,1) = 0)
				Then SUBSTRING(c.MaterialNumber,6,2) 
				End as 'HtgInput'

		  ,Case When SUBSTRING(c.MaterialNumber,1,1) = 'R'
				Then Cast(SUBSTRING(c.MaterialNumber,6,3) * ([AFUE]/100) as decimal(8,1)) 
				Else Cast(SUBSTRING(c.MaterialNumber,5,3) * ([AFUE]/100) as decimal(8,1))
				End as 'HtgOutput' 
		  
		  ,'' as 'Blank1'
		  ,'' as 'Blank2'
		  ,'' as 'Blank3'
		  ,'' as 'Blank4'
		  ,'' as 'Blank5'
		  ,'' as 'Blank6'

		  ,[NominalAirflow] as 'ClgFanAVF'
		  ,[BlowerAmps] as 'ClgFanPwr'

		  ,'' as 'Blank7'
		  ,'' as 'Blank8'
		  ,'' as 'Blank9'
		  ,'' as 'Blank10'

		  ,[NominalAirflow] as 'HtgFanAVF'
		  ,[BlowerAmps] as 'HtgFanPwr'

		  ,'' as 'Blank11'
		  ,'' as 'Blank12'
		  ,'' as 'Blank13'
		  ,'' as 'Blank14'

		  ,[NominalAirflow] as 'ContFanAVF'
		  ,[BlowerAmps] as 'ContFanPwr'

		  ,'' as 'Blank15'
		  ,'' as 'Blank16'
		  ,'' as 'Blank17'

		  ,m.height as 'HeightNom'
		  ,m.width as 'WidthNom'
		  ,m.length as 'DepthNom'
		  ,[OperatingWeight] as 'WeightOpr'

		  ,'115-1-60' as 'PowerSupply'
		  ,[MaxOCP]
		  ,[TotalUnitAmps] as 'MinAmpacity'
	  
		  ,'' as 'MotorSpeed'
		  ,Case When SUBSTRING(c.MaterialNumber,3,1) = 'L' or SUBSTRING(c.MaterialNumber,5,1) = 'L'
				Then 1
				Else 0
				End as 'LoNoxOpt'
      
	  FROM [MasterDataManagement].[dbo].[vwFurnaceElectricAndPerformanceToModel] as c
	  join [MasterDataManagement].[dbo].[MaterialMaster] as m on m.MaterialMasterGUID = c.MaterialMasterGUID
	  join [MasterDataManagement].[dbo].[MaterialMaster_ProductSeries] as mp on mp.MaterialMasterGUID = m.MaterialMasterGUID
	  join [MasterDataManagement].[dbo].[ProductSeries] as ps on ps.ProductSeriesGUID = mp.ProductSeriesGUID
	  join [MasterDataManagement].[dbo].[ProductSeriesFamilies] as psf on psf.PSFGUID = ps.PSFGUID
	  join [MasterDataManagement].[dbo].[Brands] as b on b.BrandGUID = ps.BrandGUID
	  where c.materialnumber not like 'P%' and
	  m.ProductionStatus <> 'P4' and
	  b.BrandDescription = @MDM_Brand
  
	  Order by c.materialnumber asc


END


GO
