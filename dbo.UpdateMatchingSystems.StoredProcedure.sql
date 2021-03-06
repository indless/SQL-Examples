USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[UpdateMatchingSystems]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-10
-- Description:	Update RWS_MatchingSystems
-- =============================================
CREATE PROCEDURE [dbo].[UpdateMatchingSystems]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	--CREATE TABLE RSW_Abbreviation_MaterialNumber_Outdoor
	--	(
	--		Abbreviation nvarchar(75) NOT NULL
	--		,MaterialNumber nvarchar(75) NOT NULL
	--		,AbbreviationGUID uniqueidentifier NOT NULL
	--		,MaterialMasterGUID uniqueidentifier NOT NULL
	--	)

	--CREATE TABLE RSW_Abbreviation_MaterialNumber_Coil
	--	(
	--		Abbreviation nvarchar(75) NOT NULL
	--		,MaterialNumber nvarchar(75) NOT NULL
	--		,AbbreviationGUID uniqueidentifier NOT NULL
	--		,MaterialMasterGUID uniqueidentifier NOT NULL
	--	)
		
	--CREATE TABLE RSW_Abbreviation_MaterialNumber_AirHandler
	--	(
	--		Abbreviation nvarchar(75) NOT NULL
	--		,MaterialNumber nvarchar(75) NOT NULL
	--		,AbbreviationGUID uniqueidentifier NOT NULL
	--		,MaterialMasterGUID uniqueidentifier NOT NULL
	--	)
		
	--CREATE TABLE RSW_Abbreviation_MaterialNumber_Furnace
	--	(
	--		Abbreviation nvarchar(75) NOT NULL
	--		,MaterialNumber nvarchar(75) NOT NULL
	--		,AbbreviationGUID uniqueidentifier NOT NULL
	--		,MaterialMasterGUID uniqueidentifier NOT NULL
	--	)

	--CREATE TABLE RSW_Abbreviation_MaterialNumber_Indoor_for_TXV
	--	(
	--		Abbreviation nvarchar(75) NOT NULL
	--		,MaterialNumber nvarchar(75) NOT NULL
	--		,AbbreviationGUID uniqueidentifier NOT NULL
	--		,MaterialMasterGUID uniqueidentifier NOT NULL
	--	)

	--CREATE TABLE RSW_Abbreviation_Matchup_TXV
	--	(
	--		Outdoor nvarchar(75) NOT NULL
	--		,Indoor nvarchar(75) NOT NULL
	--		,TXV nvarchar(75) NOT NULL
	--	)
		
		
	--Drop Table RSW_Abbreviation_MaterialNumber_Outdoor
	--Drop Table RSW_Abbreviation_MaterialNumber_Coil
	--Drop Table RSW_Abbreviation_MaterialNumber_AirHandler
	--Drop Table RSW_Abbreviation_MaterialNumber_Furnace
	--Drop Table RSW_Abbreviation_MaterialNumber_Indoor_for_TXV
	--Drop Table RSW_Abbreviation_Matchup_TXV

	Truncate Table RSW_Abbreviation_MaterialNumber_Outdoor
	Truncate Table RSW_Abbreviation_MaterialNumber_Coil
	Truncate Table RSW_Abbreviation_MaterialNumber_AirHandler
	Truncate Table RSW_Abbreviation_MaterialNumber_Furnace
	Truncate Table RSW_Abbreviation_MaterialNumber_Indoor_for_TXV
	Truncate Table RSW_Abbreviation_Matchup_TXV

	/* Outdoor ********************************************************************************************************/
	/* AC & HP */
	Insert Into RSW_Abbreviation_MaterialNumber_Outdoor
	Select distinct
		 abb.Abbreviation
		 ,mm.MaterialNumber
		 ,abb.AbbreviationGUID
		 ,mm.MaterialMasterGUID
	From dbo.Abbreviations as abb
	join dbo.CoolingCapacity_test as cc on cc.OutdoorUnitAbbrevGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster_Abbreviation as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Order by abb.Abbreviation


	/* Coil ********************************************************************************************************/
	Insert Into RSW_Abbreviation_MaterialNumber_Coil
	Select distinct
		 abb.Abbreviation
		 ,mm.MaterialNumber
		 ,abb.AbbreviationGUID
		 ,mm.MaterialMasterGUID
	From dbo.Abbreviations as abb
	join dbo.CoolingCapacity_test as cc on cc.CoilAbbrevGuid = abb.AbbreviationGUID
	join dbo.MaterialMaster_Abbreviation as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Order by abb.Abbreviation


	/* Air Handler **************************************************************************************************/
	Insert Into RSW_Abbreviation_MaterialNumber_AirHandler
	Select distinct
		 abb.Abbreviation
		 ,mm.MaterialNumber
		 ,abb.AbbreviationGUID
		 ,mm.MaterialMasterGUID
	From dbo.Abbreviations as abb
	join dbo.CoolingCapacity_test as cc on cc.AirHandlerAbbrevGuid = abb.AbbreviationGUID
	join dbo.MaterialMaster_Abbreviation as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Order by abb.Abbreviation


	/* Furnace ********************************************************************************************************/
	Insert Into RSW_Abbreviation_MaterialNumber_Furnace
	Select distinct
		 abb.Abbreviation
		 ,mm.MaterialNumber
		 ,abb.AbbreviationGUID
		 ,mm.MaterialMasterGUID
	From dbo.Abbreviations as abb
	join dbo.CoolingCapacity_test as cc on cc.VSFurnaceAbbrevGuid = abb.AbbreviationGUID
	join dbo.MaterialMaster_Abbreviation as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Order by abb.Abbreviation

	Insert Into RSW_Abbreviation_MaterialNumber_Furnace
	Select distinct
		 abb.Abbreviation
		 ,mm.MaterialNumber
		 ,abb.AbbreviationGUID
		 ,mm.MaterialMasterGUID
	From dbo.Abbreviations as abb
	join dbo.MaterialMaster_Abbreviation as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join dbo.MaterialMaster as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID
	Where abb.Abbreviation = 'TG*S'
	Order by abb.Abbreviation


	/* Indoor for TXV, Active & Obsolete *************************************************************************/
	Insert Into RSW_Abbreviation_MaterialNumber_Indoor_for_TXV
	SELECT [Abbreviation]
		  ,[MaterialNumber]
		  ,[AbbreviationGUID]
		  ,[MaterialMasterGUID]
	FROM [MasterDataManagement].[dbo].[vwAbbreviation_MaterialMaster]
	where Abbreviation like 'active%' or Abbreviation like 'obsolete%'
	order by Abbreviation, MaterialNumber asc


	/* Matchup TXV **************************************************************************************/
	Insert into RSW_Abbreviation_Matchup_TXV
	SELECT Distinct 
	  od.Abbreviation as Outdoor
	  ,rswid.Abbreviation as Indoor
	  ,mm7.MaterialNumber as TXV
	FROM [MasterDataManagement].[dbo].[AdditionalCharges] as addc
	join [MasterDataManagement].[dbo].[Abbreviations] as abb on abb.AbbreviationGUID = addc.OutdoorUnitAbbrevGUID
	join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma on mma.AbbreviationGUID = abb.AbbreviationGUID
	join [MasterDataManagement].[dbo].[MaterialMaster] as mm on mm.MaterialMasterGUID = mma.MaterialMasterGUID

	join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma12 on mma12.MaterialMasterGUID = mm.MaterialMasterGUID
	join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Outdoor] as od on od.AbbreviationGUID = mma12.AbbreviationGUID  

	join [MasterDataManagement].[dbo].[Abbreviations] as abb2 on abb2.AbbreviationGUID = addc.IndoorUnitAbbrevGUID
	join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma2 on mma2.AbbreviationGUID = abb2.AbbreviationGUID
	join [MasterDataManagement].[dbo].[MaterialMaster] as mm2 on mm2.MaterialMasterGUID = mma2.MaterialMasterGUID
	join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Indoor_for_TXV] as rswid on rswid.MaterialNumber = mm2.MaterialNumber

	join [MasterDataManagement].[dbo].[Abbreviations] as abb7 on abb7.AbbreviationGUID = addc.ApprovedTXVAbbrevGuid
	join [MasterDataManagement].[dbo].[MaterialMaster_Abbreviation] as mma7 on mma7.AbbreviationGUID = abb7.AbbreviationGUID
	join [MasterDataManagement].[dbo].[MaterialMaster] as mm7 on mm7.MaterialMasterGUID = mma7.MaterialMasterGUID
	Order by od.Abbreviation, rswid.Abbreviation, TXV asc	




	/* Insert Into RSW_MatchingSystems *****************************************************************************************************************/

	--Create Table RWS_MatchingSystems
	--(
	--	RowID int IDENTITY(1,1) Primary Key
	--	,ARIRefNumber	int	NOT NULL
	--	,OutdoorModelNumber	varchar(50)	
	--	,AirHandlerModelNumber	varchar(50)	
	--	,FurnaceModelNumber	varchar(50)	
	--	,CoilModelNumber	varchar(50)	
	--	,BrandCode	varchar(50)	
	--	,SEER	decimal(8, 2)	
	--	,EER	decimal(8, 2)	
	--	,HSPF	decimal(8, 2)	
	--	,TotalCapacity	decimal(8, 2)	
	--	,SensibleCapacity	decimal(8, 2)	
	--	,SystemKW	decimal(8, 2)	
	--	,TVATotalCapacity	decimal(8, 2)	
	--	,TVASensibleCapacity	decimal(8, 2)	
	--	,TVAEER	decimal(8, 2)	
	--	,TXV	varchar(50)	
	--	,IsLooseCoil	bit	
	--	,Airflow	decimal(8, 0)	
	--	,CanadaRegion	bit	NOT NULL
	--	,NorthernRegion	bit	NOT NULL
	--	,SouthwestRegion	bit	NOT NULL
	--	,SoutheastRegion	bit	NOT NULL
	--	,IsMatchedWidth	bit	NOT NULL
	--)

	Truncate Table RWS_MatchingSystems

	Insert into RWS_MatchingSystems
	SELECT distinct 
		  cc.[ARIRefNumber]
		  ,abb.MaterialNumber as OutdoorModelNumber
		  ,abb4.MaterialNumber as AirHandlerModelNumber
		  ,abb3.MaterialNumber as FurnaceModelNumber
		  ,abb2.MaterialNumber as CoilModelNumber
		  ,Case When cc.Brand = 'York' Then 'YOR'
				When cc.Brand = 'Coleman' Then 'COL'
				When cc.Brand = 'Luxaire' Then 'LUX'
				When cc.Brand = 'Johnson Controls' Then 'JCI'
				When cc.Brand = 'Guardian' Then 'GRD'
				When cc.Brand = 'Evcon' Then 'EVC'
				When cc.Brand = 'Champion' Then 'CHA'
				When cc.Brand = 'Fraser-Johnston' Then 'FRJ'
				--Else Brand
				End as BrandCode
		  ,[SEER]
		  ,[EER]
		  ,hc.HSPF as HSPF
		  ,cc.[TotalNetMBH] * 1000 as TotalCapacity
		  ,Null as [SensibleCapacity]
		  ,Null as [SystemKW]
		  ,Null as [TVATotalCapacity]
		  ,Null as [TVASensibleCapacity]
		  ,Null as [TVAEER]
		  ,matchtxv.TXV as [TXV] 
		  ,Case When abb4.MaterialNumber is Null and abb3.MaterialNumber is Null Then 1 Else 0
				End as [IsLooseCoil]
		  ,cc.[RatedCFM] as [Airflow] 
		  ,0 as [CanadaRegion]
		  ,0 as [NorthernRegion]
		  ,0 as [SouthwestRegion]
		  ,0 as [SoutheastRegion]
		  ,0 as [IsMatchedWidth]
	  FROM [MasterDataManagement].[dbo].[CoolingCapacity_test] as cc
	  Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Outdoor] as abb on abb.AbbreviationGUID = cc.OutdoorUnitAbbrevGUID
	  Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Coil] as abb2 on abb2.AbbreviationGUID = cc.CoilAbbrevGuid
		Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Indoor_for_TXV] as idcoil on idcoil.MaterialNumber = abb2.MaterialNumber
	  Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Furnace] as abb3 on abb3.AbbreviationGUID = cc.VSFurnaceAbbrevGuid
	  Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_AirHandler] as abb4 on abb4.AbbreviationGUID = cc.AirHandlerAbbrevGuid
		Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_MaterialNumber_Indoor_for_TXV] as idah on idah.MaterialNumber = abb4.MaterialNumber
	  Left join [MasterDataManagement].[dbo].[HeatingCapacity_test] as hc on hc.ARIRefNumber = cc.ARIRefNumber
	  Left join [MasterDataManagement].[dbo].[RSW_Abbreviation_Matchup_TXV] as matchtxv on matchtxv.Outdoor = abb.Abbreviation and (matchtxv.Indoor = idcoil.Abbreviation or matchtxv.Indoor = idah.Abbreviation)
	  where abb.MaterialNumber is not null
	  order by BrandCode, cc.ARIRefNumber, abb.MaterialNumber, abb2.MaterialNumber, abb3.MaterialNumber, abb4.MaterialNumber asc

	  
	/* add TG*S furnaces */  
	Insert into RWS_MatchingSystems
	Select [ARIRefNumber]
		  ,[OutdoorModelNumber]
		  ,[AirHandlerModelNumber]
		  ,furn.MaterialNumber as [FurnaceModelNumber]
		  ,[CoilModelNumber]
		  ,[BrandCode]
		  ,[SEER]
		  ,[EER]
		  ,[HSPF]
		  ,[TotalCapacity]
		  ,[SensibleCapacity]
		  ,[SystemKW]
		  ,[TVATotalCapacity]
		  ,[TVASensibleCapacity]
		  ,[TVAEER]
		  ,[TXV]
		  ,0 as [IsLooseCoil]
		  ,[Airflow]
		  ,[CanadaRegion]
		  ,[NorthernRegion]
		  ,[SouthwestRegion]
		  ,[SoutheastRegion]
		  ,[IsMatchedWidth]
	From dbo.RWS_MatchingSystems as match
	join [dbo].[RSW_Abbreviation_MaterialNumber_Furnace] as furn on furn.Abbreviation = 'TG*S'
	Where [CoilModelNumber] is not NULL and 
		  [FurnaceModelNumber] is NULL and 
		  [AirHandlerModelNumber] is NULL 
	Order by BrandCode, [ARIRefNumber], [OutdoorModelNumber], [CoilModelNumber], [FurnaceModelNumber] asc
	

	--Set TXV to blank where NULL
	Update [dbo].[RWS_MatchingSystems]
	Set TXV = ''
	where [dbo].[RWS_MatchingSystems].TXV is NULL

	--Set TXV to blank where coil has factory installed equivalent TXV
	Update [dbo].[RWS_MatchingSystems]
	Set TXV = ''
	where [dbo].[RWS_MatchingSystems].TXV <> '' And [dbo].[RWS_MatchingSystems].CoilModelNumber not like '%x%' AND
	(Left(Right([dbo].[RWS_MatchingSystems].TXV, 3),2) = LEFT(RIGHT([dbo].[RWS_MatchingSystems].CoilModelNumber,4),2)) 


	--Delete any row where the factory installed TXV is not equivalent to the required TXV
	Delete From [dbo].[RWS_MatchingSystems]
	Where [dbo].[RWS_MatchingSystems].TXV <> '' And [dbo].[RWS_MatchingSystems].CoilModelNumber not like '%x%' AND
	(Left(Right([dbo].[RWS_MatchingSystems].TXV, 3),2) <> LEFT(RIGHT([dbo].[RWS_MatchingSystems].CoilModelNumber,4),2)) 
	
	
	/* Remove TXV from AHRI #'s that do not require one */
	Update match
	Set match.TXV = ''
	From [dbo].[RWS_MatchingSystems] as match
	join [dbo].[AHRI_AC_MarketingReport] as ahriac on match.ARIRefNumber = ahriac.[AHRIRefNumber]
	Where RIGHT(ahriac.[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4) <> '+TXV' 
	
	Update match
	Set match.TXV = ''
	From [dbo].[RWS_MatchingSystems] as match
	join [dbo].[AHRI_HP_MarketingReport] as ahrihp on match.ARIRefNumber = ahrihp.[AHRIRefNumber]
	Where RIGHT(ahrihp.[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],4) <> '+TXV' 

	/* Remove TXV that mapping to incorrect Abbreviation due to cross sql join above*/
	DECLARE @DeletedRows TABLE (ID int)

	-- Get rows need to be deleted, then insert to temp table
	insert
		@DeletedRows
			(ID)        

	select ms.RowID
	from [MasterDataManagement].[dbo].[RWS_MatchingSystems] as ms
	where ms.RowID not in 
	(
	  select m.RowID
	  from [MasterDataManagement].[dbo].[RWS_MatchingSystems] as m
	  inner join [MasterDataManagement].[dbo].[vwAdditionalChargesToModel] as ac 
		on (ac.OutdoorUnitMaterialNumber = m.OutdoorModelNumber and ac.IndoorUnitMaterialNumber = m.AirHandlerModelNumber and ac.TXVMaterialNumber = m.TXV)
	  where (m.OutdoorModelNumber is not null and m.AirHandlerModelNumber is not null and m.TXV != '')

	  union 

	  select m.RowID
	  from [MasterDataManagement].[dbo].[RWS_MatchingSystems] as m
	  inner join [MasterDataManagement].[dbo].[vwAdditionalChargesToModel] as ac 
		on (ac.OutdoorUnitMaterialNumber = m.OutdoorModelNumber and ac.IndoorUnitMaterialNumber = m.FurnaceModelNumber and ac.TXVMaterialNumber = m.TXV)
	  where (m.OutdoorModelNumber is not null and m.FurnaceModelNumber is not null and m.TXV != '')

	  union 

	  select m.RowID
	  from [MasterDataManagement].[dbo].[RWS_MatchingSystems] as m
	  inner join [MasterDataManagement].[dbo].[vwAdditionalChargesToModel] as ac 
		on (ac.OutdoorUnitMaterialNumber = m.OutdoorModelNumber and ac.IndoorUnitMaterialNumber = m.CoilModelNumber and ac.TXVMaterialNumber = m.TXV)
	  where (m.OutdoorModelNumber is not null and m.CoilModelNumber is not null and m.TXV != '')
	) 
	and (ms.OutdoorModelNumber is not null and ms.TXV != '' and (ms.AirHandlerModelNumber is not null OR ms.FurnaceModelNumber is not null OR ms.CoilModelNumber is not null))	  

	--Delete rows in temp table
	DELETE
		[MasterDataManagement].[dbo].[RWS_MatchingSystems]
	FROM
		[MasterDataManagement].[dbo].[RWS_MatchingSystems] g
	JOIN
		@DeletedRows x
		on x.ID = g.RowID
	/* Create summary table of valid material + brand combinations */
	EXEC UpdateMatchingSystemsVerifyMaterialBrandMasterTable
	/* Delete any invalid material brand combinations from RSW_MatchingSystems */
	EXEC UpdateMatchingSystemsVerifyMaterialBrandCombinations
	

END


GO
