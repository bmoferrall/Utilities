#!/bin/bash
#
# mooreof@ie.ibm.com, September 2019
#

log() {
	local msg=$1
	
	echo "### ${msg} ###"
	echo "### ${msg} ###" >> $logFile 2>&1
}

error() {
	local msg=$1
	
	echo "### ERROR: ${msg} ###"
	echo "### ERROR: ${msg} ###" >> $logFile 2>&1
}

exitIfCurrentUserNotEqual() {
   local correctUser=$1
   local currentUser="$(whoami)"
   
   if [ "$currentUser" != "$correctUser" ]; 
   then
      echo "USER ERROR: This script is running as user: $currentUser"
      echo "            This script should be run as user: $correctUser"
      exit -1;
   fi
}

initLogFile() {
   logFile="${outputDir}/dbmon_log_`date +\%m\%d`.txt"
   echo "Log Start Time: `date`" > $logFile
}

usage() {
   echo "Runs the script for each DB in the specified list"
   echo "Usage: dbmon_report.sh snapshotDuration_in_secs snapshotInterval_in_secs iterations outputDir instance user password dbList"
   echo "Example: dbmon_report.sh 900 10 2 /var/log/db/mon/10/WIHDB_IOCDB db2i1own db2i1own password 'DB1,DB2' &"
   exit 1
}

