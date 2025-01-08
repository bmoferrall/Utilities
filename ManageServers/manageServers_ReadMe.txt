----------------------------------------------------------------------------------------------------------------
ManageServers.py

version 11.12.2012.1
----------------------------------------------------------------------------------------------------------------

DESCRIPTION:
Script for stopping/starting/restarting a list of servers and nodeagents in a specified order

TO USE:
Copy script and configuration file to a directory on deployment manager node
Script takes two arguments: path to configuration file and start|stop|restart
Open command prompt and navigate to the 'bin' directory of WAS on the deployment manager, e.g.:
   C:\Program Files\IBM\WebSphere\AppServer\bin (Windows)
   /opt/IBM/WebSphere/AppServer/bin (Linux)
invoke wsadmin script with WAS user/password, jython option, -f option with path to script, two required parameters, e.g.

> wsadmin.bat -user waswebadmin -password passw0rd -lang jython -f c:\Scripts\ManageServers.py c:\Scripts\ManageServers.settings start
> wsadmin.sh -user waswebadmin -password passw0rd -lang jython -f /tmp/ManageServers.py /tmp/ManageServers.settings start

PARAMETER 1:
Configuration file contains three sections [OPTIONS], [STOPSERVERS] and [STARTSERVERS]. 
[OPTIONS] allows user to override default values for a select few parameters
[STOPSERVERS] specifies the order in which to stop servers and (for restart option) node agents
[STARTSERVERS] specifies the order in which to start servers

PARAMETER 2:
'stop'    - stops the listed servers in the specified order
            If a server is already stopped it is skipped and a message printed
'start'   - starts the listed servers in the specified order
            If a server is already started it is skipped
            If the node agent for a server is not in STARTED state an error message is printed
            and the server skipped
'restart' - stops the servers in the specified order, restarts the deployment manager,
            restarts the node agents in the specified order, finally starts the servers in the specified
			order
            A node agent can only be restarted from 'STARTED' state. It cannot be started from a stopped
            state (limitation of wsadmin). The script will continue onto the next node/server

NOTES:
Tested on Windows and Linux (WASND 7)

SAMPLE CONFIGURATION FILE:
#########################################################################################################
#Place '#' at start of a line for it to be ignored (e.g., to start/stop a subset of server/nodes)
[OPTIONS]

#Number of times the script will wait for a server to stop or start (delay of 10 seconds before each retry)
numRetries=100
#ERROR=0|WARNING=1|INFO=2|VERBOSE=3|DEBUG=4
logLevel=3

#Order to stop servers and nodes
[STOPSERVERS]

#node,server
IICCltSvcsNode1,IICCltSvcsServer1
IICDaAqSvcsNode1,IICDaAqSvcsServer1
IICMgmtSvcsNode1,IICMgmtSvcsServer1
IICRTCSvcsNode,IICRTCSvcsServer
IICMDLSvcsNode,IICMDLSvcsServer

# Order to start servers and nodes
[STARTSERVERS]

#node,server
IICMDLSvcsNode,IICMDLSvcsServer
IICRTCSvcsNode,IICRTCSvcsServer
IICMgmtSvcsNode1,IICMgmtSvcsServer1
IICDaAqSvcsNode1,IICDaAqSvcsServer1
IICCltSvcsNode1,IICCltSvcsServer1

##########################################################################################################

