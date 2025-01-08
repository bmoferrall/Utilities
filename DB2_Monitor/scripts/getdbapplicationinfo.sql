-- Fergus (fergusmc@ie.ibm.com)
-- getting agent & subagent info.
-- Need to check if nbr subagents is common to whole DB
SELECT 
       varchar(DB_NAME,10) AS DB_NAME, 
       AGENT_ID, num_assoc_agents AS NSUBAGENTS, 
       varchar(APPL_NAME,20) AS APP_NAME, 
       substr(appl_status, 1, 10) AS CUR_STATE 
FROM 
     table (SNAP_get_APPL_INFO(null,-1)) 
order by 
      db_name, 
      agent_id
;