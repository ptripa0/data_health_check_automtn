-----------------------------------------------------------------------------------------
	--      SYSTEM                     : STR_GMG                                                 
	--      AUTHOR                     : Prabodh Tripathi(qa)                                        
	--      2013-10-17                 : INITIAL VERSION
	--      PURPOSE                    : MONTHLY DATA VALIDATION
-----------------------------------------------------------------------------------------
--Verify default rank  (9999) of Overall point metrics
SELECT STR_GMG_LOCN_NBR FROM STR_GMG_RPT_VIEWS_PRD.FACT_SRS_STR_GMG_COMPET_MTHLY
WHERE STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM)
AND MTH_NBR = (SELECT MTH_NO FROM TEMPPARM)
AND STR_GMG_COMPET_KEY IN

(
SELECT STR_GMG_COMPET_KEY FROM STR_GMG_RPT_VIEWS_PRD.LU_STR_GMG_COMPET 
WHERE STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM)  AND STR_GMG_COMPET_STA_MTH_NBR = (SELECT MTH_NO FROM TEMPPARM) AND STR_GMG_COMPET_LVL_CD = 'S'
)

AND STR_GMG_COMPET_RNK_LVL_CD = 'F'
AND STR_GMG_METRIC_KEY IN
( SELECT STR_GMG_METRIC_KEY FROM STR_GMG_RPT_VIEWS_PRD.LU_STR_GMG_METRIC WHERE STR_GMG_METRIC_NM = 'OVERALL_POINTS' AND STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM))
AND STR_GMG_METRIC_VALU_AMT = 9999
AND STR_GMG_METRIC_RNK = 9999

MINUS

SELECT STR_GMG_LOCN_NBR FROM STR_GMG_RPT_VIEWS_PRD.FACT_SRS_STR_GMG_COMPET_MTHLY
WHERE STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM)
AND MTH_NBR = (SELECT MTH_NO FROM TEMPPARM)
AND STR_GMG_COMPET_KEY IN

(
SELECT STR_GMG_COMPET_KEY FROM STR_GMG_RPT_VIEWS_PRD.LU_STR_GMG_COMPET 
WHERE STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM)  AND STR_GMG_COMPET_STA_MTH_NBR = (SELECT MTH_NO FROM TEMPPARM) AND STR_GMG_COMPET_LVL_CD = 'S'
)

AND STR_GMG_COMPET_RNK_LVL_CD = 'F'
AND STR_GMG_METRIC_KEY IN ( SELECT STR_GMG_METRIC_KEY FROM STR_GMG_RPT_VIEWS_PRD.LU_STR_GMG_METRIC WHERE STR_GMG_METRIC_NM = 'SYWR_TRAN_PCT_IMPRV' AND STR_GMG_STR_FMT_CD = (SELECT FMT_CD FROM TEMPPARM))
AND STR_GMG_METRIC_RNK = 9999
;
