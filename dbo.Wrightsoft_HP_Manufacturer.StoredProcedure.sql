USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_HP_Manufacturer]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/20
-- Description:	/* HP Explicit Matchups & Performance Info */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_HP_Manufacturer]
	-- Add the parameters for the stored procedure here
	@Wrightsoft_Brand nvarchar(30)
	,@Short_Brand nvarchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	/* Heat Pump matchups */
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
	  ,hp.[AHRI_TYPE] as "Classification"
	  ,hp.[TRADENAME] as "Trade Name"
	  ,'' as "Sound Level"
	  ,'Yes' as "DOE"
	  ,'' as "Features"
	  ,'1' as "Stages"
	  ,m.[SEER] as "SEER/EER"
	  ,o.[Tonnage] * 12 as "ClgCapNom"
	  ,m.[TotalCapacity] as "Cap95"
	  ,m.[EER] as "EER95"
	  ,hp.[Cool_Cap_B2_Single_or_High_Stage_82F] as "Cap82"
	  ,hp.[EER_B2_Single_or_High_Stage_82F] as "EER82"
	  ,hp.[DEG_COEF_COOL] as "ClgCd"
	  ,m.[Airflow] as "ClgFanAVF"
	  ,'' as "Cap95_LS"
	  ,'' as "EER95_LS"
	  ,'' as "Cap82_LS"
	  ,'' as "EER82_LS"
	  ,'' as "ClgCd_LS"
	  ,'' as "ClgFanAVF_LS"
	  ,m.[HSPF] as "HSPF"
	  ,hp.[Heat_Cap_H1_2_Single_or_High_Stage_47F] as "Cap47"
	  ,hp.[Heat_COP_H1_2_Single_or_High_Stage_47F] as "COP47"
	  ,'' as "Cap35"
	  ,'' as "COP35"
	  ,hp.[Heat_Cap_H3_2_Single_or_High_Stage_17F] as "Cap17"
	  ,hp.[Heat_COP_H3_2_Single_or_High_Stage_17F] as "COP17"
	  ,hp.[DEG_COEF_HEAT] as "HtgCd"
	FROM [dbo].[MatchingSystemsWrightsoft] as m
	Right Join [dbo].[AHRI_HP] as hp on hp.AHRIRefNumber = m.ARIRefNumber
	Right Join [dbo].[OutdoorUnits] as o on o.ModelNumber = m.OutdoorModelNumber and o.BrandCode = m.BrandCode
	where m.BrandCode = @Short_Brand and o.MatchupType = 'HeatPump' 
	Order By m.ARIRefNumber, "Coil Model", "Furn Model", "AH Model" asc  
END

GO
