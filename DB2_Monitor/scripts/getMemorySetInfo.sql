-- Fergus (fergusmc@ie.ibm.com)
SELECT varchar(memory_set_type, 20) AS MEM_TYPE,
       varchar(db_name, 20) AS dbname,
       memory_set_committed as KB_COMMITTED,
       memory_set_size as MAX_COMMIT_KB,
       memory_set_USED as IN_USE_KB
FROM 
     TABLE( MON_GET_MEMORY_SET(NULL, NULL, -2)   )
order by 
      DBNAME    DESC
      
      
;