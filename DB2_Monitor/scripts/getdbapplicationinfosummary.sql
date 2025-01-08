-- Fergus (fergusmc@ie.ibm.com)
-- getting agent & subagent info.
-- Need to check if nbr subagents is common to whole DB
SELECT 
       varchar(DB_NAME,10)	AS DB_NAME, 
       COUNT(AGENT_ID) 	   	AS NAGENTS, 
       SUM(num_assoc_agents) 	AS NSUBAGENTS
FROM 
     table (SNAP_get_APPL_INFO(null,-1)) 
GROUP BY
      DB_NAME
order by 
      db_name
;