processArguments() {

   if [ $# -ne 8 ]
   then
      usage
   fi
   
   snapshotDuration=$1
   snapshotInterval=$2
   iterations=$3
   outputDir=$4
   instance=$5
   user=$6
   password=$7
   dbList=$(echo $8 | tr "," "\n")

   scriptDir="$( cd "$(dirname "$0")" ; pwd -P )"
   
   cd ${scriptDir}
   
   if [ ! -d "$outputDir" ]
   then
      mkdir -p $outputDir
      chmod 755 $outputDir
   fi
   
   initLogFile
}

initialiseMonTables() {
   local iteration=$1
   
   if [[ $iteration -eq 1 ]]
   then
      db2 'drop table dbmon.dubperf_db_diff' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_db_start' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_db_end' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_moncontainer_diff' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_moncontainer_start' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_moncontainer_end' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_monindex_diff' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_monindex_start' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_monindex_end' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montable_diff' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montable_start' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montable_end' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montablespace_diff' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montablespace_start' >> $logFile 2>&1
      db2 'drop table dbmon.dubperf_montablespace_end' >> $logFile 2>&1
      db2 -ntf dbmon_1_combined.sql >> $logFile 2>&1
   else
      db2 'truncate dbmon.dubperf_db_diff immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_db_start immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_db_end immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_moncontainer_diff immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_moncontainer_start immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_moncontainer_end immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_monindex_diff immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_monindex_start immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_monindex_end immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montable_diff immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montable_start immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montable_end immediate' >> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montablespace_diff immediate'>> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montablespace_start immediate'>> $logFile 2>&1
      db2 'truncate dbmon.dubperf_montablespace_end immediate'>> $logFile 2>&1
   fi
}

captureStartStatsForDB() {
   db2 -ntf dbmon_2_combined.sql >> $logFile 2>&1
}

clearCacheForDB() {
   db2 flush package cache dynamic >> $logFile 2>&1
}

connectToDB() {
   local dbName=$1
   
   db2 connect to ${dbName} user ${user} using ${password} >> $logFile 2>&1
}

disconnectFromDB() {
   db2 connect reset >> $logFile
}

initialiseDBForStatsCollection() {
   local dbName=$1
   local iteration=$2

   log "Initialising ${dbName} for stats collection"
   
   connectToDB $dbName
   initialiseMonTables $iteration
   captureStartStatsForDB
   clearCacheForDB
   disconnectFromDB
}

exportDBMconfiguration() {
    db2 get dbm cfg >> ${outputDir}/dbm_cfg_${instance}_`date +\%m\%d`.txt
}

captureEndStatsForDB() {
   local dbName=$1
   local iteration=$2
   
   db2 -ntf dbmon_3_combined.sql >> $logFile 2>&1
}

exportCacheContentsForDB() {
   local dbName=$1
   local iteration=$2
   
   db2 -ntf getdbsqlcache.sql > ${outputDir}/dbmon_${dbName}_cache_`date +\%m\%d`_${iteration}.txt
}

exportCurrentSqlForDB() {
   local dbName=$1
   local iteration=$2
   
   db2 -ntf getmoncurrentsql.sql > ${outputDir}/dbmon_${dbName}_current_`date +\%m\%d`_${iteration}.txt
}

generateStatsDifferenceForDB() {
   db2 -ntf dbmon_4_combined.sql >> $logFile 2>&1
}

generateStatsReportForDB() {
   local dbName=$1
   local iteration=$2
   local fileName="${outputDir}/dbmon_${dbName}_report_`date +\%m\%d`_${iteration}.txt"
   
   db2 get db cfg > $fileName
   db2 -ntxf dbmon_5_combined.sql >> $fileName
}

exportConnectionInfoForDB() {
   local dbName=$1
   local iteration=$2
   
   db2 -ntf getdbconnectionssummary.sql > ${outputDir}/dbmon_${dbName}_connectionssummary_`date +\%m\%d`_${iteration}.txt
   db2 -ntf getdbconnectionsinfo.sql    > ${outputDir}/dbmon_${dbName}_connectionsinfo_`date +\%m\%d`_${iteration}.txt
}

exportDiskSpaceInfoForDB() {
   local dbName=$1
   local iteration=$2
   
   db2 -ntf diskspaceutil.sql > ${outputDir}/dbmon_${dbName}_diskspaceutil_`date +\%m\%d`_${iteration}.txt
}

collectStatsForDB() {
   local dbName=$1
   local iteration=$2
   
   log "Collecting stats for db ${dbName}"
   
   connectToDB $dbName
   captureEndStatsForDB $dbName $iteration
   exportCacheContentsForDB $dbName $iteration
   exportCurrentSqlForDB $dbName $iteration
   generateStatsDifferenceForDB
   generateStatsReportForDB $dbName $iteration
   exportConnectionInfoForDB $dbName $iteration
   exportDiskSpaceInfoForDB $dbName $iteration
   disconnectFromDB
}

exportExplainPlansForDB() {
   local dbName=$1
   local currentIteration=$2
   local totalIterations=$3
   local explainConfigured=0

   connectToDB $dbName
   explainConfigured=$(db2 -x "SELECT COUNT FROM SYSCAT.TABLES WHERE TYPE='T' AND TABSCHEMA='SYSTOOLS' and TABNAME='EXPLAIN_INSTANCE'")
   explainConfigured=$(echo $explainConfigured | xargs)

   if [[ ${currentIteration} -eq ${totalIterations} && $explainConfigured -eq 1 ]] ;
   then
      exportExplainPlans $dbName
   fi
   
   disconnectFromDB
}

exportExplainPlans() {
   local dbName=$1
   local execIds=()
   local execString=
 
   log "Exporting explain plans for the top 15 slowest-executing queries in db ${dbName}"
   
   execIdString=$(db2 -ntxf getTopExplainPlans.sql)

   readarray -t execIds <<< "$execIdString"

   for index in "${!execIds[@]}"
   do
      db2 "call explain_from_section(${execIds[index]},'M',NULL,0,'',?,?,?,?,?)" >> $logFile 2>&1
      db2exfmt -d $dbName -1 -o $outputDir/${dbName}_explain_q${index}.txt >> $logFile 2>&1
   done
}

exportInstanceApplicationInfo() {
   local iteration=$1
   local fileName
   
   fileName="${outputDir}/dbmon_${instance}_applicationinfo_`date +\%m\%d`_${iteration}.txt"
   date > $fileName
   db2 -ntf getdbapplicationinfo.sql >> $fileName
   
   fileName="${outputDir}/dbmon_${instance}_applicationinfosummary_`date +\%m\%d`_${iteration}.txt"
   date > $fileName
   db2 -ntf getdbapplicationinfosummary.sql >> $fileName
}

exportInstanceMemoryInfo() {
   local iteration=$1
   
   db2 -ntf getMemorySetInfo.sql > ${outputDir}/dbmon_${instance}_memorysetinfo_`date +\%m\%d`_${iteration}.txt
   db2 -ntf getmempoolinfo.sql   > ${outputDir}/dbmon_${instance}_mempoolinfo_`date +\%m\%d`_${iteration}.txt
   db2mtrk -i -d -v > ${outputDir}/db2mtrk_${instance}_`date +\%m\%d`_${iteration}.txt
   db2pd -dbptnmem >> ${outputDir}/db2pd_${instance}_`date +\%m\%d`.txt
}

exportInstanceLevelStats() {
   local dbName=$1
   local iteration=$2
 
   connectToDB $dbName # we need a valid connection 
   
   exportInstanceApplicationInfo $iteration
   exportInstanceMemoryInfo $iteration
   
   disconnectFromDB
   
   exportDBMconfiguration
}

convertOutputFromUnixToDosFormat() {
   unix2dos $outputDir/*.txt > /dev/null 2>&1
   sed -i 's/\s*$//' $outputDir/dbmon*report*.txt > /dev/null 2>&1
}

compressOutputFiles() {
   local dbNames=$(echo $dbList | tr " \n\r" "__")
   local zipFileName="${outputDir}/${dbNames}`date +\%m\%d_\%H\%M`.zip"
   
   rm -f ${zipFileName} > /dev/null 2>&1
   zip -9 -q -r ${zipFileName} ${outputDir}/*.txt >> $logFile 2>&1

   if [[ $? -eq 0 ]]; then
      rm -f ${outputDir}/*.txt
      rm -fR ${outputDir}/explain
   else
      log "Problem compressing the output files"
   fi
}

collectStatsForSelectedDatabases() {
   local validDb
   local iteration

   log "---------------------------------------"
   log "Current User: $(whoami)"
   log "Collecting stats for instance \"${instance}\" and database(s) \"$(echo $dbList | tr "\n" " " | xargs)\""
   
   for (( iteration = 1; iteration <= $iterations; iteration++ ))
   do
      log "Starting iteration ${iteration} of ${iterations}"
	  
      for DB in ${dbList}
      do
         initialiseDBForStatsCollection $DB $iteration
      done
   
      sleep $snapshotDuration
      
      for DB in ${dbList}
      do
         validDb=${DB}
	     collectStatsForDB $DB $iteration
		 exportExplainPlansForDB $DB $iteration $iterations
      done
   
      exportInstanceLevelStats $validDb $iteration
	  
      log "Iteration ${iteration} complete"
   
      if [[ ${iteration} < ${iterations} ]]
      then
         log "Sleeping for ${snapshotInterval} seconds between snapshots"
         sleep $snapshotInterval
      fi  
   done

   log "All ${iterations} iteration(s) complete"
   log "Output has been saved in compressed form to the directory \"${outputDir}\""
   log "Press <return> to exit"
  
   convertOutputFromUnixToDosFormat
   compressOutputFiles
}

processArguments "$@"
collectStatsForSelectedDatabases

exit 0
