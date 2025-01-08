-- Fergus (fergusmc@ie.ibm.com)
-- 04-Feb-14 Relevant Connections details to determine what's going on
-- in each connection.

select
	client_wrkstnname,
	client_hostname,
	application_id,
	application_name,
	coord_member,
--	client_userid,
	client_protocol,
	system_auth_id,
	session_auth_id,
	connection_start_time,
	client_applname,
	act_aborted_total,
	act_completed_total,
	act_rejected_total,
	agent_wait_time,
	agent_waits_total,
	client_idle_wait_time,
	total_cpu_time,
	rows_read,
	lock_wait_time,
	lock_waits,
	deadlocks
from
	TABLE(MON_GET_CONNECTION(cast(NULL as bigint), -1))		
;
