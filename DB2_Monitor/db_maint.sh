#!/bin/sh

# Script to run maintenance on a DB2 database
#
# mooreof@ie.ibm.com, September 2014
#
# USAGE: ./db_maint.sh -d DBNAME -s 'SCHEMA1 SCHEMA2...' -u DBUSER -p DBPASSWORD [-r REORGTHRESH]
# Required:
#   -d: database name
#   -s: space-separated list of schema names
# Optional:
#   -r: reorg threshold in MB (only reorg tables below this size, default 100MB)


DBNAME=
SCHEMAS=
#DBUSER=
#DBPASS=
REORGTHRESH=100

while [ -n "$1" ] 
do
	case $1 in
	"-d")
		shift
		if [ -n "$1" ]
		then
			DBNAME=$1
			shift
		fi
		continue
	;;

	"-s")
		shift
		if [ -n "$1" ]
		then
			SCHEMAS=$1
			shift
		fi
		continue
	;;

#	"-u")
#		shift
#		if [ -n "$1" ]
#		then
#			DBUSER=$1
#			shift
#		fi
#		continue
#	;;

#	"-p")
#		shift
#		if [ -n "$1" ]
#		then
#			DBPASS=$1
#			shift
#		fi
#		continue
#	;;

	"-r")
		shift
		if [ -n "$1" ]
		then
			REORGTHRESH=$1
			shift
		fi
		continue
	;;

	"-h")
		echo "USAGE: ./db_maint.sh -d DBNAME -s 'SCHEMA1 SCHEMA2...' -u DBUSER -p DBPASSWORD [-r REORGTHRESH]"
		echo "   Required:"
		echo "      -d: database name"
		echo "      -s: space-separated list of schema names"
#		echo "      -u: database user name"
#		echo "      -p: database user password"
		echo "   Optional:"
		echo "      -r: reorg threshold in MB (only reorg tables below this size, default 100MB)"
		
		exit 1
	;;

	*)
		shift;
	;;

	esac
done

if [ -z "$DBNAME" ] 
then
	echo "-d DBNAME: Database name not specified"  1>&2
	exit 1
fi

if [ -z "$SCHEMAS" ] 
then
	echo "-s 'SCHEMA1 SCHEMA2': schema name(s) not specified"  1>&2
	exit 1
fi

#if [ -z "$DBUSER" ] 
#then
#	echo "-u DBUSER: Database user name not specified"  1>&2
#	exit 1
#fi

#if [ -z "$DBPASS" ] 
#then
#	echo "-p DBPASS: Database user password not specified"  1>&2
#	exit 1
#fi

TEMPFILE=/tmp/temp_maint_tables
LOGFILE=/tmp/db_maint_${DBNAME}_`date +\%m\%d`.log

echo ----------------------------------------------------------------------------- > ${LOGFILE}
echo Starting maintenance. Date and time: `date` >> ${LOGFILE}
echo DBNAME=${DBNAME} >> ${LOGFILE}
echo SCHEMAS=${SCHEMAS} >> ${LOGFILE}
echo DBUSER=${DBUSER} >> ${LOGFILE} 
echo REORGTHRESH=${REORGTHRESH} MB >> ${LOGFILE} 
echo ----------------------------------------------------------------------------- >> ${LOGFILE}

