-- Fergus (fergusmc@ie.ibm.com), June 2015.

---------------------  OVERALL DB PERFORMANCE DATA  -----------------------------------------


ECHO	**********************************************************************;
ECHO	******** DUBPERF DB SNAPSHOT PERFORMANCE REPORT **********************;
ECHO	**********************************************************************;
ECHO   TOOLS DATE        : 23-JULY-2013, DUBLIN PERFORMANCE TEAM;
SELECT 
	'  Capture START Time:', start_timestamp,
	CHR(10),	' Capture END   Time  :', end_timestamp,
	CHR(10),	' DURATION: ', CHAR(LPAD (DURATION_DAYS, 3), 3), 'Days,', 
	CHAR(LPAD(DURATION_HOURS, 3), 3), 'Hours,',
	CHAR(LPAD(DURATION_MINS, 3), 3), 'Mins,', 
	CHAR(LPAD(DURATION_SECS, 3), 3), 'Secs,', 
	CHAR(LPAD(DURATION_USECS, 10), 10), 'USecs',
	CHR(10),	'TOTAL DURATION SECS    :',   DURATION_SECS_TOTAL,
	CHR(10),
	CHR(10),	'DBNAME                 :',   SUBSTR (DB_NAME, 1, 72),
	CHR(10),	'DB_PATH                :',   SUBSTR (DB_PATH, 1, 72),
	CHR(10),	'INPUT_DB_ALIAS         :',   SUBSTR (INPUT_DB_ALIAS, 1, 72),
	CHR(10),	'CATALOGPARTITION       :',   CHAR (CATALOG_PARTITION),
	CHR(10),	'CATALOG_PARTITION_NAME :',   SUBSTR (CATALOG_PARTITION_NAME, 1, 72),
	CHR(10),	'SERVER PLATFORM        :',   SERVER_PLATFORM,
	CHR(10),	'DB_LOCATION            :',   DB_LOCATION,
	CHR(10),	'DB_STATUS              :',   DB_STATUS,


