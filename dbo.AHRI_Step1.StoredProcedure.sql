USE [MasterDataManagement]
GO
/****** Object:  StoredProcedure [dbo].[AHRI_Step1]    Script Date: 6/30/2017 8:17:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016-11-3
-- Description:	Step 1 of AHRI load process, Truncate Table AHRI_AC_MarketingReport & AHRI_HP_MarketingReport, Import Data from AHRI Marketing Report.xlsx files
-- =============================================
CREATE PROCEDURE [dbo].[AHRI_Step1]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Truncate Table AHRI_AC_MarketingReport
	Truncate Table AHRI_HP_MarketingReport

   /* AC Marketing Report table */
	--AHRI_AC_MarketingReport
	--Import Data from AHRI Marketing Report.xlsx
	--Right click database
	--Tasks
	--Import Data
	--Data Source: Microsoft Excel
	--Select AHRI AC Marketing Report.xlsx file
	--Verify/Select Destination SQL Server Name & Database Name
	--Copy Data from one or more tables or views
	--Select first table/view
	--Change destination table name to [dbo].[AHRI_AC_MarketingReport]
	--Check Run Immediately
	--Click Finish
	
	

	/* HP Marketing Report table */
	--AHRI_HP_MarketingReport
	--Import Data from AHRI Marketing Report.xlsx
	--Right click database
	--Tasks
	--Import Data
	--Data Source: Microsoft Excel
	--Select AHRI HP Marketing Report.xlsx file
	--Verify/Select Destination SQL Server Name & Database Name
	--Copy Data from one or more tables or views
	--Select first table/view
	--Change destination table name to [dbo].[AHRI_HP_MarketingReport]
	--Check Run Immediately
	--Click Finish


END

GO
