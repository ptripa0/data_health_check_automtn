# !/bin/ksh
# Wrapper script to invoke sql and bteq scripts
# To export database parameter
# CALLING PARAMETER FILES
. /di/Projects/acrgame/scripts/qaQA/config/env_unix.ksh
. /di/Projects/acrgame/scripts/qaQA/config/env_db.ksh
echo "Environment Parameters set Successfully!"
echo "Check for the logs in path: $LOG"
#export START_DT=$1
#export END_DT=$2
export FMT_CD=$1
export MTH_NO=$2
export TIMESTAMP=`date +%Y%m%d%H%M%S` # Get The Timestamp
export master_log=${LOG}/Mly_${FMT_CD}_Data_Val_QA_LOG_${TIMESTAMP}.log
export bteq_log=${LOG}/Mly_${FMT_CD}_Data_Val_BTEQ_QA_LOG_${TIMESTAMP}.bteq
touch $master_log
touch $bteq_log
echo "Script execution started at `date`" >> $master_log 
echo "Running script for $FMT_CD UMR data load for month number: $MTH_NO" >> $master_log 
bteq<<EOF> $bteq_log 2>&1
.LOGON $TD_SERVER/$TD_STR_GMG_BATCH_USER_KMT, $TD_STR_GMG_BATCH_PWD_KMT;

CREATE SET VOLATILE TABLE TEMPPARM, NO LOG AS
(
SELECT 
'$FMT_CD' AS FMT_CD
, '$MTH_NO' AS MTH_NO
)
WITH DATA
PRIMARY INDEX(FMT_CD, MTH_NO)
ON COMMIT PRESERVE ROWS
;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_threshold_val_${FMT_CD}_${TIMESTAMP}.csv

.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';


.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_threshold_val.sql
.EXPORT RESET;


.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_overall_pt_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_overall_pt_val.sql
.EXPORT RESET;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_null_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_null_val.sql
.EXPORT RESET;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_missing_proration_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_missing_proration_val.sql
.EXPORT RESET;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_metrics#_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_metrics#_val.sql
.EXPORT RESET;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_locn#_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_locn#_val.sql
.EXPORT RESET;

.EXPORT REPORT FILE=$OUTBOUND/acr_game_qa_force_proration_val_${FMT_CD}_${TIMESTAMP}.csv
.SET RECORDMODE OFF;
.QUIET ON;
.SET TITLEDASHES OFF;
.SET WIDTH 15000;
.SET SEPARATOR ',';

.RUN FILE=/di/Projects/acrgame/scripts/qaQA/config/MLY_VAL/acr_game_qa_force_proration_val.sql
.EXPORT RESET;

EOF

#filename=`echo $SQL/R11_staging_load_script_qa.sql`
#echo "Running Metric SQL file: $filename" >> $master_log
#$DI_UTILS_DIR/bin/run_sql.ksh -pf td -m bteq -p $PROJECT_NAME -u $TD_STR_GMG_BATCH_USER_FLS -pw $TD_STR_GMG_BATCH_PWD_FLS -host $TD_SERVER -d $TD_STR_GMG_STG_TBLS_DB -sql $filename >> $bteq_log
ret_val=$?
if [[ $ret_val -ne 0 ]]; then

   printf "\nMonthly load of $FMT_CD UMR for month no $MTH_NO Failed!:$ret_val" >> $master_log
   printf "\nScript execution failed at `date`" >> $master_log

else
   printf "\nMonthly load of $FMT_CD UMR for month no $MTH_NO excecuted Successfully!" >> $master_log
   printf "\nScript execution completed at `date`"  >> $master_log
fi