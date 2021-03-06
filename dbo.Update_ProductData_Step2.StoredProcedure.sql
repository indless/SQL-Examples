USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[Update_ProductData_Step2]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 1 of ProductData update process 
				--Finds Materials & Brand combinations, adds them to DO_ProductData table
				--Updates Marketing Text using DO_MarketingText
-- =============================================
CREATE PROCEDURE [dbo].[Update_ProductData_Step2]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  /* Update LWH values using Size/Dimensions in dbo.DO_SizeAndDimensions */
  Truncate Table dbo.DO_SizeAndDimensions

  Insert into dbo.DO_SizeAndDimensions
  Select Distinct
	[Size/dimensions]
	,Null as [Shipping Item Length]
	,Null as [Shipping Item Width]
	,Null as [Shipping Item Height]
  From [dbo].[DO_SAP_GrossWeightsAndDimensions]
  Order by [Size/dimensions] asc

  Update dbo.DO_SizeAndDimensions
  Set [Shipping Item Length] = (Select dbo.GetDimension([Size/dimensions],'L'))
   	  ,[Shipping Item Width] = (Select dbo.GetDimension([Size/dimensions],'W'))
	  ,[Shipping Item Height] = (Select dbo.GetDimension([Size/dimensions],'H'))
  From dbo.DO_SizeAndDimensions

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
			When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveOutdoorUnitsWithProductSeriesCode] as active
  left join [dbo].[vwPhysicalandElectricalDataToModel] as pe on active.MaterialNumber = pe.MaterialNumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
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
			When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveVSFurnaces] as active
  Left Join [dbo].[vwFurnaceElectricAndPerformanceToModel] as elecperf on elecperf.MaterialNumber = active.Materialnumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
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
			When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  FROM [dbo].[vwUSTActiveFurnaces] as active
  Left Join [dbo].[vwFurnaceElectricAndPerformanceToModel] as elecperf on elecperf.MaterialNumber = active.Materialnumber
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
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
			When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
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
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
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
			When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When Cast(mmatr.[ActualWidthInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualWidthInches]
			When Cast(mm.width AS decimal(8,2)) > 0
			Then mm.width
			When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When Cast(mmatr.[ActualHeightInches] AS decimal(8,2)) > 0
			Then mmatr.[ActualHeightInches]
			When Cast(mm.height AS decimal(8,2)) > 0
			Then mm.height
			When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
			Else Null end as [Shipping Item Height]
      ,Case When CAST(sap.[Gross Weight] as decimal(8,2)) > 0
			Then sap.[Gross Weight]
			Else mm.ntgew End as [Shipping Item Weight]
  From [dbo].[vwUSTActiveCoils] as active
  left join [dbo].[MaterialMasterAttributes] as mmatr on mmatr.MaterialNumber = active.MaterialNumber
  left join [dbo].[MaterialMaster] as mm on mm.MaterialNumber = active.MaterialNumber
  left join [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap on Cast(sap.Material as varchar) = active.MaterialNumber
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
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
  
  /* add new material + brand combinations to DO_ProductData */
  Insert into DO_ProductData
  Select * 
  From #ProductData
  
  /* add new S1- parts to DO_ProductData from DO_Sap */
  Insert into DO_ProductData
  Select distinct 
	  1 as [ID]
	  ,[Material] as [Material Number]
      ,'Parts' as [Product Type]
      ,NULL as [ModelSeries]
      ,NULL as [Brand]
      ,NULL as [Tonnage]
      ,NULL as [Stage]
      ,[Material Description] as [Product Description]
      ,NULL as [Marketing Text]
      ,NULL as [Parts Warranty]
      ,NULL as [Other Warranty]
      ,NULL as [AFUE]
      ,NULL as [Nominal Cooling Capacity]
      ,NULL as [Nominal Heating Capacity]
      ,NULL as [Electric]
      ,NULL as [Voltage]
      ,NULL as [Phase]
      ,NULL as [Cycle/Hertz]
      ,NULL as [Minimum Circuit Amps]
      ,NULL as [Maximum Fuse Size]
      ,NULL as [Refrigerant]
      ,NULL as [Refrigerant Control]
      ,NULL as [Compressor]
      ,NULL as [Liquid Line Fitting]
      ,NULL as [Suction Line Fitting]
      ,NULL as [Coil Rows]
      ,NULL as [Condenser Fan Speed]
      ,NULL as [Condensor Motor HP]
      ,NULL as [Blower Type]
      ,NULL as [Blower Motor HP]
      ,Case When dims.[Shipping Item Length] is not Null
			Then dims.[Shipping Item Length]
			Else Null end as [Shipping Item Length]
      ,Case When dims.[Shipping Item Width] is not Null
			Then dims.[Shipping Item Width]
			Else Null end as [Shipping Item Width]
      ,Case When dims.[Shipping Item Height] is not Null
			Then dims.[Shipping Item Height]
			Else Null end as [Shipping Item Height]
      ,Case When CAST([Gross Weight] as decimal(8,2)) > 0
			Then CAST([Gross Weight] AS decimal(8,2))
			Else NULL End as [Shipping Item Weight]
  From [dbo].[DO_SAP_GrossWeightsAndDimensions] as sap
  left join [dbo].[DO_SizeAndDimensions] as dims on dims.[Size/dimensions] = sap.[Size/dimensions]
  Where [Material] not in (Select distinct [Material Number]
						   From [dbo].[DO_ProductData]
						  )
	   
  
  --Update DO_ProductData using Table DO_MarketingText
  Update DO_ProductData
  Set DO_ProductData.[Marketing Text] = DO_MarketingText.[ MarketingText],
	  DO_ProductData.[Product Description] = DO_MarketingText.[ Description]
  From dbo.DO_MarketingText
  Where DO_ProductData.[Material Number] = DO_MarketingText.[ModelNumber]
		And DO_ProductData.Brand = DO_MarketingText.[ Brand]
  
  --Update ID in DO_ProductData (sort by brand, material number)
  Update DO_ProductData
  Set ID = p.RowNumber
  From [dbo].[DO_ProductData] as ProductData
  inner join 
	(SELECT Top 1000000 [ID]
		  ,[Material Number]
		  ,[Product Type]
		  ,[ModelSeries]
		  ,[Brand]
		  ,[Tonnage]
		  ,[Stage]
		  ,[Product Description]
		  ,[Marketing Text]
		  ,[Parts Warranty]
		  ,[Other Warranty]
		  ,[AFUE]
		  ,[Nominal Cooling Capacity]
		  ,[Nominal Heating Capacity]
		  ,[Electric]
		  ,[Voltage]
		  ,[Phase]
		  ,[Cycle/Hertz]
		  ,[Minimum Circuit Amps]
		  ,[Maximum Fuse Size]
		  ,[Refrigerant]
		  ,[Refrigerant Control]
		  ,[Compressor]
		  ,[Liquid Line Fitting]
		  ,[Suction Line Fitting]
		  ,[Coil Rows]
		  ,[Condenser Fan Speed]
		  ,[Condensor Motor HP]
		  ,[Blower Type]
		  ,[Blower Motor HP]
		  ,[Shipping Item Length]
		  ,[Shipping Item Width]
		  ,[Shipping Item Height]
		  ,[Shipping Item Weight]
		  ,Row_Number() Over(order by [Brand], [Material Number] asc) as RowNumber
	  FROM [dbo].[DO_ProductData]
	  order by Brand, [Material Number] asc
	  ) as p
	  on p.ID = ProductData.ID
  
  Drop Table #ProductData


  /******** Update Literature ****************************************************************************/
  CREATE TABLE #Literature
  (
		[ProductID] [float] NULL,
		[ModelSeries] [nvarchar](255) NULL,
		[Brand] [nvarchar](255) NULL,
		[DocumentCategory] [nvarchar](255) NULL,
		[Description] [nvarchar](255) NULL,
		[FileName] [nvarchar](255) NULL,
		[PubID] [float] NULL,
		[LinkID] [float] NULL,
		[FileSize] [float] NULL
  )
  
  Insert Into #Literature
  SELECT    Teqpubsmodels.ProductID,
			Teqproducts.ModelSeries, 
			CASE WHEN Teqproducts.Brand = 'Champion' THEN 'CHA'
				WHEN Teqproducts.Brand = 'Coleman' THEN 'COL'
				WHEN Teqproducts.Brand = 'Evcon' THEN 'EVC'
				WHEN Teqproducts.Brand = 'FJ' THEN 'FRJ'
				WHEN Teqproducts.Brand = 'Guardian' THEN 'GRD'
				WHEN Teqproducts.Brand = 'Luxaire' THEN 'LUX'
				WHEN Teqproducts.Brand = 'York' THEN 'YOR'  
				else Teqproducts.Brand end as "Brand",
			Teqpubsclass.ClassName as "DocumentCategory", 
			Teqpubsmaster.Description, 
			Teqpubsmaster.FileName, 
			Teqpubsmodels.PubID, 
			Teqpubsmodels.LinkID, 
			Teqpubsmaster.FileSize
  FROM    [c4445m035].[Web0099].[dbo].[EqPubsModels] as Teqpubsmodels INNER JOIN
		  [c4445m035].[Web0099].[dbo].[EqPubsMaster] as Teqpubsmaster ON Teqpubsmodels.PubID = Teqpubsmaster.PubID INNER JOIN
	      [c4445m035].[Web0099].[dbo].[EqProducts] as Teqproducts ON Teqpubsmodels.ProductID = Teqproducts.ProductID Left JOIN
		  [c4445m035].[Web0099].[dbo].[EqPubsClass] as Teqpubsclass ON Teqpubsmaster.ClassID = Teqpubsclass.ClassID
  WHERE   Teqpubsmaster.ClassID IN (3 ,56 ,6 ,8 ,7 ,57 ,18 ,60 ,21 ,22 ,26 ,62 ,33 ,64 ,61 ,38 ,41 ,42 ,53 ,48 ,50 ,51) 
		   And NOT (Teqpubsmaster.Description = N'UPDATED') 
		   And Teqpubsmaster.Description not like '%archive%'
		

  --Update DO_Literature
  --Set DO_Literature.DocumentCategory = #Literature.DocumentCategory,
	 -- DO_Literature.Description = #Literature.Description, 
	 -- --DO_Literature.FileName = #Literature.FileName, 
	 -- DO_Literature.PubID = #Literature.PubID, 
	 -- DO_Literature.LinkID = #Literature.LinkID, 
	 -- DO_Literature.FileSize = #Literature.FileSize
  --From #Literature 
  --Where DO_Literature.ProductID = #Literature.ProductID 
  -- 	    And DO_Literature.ModelSeries = #Literature.ModelSeries 
		--And DO_Literature.Brand = #Literature.Brand
		--And DO_Literature.FileName = #Literature.FileName
		
	Truncate Table DO_Literature
	
	/**** Literature Output ****/
	Insert into DO_Literature
	Select * 
	From #Literature
	--Where DO_Literature.ProductID <> #Literature.ProductID
	--	  And DO_Literature.ModelSeries <> #Literature.ModelSeries
	--	  And DO_Literature.Brand <> #Literature.Brand
	--	  And DO_Literature.FileName <> #Literature.FileName
	--	  And NOT (EqPubsMaster.Description = N'UPDATED') 
	--	  And EqPubsMaster.Description not like '%archive%'


	Drop Table #Literature




	/******** Update Images ****************************************************************************/
	--CREATE TABLE #Images
	--(
	--	[ProductID] [float] NULL,
	--	[ModelSeries] [nvarchar](255) NULL,
	--	[Brand] [nvarchar](255) NULL,
	--	[Picture] [nvarchar](255) NULL,
	--	[ProductName] [nvarchar](255) NULL,
	--	[ProductDescription] [nvarchar](max) NULL,
	--	[ProductBenefits] [nvarchar](max) NULL,
	--	[TradeName] [nvarchar](255) NULL,
	--	[ShortName] [nvarchar](255) NULL,
	--	[NominalCapacities] [nvarchar](255) NULL,
	--	[EfficiencyRating] [nvarchar](max) NULL,
	--	[CompressorWarranty] [nvarchar](255) NULL,
	--	[HeatExchangerWarranty] [nvarchar](255) NULL,
	--	[PartsWarranty] [nvarchar](255) NULL,
	--	[Residential] [float] NULL,
	--	[Commercial] [float] NULL,
	--	[ManufacturedHousing] [float] NULL,
	--	[EnergyStarCompliant] [float] NULL,
	--	[Descriptor1] [nvarchar](255) NULL,
	--	[Descriptor2] [nvarchar](255) NULL,
	--	[HighResImage] [nvarchar](255) NULL
	--)
	
	
	/****** Product Images by ModelSeries & Brand  ******/
	--Insert into #Images
	Truncate Table DO_Images
	
	Insert Into DO_Images
	SELECT Teqproducts.ProductID
		  ,Teqproducts.ModelSeries
		  ,CASE WHEN Teqproducts.Brand = 'Champion' THEN 'CHA'
				WHEN Teqproducts.Brand = 'Coleman' THEN 'COL'
				WHEN Teqproducts.Brand = 'Evcon' THEN 'EVC'
				WHEN Teqproducts.Brand = 'FJ' THEN 'FRJ'
				WHEN Teqproducts.Brand = 'Guardian' THEN 'GRD'
				WHEN Teqproducts.Brand = 'Luxaire' THEN 'LUX'
				WHEN Teqproducts.Brand = 'York' THEN 'YOR'  
				else Teqproducts.Brand end as "Brand"
		  ,Teqproducts.Picture
		  ,Teqproducts.ProductName 
		  --,EqEquipmentType.Name as "ProductType"   
		  ,Teqproducts.ProductDescription
		  ,Teqproducts.ProductBenefits
		  ,Teqtradenames.TradeNameCat as "TradeName"
		  ,Teqproducts.ShortName
		  ,Teqproducts.NominalCapacities
		  ,Teqproducts.EfficiencyRating
		  ,Teqproducts.CompressorWarranty
		  ,Teqproducts.HeatExchangerWarranty
		  ,Teqproducts.PartsWarranty
		  ,Teqproducts.Residential
		  ,Teqproducts.Commercial
		  ,Teqproducts.ManufacturedHousing
		  ,Teqproducts.EnergyStarCompliant
		  ,Teqproducts.Descriptor1
		  ,Teqproducts.Descriptor2
		  ,Teqproducts.HighResImage
	FROM [c4445m035].[Web0099].[dbo].[EqProducts] as Teqproducts
	Left Join [c4445m035].[Web0099].[dbo].[EqTradeNames] as Teqtradenames ON Teqproducts.TradeNameID = Teqtradenames.TradeNameID
	order by Teqproducts.ProductID asc

	--Truncate Table DO_Images
	
	--Insert Into DO_Images
	--Select *
	--From #Images

	--Drop Table #Images

END


GO
