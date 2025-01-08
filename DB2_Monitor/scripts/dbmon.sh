#!/bin/bash
#
# mooreof@ie.ibm.com, September 2019
#
# PREREQUISITES
#
# 1. sysstat package is installed. Check using 'yum list installed sysstat'
#    The package can be installed from here: http://sebastien.godard.pagesperso-orange.fr/download.html
#    
#    Once installed, increase the frequency of background stats collection from the default 10 min to 1 min
#    Edit the file '/etc/cron.d/sysstat' and configure sa1 as follows
#    
#    * * * * * root /usr/lib64/sa/sa1 1 1
#
# 2. Turn on DB monitor switches for each instance to be monitored. 
#    If these switches are not enabled some of the report statistics will be zero
#    You can check if they have been set with 'db2 get dbm cfg | grep dft_mon'
#    To enable:
#       db attach to <instance_name>
#       db2 update dbm cfg using dft_mon_bufpool ON
#       db2 update dbm cfg using dft_mon_lock ON
#       db2 update dbm cfg using dft_mon_stmt ON
#       db2 update dbm cfg using dft_mon_table ON
#       db2 update dbm cfg using dft_mon_timestamp ON
#       db2 update dbm cfg using dft_mon_uow ON
#       db2 update dbm cfg using dft_mon_sort ON
#    Restart the instance:
#       db2stop force
#       db2start
#
# 3. (optional) Install DB2's explain facility in the database(s) to be monitored.
#    If installed, the utility will export Explain Plans for the top 15 slowest-executing statements
#    Example for DB2 11.1:
#    db2 connect to <dbname>
#    db2 -ntf /opt/ibm/db2/V11.1/misc/EXPLAIN.DDL
#    db2 connect reset
#
# 4. (optional) Install the 'unix2dos' utility if you plan to view the output in Windows
#    yum install unix2dos
#
# SETUP    
#
# 1. Create script directory ($scriptDir) and copy the sh and sql scripts into it.
# 2. Execute the following commands on the contents of the script directory:
#    dos2unix $scriptDir/*
#    chmod -R 755 $scriptDir
#    chmod +x $scriptDir/*.sh
#
# DESCRIPTION
#
#    The DB monitor tool uses a diff approach to capture SQL activity during the monitor period only
#    If the load  you are monitoring is constant over the duration of a test you can simply start monitoring before the test
#    and set the monitor duration to the duration of the test, or slightly longer
#
#    If varying loads are applied in phases you can configure the tool to match those phases.
#    Output files will be generated for each monitor phase (_1, _2, _3, etc)
#    For example, given the following load scenario:
#
#    | ramp up to 10 users over 1 min | hold at 10 users for 20 mins | 
#           ...       | ramp up to 20 users over 1 min | hold at 20 users for 20 mins |
#
#    You can configure the DB monitoring to synchronise with the hold phases as follows:
#
#    dbmon.sh -s 1200 -i 60 -n 2 -c <instance> -l <localuser> -u <user> -p <password> -d 'DB1,DB2'
#
#    e.g.
#    dbmon.sh -s 1200 -i 60 -n 2 -c db2i1own -l db2inst1 -u db2i1own -p XXX -d 'IOCDB,IOCDATA'
#
#    Output files will be saved to /var/log/db/mon/XX/DBLIST/, where XX is the 2-digit day number
#    For example: /var/log/db/mon/24/DB1_DB2/DB1_DB2_0820_0958.zip
#
#    Note that this script should be run as root. It will invoke the child script as the database user