db2 connect to ${DBNAME} >> ${LOGFILE}
for SCHEMA in ${SCHEMAS}
do
	SCHEMA="$(echo ${SCHEMA} | tr '[a-z]' '[A-Z]')"
	db2 "select distinct tabname from syscat.tables where type='T' and tabschema='${SCHEMA}'" > ${TEMPFILE}.log
	tail -n +4 ${TEMPFILE}.log > ${TEMPFILE}_tail.log
	head -n -3 ${TEMPFILE}_tail.log > ${TEMPFILE}.log

	TABLIST=()
	readarray -t TABLIST < ${TEMPFILE}.log

	# Check if any tables in the current schema require reorganisation
	db2 "CALL SYSPROC.REORGCHK_TB_STATS('S','${SCHEMA}')" > /dev/null
	db2 "select table_name from session.tb_stats where table_name not like '%ADVISE%' and table_name not like '%EXPLAIN%' and LOCATE('*',REORG) <> 0" > ${TEMPFILE}_reorgchk_t.log

	tail -n +4 ${TEMPFILE}_reorgchk_t.log > ${TEMPFILE}_reorgchk_tail.log
	head -n -3 ${TEMPFILE}_reorgchk_tail.log > ${TEMPFILE}_reorgchk.log

	#db2 "CALL SYSPROC.REORGCHK_IX_STATS('S','${SCHEMA}')" > /dev/null
	#db2 "select table_name from session.ix_stats where table_name not like '%ADVISE%' and table_name not like '%EXPLAIN%' and REORG LIKE '*%%%%'" > ${TEMPFILE}_reorgchk_i.log

	#tail -n +4 ${TEMPFILE}_reorgchk_i.log > ${TEMPFILE}_reorgchk_tail.log
	#head -n -3 ${TEMPFILE}_reorgchk_tail.log >> ${TEMPFILE}_reorgchk.log

	REORGTABLIST=()
	readarray -t REORGTABLIST < ${TEMPFILE}_reorgchk.log
	REORGTABLIST=($(printf "%s\n" "${REORGTABLIST[@]}" | sort -u))
	
	if [ ${#REORGTABLIST[@]} -eq 0 ]; then
		echo -----------------------------------------------------------------------------------
		echo No tables in Schema ${SCHEMA} require reorganisation
		echo -e "\nNo tables in Schema ${SCHEMA} require reorganisation" >> ${LOGFILE}
		echo -----------------------------------------------------------------------------------
	else
		echo -----------------------------------------------------------------------------------
		echo Executing REORG on selected tables in schema ${SCHEMA}
		echo -e "\nExecuting REORG on selected tables in schema ${SCHEMA}" >> ${LOGFILE}
		echo -----------------------------------------------------------------------------------
		for TABLE in "${REORGTABLIST[@]}"
		do
			db2 "select data_object_p_size from sysibmadm.admintabinfo where tabschema='${SCHEMA}' and tabname='${TABLE}'" > ${TEMPFILE}
			TABLESIZE=`sed -n '4p' ${TEMPFILE}`
			TABLESIZE=$(( ${TABLESIZE}/1024 ))
			echo Checking if table ${SCHEMA}.${TABLE} is below the REORG threshold size of ${REORGTHRESH} MB >> ${LOGFILE}
			if [ ${TABLESIZE} -lt ${REORGTHRESH} ]; then
				echo db2 REORG TABLE ${SCHEMA}.${TABLE} >> ${LOGFILE}
				db2 REORG TABLE ${SCHEMA}.${TABLE}
			else
				echo Table ${SCHEMA}.${TABLE} is above the REORG threshold >> ${LOGFILE}
				echo Table ${SCHEMA}.${TABLE} is above the REORG threshold size of ${REORGTHRESH} MB
			fi
		done
	fi
	
	echo
	echo -----------------------------------------------------------------------------------
	echo Executing RUNSTATS on all tables in schema ${SCHEMA}
	echo -e "\nExecuting RUNSTATS on all tables in schema ${SCHEMA}\n" >> ${LOGFILE}
	echo -----------------------------------------------------------------------------------
	for TABLE in "${TABLIST[@]}"
	do
		echo db2 RUNSTATS ON TABLE ${SCHEMA}.${TABLE} ON ALL COLUMNS WITH DISTRIBUTION ON ALL COLUMNS AND DETAILED INDEXES ALL ALLOW WRITE ACCESS SET PROFILE >> ${LOGFILE}
		db2 RUNSTATS ON TABLE ${SCHEMA}.${TABLE} ON ALL COLUMNS WITH DISTRIBUTION ON ALL COLUMNS AND DETAILED INDEXES ALL ALLOW WRITE ACCESS SET PROFILE
	done
done

db2 connect reset > /dev/null

BINDLOG=/tmp/db_maint_${DBNAME}_rebind_`date +\%m\%d`.log

echo
echo -----------------------------------------------------------------------------------
echo Rebinding database ${DBNAME}
echo -e "\nRebinding database ${DBNAME} (details in ${BINDLOG})" >> ${LOGFILE}
echo -----------------------------------------------------------------------------------
#db2rbind ${DBNAME} -l ${BINDLOG} all -u ${DBUSER} -p ${DBPASS}
db2rbind ${DBNAME} -l ${BINDLOG} all

echo -----------------------------------------------------------------------------------
echo Maintenance Complete.
echo Check log files \"${LOGFILE}\" and \"${BINDLOG}\" for more details
echo -----------------------------------------------------------------------------------
