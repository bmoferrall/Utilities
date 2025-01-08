echo	**********************************************************************;
echo	************ DISK SPACE USED BY TABLE SPACE CONTAINERS ***************;
echo	**********************************************************************;
SELECT CAST(TBSP_NAME AS VARCHAR(30)) AS TBSP_NAME, INT(TBSP_ID) AS TBSP_ID, 
		CAST(CONTAINER_NAME AS VARCHAR(65)) AS CONTAINER_NAME, INT(CONTAINER_ID) AS CONTAINER_ID, 
		CONTAINER_TYPE, INT(TOTAL_PAGES) AS TOTAL_PAGES, INT(USABLE_PAGES) AS USABLE_PAGES,
		DECIMAL((DOUBLE(TOTAL_PAGES-USABLE_PAGES)/DOUBLE(TOTAL_PAGES))*100,5,2) AS PERCENT_USED_PAGES,
		FS_TOTAL_SIZE_KB, FS_USED_SIZE_KB, 
		DECIMAL((DOUBLE(FS_USED_SIZE_KB)/DOUBLE(FS_TOTAL_SIZE_KB))*100,5,2) AS PERCENT_USED_FS,
		ACCESSIBLE
FROM SYSIBMADM.CONTAINER_UTILIZATION;
echo    ;
echo	**********************************************************************;
echo	***************** DISK SPACE USED BY TRANSACTION LOGS ****************;
echo	**********************************************************************;
SELECT CHAR(DB_NAME,16) AS DB_NAME, LOG_UTILIZATION_PERCENT, TOTAL_LOG_USED_KB, TOTAL_LOG_AVAILABLE_KB, 
		TOTAL_LOG_USED_TOP_KB, DBPARTITIONNUM 
FROM SYSIBMADM.LOG_UTILIZATION;
echo    ;
echo	**********************************************************************;
echo	********************** DISK SPACE USED BY TABLES *********************;
echo	**********************************************************************;
SELECT CAST(TABSCHEMA AS VARCHAR(25)) AS TABSCHEMA,CAST (TABNAME AS VARCHAR(55)) AS TABNAME,
		DATA_OBJECT_P_SIZE AS SIZE_IN_KB
FROM SYSIBMADM.ADMINTABINFO 
ORDER BY TABSCHEMA,TABNAME;
echo    ;
echo	**********************************************************************;
echo	********************** DISK SPACE USED BY INDEXES ********************;
echo	**********************************************************************;
SELECT CAST(TABSCHEMA AS VARCHAR(25)) AS TABSCHEMA,CAST (TABNAME AS VARCHAR(55)) AS TABNAME,
		INDEX_OBJECT_P_SIZE AS SIZE_IN_KB
FROM TABLE(ADMIN_GET_INDEX_INFO('','','')) 
GROUP BY TABSCHEMA,TABNAME,INDEX_OBJECT_P_SIZE 
ORDER BY TABSCHEMA,TABNAME;
echo    ;
echo	**********************************************************************;
echo	********************* NUMBER OF INDEXES PER TABLE ********************;
echo	**********************************************************************;
SELECT TABSCHEMA, TABNAME, COUNT(INDNAME) AS INDEXCOUNT
  FROM TABLE (ADMIN_GET_INDEX_INFO('', '', ''))
  WHERE TABSCHEMA NOT IN ('SYSIBM', 'DB2GSE', 'SYSTOOLS')
  GROUP BY TABSCHEMA, TABNAME;