initOutputDir() {
   local baseLogDir=/var/log/db/mon
   local subDir=$(echo $dbList | tr "," "_")   
   
   if [ ! -d "$baseLogDir" ]
   then
      mkdir -p $baseLogDir
   fi
   
   outputDir=${baseLogDir}/`date +\%d`
   outputDir=${outputDir}/${subDir}
   
   if [ ! -d "$outputDir" ]
   then
      mkdir -p $outputDir
      chmod -R 777 $outputDir
   else
      chmod -R 777 $outputDir
      rm -f $outputDir/*.txt
      rm -f $outputDir/*.log
   fi
}

usage() {
   local msg=$1
   
   echo ">>>> ${msg} <<<<<<"
   echo "------------------------------------------------------------------------------------"
   echo "Usage:   ./dbmon.sh -s snapshotDuration_secs -i snapshotInterval_secs -n iterations "
   echo "                    -c instance -l localDbUser -u remoteDbUser -p dbpwd -d 'list_of_DBs'"
   echo "   Required:"
   echo "      -u: database user for database(s) to be monitored"
   echo "      -p: password of database user for database(s) to be monitored"
   echo "      -d: comma-separated list of database names (no space after commas)"
   echo "   Optional:"
   echo "      -s: duration of each snapshot in seconds (defaults to 300 seconds)"
   echo "      -i: interval in seconds between each snapshot (defaults to 0)"
   echo "      -n: number of snaphots (defaults to 1)"
   echo "      -c: name of the database instance to be monitored (defaults to name of database user -u)"
   echo "      -l: local database user in remote catalog set up (defaults to name of database user -u)"
   echo "   "
   echo "      -h: usage"
   echo "   "
   echo "There are two types of set up possible:"
   echo "   "
   echo "1. Databases are remotely catalogued on a server with DB2 client tools installed "
   echo "   and the utility is run from the client."
   echo "   In this case the local database user <localDbuser> will be that of the DB2 client, so may"
   echo "   be different from the database user <remoteDbuser> on the server to be monitored"
   echo "   Note that in this scenario the iostat/mpstat/top data will be for the client machine, so can be ignored"
   echo "2. The utility is run directly on the monitored server."
   echo "   In this case the local and remote database users will be the same, so the -l option can be omitted"
   echo "   "
   echo "Example: Run two 15 min phases for the databases IOCDATA and IOCDB, with a 10 second interval between the phases"
   echo "   "
   echo "         ./dbmon.sh -s 900 -i 10 -n 2 -c db2i1own -l db2inst1 -u db2i1own -p XXX -d 'IOCDATA,IOCDB'"
   echo "   "
   echo "------------------------------------------------------------------------------------"
   exit 1
}

processArguments() {
   snapshotDuration=300
   snapshotInterval=0
   iterations=1
   topInterval=600
   iostatInterval=120
   mpstatInterval=60

   instance=
   localDbUser=
   dbUser=
   dbPwd=
   dbList=
   
   scriptDir="$( cd "$(dirname "$0")" ; pwd -P )"

   while getopts c:u:p:d:l:s:i:n:h option
   do
      case $option in
      c) instance="${OPTARG}"
      ;;
      u) dbUser="${OPTARG}"
      ;;
      p) dbPwd="${OPTARG}"
      ;;
      d) dbList="${OPTARG}"
      ;;
      l) localDbUser="${OPTARG}"
      ;;
      s) snapshotDuration="${OPTARG}"
      ;;
      i) snapshotInterval="${OPTARG}"
      ;;
      n) iterations="${OPTARG}"
      ;;
      h) usage "USAGE"
      ;;
      *) usage "Unrecognised Option ${option}"
      ;;
      esac
   done
   
   if [ -z "$dbUser" ] || [ -z "$dbPwd" ] || [ -z "$dbList" ] 
   then
      usage "Missing required parameter(s)"
   fi
   localDbUser=${localDbUser:-$dbUser}
   instance=${instance:-$dbUser}

   testDuration=$(( ($snapshotDuration * $iterations) + ($snapshotInterval * $iterations) ))
   topIterations=$(( $testDuration/$topInterval ))
   iostatIterations=$(( $testDuration/$iostatInterval ))
   mpstatIterations=$(( $testDuration/$mpstatInterval ))
      
   initOutputDir
   printParameters
}

printParameters() {
   echo "   "
   echo "PARAMETERS:"
   echo "   Local database user: ${localDbUser}"
   echo "   Database user: ${dbUser}"
   echo "   Database instance: ${instance}"
   echo "   Database user password: ${dbPwd}"
   echo "   Database list: ${dbList}"
   echo "   Snapshot duration (secs): ${snapshotDuration}"
   echo "   Snapshot interval (secs): ${snapshotInterval}"
   echo "   Snapshot iterations: ${iterations}"
   echo "   top monitor interval (secs): ${topInterval}"
   echo "   iostat monitor interval (secs): ${iostatInterval}"
   echo "   mpstat monitor interval (secs): ${mpstatInterval}"
   echo "   "
}

collectResourceStats() {
   if [ $topIterations -gt 0 ]
   then
      top -d $topInterval -n $topIterations -b >> $outputDir/dbmon_top_`date +\%m\%d`.txt &
   else
      top -d $testDuration -n 1 -b >> $outputDir/dbmon_top_`date +\%m\%d`.txt &
   fi
   
   if [ $iostatIterations -gt 0 ]
   then
      iostat -d -k -t -N -x $iostatInterval $iostatIterations >> $outputDir/dbmon_iostat_`date +\%m\%d`.txt &
   else
      iostat -d -k -t -N -x $testDuration 1 >> $outputDir/dbmon_iostat_`date +\%m\%d`.txt &
   fi
   
   if [ $mpstatIterations -gt 0 ]
   then
      mpstat $mpstatInterval $mpstatIterations >> $outputDir/dbmon_mpstat_`date +\%m\%d`.txt &
   else
      mpstat $testDuration 1 >> $outputDir/dbmon_mpstat_`date +\%m\%d`.txt &
   fi
}

executeStatsCollection() {
   local cmd="${scriptDir}/dbmon_report.sh $snapshotDuration $snapshotInterval $iterations $outputDir $instance $dbUser $dbPwd '${dbList}' &"

   su - $localDbUser -c "$cmd"
   
   collectResourceStats
}

processArguments "$@"
executeStatsCollection

exit 0
