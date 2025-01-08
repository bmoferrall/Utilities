
select 
	SUM(MEMORY_POOL_USED) as TOTAL_KB_COMMITTED
-- 	SUM(MEMORY_POOL_USED_HWM) as TOTAL_KB_USED_HWM
from table(MON_GET_MEMORY_POOL(null,null,-2));



SELECT 
       varchar(memory_set_type, 20) AS set_type,
       varchar(memory_pool_type,20) AS pool_type,
       varchar(db_name, 20) AS dbname,
--       memory_pool_id,
--       application_handle,
--       edu_id,
--       varchar(HOST_name, 20) AS dbname,

      sum(memory_pool_used) as KB_COMMITTED
FROM TABLE( 
       MON_GET_MEMORY_POOL(NULL, NULL, -2))
group by 
      db_name,
      memory_set_type,
      memory_pool_type
order by 
      KB_COMMITTED DESC
;

SELECT 
       varchar(memory_set_type, 20) AS set_type,
       varchar(memory_pool_type,20) AS pool_type,
       varchar(db_name, 20) AS dbname,
       memory_pool_id,
       application_handle,
       edu_id,
--       varchar(HOST_name, 20) AS dbname,

       memory_pool_used 	as KB_COMMITTED,
       memory_pool_used_hwm	AS KB_HWM
FROM TABLE( 
       MON_GET_MEMORY_POOL(NULL, NULL, -2))
--group by 
--      EDU_ID
--      ,memory_set_type,
--      memory_pool_type
order by 
      KB_HWM    DESC
;