CHR(10), '*******************************************************************',
CHR(10), 'CONNECTION DATA            : TOTAL RUN DATA  *   PER SECOND DATA  ',
CHR(10), '*******************************************************************',
CHR(10), '* NBR of connects   @START :' , CHAR(LPAD(START_APPLS_CUR_CONS , 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* NBR of connects   @END   :' , CHAR(LPAD(END_APPLS_CUR_CONS   , 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP connects NBR  @START :' , CHAR(LPAD(START_CONNECTIONS_TOP, 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP connects NBR  @END   :' , CHAR(LPAD(END_CONNECTIONS_TOP, 15), 15),   	CHAR(LPAD('*', 1), 1), 
CHR(10), '* DB APPS executing @START :' , CHAR(LPAD(START_APPLS_IN_DB  , 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* DB APPS executing @END   :' , CHAR(LPAD(END_APPLS_IN_DB    , 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* Nbr DB subagents   @START:' , CHAR(LPAD(START_NUM_ASSOC_AGENTS, 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* Nbr DB subagents   @END  :' , CHAR(LPAD(END_NUM_ASSOC_AGENTS , 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP nbr DB agents  @START:' , CHAR(LPAD(START_AGENTS_TOP, 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP nbr DB agents  @END  :' , CHAR(LPAD(END_AGENTS_TOP , 15), 15), 		CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP nbr subagents  @START:' , CHAR(LPAD(START_COORD_AGENTS_TOP, 15), 15), 	CHAR(LPAD('*', 1), 1), 
CHR(10), '* TOP nbr subagents  @END  :' , CHAR(LPAD(END_COORD_AGENTS_TOP , 15), 15), 	CHAR(LPAD('*', 1), 1), 

CHR(10), '* New Connections          :' , CHAR(LPAD(TOTAL_CONS, 15), 15),  		CHAR(LPAD('*', 1), 1),
		CHAR(LPAD( DEC(DEC(TOTAL_CONS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* Secondary/Agent connects :' , CHAR(LPAD(TOTAL_SEC_CONS, 15), 15),  		CHAR(LPAD('*', 1), 1),
		CHAR(LPAD( DEC(DEC(TOTAL_SEC_CONS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '*******************************************************************',
CHR(10), 'STATEMENTS                 : TOTAL RUN DATA  *   PER SECOND DATA  ',
CHR(10), '*******************************************************************',
CHR(10), '* Commits                  :' , CHAR(LPAD(COMMIT_SQL_STMTS, 15), 15),  	CHAR('*', 1),
		CHAR(LPAD( DEC(DEC(COMMIT_SQL_STMTS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* Rollback                 :' , CHAR(LPAD(ROLLBACK_SQL_STMTS, 15), 15),	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(ROLLBACK_SQL_STMTS)/(DURATION_SECS_TOTAL), 17, 2), 17)), 
CHR(10), '* Select                   :' , CHAR(LPAD(SELECT_SQL_STMTS, 15), 15),  	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(SELECT_SQL_STMTS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* Update/Insert/Delete     :' , CHAR(LPAD(UID_SQL_STMTS, 15),15),     	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(UID_SQL_STMTS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* DDL                      :' , CHAR(LPAD(DDL_SQL_STMTS, 15), 15),     	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(DDL_SQL_STMTS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* Failed SQL               :' , CHAR(LPAD(FAILED_SQL_STMTS, 15), 15),  	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(FAILED_SQL_STMTS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* Dynamic SQL (Fetch.Open, :' , CHAR(LPAD(DYNAMIC_SQL_STMTS, 15), 15), 	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(DYNAMIC_SQL_STMTS)/(DURATION_SECS_TOTAL) , 17, 2), 17)), 
CHR(10), '*  Prepare,Close,Describe) :' , CHAR(LPAD('*', 17), 17),  CHAR(LPAD('*', 17), 17), 
CHR(10), '* Static SQL               :' , CHAR(LPAD(STATIC_SQL_STMTS, 15), 15),
		CHAR(LPAD( DEC(DEC(STATIC_SQL_STMTS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* BINDS_PRECOMPILES        :' , CHAR(LPAD(BINDS_PRECOMPILES, 15), 15), 	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(BINDS_PRECOMPILES)/(DURATION_SECS_TOTAL) , 17, 2), 17)), 
CHR(10), '* INT_AUTO_REBINDS         :' , CHAR(LPAD(INT_AUTO_REBINDS, 15), 15),  	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_AUTO_REBINDS)/(DURATION_SECS_TOTAL)  , 17, 2), 17)), 
CHR(10), '* INT_COMMITS              :' , CHAR(LPAD(INT_COMMITS, 15), 15),       	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_COMMITS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* INT_DEADLOCK_ROLLBACKS   :' , CHAR(LPAD(INT_DEADLOCK_ROLLBACKS, 15), 15), 	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_DEADLOCK_ROLLBACKS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* INT_ROLLBACKS            :' , CHAR(LPAD(INT_ROLLBACKS, 15), 15),     	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_ROLLBACKS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* INT_ROWS_DELETED         :' , CHAR(LPAD(INT_ROWS_DELETED, 15), 15),  	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_ROWS_DELETED)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* INT_ROWS_INSERTED        :' , CHAR(LPAD(INT_ROWS_INSERTED, 15), 15), 	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_ROWS_INSERTED)/(DURATION_SECS_TOTAL) , 17, 2), 17)), 
CHR(10), '* INT_ROWS_UPDATED         :' , CHAR(LPAD(INT_ROWS_UPDATED, 15), 15),  	CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(INT_ROWS_UPDATED)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '*******************************************************************',
CHR(10), 'ROW ACCESS',
CHR(10), '*******************************************************************',
CHR(10), '* ROWS_READ                :' , CHAR(LPAD(ROWS_READ, 15), 15),     CHAR('*', 1)     , 
		CHAR(LPAD( DEC(DEC(ROWS_READ)/(DURATION_SECS_TOTAL),          17, 2), 17)), 
CHR(10), '* ROWS_SELECTED            :' , CHAR(LPAD(ROWS_SELECTED, 15), 15), CHAR('*', 1)     , 
		CHAR(LPAD( DEC(DEC(ROWS_SELECTED)/(DURATION_SECS_TOTAL),      17, 2), 17)), 
CHR(10), '* ROWS READ/SELECTED RATIO :' , CHAR(LPAD(DEC(DEC(ROWS_READ)/(ROWS_SELECTED+1), 17, 2), 15)),  CHAR('*', 1), 
							CHAR(LPAD(' ', 16), 16), 
CHR(10), '* PREFETCH_WAIT_TIME msecs :' , CHAR(LPAD(PREFETCH_WAIT_TIME, 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), 
CHR(10), '* ROWS_DELETED             :' , CHAR(LPAD(ROWS_DELETED , 15), 15),  CHAR('*', 1)    , 
		CHAR(LPAD( DEC(DEC(ROWS_DELETED )/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* ROWS_INSERTED            :' , CHAR(LPAD(ROWS_INSERTED, 15), 15),  CHAR('*', 1)    , 
		CHAR(LPAD( DEC(DEC(ROWS_INSERTED)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* ROWS_UPDATED             :' , CHAR(LPAD(ROWS_UPDATED, 15), 15),  CHAR('*', 1)     , 
		CHAR(LPAD( DEC(DEC(ROWS_UPDATED)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* BINDS_PRECOMPILES        :' , CHAR(LPAD(BINDS_PRECOMPILES, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(BINDS_PRECOMPILES)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* TOTAL_HASH_JOINS         :' , CHAR(LPAD(TOTAL_HASH_JOINS, 15), 15),  CHAR('*', 1) , 
		CHAR(LPAD( DEC(DEC(TOTAL_HASH_JOINS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* TOTAL_HASH_LOOPS         :' , CHAR(LPAD(TOTAL_HASH_LOOPS, 15), 15),  CHAR('*', 1) , 
		CHAR(LPAD( DEC(DEC(TOTAL_HASH_LOOPS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* HASH_JOIN_OVERFLOWS      :' , CHAR(LPAD(HASH_JOIN_OVERFLOWS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(HASH_JOIN_OVERFLOWS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* HASH_JOIN_SMALL_OVERFLOWS:' , CHAR(LPAD(HASH_JOIN_SMALL_OVERFLOWS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(HASH_JOIN_SMALL_OVERFLOWS)/(DURATION_SECS_TOTAL), 17, 2), 17)),
CHR(10), '* TOTAL_OLAP_FUNCS         :' , CHAR(LPAD(TOTAL_OLAP_FUNCS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(TOTAL_OLAP_FUNCS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)),
CHR(10), '* OLAP_FUNC_OVERFLOWS      :' , CHAR(LPAD(OLAP_FUNC_OVERFLOWS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(OLAP_FUNC_OVERFLOWS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 

CHR(10), '*******************************************************************',
CHR(10), 'APPLICATION & CATALOG CACHE',
CHR(10), '*******************************************************************',
CHR(10), '* APPL_SECTION_LOOKUPS     :' , CHAR(LPAD(APPL_SECTION_LOOKUPS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(APPL_SECTION_LOOKUPS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* APPL_SECTION_INSERTS     :' , CHAR(LPAD(APPL_SECTION_INSERTS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(APPL_SECTION_INSERTS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* CAT_CACHE_LOOKUPS        :' , CHAR(LPAD(CAT_CACHE_LOOKUPS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(CAT_CACHE_LOOKUPS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* CAT_CACHE_INSERTS        :' , CHAR(LPAD(CAT_CACHE_INSERTS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(CAT_CACHE_INSERTS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 
CHR(10), '* CAT_CACHE_OVERFLOWS      :' , CHAR(LPAD(CAT_CACHE_OVERFLOWS, 15), 15),  CHAR('*', 1), 
		CHAR(LPAD( DEC(DEC(CAT_CACHE_OVERFLOWS)/(DURATION_SECS_TOTAL)     , 17, 2), 17)), 

CHR(10), '*******************************************************************',
CHR(10), 'BUFFER POOL',
CHR(10), '*******************************************************************' ,
CHR(10), '* POOL_ASYNC_DATA_READS    :' , CHAR(LPAD(POOL_ASYNC_DATA_READS,   15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_ASYNC_DATA_READS)/(DURATION_SECS_TOTAL)  , 17, 2), 17), 17), CHAR('*', 1),
CHR(10), '* POOL_ASYNC_DATA_WRITES   :' , CHAR(LPAD(POOL_ASYNC_DATA_WRITES,  15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_ASYNC_DATA_WRITES)/(DURATION_SECS_TOTAL) , 17, 2), 17), 17), CHAR('*', 1),
CHR(10), '* POOL_ASYNC_INDEX_READS   :' , CHAR(LPAD(POOL_ASYNC_INDEX_READS,  15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_ASYNC_INDEX_READS)/(DURATION_SECS_TOTAL) , 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_ASYNC_INDEX_WRITES  :' , CHAR(LPAD(POOL_ASYNC_INDEX_WRITES, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_ASYNC_INDEX_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),


CHR(10), '* POOL_INDEX_L_READS       :' , CHAR(LPAD(POOL_INDEX_L_READS, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_INDEX_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_INDEX_P_READS       :' , CHAR(LPAD(POOL_INDEX_P_READS, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),

CHR(10), '* BP INDEX HIT RATIO %     :' 
			, CHAR(LPAD(DEC(100 * DEC(POOL_INDEX_L_READS - POOL_INDEX_P_READS)/(POOL_INDEX_L_READS+1), 17, 2), 15), 15), CHAR('*', 1), 
				CHAR(LPAD(' ', 16), 16), CHAR('*', 1),

CHR(10), '* POOL_INDEX_WRITES        :' , CHAR(LPAD(POOL_INDEX_WRITES, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_INDEX_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* SynchronousIndex Writes :' , CHAR(LPAD(POOL_INDEX_WRITES - POOL_ASYNC_INDEX_WRITES, 16), 16), CHAR('*', 1),
					CHAR(LPAD( DEC(DEC(POOL_INDEX_WRITES - POOL_ASYNC_INDEX_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_DATA_L_READS        :' , CHAR(LPAD(POOL_DATA_L_READS, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_DATA_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_DATA_P_READS        :' , CHAR(LPAD(POOL_DATA_P_READS, 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* BP DATA HIT RATIO %      :' 
			, CHAR(LPAD(DEC(100 * (POOL_DATA_L_READS - POOL_DATA_P_READS)/(POOL_DATA_L_READS+1), 17, 2), 15), 15), CHAR('*', 1), 
				CHAR(LPAD(' ', 16), 16), CHAR('*', 1),

CHR(10), '* POOL_DATA_WRITES         :' , CHAR(LPAD(POOL_DATA_WRITES,       15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_DATA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* Synchronous Data Writes  :' , CHAR(LPAD(POOL_DATA_WRITES - POOL_ASYNC_DATA_WRITES, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_DATA_WRITES - POOL_ASYNC_DATA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_TEMP_DATA_L_READS   :' , CHAR(LPAD(POOL_TEMP_DATA_L_READS, 15), 15), CHAR('*', 1),
                                CHAR(LPAD( DEC(DEC(POOL_TEMP_DATA_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_TEMP_DATA_P_READS   :' , CHAR(LPAD(POOL_TEMP_DATA_P_READS, 15), 15), CHAR('*', 1),
                                CHAR(LPAD( DEC(DEC(POOL_TEMP_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),

CHR(10), '* BP TEMP DATA HIT RATIO%  :' , CHAR(LPAD(100 * (POOL_TEMP_DATA_L_READS - POOL_TEMP_DATA_P_READS)/(POOL_TEMP_DATA_L_READS+1), 15), 15), CHAR('*', 1), 
				CHAR(LPAD(' ', 16), 16), CHAR('*', 1),

CHR(10), '* POOL_TEMP_INDEX_L_READS  :' , CHAR(LPAD(POOL_TEMP_INDEX_L_READS, 15), 15),    CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_TEMP_INDEX_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_TEMP_INDEX_P_READS  :' , CHAR(LPAD(POOL_TEMP_INDEX_P_READS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_TEMP_INDEX_P_READS)/(DURATION_SECS_TOTAL)   , 17, 2), 16), 16), CHAR('*', 1),

CHR(10), '* BP TEMP INDEX HIT RATIO% :' , 
				CHAR(LPAD(100 * (POOL_TEMP_INDEX_L_READS - POOL_TEMP_INDEX_P_READS)/(POOL_TEMP_INDEX_L_READS+1) , 15), 15),  CHAR('*', 1), 
				CHAR(LPAD(' ', 16), 16), CHAR('*', 1),
CHR(10), '* DATA+TEMP+INDEX           ', CHAR(LPAD(' ', 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1),
CHR(10), '*             PREAD/COMMIT :' ,
CHAR(LPAD( DEC( DEC((POOL_DATA_P_READS + POOL_INDEX_P_READS + POOL_TEMP_DATA_P_READS + POOL_TEMP_INDEX_P_READS))/(COMMIT_SQL_STMTS+1), 17, 2), 15), 15), 
	CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1),


CHR(10), '* DATA+INDEX PWRITE/COMMIT :' 
			, CHAR(LPAD( DEC( DEC( (POOL_DATA_WRITES + POOL_INDEX_WRITES) )/(COMMIT_SQL_STMTS+1), 17, 2), 15), 15), CHAR('*', 1), 
			CHAR(LPAD(' ', 16), 16), CHAR('*', 1),


CHR(10), '* POOL_READ_TIME msecs     :' , CHAR(LPAD(POOL_READ_TIME,         15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1),
CHR(10), '* POOL_WRITE_TIME msecs    :' , CHAR(LPAD(POOL_WRITE_TIME,        15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1),
CHR(10), '* POOL_NO_VICTIM_BUFFER    :' , CHAR(LPAD(POOL_NO_VICTIM_BUFFER,   15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_NO_VICTIM_BUFFER)/(DURATION_SECS_TOTAL),   17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_DRTY_PG_STEAL_CLNS  :' , CHAR(LPAD(POOL_DRTY_PG_STEAL_CLNS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(POOL_DRTY_PG_STEAL_CLNS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1),
CHR(10), '* POOL_DRTY_PG_STEAL_CLNS   ', CHAR(LPAD(' ', 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1),
CHR(10), '*    per 1000 Commits      :' 	
					, CHAR(LPAD( DEC(DEC(1000*POOL_DRTY_PG_STEAL_CLNS)/(COMMIT_SQL_STMTS+1), 17, 2), 15), 15), CHAR('*', 1), 
				CHAR(LPAD(' ', 16), 16), CHAR('*', 1)


, CHR(10), '*******************************************************************' 
, CHR(10), 'NON BUFFER POOL DIRECT IO ACTIVITY'
, CHR(10), '*******************************************************************' 
, CHR(10), '* DIRECT_WRITES            :' , CHAR(LPAD(DIRECT_WRITES     , 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(DIRECT_WRITES)/(DURATION_SECS_TOTAL),     17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* DIRECT_WRITE_REQS        :' , CHAR(LPAD(DIRECT_WRITE_REQS , 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(DIRECT_WRITE_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* AVG DIRECT_WRITE_SIZE    :' , CHAR(LPAD(DIRECT_WRITES/(DIRECT_WRITE_REQS+1) , 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* DIRECT_READS             :' , CHAR(LPAD(DIRECT_READS      , 15), 15), CHAR('*', 1), 
					CHAR(LPAD( DEC(DEC(DIRECT_READS)/(DURATION_SECS_TOTAL),     17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* DIRECT_READ_REQS         :' , CHAR(LPAD(DIRECT_READ_REQS  , 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(DIRECT_READ_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* AVG DIRECT_READ_SIZE     :' , CHAR(LPAD(DIRECT_READS/(DIRECT_READ_REQS+1) , 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*******************************************************************' 
, CHR(10), 'LOCK DATA'
, CHR(10), '*******************************************************************' 
, CHR(10), '* CURRENT LOCKS_HELD       :' , CHAR(LPAD(LOCKS_HELD    , 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR(LPAD(' ', 1), 1)
, CHR(10), '* LOCK_WAITS               :' , CHAR(LPAD(LOCK_WAITS    , 15), 15),  CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(LOCK_WAITS)/(DURATION_SECS_TOTAL),     17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* LOCK_WAIT_TIME msecs     :' , CHAR(LPAD(LOCK_WAIT_TIME, 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*  msecs per LOCK_WAIT     :' , CHAR(LPAD(LOCK_WAIT_TIME/(LOCK_WAITS+1), 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* LOCK_WAIT_TIME           '  , CHAR(LPAD('  ', 16), 16),             ' *', CHAR(LPAD(' ', 16), 16), ' *'
, CHR(10), '*  per 1000 Commits, msecs :'
					   , CHAR(LPAD(1000*LOCK_WAIT_TIME/(COMMIT_SQL_STMTS+1), 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* LOCK_TIMEOUTS            :' , CHAR(LPAD(LOCK_TIMEOUTS, 15), 15), CHAR('*', 1),  CHAR(LPAD( DEC(DEC(LOCK_TIMEOUTS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* DEADLOCKS                :' , CHAR(LPAD(DEADLOCKS, 15), 15),     CHAR('*', 1),      CHAR(LPAD( DEC(DEC(DEADLOCKS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* LOCK_TIMEOUTS+DEADLOCKS  ' , CHAR(LPAD(' ', 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*    per 1000 Commits      :' 	
					, CHAR(LPAD(1000*(LOCK_TIMEOUTS+DEADLOCKS)/(COMMIT_SQL_STMTS+1), 15), 15), CHAR('*'), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*******************************************************************' 
, CHR(10), 'SORT DATA'
, CHR(10), '*******************************************************************' 
, CHR(10), '* TOTAL_SORTS              :' , CHAR(LPAD(TOTAL_SORTS,     15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(TOTAL_SORTS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* SORT_OVERFLOWS           :' , CHAR(LPAD(SORT_OVERFLOWS,  15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(SORT_OVERFLOWS)/(DURATION_SECS_TOTAL),   17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* TOTAL_SORT_TIME msecs    :' , CHAR(LPAD(TOTAL_SORT_TIME, 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* TOTAL_SORT_TIME/COMMITS  :' 	
				, CHAR(LPAD(TOTAL_SORT_TIME/(COMMIT_SQL_STMTS+1), 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)

, CHR(10), '*******************************************************************' 
, CHR(10), 'PACKAGE ACCESS'
, CHR(10), '*******************************************************************' 
, CHR(10), '* PKG_CACHE_LOOKUPS        :', CHAR(LPAD(PKG_CACHE_LOOKUPS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(PKG_CACHE_LOOKUPS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* PKG_CACHE_INSERTS        :', CHAR(LPAD(PKG_CACHE_INSERTS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(PKG_CACHE_INSERTS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* PKG_CACHE_INSERTS         ', CHAR(LPAD(' ', 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*    per 1000 Commits      :', CHAR(LPAD(1000*(PKG_CACHE_INSERTS)/(COMMIT_SQL_STMTS+1), 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16))
, CHR(10), '* PKG_CACHE_NUM_OVERFLOWS  :', CHAR(LPAD(PKG_CACHE_NUM_OVERFLOWS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(PKG_CACHE_NUM_OVERFLOWS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)

, CHR(10), '*******************************************************************' 
, CHR(10), 'DB LOG ACTIVITY'
, CHR(10), '*******************************************************************' 
, CHR(10), '* Page WRITES              :', CHAR(LPAD(LOG_WRITES, 15), 15),  CHAR('*', 1), CHAR(LPAD( DEC(DEC(LOG_WRITES)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* Page WRITES/COMMITS      :', CHAR(LPAD(DEC(DEC(LOG_WRITES)/(COMMIT_SQL_STMTS+1),17, 2), 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* LOG_WRITE_TIME_S secs    :', CHAR(LPAD(LOG_WRITE_TIME_S, 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16))
, CHR(10), '* LogWriteTime/Commit nsecs:', CHAR(LPAD( (LOG_WRITE_TIME_S*1000000000 + LOG_WRITE_TIME_NS)/(COMMIT_SQL_STMTS+1), 15), 15),
				CHAR(LPAD(' ', 16)), CHAR('*', 1)
, CHR(10), '* NUM_LOG_WRITE Requests   :', CHAR(LPAD(NUM_LOG_WRITE_IO, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(NUM_LOG_WRITE_IO)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* NUM_LOG_WRITE Requests    ' , CHAR(LPAD(' ', 15), 15),  CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*         PER Commit       :', CHAR(LPAD(  DEC (DEC(NUM_LOG_WRITE_IO)/DEC(COMMIT_SQL_STMTS+1), 10, 2), 15), 15),  CHAR('*', 1), 
					CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '* NUM_PART_PAGE_WRITE RQSTS:', CHAR(LPAD(NUM_LOG_PART_PAGE_IO, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(NUM_LOG_PART_PAGE_IO)/(DURATION_SECS_TOTAL),       17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* NUM_BUFFER_FULL Incidents:', CHAR(LPAD(NUM_LOG_BUFFER_FULL, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(NUM_LOG_BUFFER_FULL)/(DURATION_SECS_TOTAL),         17, 2), 16), 16), CHAR('*', 1)

, CHR(10), '* Page READS               :', CHAR(LPAD(LOG_READS, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(LOG_READS)/(DURATION_SECS_TOTAL),                 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* NUM Read Requests        :', CHAR(LPAD(NUM_LOG_READ_IO, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(NUM_LOG_READ_IO)/(DURATION_SECS_TOTAL),                 17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* LOG_READ_TIME_S secs     :', CHAR(LPAD(LOG_READ_TIME_S, 15), 15), CHAR('*', 1)
, CHR(10), '* Agent READS fromLogBuffer:', CHAR(LPAD(NUM_LOG_DATA_FOUND_IN_BUFFER, 15), 15), CHAR('*', 1), 
				CHAR(LPAD( DEC(DEC(NUM_LOG_DATA_FOUND_IN_BUFFER)/(DURATION_SECS_TOTAL),                 17, 2), 16), 16), CHAR('*', 1)

-- THE FOLLOWING IS a point in time value, not an incremental counter.
, CHR(10), '* LOG_HELD_BY_DIRTY_PAGES  :', CHAR(LPAD(LOG_HELD_BY_DIRTY_PAGES, 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*  (End Snapshot value)    :' , CHAR(LPAD(' ', 15), 15),  CHAR('*', 1)
, CHR(10), '* LOG bytes to redo for    :', CHAR(LPAD(LOG_TO_REDO_FOR_RECOVERY, 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*          Crash Recovery   ' , CHAR(LPAD(' ', 15), 15),  CHAR('*', 1)
, CHR(10), '* App/AgentID of oldest trn:', CHAR(LPAD(APPL_ID_OLDEST_XACT, 15), 15), CHAR('*', 1), CHAR(LPAD(' ', 16), 16), CHAR('*', 1)
, CHR(10), '*******************************************************************' 
, CHR(10), 'REALTIME RUNSTATS ACTIVITY'
, CHR(10), '*******************************************************************' 
, CHR(10), '* STATS CACHE SIZE Bytes   :', CHAR(LPAD(STATS_CACHE_SIZE, 15), 15),  CHAR('*', 1)
, CHR(10), '* NBR STATS FABRICATIONS   :', CHAR(LPAD(STATS_FABRICATIONS, 15), 15),  CHAR('*', 1)
				, CHAR(LPAD( DEC(DEC(STATS_FABRICATIONS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* STATS FABRICAT TIME msecs:', CHAR(LPAD(STATS_FABRICATE_TIME, 15), 15),  CHAR('*', 1)
, CHR(10), '* NBR SYNC RUNSTATS        :', CHAR(LPAD(SYNC_RUNSTATS, 15), 15),  CHAR('*', 1)
				, CHAR(LPAD( DEC(DEC(SYNC_RUNSTATS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* SYNC RUNSTATS TIME msecs :', CHAR(LPAD(SYNC_RUNSTATS_TIME, 15), 15),  CHAR('*', 1)
				
, CHR(10), '* NBR ASYNC RUNSTATS       :', CHAR(LPAD(ASYNC_RUNSTATS, 15), 15),  CHAR('*', 1)
				, CHAR(LPAD( DEC(DEC(ASYNC_RUNSTATS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '*******************************************************************' 
, CHR(10), 'THRESHOLD VIOLATIONS'
, CHR(10), '*******************************************************************' 
, CHR(10), '* THRESHOLD VIOLATIONS     :', CHAR(LPAD(NUM_THRESHOLD_VIOLATIONS, 15), 15), CHAR('*', 1)
				, CHAR(LPAD( DEC(DEC(NUM_THRESHOLD_VIOLATIONS)/(DURATION_SECS_TOTAL),      17, 2), 16), 16), CHAR('*', 1)
, CHR(10), '* THRESHOLD VIOLATIONS     :', CHAR(LPAD(DEC(DEC(NUM_THRESHOLD_VIOLATIONS)/(COMMIT_SQL_STMTS+1),17, 2), 15), 15), CHAR('*', 1)
, CHR(10), '*       /commits+1          ' , CHAR(LPAD(' ', 15), 15),  CHAR('*', 1)
, CHR(10), '********************************************************************' 
, CHR(10)

FROM
	dbmon.dubperf_DB_diff;


ECHO ;


ECHO *********************************************************************************************************;
ECHO ********************************* TABLE DATA PERFORMANCE REPORT *****************************************;
ECHO *********************************************************************************************************;

SELECT 
    	'* Capture START TIME:',        start_timestamp,
	CHR(10)||
	'* Capture END TIME  :',        end_timestamp,

	CHR(10)||
    	'* DURATION: ',	CHAR(LPAD(DURATION_DAYS, 2), 2), 'Days,', 
	CHAR(LPAD(DURATION_HOURS, 2), 2), 'Hours,',
	CHAR(LPAD(DURATION_MINS, 2), 2), ' Mins,', CHAR(LPAD(DURATION_SECS,2), 2), ' Secs, ',
	CHAR(LPAD(DURATION_USECS, 6), 6), 'USecs',
	'' || CHR(10)||
	'* Capture TOTAL DURATION SECS  :', CHAR(LPAD(DURATION_SECS_TOTAL, 5), 5)
FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
ORDER BY 
	DURATION_SECS_TOTAL ASC
FETCH FIRST
	1 ROW ONLY
;
--ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *;
--ECHO *********************************************************************************************************;


ECHO ******************** TOP 20 TABLE SCANS ***********************;
ECHO SCHEMA     TABLE                SCANS          /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- ------------ ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) AS TABLE,
	CHAR(LPAD(TABLE_SCANS, 12), 12) AS SCANS,
	CHAR(LPAD(DEC(TABLE_SCANS / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN 
--      ,
--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9) AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	TABLE_SCANS >0
	
ORDER BY 
	TABLE_SCANS DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 ROWS READ ***********************;
ECHO SCHEMA               TABLE                ROWS_READ         /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO -------------------- -------------------- --------------- ---------- --- ------ -------------- ------- ------- --------- -------;

SELECT

	CHAR(RPAD(TABSCHEMA, 20), 20) 	AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD(ROWS_READ, 15), 15)	AS ROWS_READ,
	CHAR(LPAD(ROWS_READ / DURATION_SECS_TOTAL, 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN

--	,
--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9) AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	ROWS_READ IS NOT NULL
	
ORDER BY 
	ROWS_READ DESC

FETCH FIRST 20 ROWS ONLY
;
--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 ROWS INSERTED ***********************;
ECHO SCHEMA     TABLE                ROWS_INSERTED     /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID  ;
ECHO ---------- -------------------- --------------- ---------- --- ------ -------------- ------- ------- --------- ---------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD(ROWS_INSERTED, 15), 15) AS ROWS_INSERTED,
	CHAR(LPAD(ROWS_INSERTED / DURATION_SECS_TOTAL, 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN
-- 	,

--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7)  	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9)	AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID,7), 9)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	ROWS_INSERTED IS NOT NULL
	
ORDER BY 
	ROWS_INSERTED DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 ROWS UPDATED ***********************;
ECHO SCHEMA     TABLE                ROWS_UPDATED          /Sec PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- --------------- ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) 	AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD(ROWS_UPDATED, 15), 15) 	AS ROWS_UPDATED,
	CHAR(LPAD(ROWS_UPDATED / DURATION_SECS_TOTAL, 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN
-- 	,

--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9)	AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID,7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	ROWS_UPDATED IS NOT NULL
	
ORDER BY 
	ROWS_UPDATED DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 ROWS DELETED ***********************;
ECHO SCHEMA     TABLE                ROWS_DELETED      /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- --------------- ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) 	AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD(ROWS_DELETED, 15), 15) 	AS ROWS_DELETED,
	CHAR(LPAD(DEC(ROWS_DELETED / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN
--	,

--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9)	AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	ROWS_DELETED IS NOT NULL
	
ORDER BY 
	ROWS_DELETED DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 OVERFLOW ACCESSES ***********************;
ECHO SCHEMA     TABLE                OVERFLOW_ACCESSES   /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- ----------------- ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) 		AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 		AS TABLE,
	CHAR(LPAD(OVERFLOW_ACCESSES, 15), 15) 	AS OVERFLOW_ACCESSES,
	CHAR(LPAD(DEC(OVERFLOW_ACCESSES / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3)
-- 	AS PTN,

--	MEMBER,
--	TAB_TYPE 		,
--	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
--	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
--	CHAR(LPAD(INDEX_TBSP_ID, 9), 9)	AS IDXTBSPID,
--	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	OVERFLOW_ACCESSES IS NOT NULL
	
ORDER BY 
	OVERFLOW_ACCESSES DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 OVERFLOW CREATES ***********************;
ECHO SCHEMA     TABLE                OVERFLOW_CREATES   /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- ---------------- ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD (OVERFLOW_CREATES, 15), 15) AS OVERFLOW_CREATES,
	CHAR(LPAD(DEC(OVERFLOW_CREATES / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN,

	MEMBER,
	TAB_TYPE,
	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
	CHAR(LPAD(INDEX_TBSP_ID, 9), 9)	AS IDXTBSPID,
	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	OVERFLOW_CREATES IS NOT NULL
	
ORDER BY 
	OVERFLOW_CREATES DESC

FETCH FIRST 20 ROWS ONLY
;

--------------------------------------------------------------------------------------------------------------
ECHO ******************** TOP 20 PAGE REORGS ***********************;
ECHO SCHEMA     TABLE                PAGE_REORGS       /Sec     PTN MEMBER TAB_TYPE       FILE_ID TBSPID  IDXTBSPID LTBSPID;
ECHO ---------- -------------------- --------------- ---------- --- ------ -------------- ------- ------- --------- -------;
SELECT

	CHAR(RPAD(TABSCHEMA, 10), 10) 	AS SCHEMA,
	CHAR(RPAD(TABNAME, 20), 20) 	AS TABLE,
	CHAR(LPAD (PAGE_REORGS, 15), 15) 	AS PAGE_REORGS,
	CHAR(LPAD(DEC(PAGE_REORGS / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	CHAR(LPAD(DATA_PARTITION_ID, 3), 3) AS PTN,

	MEMBER,
	TAB_TYPE 		,
	CHAR(LPAD(TAB_FILE_ID, 7), 7) 	AS FILE_ID,
	CHAR(LPAD(TBSP_ID, 7), 7) 	AS TBSPID,
	CHAR(LPAD(INDEX_TBSP_ID, 9), 9) AS IDXTBSPID,
	CHAR(LPAD(LONG_TBSP_ID, 7), 7)	AS LTBSPID

FROM 
	DBMON.DUBPERF_MONTABLE_DIFF
WHERE
	PAGE_REORGS IS NOT NULL
	
ORDER BY 
	PAGE_REORGS DESC

FETCH FIRST 20 ROWS ONLY
;

ECHO *****************************************************************;
ECHO ***************** END DUBPERF PERFORMANCE REPORTS ***************;
ECHO *****************************************************************;      


ECHO ;
ECHO *********************************************************************************************************;
ECHO ********************************* DB2 CONTAINER DATA PERFORMANCE REPORT *****************************************;
ECHO *********************************************************************************************************;

SELECT 
    	'* Capture START TIME:',        start_timestamp,
	CHR(10)||
	'* Capture END TIME  :',        end_timestamp,

	CHR(10)||
    	'* DURATION: ',	CHAR(LPAD(DURATION_DAYS, 2), 2), 'Days,', 
	CHAR(LPAD(DURATION_HOURS, 2), 2), 'Hours,',
	CHAR(LPAD(DURATION_MINS, 2), 2), ' Mins,', CHAR(LPAD(DURATION_SECS,2), 2), ' Secs, ',
	CHAR(LPAD(DURATION_USECS, 6), 6), 'USecs',
	'' || CHR(10)||
	'* Capture TOTAL DURATION SECS  :', CHAR(LPAD(DURATION_SECS_TOTAL, 5), 5)
FROM 
	DBMON.DUBPERF_MONCONTAINER_DIFF
ORDER BY 
	DURATION_SECS_TOTAL ASC
FETCH FIRST
	1 ROW ONLY
;
--ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *;
--ECHO *********************************************************************************************************;


--ECHO 
--ECHO 
SELECT
	CHR(10),
	'************************* CONTAINER ********************************************************************',
	CHR(10),
 		 '* TBSP_NAME               :',	CHR(9), CHAR(RPAD(TBSP_NAME, 	15), 15),
	CHR(10), '* TPSP_ID                 :',	CHR(9),	CHAR(LPAD(TBSP_ID, 	15), 15),
	CHR(10), '* CONTAINER_NAME          :',	CHR(9), CHAR(RPAD(CONTAINER_NAME, 100), 100),
--CHAR(RPAD(CONTAINER_NAME, 60), 60),
	CHR(10), '* CONTAINER_ID            :',	CHR(9),	CHAR(LPAD(CONTAINER_ID, 15), 15),
	CHR(10), '* CONTAINER_TYPE          :',	CHR(9),	CHAR(RPAD(CONTAINER_TYPE, 16), 16),
	CHR(10), '* ACCESSIBLE              :',	CHR(9), CHAR(LPAD(ACCESSIBLE, 15), 15),
	CHR(10), '* MEMBER                  :',	CHR(9),	CHAR(LPAD(MEMBER, 	15), 15),
	CHR(10), '* STRIPE_SET              :',	CHR(9),	CHAR(LPAD(STRIPE_SET, 	15), 15),
	CHR(10), '* FILE_SYSTEM ID          :',	CHR(9),	CHAR(LPAD(FS_ID, 	15), 15),
	CHR(10), '* FILE_SYSTEM SIZE        :',	CHR(9), CHAR(LPAD(FS_TOTAL_SIZE,15), 15),
	CHR(10), '* FILESYSTEM_USED         :',	CHR(9), CHAR(LPAD(FS_USED_SIZE, 15), 15),
	CHR(10), '* TOTAL_PAGES             :',	CHR(9), CHAR(LPAD(TOTAL_PAGES,  15), 15),
	CHR(10), '* USABLE_PAGES            :',	CHR(9), CHAR(LPAD(USABLE_PAGES, 15), 15),
	CHR(10), '------------------------- Performance Data ---------------------------------------------------',
	CHR(10), '* DIRECT_READS            :',	CHR(9), CHAR(LPAD(DIRECT_READS, 15), 15),
		 ' * DR/SEC :',	 CHAR(LPAD(DEC(DEC(DIRECT_READS)/DURATION_SECS_TOTAL), 8), 8),
		 ' * T_DR_MSECS :',	 CHAR(LPAD(DIRECT_READ_TIME, 12), 12),
		 ' * MSECS/DR :',	 CHAR(LPAD(DEC(DEC(DIRECT_READ_TIME)/(DIRECT_READS+1)), 5), 5),

	CHR(10), '* DIRECT_WRITES           :',	CHR(9), CHAR(LPAD(DIRECT_WRITES,15), 15),
		 ' * DW/SEC :',	 CHAR(LPAD(DEC(DEC(DIRECT_WRITES)/DURATION_SECS_TOTAL), 8), 8),
	         ' * T_DW_MSECS :',	 CHAR(LPAD(DIRECT_WRITE_TIME, 12), 12),
		 ' * MSECS/DW :',	 CHAR(LPAD(DEC(DEC(DIRECT_WRITE_TIME)/(DIRECT_WRITES+1)), 5), 5),
	CHR(10), '* PAGES_READ (Physical)   :',	CHR(9), CHAR(LPAD(PAGES_READ, 	15), 15),
		 ' * PR/SEC :',	 CHAR(LPAD(DEC(DEC(PAGES_READ)/DURATION_SECS_TOTAL), 8), 8),
	         ' * T_RD_MSECS :',	 CHAR(LPAD(POOL_READ_TIME, 12), 12),
	         ' * MSECS/RD :',	 CHAR(LPAD(DEC(DEC(POOL_READ_TIME)/(PAGES_READ+1)), 5), 5),
	CHR(10), '*  (Data, Index, XML)     ',	CHR(9), 
	CHR(10), '* PAGES_WRITTEN           :',	CHR(9), CHAR(LPAD(PAGES_WRITTEN, 15), 15),
		 ' * PW/SEC :',	 CHAR(LPAD(PAGES_WRITTEN/DURATION_SECS_TOTAL, 8), 8),
	         ' * T_WR_MSECS :',	 CHAR(LPAD(POOL_WRITE_TIME, 12), 12),
	         ' * MSECS/WR :',	 CHAR(LPAD(POOL_WRITE_TIME/(PAGES_WRITTEN+1), 5), 5),

	CHR(10), '* VECTORED_IOS            :',	CHR(9), CHAR(LPAD(VECTORED_IOS, 15), 15),
		 ' * IO/SEC :',	 CHAR(LPAD(VECTORED_IOS/DURATION_SECS_TOTAL, 8), 8),
	CHR(10), '*  (Sequential Prefetches) ',	CHR(9), 
	CHR(10), '* PAGES_FROM_VECTORED_IOS :',	CHR(9), CHAR(LPAD(PAGES_FROM_VECTORED_IOS, 15), 15),
		 ' * PG/SEC :',	 CHAR(LPAD(PAGES_FROM_VECTORED_IOS/DURATION_SECS_TOTAL, 8), 8),
	CHR(10), '* BLOCK_IOS               :',	CHR(9), CHAR(LPAD(BLOCK_IOS, 15), 15),
		 ' * IO/SEC :',	 CHAR(LPAD(BLOCK_IOS/DURATION_SECS_TOTAL, 8), 8),
	CHR(10), '* PAGES_FROM_BLOCK_IOS    :',	CHR(9), CHAR(LPAD(PAGES_FROM_BLOCK_IOS, 15), 15),
		 ' * PG/SEC :',	 CHAR(LPAD(PAGES_FROM_BLOCK_IOS/DURATION_SECS_TOTAL, 8), 8)
FROM 
	DBMON.DUBPERF_MONCONTAINER_DIFF
--WHERE
--	TABLE_SCANS IS NOT NULl
	
ORDER BY 
	TBSP_NAME,
	CONTAINER_NAME
;
ECHO ;

ECHO	**********************************************************************;
ECHO	******** DUBPERF DB SNAPSHOT TABLESPACE REPORT ***********************;
ECHO	**********************************************************************;


SELECT 
    	'* Capture START TIME:',        start_timestamp,
	CHR(10)||
	'* Capture END TIME  :',        end_timestamp,

	CHR(10)||
    	'* DURATION: ',	CHAR(LPAD(DURATION_DAYS, 2), 2), 'Days,', 
	CHAR(LPAD(DURATION_HOURS, 2), 2), 'Hours,',
	CHAR(LPAD(DURATION_MINS, 2), 2), ' Mins,', CHAR(LPAD(DURATION_SECS,2), 2), ' Secs, ',
	CHAR(LPAD(DURATION_USECS, 6), 6), 'USecs',
	'' || CHR(10)||
	'* Capture TOTAL DURATION SECS  :', CHAR(LPAD(DURATION_SECS_TOTAL, 5), 5)
FROM 
	DBMON.DUBPERF_MONTABLESPACE_DIFF
ORDER BY 
	DURATION_SECS_TOTAL ASC
FETCH FIRST
	1 ROW ONLY
;
ECHO	**********************************************************************;


SELECT
	  CHR(10), 'TBSP_NAME                     :',   TRIM(SUBSTR(TBSP_NAME, 1, 30))
	, CHR(10), 'TBSPID                        :',   CHAR(LPAD(TBSP_ID,12),12)
        , CHR(10), 'MEMBER                        :',   CHAR(LPAD(MEMBER,12),12)
        , CHR(10), 'TBSP_TYPE                     :',   TBSP_TYPE
        , CHR(10), 'TBSP_CONTENT_TYPE             :',   TBSP_CONTENT_TYPE
        , CHR(10), 'TBSP_STATE @Start             :',   TRIM(SUBSTR(TBSP_STATE_START, 1, 30))
        , CHR(10), 'TBSP_STATE @End               :',   TRIM(SUBSTR(TBSP_STATE_END, 1, 30))
	, CHR(10), 'TBSP_REBALANCER_MODE          :',   TRIM(SUBSTR(TBSP_REBALANCER_MODE, 1, 30))

        , CHR(10), 'TBSP_PAGE_SIZE                :',   CHAR(LPAD(TBSP_PAGE_SIZE, 12),12)
        , CHR(10), 'TBSP_EXTENT_SIZE              :',   CHAR(LPAD(TBSP_EXTENT_SIZE, 12),12)
        , CHR(10), 'TBSP_PREFETCH_SIZE            :',   CHAR(LPAD(TBSP_PREFETCH_SIZE, 12), 12)

	, CHR(10), 'TBSP_USING_AUTO_STORAGE       :',   CHAR(LPAD(TBSP_USING_AUTO_STORAGE, 12), 12)
	, CHR(10), 'TBSP_AUTO_RESIZE_ENABLED      :',   CHAR(LPAD(TBSP_AUTO_RESIZE_ENABLED, 12), 12)

	, CHR(10), 'RECLAIMABLE_SPACE_ENABLED     :' , CHAR(LPAD( RECLAIMABLE_SPACE_ENABLED , 15), 15)
	, CHR(10), 'STORAGE_GROUP_NAME            :' , CHAR(LPAD( STORAGE_GROUP_NAME , 15), 15)

	, CHR(10), 'STORAGE_GROUP_ID              :' , CHAR(LPAD(STORAGE_GROUP_ID  , 15), 15)

	, CHR(10), 'AUTO_STORAGE_HYBRID           :' , CHAR(LPAD( AUTO_STORAGE_HYBRID , 15), 15)
	, CHR(10), 'TABLESPACE_MIN_RECOVERY_TIME  :' , CHAR(LPAD( TABLESPACE_MIN_RECOVERY_TIME , 15), 15)

	, CHR(10), 'TBSP_TRACKMOD_STATE           :' , CHAR(LPAD(TBSP_TRACKMOD_STATE  , 15), 15)
	, CHR(10), 'TBSP_DATATAG                  :' , CHAR(LPAD(TBSP_DATATAG  , 15), 15)



	, CHR(10), '**************************************************************************************'
	-- DIRECT READS
	, CHR(10), 'DIRECT_READS                  :' , CHAR(LPAD(DIRECT_READS      , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(DIRECT_READS)/(DURATION_SECS_TOTAL),     17, 2), 16), 16)
--	, CHAR('*', 1)
	, CHR(10), 'DIRECT_READ_REQS              :' , CHAR(LPAD(DIRECT_READ_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(DIRECT_READ_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	, CHR(10), 'DIRECT_READ_TIME_MSECS        :' , CHAR(LPAD(DIRECT_READ_TIME, 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'DIRECT_WRITE_TIME_MSECS       :' , CHAR(LPAD(DIRECT_WRITE_TIME, 15), 15)
	, CHAR('*', 1)


	-- DIRECT WRITES
	, CHR(10), 'DIRECT_WRITES                 :' , CHAR(LPAD(DIRECT_WRITES      , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(DIRECT_WRITES)/(DURATION_SECS_TOTAL),     17, 2), 16), 16)
--	, CHAR('*', 1)
	, CHR(10), 'DIRECT_WRITE_REQS             :' , CHAR(LPAD(DIRECT_WRITE_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(DIRECT_WRITE_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

	-- POOL READS
	, CHR(10), 'POOL_DATA_L_READS             :' , CHAR(LPAD(POOL_DATA_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_DATA_L_READS)/(DURATION_SECS_TOTAL),17, 2), 16), 16)

	, CHR(10), 'POOL_INDEX_L_READS            :' , CHAR(LPAD(POOL_INDEX_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_INDEX_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_XDA_L_READS              :' , CHAR(LPAD(POOL_XDA_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_XDA_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
--	, CHAR('*', 1)

	, CHR(10), '**************************************************************************************'

	, CHR(10), 'POOL_TEMP_DATA_L_READS        :' , CHAR(LPAD(POOL_TEMP_DATA_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_DATA_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_TEMP_INDEX_L_READS       :' , CHAR(LPAD(POOL_TEMP_INDEX_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_INDEX_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_TEMP_XDA_L_READS         :' , CHAR(LPAD(POOL_TEMP_XDA_L_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_XDA_L_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)


	, CHR(10), '**************************************************************************************'

        , CHR(10), 'POOL_DATA_P_READS             :' , CHAR(LPAD(POOL_DATA_P_READS,15), 15)
        , CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_DATA_P_READS)/(DURATION_SECS_TOTAL),17, 2), 16), 16)

        , CHR(10), 'POOL_INDEX_P_READS            :' , CHAR(LPAD(POOL_INDEX_P_READS  , 15), 15)
        , CHAR('*', 1)
        , CHAR(LPAD( DEC(DEC(POOL_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_XDA_P_READS              :' , CHAR(LPAD(POOL_XDA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

        , CHR(10), 'POOL_TEMP_DATA_P_READS        :' , CHAR(LPAD(POOL_TEMP_DATA_P_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

        , CHR(10), 'POOL_TEMP_INDEX_P_READS       :' , CHAR(LPAD(POOL_TEMP_INDEX_P_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

        , CHR(10), 'POOL_TEMP_XDA_P_READS         :' , CHAR(LPAD(POOL_TEMP_XDA_P_READS  , 15), 15)
        , CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_TEMP_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

        , CHR(10), 'POOL_DATA_WRITES              :' , CHAR(LPAD(POOL_DATA_WRITES, 15), 15)
        , CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_DATA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
--	, CHAR('*', 1)

	, CHR(10), 'POOL_INDEX_WRITES             :' , CHAR(LPAD(POOL_INDEX_WRITES, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_INDEX_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_XDA_WRITES               :' , CHAR(LPAD(POOL_XDA_WRITES, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_XDA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'


	, CHR(10), 'POOL_ASYNC_DATA_READS         :' , CHAR(LPAD(POOL_ASYNC_DATA_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_DATA_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_DATA_READ_REQS     :' , CHAR(LPAD(POOL_ASYNC_DATA_READ_REQS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_DATA_READ_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_INDEX_READS        :' , CHAR(LPAD(POOL_ASYNC_INDEX_READS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_INDEX_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_INDEX_READ_REQS    :' , CHAR(LPAD(POOL_ASYNC_INDEX_READ_REQS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_INDEX_READ_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_XDA_READS          :' , CHAR(LPAD(POOL_ASYNC_XDA_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_XDA_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	

	, CHR(10), 'POOL_ASYNC_XDA_READ_REQS        :' , CHAR(LPAD(POOL_ASYNC_XDA_READ_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_XDA_READ_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

	, CHR(10), 'POOL_ASYNC_DATA_WRITES        :' , CHAR(LPAD(POOL_ASYNC_DATA_WRITES, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_DATA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_INDEX_WRITES       :' , CHAR(LPAD(POOL_ASYNC_INDEX_WRITES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_INDEX_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_ASYNC_XDA_WRITES         :' , CHAR(LPAD(POOL_ASYNC_XDA_WRITES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_ASYNC_XDA_WRITES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_READ_TIME_MSECS          :' , CHAR(LPAD(POOL_READ_TIME, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_READ_TIME)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'POOL_WRITE_TIME_MSECS         :' , CHAR(LPAD(POOL_WRITE_TIME , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_WRITE_TIME)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'
	, CHR(10), 'POOL_ASYNC_READ_TIME          :' , CHAR(LPAD( POOL_ASYNC_READ_TIME , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'POOL_ASYNC_WRITE_TIME         :' , CHAR(LPAD( POOL_ASYNC_WRITE_TIME , 15), 15)
	, CHAR('*', 1)
	, CHR(10), '**************************************************************************************'


	, CHR(10), 'VECTORED_IOS                  :' , CHAR(LPAD(VECTORED_IOS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(VECTORED_IOS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	

	, CHR(10), 'PAGES_FROM_VECTORED_IOS       :' , CHAR(LPAD(PAGES_FROM_VECTORED_IOS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(PAGES_FROM_VECTORED_IOS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'BLOCK_IOS                     :' , CHAR(LPAD(BLOCK_IOS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(BLOCK_IOS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'PAGES_FROM_BLOCK_IOS          :' , CHAR(LPAD( PAGES_FROM_BLOCK_IOS , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(PAGES_FROM_BLOCK_IOS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'UNREAD_PREFETCH_PAGES         :' , CHAR(LPAD(UNREAD_PREFETCH_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(UNREAD_PREFETCH_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), 'PREFETCH_WAIT_TIME            :' , CHAR(LPAD( PREFETCH_WAIT_TIME , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'PREFETCH_WAITS                :' , CHAR(LPAD(PREFETCH_WAITS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(PREFETCH_WAITS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

	, CHR(10), 'FILES_CLOSED                  :' , CHAR(LPAD( FILES_CLOSED , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(FILES_CLOSED)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'
	
	, CHR(10), 'TBSP_USED_PAGES_START            :' , CHAR(LPAD( TBSP_USED_PAGES_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_USED_PAGES_END              :' , CHAR(LPAD( TBSP_USED_PAGES_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_FREE_PAGES_DMS_START        :' , CHAR(LPAD( TBSP_FREE_PAGES_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_FREE_PAGES_DMS_END          :' , CHAR(LPAD( TBSP_FREE_PAGES_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_USABLE_PAGES_START          :' , CHAR(LPAD( TBSP_USABLE_PAGES_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_USABLE_PAGES_END            :' , CHAR(LPAD( TBSP_USABLE_PAGES_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_TOTAL_PAGES_START           :' , CHAR(LPAD( TBSP_TOTAL_PAGES_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_TOTAL_PAGES_END             :' , CHAR(LPAD( TBSP_TOTAL_PAGES_END , 15), 15)
	, CHAR('*', 1)


	, CHR(10), 'TBSP_PENDING_FREE_PAGES_DMS_START:' , CHAR(LPAD( TBSP_PENDING_FREE_PAGES_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_PENDING_FREE_PAGES_DMS_END  :' , CHAR(LPAD( TBSP_PENDING_FREE_PAGES_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_PAGE_TOP_DMS_START          :' , CHAR(LPAD( TBSP_PAGE_TOP_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_PAGE_TOP_DMS_END            :' , CHAR(LPAD( TBSP_PAGE_TOP_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_MAX_PAGE_TOP_DMS_START      :' , CHAR(LPAD( TBSP_MAX_PAGE_TOP_DMS_START , 15), 15)
	, CHAR('*', 1)

	, CHR(10), 'TBSP_MAX_PAGE_TOP_DMS_END        :' , CHAR(LPAD( TBSP_MAX_PAGE_TOP_DMS_END , 15), 15)
	, CHAR('*', 1)

	, CHR(10), '**************************************************************************************'
	

	, CHR(10), 'TBSP_PATHS_DROPPED               :' , CHAR(LPAD( TBSP_PATHS_DROPPED , 15), 15)
	, CHAR('*', 1)


	-- 05jun15 Adding on bits missed and pool/prefetch not related to purescale
	
	, CHR(10), 'POOL_QUEUED_ASYNC_DATA_REQS      :' , CHAR(LPAD(POOL_QUEUED_ASYNC_DATA_REQS, 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_DATA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_INDEX_REQS     :' , CHAR(LPAD(POOL_QUEUED_ASYNC_INDEX_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_INDEX_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_XDA_REQS       :' , CHAR(LPAD(POOL_QUEUED_ASYNC_XDA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_XDA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)



	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_DATA_REQS :' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_DATA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_DATA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_INDEX_REQS:' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_INDEX_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_INDEX_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_XDA_REQS  :' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_XDA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_XDA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_OTHER_REQS     :' , CHAR(LPAD(POOL_QUEUED_ASYNC_OTHER_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_OTHER_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	

	, CHR(10), 'POOL_QUEUED_ASYNC_DATA_PAGES     :' , CHAR(LPAD(POOL_QUEUED_ASYNC_DATA_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_DATA_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_INDEX_PAGES    :' , CHAR(LPAD(POOL_QUEUED_ASYNC_INDEX_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_INDEX_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_XDA_PAGES    :' , CHAR(LPAD(POOL_QUEUED_ASYNC_XDA_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_XDA_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	

	
	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_DATA_PAGES:' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_DATA_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_DATA_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_INDEX_PAGES:' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_INDEX_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_INDEX_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_QUEUED_ASYNC_TEMP_XDA_PAGES  :' , CHAR(LPAD(POOL_QUEUED_ASYNC_TEMP_XDA_PAGES  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_QUEUED_ASYNC_TEMP_XDA_PAGES)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)

	, CHR(10), '**************************************************************************************'

	

	, CHR(10), 'POOL_FAILED_ASYNC_DATA_REQS       :' , CHAR(LPAD(POOL_FAILED_ASYNC_DATA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_DATA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_INDEX_REQS      :' , CHAR(LPAD(POOL_FAILED_ASYNC_INDEX_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_INDEX_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_XDA_REQS        :' , CHAR(LPAD(POOL_FAILED_ASYNC_XDA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_XDA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_TEMP_DATA_REQS  :' , CHAR(LPAD(POOL_FAILED_ASYNC_TEMP_DATA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_TEMP_DATA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_TEMP_INDEX_REQS :' , CHAR(LPAD(POOL_FAILED_ASYNC_TEMP_INDEX_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_TEMP_INDEX_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_TEMP_XDA_REQS   :' , CHAR(LPAD(POOL_FAILED_ASYNC_TEMP_XDA_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_TEMP_XDA_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'POOL_FAILED_ASYNC_OTHER_REQS      :' , CHAR(LPAD(POOL_FAILED_ASYNC_OTHER_REQS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(POOL_FAILED_ASYNC_OTHER_REQS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)


	, CHR(10), '**************************************************************************************'
	

	, CHR(10), 'SKIPPED_PREFETCH_DATA_P_READS          :' , CHAR(LPAD(SKIPPED_PREFETCH_DATA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_INDEX_P_READS         :' , CHAR(LPAD(SKIPPED_PREFETCH_INDEX_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_XDA_P_READS           :' , CHAR(LPAD(SKIPPED_PREFETCH_XDA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)



	, CHR(10), 'SKIPPED_PREFETCH_TEMP_DATA_P_READS     :' , CHAR(LPAD(SKIPPED_PREFETCH_TEMP_DATA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_TEMP_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_TEMP_INDEX_P_READS    :' , CHAR(LPAD(SKIPPED_PREFETCH_TEMP_INDEX_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_TEMP_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_TEMP_XDA_P_READS      :' , CHAR(LPAD(SKIPPED_PREFETCH_TEMP_XDA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_TEMP_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)



	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_DATA_P_READS      :' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_DATA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_INDEX_P_READS     :' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_INDEX_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_XDA_P_READS       :' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_XDA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_TEMP_DATA_P_READS :' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_TEMP_DATA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_TEMP_DATA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_TEMP_INDEX_P_READS:' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_TEMP_INDEX_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_TEMP_INDEX_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), 'SKIPPED_PREFETCH_UOW_TEMP_XDA_P_READS  :' , CHAR(LPAD(SKIPPED_PREFETCH_UOW_TEMP_XDA_P_READS  , 15), 15)
	, CHAR('*', 1)
	, CHAR(LPAD( DEC(DEC(SKIPPED_PREFETCH_UOW_TEMP_XDA_P_READS)/(DURATION_SECS_TOTAL), 17, 2), 16), 16)
	
	, CHR(10), '**************************************************************************************'
	, CHR(10), '**************************************************************************************'


from

	DBMON.DUBPERF_MONTABLESPACE_DIFF
;	



ECHO *********************************************************************************************************;
ECHO ********************************* INDEX DATA PERFORMANCE REPORT *****************************************;
ECHO *********************************************************************************************************;

SELECT 
    	'* Capture START TIME:',        start_timestamp,
	CHR(10)||
	'* Capture END TIME  :',        end_timestamp,

	CHR(10)||
    	'* DURATION: ',	CHAR(LPAD(DURATION_DAYS, 2), 2), 'Days,', 
	CHAR(LPAD(DURATION_HOURS, 2), 2), 'Hours,',
	CHAR(LPAD(DURATION_MINS, 2), 2), ' Mins,', CHAR(LPAD(DURATION_SECS,2), 2), ' Secs, ',
	CHAR(LPAD(DURATION_USECS, 6), 6), 'USecs',
	'' || CHR(10)||
	'* Capture TOTAL DURATION SECS  :', CHAR(LPAD(DURATION_SECS_TOTAL, 5), 5)
FROM 
	DBMON.DUBPERF_MONINDEX_DIFF
ORDER BY 
	DURATION_SECS_TOTAL ASC
FETCH FIRST
	1 ROW ONLY
;

ECHO ******************** TOP 20  INDEX NLEAF COUNTS ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             IDXPAGECOUNTS IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ------------- ------ ------ ---;

SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) 	AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.NLEAF, 13), 13) AS IDXPAGECOUNTS,
--	CHAR(LPAD(NLEVELS, 10) AS IDXLEVELCOUNTS,
--	CHAR(LPAD(DEC(NLEAF / DURATION_SECS_TOTAL, 2), 6) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	IDXPAGECOUNTS DESC
	
FETCH FIRST 20 ROWS ONLY
;

ECHO ******************** TOP 20  INDEX NLEVELS COUNTS ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             IDXLEVELCOUNTS IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- -------------- ------ ------ ---;

SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.NLEVELS, 13), 13) AS IDXLEVELCOUNTS,

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	IDXLEVELCOUNTS DESC
	
FETCH FIRST 20 ROWS ONLY
;
ECHO *********************************** TOP 20 INDEX SCANS **************************************;
ECHO SCHEMA       TABLE                               INDNAME                             INDEX_SCANS                /Sec IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- -------------------- ---------- ------ ------ ---;

SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.INDEX_SCANS, 20), 20) AS INDEX_SCANS,
	CHAR(LPAD(D.INDEX_SCANS / DURATION_SECS_TOTAL, 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	INDEX_SCANS DESC
	
FETCH FIRST 20 ROWS ONLY
;




ECHO ******************** TOP 20 INDEX ONLY SCANS ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             INDXONLYSCANS       /Sec IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ------------- ---------- ------ ------ ---;

SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.INDEX_ONLY_SCANS, 20), 20) AS INDXONLYSCANS,
	CHAR(LPAD(DEC(D.INDEX_ONLY_SCANS / DURATION_SECS_TOTAL, 10), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	INDEX_ONLY_SCANS DESC
	
FETCH FIRST 20 ROWS ONLY
;






ECHO ******************** TOP 20 INDEX KEY UPDATES ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             KEY_UPDATES         /Sec IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ------------- ---------- ------ ------ ---;
SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.KEY_UPDATES, 13), 13) AS KEY_UPDATES,
	CHAR(LPAD(DEC(D.KEY_UPDATES / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	KEY_UPDATES DESC
	
FETCH FIRST 20 ROWS ONLY
;

ECHO ******************** TOP 20 INDEX KEY INCLUDE COLUMN UPDATES ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             INCLUDECOLUPDATES      /Sec  IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ----------------- ---------- ------ ------ ---;
SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.INCLUDE_COL_UPDATES, 17), 17) AS INCLUDECOLUPDATES,
	CHAR(LPAD(DEC(D.INCLUDE_COL_UPDATES / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	INCLUDE_COL_UPDATES DESC
	
FETCH FIRST 20 ROWS ONLY
;


ECHO ******************** TOP 20 INDEX PSEUDO DELETES ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             PSEUDO_DELETES       /Sec IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- -------------- ---------- ------ ------ ---;


SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.PSEUDO_DELETES, 13), 13) AS PSEUDO_DELETES,
	CHAR(LPAD(DEC(D.PSEUDO_DELETES / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	PSEUDO_DELETES
	
FETCH FIRST 20 ROWS ONLY
;
ECHO ******************** TOP 20 INDEX PSEUDO DELETED KEYS CLEANED ***********************;

ECHO SCHEMA       TABLE                               INDNAME                             PSEUDO_DEL_KEYS_CLEANED   /Sec     IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ----------------------- ---------- ------ ------ ---;
SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.DEL_KEYS_CLEANED, 23), 23) AS PSEUDO_DEL_KEYS_CLEANED ,
	CHAR(LPAD(DEC(D.DEL_KEYS_CLEANED / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	 PSEUDO_DEL_KEYS_CLEANED DESC
	
FETCH FIRST 20 ROWS ONLY
;

ECHO ******************** TOP 20 INDEX PAGE ALLOCATIONS ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             PAGE_ALLOCATIONS   /Sec     IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ---------------- ---------- ------ ------ ---;
SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.PAGE_ALLOCATIONS, 16), 16) AS PAGE_ALLOCATIONS,
	CHAR(LPAD(DEC(D.PAGE_ALLOCATIONS / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	PAGE_ALLOCATIONS DESC
	
FETCH FIRST 20 ROWS ONLY
;

ECHO ******************** TOP 20 INDEX PAGES MERGED ***********************;
ECHO SCHEMA       TABLE                               INDNAME                             PAGES_MERGED        /Sec IID    MEMBER PTN;
ECHO ------------ ----------------------------------- ----------------------------------- ------------- ---------- ------ ------ ---;

SELECT
	CHAR(RPAD(D.TABSCHEMA, 12), 12) AS SCHEMA,
	CHAR(SUBSTR(D.TABNAME, 1, 35), 35) AS TABLE,
	CHAR(SUBSTR(S.INDNAME, 1, 35), 35) AS INDNAME,

	CHAR(LPAD(D.PAGES_MERGED, 13), 13) AS PAGES_MERGED,
	CHAR(LPAD(DEC(D.PAGES_MERGED / DURATION_SECS_TOTAL, 2), 10), 10) AS "  /Sec",

	D.IID,
	D.MEMBER,
	CHAR(LPAD(D.DATA_PARTITION_ID, 3), 3) AS PTN 

FROM 
	DBMON.DUBPERF_MONINDEX_DIFF AS D,
	SYSCAT.INDEXES AS S

WHERE
	D.TABSCHEMA = S.TABSCHEMA
	AND D.TABNAME = S.TABNAME
	AND D.IID = S.IID

ORDER BY
	PAGES_MERGED DESC
	
FETCH FIRST 20 ROWS ONLY
;


