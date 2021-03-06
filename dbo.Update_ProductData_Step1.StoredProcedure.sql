USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Update_ProductData_Step1]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 1 of ProductData update process 
				--Finds Materials & Brand combinations to add to ProductData table
				--places list in DO_FindMarketingText 
					--(will need list to run LoadDescriptionsByModelsListExt.exe)
-- =============================================
CREATE PROCEDURE [dbo].[Update_ProductData_Step1]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Create TABLE DO_FindMarketingText
	--(
	--	[ModelNumber] [nvarchar](255) NULL,
	--	[Brand] [nvarchar](255) NULL
	--)

	--CREATE TABLE [dbo].[DO_MarketingText](
	--	[ModelNumber] [nvarchar](255) NULL,
	--	[ Brand] [nvarchar](255) NULL,
	--	[ Description] [nvarchar](255) NULL,
	--	[ MarketingText] [nvarchar](max) NULL
	--) ON [PRIMARY]

  CREATE TABLE #ProductData
	(
		[ID] [int] NOT NULL,
		[Material Number] [nvarchar](255) NULL,
		[Product Type] [nvarchar](255) NULL,
		[ModelSeries] [nvarchar](255) NULL,
		[Brand] [nvarchar](255) NULL,
		[Tonnage] [float] NULL,
		[Stage] [nvarchar](255) NULL,
		[Product Description] [nvarchar](255) NULL,
		[Marketing Text] [nvarchar](max) NULL,
		[Parts Warranty] [nvarchar](255) NULL,
		[Other Warranty] [nvarchar](255) NULL,
		[AFUE] [nvarchar](255) NULL,
		[Nominal Cooling Capacity] [nvarchar](255) NULL,
		[Nominal Heating Capacity] [nvarchar](255) NULL,
		[Electric] [nvarchar](255) NULL,
		[Voltage] [nvarchar](255) NULL,
		[Phase] [nvarchar](255) NULL,
		[Cycle/Hertz] [nvarchar](255) NULL,
		[Minimum Circuit Amps] [nvarchar](255) NULL,
		[Maximum Fuse Size] [nvarchar](255) NULL,
		[Refrigerant] [nvarchar](255) NULL,
		[Refrigerant Control] [nvarchar](255) NULL,
		[Compressor] [nvarchar](255) NULL,
		[Liquid Line Fitting] [nvarchar](255) NULL,
		[Suction Line Fitting] [nvarchar](255) NULL,
		[Coil Rows] [nvarchar](255) NULL,
		[Condenser Fan Speed] [nvarchar](255) NULL,
		[Condensor Motor HP] [nvarchar](255) NULL,
		[Blower Type] [nvarchar](255) NULL,
		[Blower Motor HP] [nvarchar](255) NULL,
		[Shipping Item Length] [float] NULL,
		[Shipping Item Width] [float] NULL,
		[Shipping Item Height] [float] NULL,
		[Shipping Item Weight] [float] NULL
	)

  /* Outdoor */
  Insert into #ProductData
  SELECT distinct 
	  1 as [ID]
	  ,active.[MaterialNumber] as [Material Number]
	  ,active.ProductClassDescription as [Product Type]
	  ,active.ProductSeriesCode as [ModelSeries]
	  ,Case When active.BrandDescription = 'York' Then 'YOR'
			When active.BrandDescription = 'Coleman' Then 'COL'
			When active.BrandDescription = 'Luxaire' Then 'LUX'
			When active.BrandDescription = 'Johnson Controls' Then 'JCI'
			When active.BrandDescription = 'Guardian' Then 'GRD'
			When active.BrandDescription = 'Evcon' Then 'EVC'
			When active.BrandDescription = 'Champion' Then 'CHA'
			When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
			--Else Brand
			End as [Brand]
	  ,active.MarketingTonnage as [Tonnage]
	  ,Null as [Stage]
	  ,active.MaterialDescription as [Product Description]
      ,Null as [Marketing Text]
      ,Null as [Parts Warranty]
      ,Null as [Other Warranty]
      ,Null as [AFUE]
      ,Case When active.MarketingTonnage is Not NULL
			Then Cast(RTRIM(active.MarketingTonnage) AS decimal(8,2)) * 12000 
			Else null End as [Nominal Cooling Capacity]
      ,Case When active.ProductClassDescription = 'Heat Pump' 
			Then Cast(RTRIM(active.MarketingTonnage) AS decimal(8,2)) * 12000
			Else Null End as [Nominal Heating Capacity]
      ,pe.[Description] as [Electric]
      ,Case When LEFT(pe.[Description],7) = '208/230'
			Then LEFT(pe.[Description],7)
			Else LEFT(pe.[Description],3) End as [Voltage]
	  ,Left(Right(pe.[Description],4),1) as [Phase]
	  ,RIGHT(pe.[Description],2) as [Cycle/Hertz]
      ,[MinCircuitCurrentCapacity] as [Minimum Circuit Amps]
      ,[MaxOverCurrentDeviceAmps] as [Maximum Fuse Size]
      ,rt.RefrigerantTypeDescription as [Refrigerant]
      ,'TXV or Field Installed' as [Refrigerant Control]
      ,[CompressorTypeDescription] as [Compressor]
      ,[LiquidLineSetOD] as [Liquid Line Fitting]
      ,[VaporLineSetOD] as [Suction Line Fitting]
      ,[CoilsRowsDeep] as [Coil Rows]
      ,[FanMotorNominalRPM] as [Condenser Fan Speed]
      ,[FanMotorRatedHP] as [Condensor Motor HP]
      ,Null as [Blower Type]
      ,Null as [Blower Motor HP]
      ,Case When Cast(mmatr.ActualLengthInches AS decimal(8,2)) > 0
			Then mmatr.ActualLengthInches
			When Cast(mm.length AS decimal(8,2)) > 0
			Then mm.length
			When Cast(SUBSTRING(sap.[Size/dimensions],2,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],2,3)
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When Cast(SUBSTRING(sap.[Size/dimensions],7,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],7,3)
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When Cast(SUBSTRING(sap.[Size/dimensions],12,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],12,3)
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveOutdoorUnitsWithProductSeriesCode] as active
  left join [dbo].[vwPhysicalandElectricalDataToModel] as pe on active.MaterialNumber = pe.MaterialNumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  left join (
			 SELECT mm.MaterialNumber
					,rt.RefrigerantTypeDescription
			 FROM  dbo.InitialCharges as ic 
			 INNER JOIN dbo.Abbreviations as abbr ON ic.ModelAbbrevGUID = abbr.MasterAbbreviationGuid 
			 INNER JOIN dbo.RefrigerantTypes as rt ON ic.RefrigerantTypeGUID = rt.RefrigerantTypeGUID 
			 INNER JOIN dbo.MaterialMaster_Abbreviation as mma ON abbr.AbbreviationGUID = mma.AbbreviationGUID
			 INNER JOIN dbo.MaterialMaster as mm ON mma.MaterialMasterGUID = mm.MaterialMasterGUID
             ) as rt on rt.MaterialNumber = active.MaterialNumber
  where active.BrandDescription in ('York','Coleman','Luxaire','Johnson Controls','Guardian','Evcon','Champion','Fraser-Johnston')
  and (active.[MaterialNumber] not in (Select distinct [Material Number]
									   From [dbo].[DO_ProductData]
									  )
	   and Case When active.BrandDescription = 'York' Then 'YOR'
				When active.BrandDescription = 'Coleman' Then 'COL'
				When active.BrandDescription = 'Luxaire' Then 'LUX'
				When active.BrandDescription = 'Johnson Controls' Then 'JCI'
				When active.BrandDescription = 'Guardian' Then 'GRD'
				When active.BrandDescription = 'Evcon' Then 'EVC'
				When active.BrandDescription = 'Champion' Then 'CHA'
				When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
				End not in (Select distinct [Material Number]
							From [dbo].[DO_ProductData]
						   )
	  )
  order by [Brand], active.MaterialNumber asc
  
  
  /* Furnaces VS */
  Insert into #ProductData
  SELECT distinct 
	  1 as [ID]
	  ,active.[MaterialNumber] as [Material Number]
	  ,'Furnace' as [Product Type]
	  ,active.ProductSeriesCode as [ModelSeries]
	  ,Case When active.BrandDescription = 'York' Then 'YOR'
			When active.BrandDescription = 'Coleman' Then 'COL'
			When active.BrandDescription = 'Luxaire' Then 'LUX'
			When active.BrandDescription = 'Johnson Controls' Then 'JCI'
			When active.BrandDescription = 'Guardian' Then 'GRD'
			When active.BrandDescription = 'Evcon' Then 'EVC'
			When active.BrandDescription = 'Champion' Then 'CHA'
			When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
			--Else Brand
			End as [Brand]
	  ,NULL as [Tonnage]
	  ,Null as [Stage]
	  ,mm.MaterialDescription as [Product Description]
      ,Null as [Marketing Text]
      ,Null as [Parts Warranty]
      ,Null as [Other Warranty]
      ,elecperf.[AFUE] as [AFUE]
      ,NULL as [Nominal Cooling Capacity]
      ,Case When elecperf.[InputMaxMBH] > 0 
			Then elecperf.[InputMaxMBH] * 1000
			When ISNumeric(SUBSTRING(active.[MaterialNumber],5,3)) >0
			Then SUBSTRING(active.[MaterialNumber],5,3) * 1000
			Else Null End as [Nominal Heating Capacity]
      ,furnvolt.FurnaceServiceVoltage as [Electric]
      ,Case When LEFT(furnvolt.FurnaceServiceVoltage,7) = '208/230'
			Then LEFT(furnvolt.FurnaceServiceVoltage,7)
			Else LEFT(furnvolt.FurnaceServiceVoltage,3) End as [Voltage]
	  ,Left(Right(furnvolt.FurnaceServiceVoltage,4),1) as [Phase]
	  ,RIGHT(furnvolt.FurnaceServiceVoltage,2) as [Cycle/Hertz]
      ,elecperf.[TotalUnitAmps] as [Minimum Circuit Amps]
      ,elecperf.[MaxOCP] as [Maximum Fuse Size]
      ,NULL as [Refrigerant]
      ,NULL as [Refrigerant Control]
      ,NULL as [Compressor]
      ,NULL as [Liquid Line Fitting]
      ,NULL as [Suction Line Fitting]
      ,NULL as [Coil Rows]
      ,NULL as [Condenser Fan Speed]
      ,NULL as [Condensor Motor HP]
      ,Null as [Blower Type]
      ,elecperf.[BlowerHP] as [Blower Motor HP]
      ,Case When Cast(mmatr.ActualLengthInches AS decimal(8,2)) > 0
			Then mmatr.ActualLengthInches
			When Cast(mm.length AS decimal(8,2)) > 0
			Then mm.length
			When Cast(SUBSTRING(sap.[Size/dimensions],2,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],2,3)
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When Cast(SUBSTRING(sap.[Size/dimensions],7,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],7,3)
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When Cast(SUBSTRING(sap.[Size/dimensions],12,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],12,3)
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveVSFurnaces] as active
  Left Join [dbo].[vwFurnaceElectricAndPerformanceToModel] as elecperf on elecperf.MaterialNumber = active.Materialnumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  Left join (SELECT distinct [FurnaceMaterialNumber]
			   ,[FurnaceServiceVoltage]
			 FROM [dbo].[vwFurnaceServiceVoltages]) as furnvolt on furnvolt.FurnaceMaterialNumber = active.Materialnumber
  where active.BrandDescription in ('York','Coleman','Luxaire','Johnson Controls','Guardian','Evcon','Champion','Fraser-Johnston')
  and active.MaterialNumber not like 'a%' and active.Materialnumber not like 'm%'
  and active.ProductionStatus <> 'P4'
  and active.ProductSeriesCode not like 'ductless%'
  and (active.[MaterialNumber] not in (Select distinct [Material Number]
									   From [dbo].[DO_ProductData]
									  )
	   and Case When active.BrandDescription = 'York' Then 'YOR'
				When active.BrandDescription = 'Coleman' Then 'COL'
				When active.BrandDescription = 'Luxaire' Then 'LUX'
				When active.BrandDescription = 'Johnson Controls' Then 'JCI'
				When active.BrandDescription = 'Guardian' Then 'GRD'
				When active.BrandDescription = 'Evcon' Then 'EVC'
				When active.BrandDescription = 'Champion' Then 'CHA'
				When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
				End not in (Select distinct [Material Number]
							From [dbo].[DO_ProductData]
						   )
	  )
  order by [Brand], active.MaterialNumber asc
  
  
  /* Furnaces */
  Insert into #ProductData
  SELECT distinct 
	  1 as [ID]
	  ,active.[MaterialNumber] as [Material Number]
	  ,'Furnace' as [Product Type]
	  ,Case When Left(active.[MaterialNumber],1) = 'R'
			Then LEFT(active.[MaterialNumber],6)
			Else LEFT(active.[MaterialNumber],4) End as [ModelSeries]
	  ,Case When active.BrandDescription = 'York' Then 'YOR'
			When active.BrandDescription = 'Coleman' Then 'COL'
			When active.BrandDescription = 'Luxaire' Then 'LUX'
			When active.BrandDescription = 'Johnson Controls' Then 'JCI'
			When active.BrandDescription = 'Guardian' Then 'GRD'
			When active.BrandDescription = 'Evcon' Then 'EVC'
			When active.BrandDescription = 'Champion' Then 'CHA'
			When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
			--Else Brand
			End as [Brand]
	  ,NULL as [Tonnage]
	  ,Null as [Stage]
	  ,mm.MaterialDescription as [Product Description]
      ,Null as [Marketing Text]
      ,Null as [Parts Warranty]
      ,Null as [Other Warranty]
      ,elecperf.[AFUE] as [AFUE]
      ,NULL as [Nominal Cooling Capacity]
      ,Case When elecperf.[InputMaxMBH] > 0 
			Then elecperf.[InputMaxMBH] * 1000
			When ISNumeric(SUBSTRING(active.[MaterialNumber],5,3)) >0
			Then SUBSTRING(active.[MaterialNumber],5,3) * 1000
			Else Null End as [Nominal Heating Capacity]
      ,furnvolt.FurnaceServiceVoltage as [Electric]
      ,Case When LEFT(furnvolt.FurnaceServiceVoltage,7) = '208/230'
			Then LEFT(furnvolt.FurnaceServiceVoltage,7)
			Else LEFT(furnvolt.FurnaceServiceVoltage,3) End as [Voltage]
	  ,Left(Right(furnvolt.FurnaceServiceVoltage,4),1) as [Phase]
	  ,RIGHT(furnvolt.FurnaceServiceVoltage,2) as [Cycle/Hertz]
      ,elecperf.[TotalUnitAmps] as [Minimum Circuit Amps]
      ,elecperf.[MaxOCP] as [Maximum Fuse Size]
      ,NULL as [Refrigerant]
      ,NULL as [Refrigerant Control]
      ,NULL as [Compressor]
      ,NULL as [Liquid Line Fitting]
      ,NULL as [Suction Line Fitting]
      ,NULL as [Coil Rows]
      ,NULL as [Condenser Fan Speed]
      ,NULL as [Condensor Motor HP]
      ,Null as [Blower Type]
      ,elecperf.[BlowerHP] as [Blower Motor HP]
      ,Case When Cast(mmatr.ActualLengthInches AS decimal(8,2)) > 0
			Then mmatr.ActualLengthInches
			When Cast(mm.length AS decimal(8,2)) > 0
			Then mm.length
			When Cast(SUBSTRING(sap.[Size/dimensions],2,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],2,3)
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When Cast(SUBSTRING(sap.[Size/dimensions],7,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],7,3)
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When Cast(SUBSTRING(sap.[Size/dimensions],12,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],12,3)
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveFurnaces] as active
  Left Join [dbo].[vwFurnaceElectricAndPerformanceToModel] as elecperf on elecperf.MaterialNumber = active.Materialnumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  Left join (SELECT distinct [FurnaceMaterialNumber]
			   ,[FurnaceServiceVoltage]
			 FROM [dbo].[vwFurnaceServiceVoltages]) as furnvolt on furnvolt.FurnaceMaterialNumber = active.Materialnumber
  where active.BrandDescription in ('York','Coleman','Luxaire','Johnson Controls','Guardian','Evcon','Champion','Fraser-Johnston')
  and active.MaterialNumber not like 'a%' and active.Materialnumber not like 'm%'
  and active.ProductionStatus <> 'P4'
  and (active.[MaterialNumber] not in (Select distinct [Material Number]
									   From [dbo].[DO_ProductData]
									  )
	   and Case When active.BrandDescription = 'York' Then 'YOR'
				When active.BrandDescription = 'Coleman' Then 'COL'
				When active.BrandDescription = 'Luxaire' Then 'LUX'
				When active.BrandDescription = 'Johnson Controls' Then 'JCI'
				When active.BrandDescription = 'Guardian' Then 'GRD'
				When active.BrandDescription = 'Evcon' Then 'EVC'
				When active.BrandDescription = 'Champion' Then 'CHA'
				When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
				End not in (Select distinct [Material Number]
							From [dbo].[DO_ProductData]
						   )
	  )
  order by [Brand], active.MaterialNumber asc
  
  
  /* Air Handler */
  Insert into #ProductData
  SELECT distinct 
	  1 as [ID]
	  ,active.[MaterialNumber] as [Material Number]
	  ,'Air Handler' as [Product Type]
	  ,Case When Left(active.[MaterialNumber],1) = 'R'
			Then LEFT(active.[MaterialNumber],6)
			Else LEFT(active.[MaterialNumber],4) End as [ModelSeries]
	  ,Case When active.BrandDescription = 'York' Then 'YOR'
			When active.BrandDescription = 'Coleman' Then 'COL'
			When active.BrandDescription = 'Luxaire' Then 'LUX'
			When active.BrandDescription = 'Johnson Controls' Then 'JCI'
			When active.BrandDescription = 'Guardian' Then 'GRD'
			When active.BrandDescription = 'Evcon' Then 'EVC'
			When active.BrandDescription = 'Champion' Then 'CHA'
			When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
			--Else Brand
			End as [Brand]
	  ,NULL as [Tonnage]
	  ,Null as [Stage]
	  ,mm.MaterialDescription as [Product Description]
      ,Null as [Marketing Text]
      ,Null as [Parts Warranty]
      ,Null as [Other Warranty]
      ,NULL as [AFUE]
      ,NULL as [Nominal Cooling Capacity]
      ,NULL as [Nominal Heating Capacity]
      ,ahdata.[Electric] as [Electric]
      ,Case When LEFT(ahdata.[Electric],7) = '208/230'
			Then LEFT(ahdata.[Electric],7)
			Else LEFT(ahdata.[Electric],3) End as [Voltage]
	  ,Left(Right(ahdata.[Electric],4),1) as [Phase]
	  ,RIGHT(ahdata.[Electric],2) as [Cycle/Hertz]
      ,ahdata.[Minimum Circuit Amps] as [Minimum Circuit Amps]
      ,ahdata.[Maximum Fuse Size] as [Maximum Fuse Size]
      ,'R-410A or R-22' as [Refrigerant]
      ,'TXV or Field Installed' as [Refrigerant Control]
      ,NULL as [Compressor]
      ,NULL as [Liquid Line Fitting]
      ,NULL as [Suction Line Fitting]
      ,NULL as [Coil Rows]
      ,NULL as [Condenser Fan Speed]
      ,NULL as [Condensor Motor HP]
      ,Null as [Blower Type]
      ,ahdata.[Blower Motor HP] as [Blower Motor HP]
      ,Case When Cast(mmatr.ActualLengthInches AS decimal(8,2)) > 0
			Then mmatr.ActualLengthInches
			When Cast(mm.length AS decimal(8,2)) > 0
			Then mm.length
			When Cast(SUBSTRING(sap.[Size/dimensions],2,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],2,3)
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When Cast(SUBSTRING(sap.[Size/dimensions],7,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],7,3)
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When Cast(SUBSTRING(sap.[Size/dimensions],12,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],12,3)
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveAirHandlers] as active
  left join (
			  SELECT distinct mm.MaterialNumber as [Material Number]
				  ,[ProductClassDescription] as [Product Type]
				  ,[AirHandlerServiceVoltage] as [Electric]
				  ,[MotorType] as [Blower Type]
				  ,Case When Right([MotorHorsePower],2) = 'HP'
						Then RTRIM(Left([MotorHorsePower],Len([MotorHorsePower])-2))
						Else [MotorHorsePower] End as [Blower Motor HP]
				  ,ahelec.[MinCircuitAmpacity] as [Minimum Circuit Amps]
				  ,ahelec.MaxOCPAmps as [Maximum Fuse Size]
			  FROM [dbo].[MaterialMaster] as mm
			  left join [dbo].[vwAHBlowerDataToModel] as ahblow on mm.MaterialNumber = ahblow.AirHandlerMaterialNumber
			  Left join (SELECT distinct
						  [AirHandlerMaterialNumber]
						  ,[ServiceVoltage]
						  ,[TotalMotorAmps]
						  ,[MinCircuitAmpacity]
						  ,[MaxOCPAmps]
						FROM [dbo].[MaterialMaster] as mm
						left join [dbo].[vwAHElectricalDataCoolingToModel] as ahelec on ahelec.AirHandlerMaterialNumber =  mm.MaterialNumber
						Where mm.ProductionStatus <> 'P4' and AirHandlerMaterialNumber is not null
						and ahelec.[ServiceVoltage] not like '208%' and ahelec.[ServiceVoltage] not like '230-3%'
						) as ahelec on ahelec.AirHandlerMaterialNumber = mm.MaterialNumber and ahelec.ServiceVoltage = ahblow.AirHandlerServiceVoltage
			  Where mm.ProductionStatus <> 'P4' and mm.MaterialNumber is not null
			  and ahblow.[AirHandlerServiceVoltage] not like '208%'
			) as ahdata on ahdata.[Material Number] = active.MaterialNumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  where active.BrandDescription in ('York','Coleman','Luxaire','Johnson Controls','Guardian','Evcon','Champion','Fraser-Johnston')
  --and active.MaterialNumber not like 'a%' and active.Materialnumber not like 'm%'
  and active.ProductionStatus <> 'P4'
  and (active.[MaterialNumber] not in (Select distinct [Material Number]
									   From [dbo].[DO_ProductData]
									  )
	   and Case When active.BrandDescription = 'York' Then 'YOR'
				When active.BrandDescription = 'Coleman' Then 'COL'
				When active.BrandDescription = 'Luxaire' Then 'LUX'
				When active.BrandDescription = 'Johnson Controls' Then 'JCI'
				When active.BrandDescription = 'Guardian' Then 'GRD'
				When active.BrandDescription = 'Evcon' Then 'EVC'
				When active.BrandDescription = 'Champion' Then 'CHA'
				When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
				End not in (Select distinct [Material Number]
							From [dbo].[DO_ProductData]
						   )
	  )
  order by [Brand], active.MaterialNumber asc
  
  
  /* Coil */
  Insert into #ProductData
  Select distinct 
	  1 as [ID]
	  ,active.[MaterialNumber] as [Material Number]
	  ,'Coil' as [Product Type]
	  ,Left(active.[MaterialNumber],2) as [ModelSeries]
	  ,Case When active.BrandDescription = 'York' Then 'YOR'
			When active.BrandDescription = 'Coleman' Then 'COL'
			When active.BrandDescription = 'Luxaire' Then 'LUX'
			When active.BrandDescription = 'Johnson Controls' Then 'JCI'
			When active.BrandDescription = 'Guardian' Then 'GRD'
			When active.BrandDescription = 'Evcon' Then 'EVC'
			When active.BrandDescription = 'Champion' Then 'CHA'
			When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
			--Else Brand
			End as [Brand]
	  ,NULL as [Tonnage]
	  ,Null as [Stage]
	  ,mm.MaterialDescription as [Product Description]
      ,Null as [Marketing Text]
      ,Null as [Parts Warranty]
      ,Null as [Other Warranty]
      ,NULL as [AFUE]
      ,NULL as [Nominal Cooling Capacity]
      ,NULL as [Nominal Heating Capacity]
      ,NULL as [Electric]
      ,NULL as [Voltage]
	  ,NULL as [Phase]
	  ,NULL as [Cycle/Hertz]
      ,NULL as [Minimum Circuit Amps]
      ,NULL as [Maximum Fuse Size]
      ,'R-410A or R-22' as [Refrigerant]
      ,'TXV or Field Installed' as [Refrigerant Control]
      ,NULL as [Compressor]
      ,NULL as [Liquid Line Fitting]
      ,NULL as [Suction Line Fitting]
      ,NULL as [Coil Rows]
      ,NULL as [Condenser Fan Speed]
      ,NULL as [Condensor Motor HP]
      ,Null as [Blower Type]
      ,NULL as [Blower Motor HP]
      ,Case When Cast(mmatr.ActualLengthInches AS decimal(8,2)) > 0
			Then mmatr.ActualLengthInches
			When Cast(mm.length AS decimal(8,2)) > 0
			Then mm.length
			When Cast(SUBSTRING(sap.[Size/dimensions],2,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],2,3)
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When Cast(SUBSTRING(sap.[Size/dimensions],7,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],7,3)
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When Cast(SUBSTRING(sap.[Size/dimensions],12,3) AS decimal(8,2)) > 0
			Then SUBSTRING(sap.[Size/dimensions],12,3)
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  From [dbo].[vwUSTActiveCoils] as active
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  Where active.BrandDescription in ('York','Coleman','Luxaire','Johnson Controls','Guardian','Evcon','Champion','Fraser-Johnston') 
  and active.ProductionStatus <> 'P4'
  and (active.[MaterialNumber] not in (Select distinct [Material Number]
									   From [dbo].[DO_ProductData]
									  )
	   and Case When active.BrandDescription = 'York' Then 'YOR'
				When active.BrandDescription = 'Coleman' Then 'COL'
				When active.BrandDescription = 'Luxaire' Then 'LUX'
				When active.BrandDescription = 'Johnson Controls' Then 'JCI'
				When active.BrandDescription = 'Guardian' Then 'GRD'
				When active.BrandDescription = 'Evcon' Then 'EVC'
				When active.BrandDescription = 'Champion' Then 'CHA'
				When active.BrandDescription = 'Fraser-Johnston' Then 'FRJ'
				End not in (Select distinct [Material Number]
							From [dbo].[DO_ProductData]
						   )
	  )
  order by [Brand], active.MaterialNumber asc
  
  Select * 
  From #ProductData
  
  Truncate Table DO_FindMarketingText
  Truncate Table DO_MarketingText
  
  Insert into DO_FindMarketingText
  Select [Material Number] as [ModelNumber]
		 ,[Brand]
  From #ProductData
  
  Drop Table #ProductData


END


GO
