USE [ResidentialSplitsNewQA2]
GO
/****** Object:  StoredProcedure [dbo].[UpdateProductImagesSortOrder]    Script Date: 6/30/2017 8:19:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UpdateProductImagesSortOrder] 

AS
BEGIN

	  Update dbo.ProductImages
	  Set SortOrder = p.RowNumber
	  From dbo.ProductImages as prodimage
	  inner join 
		(SELECT Top 100000 [RowID]
			  ,[BrandCode]
			  ,[ProductFamilyCode]
			  ,[SortOrder] 
			  ,Row_Number() Over(order by BrandCode, ProductFamilyCode asc) as RowNumber
			  ,[Description]
			  ,[ImageFilename]
			  ,[ProductID]
		  FROM [dbo].[ProductImages]
		  order by BrandCode, ProductFamilyCode asc
		  ) as p
		  on p.RowID = prodimage.RowID


END


GO
