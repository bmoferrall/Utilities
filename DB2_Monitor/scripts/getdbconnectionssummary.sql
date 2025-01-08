-- Fergus (fergusmc@ie.ibm.com)
-- 04-Feb-14 Relevant Connections SUMMARY to determine what's going on
-- in each connection type.

select
	count as Count,
	substr(client_hostname, 1, 50) AS Hostname,
	substr(system_auth_id, 1, 10) AS SystemAuthID,
	substr(session_auth_id, 1, 10) AS SessionAuthID
from
	TABLE(MON_GET_CONNECTION(cast(NULL as bigint), -1))		
group by
      client_hostname,
      system_auth_id,
      session_auth_id
;
