USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[UpdateCoolingPerformance]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UpdateCoolingPerformance]
	
AS
BEGIN

	
	WITH Missing
	AS
	(
	select distinct * from OutdoorUnits where OutdoorUnitAbbrevGUID not in
	(select OutdoorUnitAbbrevGUID from CoolingPerformanceGroups) 
	)           
	--select 
	--a.OutdoorUnitAbbrevGuid as NewOutdoor, C.OutdoorUnitAbbrevGUID as CurrentOutdoor
	update c 
	set c.OutdoorUnitAbbrevGuid = a.OutdoorUnitAbbrevGuid  
	from CoolingPerformanceGroups a
	join vwAbbreviation_MaterialMaster b on b.AbbreviationGUID = a.OutdoorUnitAbbrevGuid
	join OutdoorUnits c on c.ModelNumber = b.MaterialNumber 
	join Missing on Missing.ModelNumber = c.ModelNumber and Missing.BrandCode = c.BrandCode 
	and Missing.OutdoorUnitAbbrevGUID = c.OutdoorUnitAbbrevGUID

END


GO
