#!/bin/sh

# Script to output table and index physical sizes
#
# mooreof@ie.ibm.com, August 2014
#
# USAGE: ./db_tablesizes.sh -d DBNAME -s 'SCHEMA1 SCHEMA2...'
# Required:
#   -d: database name
#   -s: space-separated list of schema names
# Optional:


DBNAME=
SCHEMAS=

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

	"-h")
		echo "USAGE: ./db_tablesizes.sh -d DBNAME -s 'SCHEMA1 SCHEMA2...'"
		echo "   Required:"
		echo "      -d: database name"
		echo "      -s: space-separated list of schema names"
		echo "   Optional:"
		
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

TEMPFILE=/tmp/temp_tablesizes
LOGFILE=/tmp/db_tablesizes_${DBNAME}_`date +\%m\%d`.log

echo ----------------------------------------------------------------------------- > ${LOGFILE}
echo Starting analysis of table sizes. Date and time: `date` >> ${LOGFILE}
echo DBNAME=${DBNAME} >> ${LOGFILE}
echo SCHEMAS=${SCHEMAS} >> ${LOGFILE}
echo ----------------------------------------------------------------------------- >> ${LOGFILE}

db2 connect to ${DBNAME} >> ${LOGFILE}
for SCHEMA in ${SCHEMAS}
do
	SCHEMA="$(echo ${SCHEMA} | tr '[a-z]' '[A-Z]')"
	echo >> ${LOGFILE}
	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" >> ${LOGFILE}
	echo ">> SCHEMA=${SCHEMA}" >> ${LOGFILE}
	db2 "select tabname,data_object_p_size from sysibmadm.admintabinfo where tabschema='${SCHEMA}' order by tabname" > ${TEMPFILE}.log
	tail -n +4 ${TEMPFILE}.log > ${TEMPFILE}_tail.log
	head -n -3 ${TEMPFILE}_tail.log > ${TEMPFILE}.log
	TABLIST=( $(awk '{print $1}' ${TEMPFILE}.log) )
	TABSIZE=( $(awk '{print $2}' ${TEMPFILE}.log) )
	
	db2 "select tabname,index_object_p_size from table(admin_get_index_info('','${SCHEMA}','')) group by tabname,index_object_p_size order by tabname" > ${TEMPFILE}.log
	tail -n +4 ${TEMPFILE}.log > ${TEMPFILE}_tail.log
	head -n -3 ${TEMPFILE}_tail.log > ${TEMPFILE}.log
	IDXSIZE=( $(awk '{print $2}' ${TEMPFILE}.log) )

	i=0
	echo -----------------------------------------------------------------------------------
	echo "Retrieving table and index sizes (in kB) for all tables in schema ${SCHEMA}"
	echo -----------------------------------------------------------------------------------
	for TABLE in "${TABLIST[@]}"
	do
		echo >> ${LOGFILE}
		echo "   TABLE=${TABLE}" >> ${LOGFILE}
		db2 "select count from ${SCHEMA}.${TABLE}" > ${TEMPFILE}.log
		ROWCOUNT=`sed -n '4p' ${TEMPFILE}.log`
		ROWCOUNT=`echo $ROWCOUNT`
		echo "   ROWCOUNT =${ROWCOUNT}" >> ${LOGFILE}
		echo "   TABLESIZE=${TABSIZE[$i]}" >> ${LOGFILE}
		echo "   INDEXSIZE=${IDXSIZE[$i]}" >> ${LOGFILE}
		i=$((i+1))
	done
done

echo -----------------------------------------------------------------------------------
echo Complete. Table/Index sizes written to file \"${LOGFILE}\"
echo -----------------------------------------------------------------------------------
