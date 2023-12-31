USE [Kabel]
GO

/****** Object:  View [dbo].[VIEW_CST_LISTA_CONSUMO_OPTCODE_JOB]    Script Date: 07/07/2023 17:21:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VIEW_CST_LISTA_CONSUMO_OPTCODE_JOB] AS      
select CST_VIEW_LISTA_MOV_JOB_ODF_OPTCODE.* FROM CST_VIEW_LISTA_MOV_JOB_ODF_OPTCODE (NOLOCK)       
 INNER JOIN (      
     select sum(ESTOQUE_LOCAL.QTDE)  Q, CODIGO FROM ESTOQUE_LOCAL (NOLOCK) WHERE LOCAL = '1565' --AND CODIGO = '0610'      
     GROUP BY CODIGO       
       ) AS TB ON TB.CODIGO = ITEM      
 INNER JOIN (SELECT ITEM I, ODF O FROM ANALISE_LOCAL (NOLOCK)       
     WHERE LOCAL = 1565      
     GROUP BY ITEM, ODF      
    ) TBX ON TBX.I = ITEM AND TBX.O = ODF      
--WHERE  APONTAR > 0 AND  ITEM in ('0610', '25489','0630','4204')
WHERE  APONTAR > 0
GO


