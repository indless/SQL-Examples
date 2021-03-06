USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[Wrightsoft_MatchingSystems_CopyAndCleanUp]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nick Hankins
-- Create date: 2016/10/24
-- Description:	/* Wrightsoft_MatchingSystems_CopyAndCleanUp */ 
-- =============================================
CREATE PROCEDURE [dbo].[Wrightsoft_MatchingSystems_CopyAndCleanUp]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  /* Delete MatchingSystemsWrightsoft */
  Drop Table [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft]

  /* Copy MatchingSystems to MatchingSystemsWrightsoft */
  Select *
  Into [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft]
  From [ResidentialSplitsNewQA2].[dbo].[MatchingSystems]

  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
  /* !!! Need to validate all abbreviations exist with corresponding models. Should write SQL logic to discern model numbers instead of using abbreviations !!! */
  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
  
  Delete from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] 
  Where RowId in(
				/* AC Air Handler */
				(
				Select distinct 
					msw.RowId
				from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
				join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.AirHandlerModelNumber
				join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
					  Case	 When Charindex('+TXV',ahriac.INDOOR_MODEL,1) > 0 
							 Then Case When Charindex('+',Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),1) > 0 
									   Then Right(Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),(Len(Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1)) - Charindex('+',Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),1))) 
									   Else Left(ahriac.INDOOR_MODEL,Charindex('+',ahriac.INDOOR_MODEL,1)-1) End 
							 Else Case When Charindex('+',ahriac.INDOOR_MODEL,1) > 0 
									   Then Right(ahriac.INDOOR_MODEL,(Len(ahriac.INDOOR_MODEL) - Charindex('+',ahriac.INDOOR_MODEL,1))) 
									   Else ahriac.INDOOR_MODEL End
							 End <> mma.Abbreviation and ahriac.AHRIRefNumber = msw.ARIRefNumber 
				Except (Select distinct 
							msw.RowId	
					  from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					  join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.AirHandlerModelNumber
					  join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
					  Case	 When Charindex('+TXV',ahriac.INDOOR_MODEL,1) > 0 
							 Then Case When Charindex('+',Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),1) > 0 
									   Then Right(Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),(Len(Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1)) - Charindex('+',Left(ahriac.INDOOR_MODEL,Charindex('+TXV',ahriac.INDOOR_MODEL,1)-1),1))) 
									   Else Left(ahriac.INDOOR_MODEL,Charindex('+',ahriac.INDOOR_MODEL,1)-1) End 
							 Else Case When Charindex('+',ahriac.INDOOR_MODEL,1) > 0 
									   Then Right(ahriac.INDOOR_MODEL,(Len(ahriac.INDOOR_MODEL) - Charindex('+',ahriac.INDOOR_MODEL,1))) 
									   Else ahriac.INDOOR_MODEL End
							 End = mma.Abbreviation and ahriac.AHRIRefNumber = msw.ARIRefNumber 
					  )
				 ) 
				 Union 
				  
				/* AC Coil */
				(
				Select distinct 
					msw.RowId
				from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
				join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.CoilModelNumber
				join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
						Case When Charindex('+',ahriac.INDOOR_MODEL,1) > 0 
							Then Left(ahriac.INDOOR_MODEL,Charindex('+',ahriac.INDOOR_MODEL,1)-1) 
							Else ahriac.INDOOR_MODEL end <> mma.Abbreviation and 
							ahriac.AHRIRefNumber = msw.ARIRefNumber 
				Except (Select distinct 
							msw.RowId	
					  from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					  join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.CoilModelNumber
					  join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
						Case When Charindex('+',ahriac.INDOOR_MODEL,1) > 0 
							Then Left(ahriac.INDOOR_MODEL,Charindex('+',ahriac.INDOOR_MODEL,1)-1) 
							Else ahriac.INDOOR_MODEL end = mma.Abbreviation and 
							ahriac.AHRIRefNumber = msw.ARIRefNumber 
					  )
				)			  
				Union

				/* AC Furnace */
				(
				Select distinct 
					msw.RowId 
				From 
					[ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.FurnaceModelNumber
					join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
						(ahriac.FURNACE_MODEL <> mma.Abbreviation  and ahriac.AHRIRefNumber = msw.ARIRefNumber) OR 
						(ahriac.FURNACE_MODEL is Null And ahriac.AHRIRefNumber = msw.ARIRefNumber and msw.FurnaceModelNumber is not null)
					Except (Select distinct msw.RowId From 
					[ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.FurnaceModelNumber
					join [ResidentialSplitsNewQA2].[dbo].[AHRI_AC] as ahriac on 
						(ahriac.FURNACE_MODEL = mma.Abbreviation  and ahriac.AHRIRefNumber = msw.ARIRefNumber) OR 
						(ahriac.FURNACE_MODEL is Null And ahriac.AHRIRefNumber = msw.ARIRefNumber) -- and msw.FurnaceModelNumber is null)
					)
				)
				
				Union 
				
				/* HP Air Handler */
				(
				Select distinct 
					msw.RowId
				from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
				join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.AirHandlerModelNumber
				join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
					Case When Charindex('+TXV',ahrihp.INDOOR_MODEL,1) > 0 
						 Then Case When Charindex('+',Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),1) > 0 
								   Then Right(Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),(Len(Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1)) - Charindex('+',Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),1))) 
								   Else Left(ahrihp.INDOOR_MODEL,Charindex('+',ahrihp.INDOOR_MODEL,1)-1) End 
						 Else Case When Charindex('+',ahrihp.INDOOR_MODEL,1) > 0 
								   Then Right(ahrihp.INDOOR_MODEL,(Len(ahrihp.INDOOR_MODEL) - Charindex('+',ahrihp.INDOOR_MODEL,1))) 
								   Else ahrihp.INDOOR_MODEL End
						 End <> mma.Abbreviation and 
						 ahrihp.AHRIRefNumber = msw.ARIRefNumber 
				Except (Select distinct 
							msw.RowId	
					  from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					  join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.AirHandlerModelNumber
					  join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
						Case When Charindex('+TXV',ahrihp.INDOOR_MODEL,1) > 0 
							 Then Case When Charindex('+',Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),1) > 0 
									   Then Right(Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),(Len(Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1)) - Charindex('+',Left(ahrihp.INDOOR_MODEL,Charindex('+TXV',ahrihp.INDOOR_MODEL,1)-1),1))) 
									   Else Left(ahrihp.INDOOR_MODEL,Charindex('+',ahrihp.INDOOR_MODEL,1)-1) End 
							 Else Case When Charindex('+',ahrihp.INDOOR_MODEL,1) > 0 
									   Then Right(ahrihp.INDOOR_MODEL,(Len(ahrihp.INDOOR_MODEL) - Charindex('+',ahrihp.INDOOR_MODEL,1))) 
									   Else ahrihp.INDOOR_MODEL End
							 End = mma.Abbreviation and 
							 ahrihp.AHRIRefNumber = msw.ARIRefNumber 
					  )
				 ) 
				 Union 
				  
				/* HP Coil */
				(
				Select distinct 
					msw.RowId
				from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
				join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.CoilModelNumber
				join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
						Case When Charindex('+',ahrihp.INDOOR_MODEL,1) > 0 
							Then Left(ahrihp.INDOOR_MODEL,Charindex('+',ahrihp.INDOOR_MODEL,1)-1) 
							Else ahrihp.INDOOR_MODEL end <> mma.Abbreviation and 
							ahrihp.AHRIRefNumber = msw.ARIRefNumber 
				Except (Select distinct 
							msw.RowId	
					  from [ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					  join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.CoilModelNumber
					  join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
						Case When Charindex('+',ahrihp.INDOOR_MODEL,1) > 0 
							Then Left(ahrihp.INDOOR_MODEL,Charindex('+',ahrihp.INDOOR_MODEL,1)-1) 
							Else ahrihp.INDOOR_MODEL end = mma.Abbreviation and 
							ahrihp.AHRIRefNumber = msw.ARIRefNumber 
					  )
				)			  
				Union

				/* HP Furnace */
				(
				Select distinct 
					msw.RowId 
				From 
					[ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.FurnaceModelNumber
					join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
						(ahrihp.FURNACE_MODEL <> mma.Abbreviation  and ahrihp.AHRIRefNumber = msw.ARIRefNumber) OR 
						(ahrihp.FURNACE_MODEL is Null And ahrihp.AHRIRefNumber = msw.ARIRefNumber and msw.FurnaceModelNumber is not null)
					Except (Select distinct msw.RowId From 
					[ResidentialSplitsNewQA2].[dbo].[MatchingSystemsWrightsoft] as msw
					join [ResidentialSplitsNewQA2].[dbo].[vwAbbreviation_MaterialMaster] as mma on mma.MaterialNumber = msw.FurnaceModelNumber
					join [ResidentialSplitsNewQA2].[dbo].[AHRI_HP] as ahrihp on 
						(ahrihp.FURNACE_MODEL = mma.Abbreviation  and ahrihp.AHRIRefNumber = msw.ARIRefNumber) OR 
						(ahrihp.FURNACE_MODEL is Null And ahrihp.AHRIRefNumber = msw.ARIRefNumber) -- and msw.FurnaceModelNumber is null)
					)
				)
					
				)

END

GO
