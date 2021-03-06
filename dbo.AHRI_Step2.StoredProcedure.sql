USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step2]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 2 of AHRI load process, Create temp tables with list of unique abbreviations for Outdoor, Coil, Air Handler & Furnace abbreviations used in AHRI Marketing Reports
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step2]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   /* AC Marketing Report table */
	--AHRI_AC_MarketingReport

	/* HP Marketing Report table */
	--AHRI_HP_MarketingReport

	/* SP: Write Distinct AC & HP Outdoor abbrev into temp table with auto index or Row# */
	CREATE TABLE temp_AHRI_Outdoor
	(
		ID int IDENTITY(1,1) PRIMARY KEY,
		Abbreviation nvarchar(50) NOT NULL
	)

	INSERT INTO temp_AHRI_Outdoor (Abbreviation)
	(SELECT distinct 
		Case
			When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)]),1)) = 0
			Then Case
					When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-1,1)) = 0
					Then Case
							When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-2,1)) = 0
							Then LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-3)
							Else LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-2)
							End
					Else LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-1)
					End
			Else [OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)]
			End
			as 'OutdoorUnitAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_AC_MarketingReport]

	  /* AC */
	  Union 
	  /* HP */
	  SELECT distinct 
		Case
			When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)]),1)) = 0
			Then Case
					When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-1,1)) = 0
					Then Case
							When isNumeric(substring([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],LEN([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-2,1)) = 0
							Then LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-3)
							Else LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-2)
							End
					Else LEFT([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)],len([OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)])-1)
					End
			Else [OUTDOOR MODEL (CONDENSER OR SINGLE PACKAGE)]
			End
			as 'OutdoorUnitAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_HP_MarketingReport])
	  Order by 'OutdoorUnitAbbrev' asc
		  
	/* SP: Write Distinct AC & HP Coil abbrev into temp table with auto index or Row# */
	CREATE TABLE temp_AHRI_Coil
	(
		ID int IDENTITY(1,1) PRIMARY KEY,
		Abbreviation nvarchar(50) NOT NULL
	)

	INSERT INTO temp_AHRI_Coil (Abbreviation)
	(SELECT distinct 
		Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC') /* When the abbreviation has separate Coil */
			Then Case 
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* When there's a + Air Handler or +TXV */
					Then Left([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1) /* take left of first + for Coil abbreviation */
					Else [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] /* Loose Coil only Abbreviation */
					End 
			Else ''
			End as 'CoilAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_AC_MarketingReport]
	  /* AC */
	  Union 
	  /* HP */
	  SELECT distinct 
		Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) in ('CF','CM','CU','FC','MC','PC','UC') /* When the abbreviation has separate Coil */
			Then Case 
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* When there's a + Air Handler or +TXV */
					Then Left([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1) /* take left of first + for Coil abbreviation */
					Else [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] /* Loose Coil only Abbreviation */
					End 
			Else ''
			End as 'CoilAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_HP_MarketingReport])
	  Order by 'CoilAbbrev' asc

	/* SP: Write Distinct AC & HP Air Handler abbrev into temp table with auto index or Row# */
	CREATE TABLE temp_AHRI_AirHandler
	(
		ID int IDENTITY(1,1) PRIMARY KEY,
		Abbreviation nvarchar(50) NOT NULL
	)

	INSERT INTO temp_AHRI_AirHandler (Abbreviation)
	(SELECT distinct 
		Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) not in ('CF','CM','CU','FC','MC','PC','UC') /* When the abbreviation does not have separate Coil */
			Then Case 
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* checks for + for what should be a +TXV */
					Then Left([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1) /* remove +TXV */
					Else [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] /* Air Handler only abbreviation */
					End 
			Else Case	
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* Abbreviation starts with Coil & + Air Handler */
						and Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <> Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)
					Then Case 
							When Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* has +TXV */
							Then SUBSTRING([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]
									,Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)+1
									,Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1 - Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)) /* take the Air Handler abbreviation between first + and +TXV */
							Else SUBSTRING([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]
									,Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)+1
									,Len([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]) - Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)) /* take the Air Handler abbreviation after + */
							End
					Else '' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
					End
			End as 'AirHandlerAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_AC_MarketingReport]
	  /* AC */
	  Union 
	  /* HP */
	  SELECT distinct 
		Case
			When LEFT([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],2) not in ('CF','CM','CU','FC','MC','PC','UC') /* When the abbreviation does not have separate Coil */
			Then Case 
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* checks for + for what should be a +TXV */
					Then Left([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1) /* remove +TXV */
					Else [INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)] /* Air Handler only abbreviation */
					End 
			Else Case	
					When Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* Abbreviation starts with Coil & + Air Handler */
						and Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) <> Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)
					Then Case 
							When Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1) > 0 /* has +TXV */
							Then SUBSTRING([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]
									,Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)+1
									,Charindex('+TXV',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)-1 - Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)) /* take the Air Handler abbreviation between first + and +TXV */
							Else SUBSTRING([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]
									,Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)+1
									,Len([INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)]) - Charindex('+',[INDOOR COIL MODEL (EVAPORATOR AND/OR AIR-HANDLER)],1)) /* take the Air Handler abbreviation after + */
							End
					Else '' /* show blank as Air Handler abbreviation where indoor contains loose coil only */
					End
			End as 'AirHandlerAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_HP_MarketingReport])
	  Order by 'AirHandlerAbbrev' asc

	/* SP: Write Distinct AC & HP Furnace abbrev into temp table with auto index or Row# */
	CREATE TABLE temp_AHRI_Furnace
	(
		ID int IDENTITY(1,1) PRIMARY KEY, 
		Abbreviation nvarchar(50) NOT NULL
	)

	INSERT INTO temp_AHRI_Furnace (Abbreviation)
	(SELECT distinct 
		Case
			When [FURNACE MODEL] IS NULL
			Then ''
			Else Case
					When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL]),1)) = 0
					Then Case
							When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL])-1,1)) = 0
							Then Case
									When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL])-2,1)) = 0
									Then LEFT([FURNACE MODEL],len([FURNACE MODEL])-3)
									Else LEFT([FURNACE MODEL],len([FURNACE MODEL])-2)
									End
							Else LEFT([FURNACE MODEL],len([FURNACE MODEL])-1)
							End
					Else [FURNACE MODEL]
					End
			End
			as 'VSFurnaceAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_AC_MarketingReport]
	  /* AC */
	  Union 
	  /* HP */
	  SELECT distinct 
		Case
			When [FURNACE MODEL] IS NULL
			Then ''
			Else Case
					When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL]),1)) = 0
					Then Case
							When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL])-1,1)) = 0
							Then Case
									When isNumeric(substring([FURNACE MODEL],LEN([FURNACE MODEL])-2,1)) = 0
									Then LEFT([FURNACE MODEL],len([FURNACE MODEL])-3)
									Else LEFT([FURNACE MODEL],len([FURNACE MODEL])-2)
									End
							Else LEFT([FURNACE MODEL],len([FURNACE MODEL])-1)
							End
					Else [FURNACE MODEL]
					End
			End
			as 'VSFurnaceAbbrev'
	  FROM [MasterDataManagement].[dbo].[AHRI_HP_MarketingReport])
	  Order by 'VSFurnaceAbbrev' asc
			  
END

GO
