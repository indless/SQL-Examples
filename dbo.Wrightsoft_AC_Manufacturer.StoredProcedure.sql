USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_AC_Manufacturer]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* AC Explicit Matchups & Performance Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_AC_Manufacturer]
	-- Add the parameters for the stored procedure here
	@Wrightsoft_Brand nvarchar(30)
	,@Short_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Air Conditioner matchups */
	SELECT m.[ARIRefNumber]
	  ,@Wrightsoft_Brand as "BrandCode"
	  ,m.[OutdoorModelNumber] as "Condenser Model"
	  ,Case When m.[CoilModelNumber] is NULL Then ''
			Else m.[CoilModelNumber] End as "Coil Model"
	  ,Case When m.[FurnaceModelNumber] is NULL Then ''
			Else m.[FurnaceModelNumber] End as "Furn Model"
	  ,Case When m.[AirHandlerModelNumber] is NULL Then ''
			Else m.[AirHandlerModelNumber] End as "AH Model"
	  ,m.[TXV] as "AccCode"
	  ,ac.[AHRI_TYPE] as "Classification"
	  ,ac.[TRADENAME] as "Trade Name"
	  ,'' as "Sound Level"
	  ,'Yes' as "DOE"
	  ,'' as "Features"
	  ,'1' as "Stages"
	  ,m.[SEER] as "SEER/EER"
	  ,o.Tonnage * 12 as "ClgCapNom"
	  ,m.[TotalCapacity] as "Cap95"
	  ,m.[EER] as "EER95"
	  ,ac.[Cool_Cap_B2_Single_or_High_Stage_82F] as "Cap82"
	  ,ac.[EER_B2_Single_or_High_Stage_82F] as "EER82"
	  ,ac.[DEG_COEF_COOL] as "Cd"
	  ,m.[Airflow] as "ClgFanAVF"
	FROM [dbo].[MatchingSystemsWrightsoft] as m
	Right Join [dbo].[AHRI_AC] as ac on ac.AHRIRefNumber = m.ARIRefNumber
	Right Join [dbo].[OutdoorUnits] as o on o.ModelNumber = m.OutdoorModelNumber and o.BrandCode = m.BrandCode
	where m.BrandCode = @Short_Brand and o.MatchupType = 'AirConditioner' 
	Order By m.ARIRefNumber, "Coil Model", "Furn Model", "AH Model" asc
END

GO
