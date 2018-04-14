# !/bin/ksh
# Wrapper script to invoke sql and bteq scripts
# To export database parameter
# CALLING PARAMETER FILES
. /di/Projects/acrgame/scripts/qaQA/config/R11/env_unix.ksh
. /di/Projects/acrgame/scripts/qaQA/config/R11/env_db.ksh
echo "Environment Parameters set Successfully!"
echo "Check for the logs in path: $LOG"
export START_DT=$1
export END_DT=$2
export FMT_CD='FLS'
export TIMESTAMP=`date +%Y%m%d%H%M%S` # Get The Timestamp

export master_log=${LOG}/str_gmg_FLS_R11_MASTER_QA_LOG_${TIMESTAMP}.log
export bteq_log=${LOG}/str_gmg_FLS_R11_BTEQ_QA_LOG_${TIMESTAMP}.bteq
export minus_quey_log=${LOG}/minus_quey_log_${TIMESTAMP}.log

touch $master_log
touch $bteq_log
touch $minus_quey_log

echo "Script execution started at `date`" >> $master_log 
echo "Running script for Date Interval: $START_DT and $END_DT" >> $master_log 
filename=`echo $SQL/R11_Data_Load_SQL.sql`
echo "Running Metric SQL file: $filename" >> $master_log
$DI_UTILS_DIR/bin/run_sql.ksh -pf td -m bteq -p $PROJECT_NAME -u $TD_STR_GMG_BATCH_USER_FLS -pw $TD_STR_GMG_BATCH_PWD_FLS -host $TD_SERVER -d $TD_STR_GMG_STG_TBLS_DB -sql $filename >> $bteq_log

ret_val=$?
if [[ $ret_val -ne 0 ]]; then

   printf "\nSQL file $filename excecution Failed!:$ret_val" >> $master_log
   printf "\nScript execution failed at `date`" >> $master_log

else

   printf "\nSQL file $filename excecuted Successfully!" >> $master_log
   printf "\nScript execution completed at `date`"  >> $master_log

fi

# Execute Assoc-Locn & Assoc-Locn-Div level minus queries and store the test results
bteq << EOF > $minus_quey_log 2>&1
.LOGON $TD_SERVER/$TD_STR_GMG_BATCH_USER_FLS, $TD_STR_GMG_BATCH_PWD_FLS;

.EXPORT REPORT FILE=$OUTBOUND/locn_assoc_minus_query_result_${TIMESTAMP}.csv 

.QUIET ON;

.SET TITLEDASHES OFF;

.SET SEPARATOR ',';

CREATE SET VOLATILE TABLE TEMPDATE, NO LOG AS
(
SELECT 
'$START_DT' AS S_DT
, '$END_DT' AS E_DT
)
WITH DATA
PRIMARY INDEX(S_DT, E_DT)
ON COMMIT PRESERVE ROWS
;


-- Execute Assoc-Locn level minus query and store the test results
.RUN FILE=$SQL/R11_Data_Validation_LocnAssoc_SQL_Auto.sql

.EXPORT RESET;

--Execute Assoc-Locn-Div level minus query and store results
.EXPORT REPORT FILE=$OUTBOUND/locn_assoc_div_minus_query_result_${TIMESTAMP}.csv 

.SET RECORDMODE OFF;
.QUIET ON;

.SET TITLEDASHES OFF;
.SET WIDTH 15000;

.SET SEPARATOR ',';

.RUN FILE=$SQL/R11_Data_Validation_LocnAssocDiv_SQL_Auto.sql

.EXPORT RESET;
.LOGOFF;
.QUIT;

EOF

ret_val2=$?
if [[ $ret_val2 -ne 0 ]]; then

   printf "\nSQL file $minus_quey_log excecution Failed!:$ret_val2"  >> $master_log
   printf "\n$minus_quey_log script execution failed at `date`"  >> $master_log
   exit $ret_val2 

else

   printf "\nSQL file $minus_quey_log excecuted Successfully!"  >> $master_log
   printf "\n$minus_quey_log script execution completed at `date`"  >> $master_log
   exit $ret_val2

fi