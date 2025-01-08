#------------------------------------------------------------------------------------------
# ManageServers.py
# version 11.12.2012.1
#
# DESCRIPTION:
# Script for stopping/starting/restarting a list of servers and nodeagents
#
# TO USE:
# Copy script and configuration file to a directory on deployment manager node
# Script takes two arguments: path to configuration file and start|stop|restart
# Open command prompt and navigate to the 'bin' directory of WAS on the deployment manager, e.g.:
#    C:\Program Files\IBM\WebSphere\AppServer\bin (Windows)
#    /opt/IBM/WebSphere/AppServer/bin (Linux)
# invoke wsadmin script with WAS user/password, jython option, -f option with path to script, two requred parameters, e.g.
#
# > wsadmin.bat -user waswebadmin -password passw0rd -lang jython -f c:\Scripts\ManageServers.py c:\Scripts\ManageServers.settings start
# > wsadmin.sh -user waswebadmin -password passw0rd -lang jython -f /tmp/ManageServers.py /tmp/ManageServers.settings start
#
# PARAMETER 1:
# Configuration file contains three sections (OPTIONS], [STOPSERVERS] and [STARTSERVERS). 
# [OPTIONS] allows user to override default values for a few parameters
# [STOPSERVERS] specifies the order in which to stop servers and (for restart option) node agents
# [STARTSERVERS] specifies the order in which to start servers
# Include path to file unless the file is located in the wsadmin bin directory
#
# PARAMETER 2
# 'stop'    - stops the listed servers in the specified order
#             If a server is already stopped it is skipped and a message printed
# 'start'   - starts the listed servers in the specified order
#             If a server is already started it is skipped
#             If the node agent for a server is not in STARTED state an error message is printed
#             and the server skipped
# 'restart' - stops the servers in the specified order, restarts the deployment manager, and
#             restarts the node agents in the specified order,
#             Starts the servers in the specified order
#             A node agent can only be restarted from 'STARTED' state. It cannot be started from a stopped
#             state (limitation of wsadmin). The script will continue onto the next node/server
#
# NOTES:
# Tested on Windows and Linux (WASND7)
#
# SAMPLE CONFIGURATION FILE:
#############################################################################################################
## Place '#' at start of a line for it to be ignored (e.g., to start/stop a subset of server/nodes)
#[OPTIONS]
#
## Number of times the script will wait for a server to stop or start (delay of 10 seconds before each retry)
#numRetries=100
##ERROR=0|WARNING=1|INFO=2|VERBOSE=3|DEBUG=4
#logLevel=3
#
## Order to stop servers and nodes
#[STOPSERVERS]
#
##node,server
#IICCltSvcsNode1,IICCltSvcsServer1
#IICDaAqSvcsNode1,IICDaAqSvcsServer1
#IICMgmtSvcsNode1,IICMgmtSvcsServer1
#IICRTCSvcsNode,IICRTCSvcsServer
#IICMDLSvcsNode,IICMDLSvcsServer
#
## Order to start servers and nodes
#[STARTSERVERS]
#
##node,server
#IICMDLSvcsNode,IICMDLSvcsServer
#IICRTCSvcsNode,IICRTCSvcsServer
#IICMgmtSvcsNode1,IICMgmtSvcsServer1
#IICDaAqSvcsNode1,IICDaAqSvcsServer1
#IICCltSvcsNode1,IICCltSvcsServer1

#
#############################################################################################################
#------------------------------------------------------------------------------------------

import sys, os
import re
import time
global AdminApp
global AdminControl
global AdminConfig
global logLevel
global ERROR_
global WARNING_
global INFO_
global VERBOSE_
global DEBUG_
global numRetries

ERROR_ = 0
WARNING_ = 1
INFO_ = 2
VERBOSE_ = 3
DEBUG_ = 4

#------------------------------------------------------------------------------------------
# Print message and exit
# -> msg = message to print
#------------------------------------------------------------------------------------------
def fail(msg):
    print "======================================================================="
    print msg
    print "======================================================================="
    sys.exit(2)
#endDef


#------------------------------------------------------------------------------------------
# Print message if level <= logLevel
# -> level = log level, msg = message to print
#------------------------------------------------------------------------------------------
def log(level,msg):
    global logLevel

    if (level == ERROR_):
        print "**** " + msg + " ****"
    elif (level == WARNING_):
        print "WARNING: " + msg
    elif (level <= logLevel):
        print msg
    #endIf
#endDef


#------------------------------------------------------------------------------------------
# Print highlighted message if level <= logLevel
# -> level = log level, msg = message to print
#------------------------------------------------------------------------------------------
def highlight(level,msg):
    global logLevel

    print "-----------------------------------------------------------------------"
    log(level,msg)
    print "-----------------------------------------------------------------------"
#endDef


#------------------------------------------------------------------------------------------
# Sleep for specified number of seconds
# -> secs = seconds to sleep
#------------------------------------------------------------------------------------------
def sleepDelay ( secs ):
    tstart = time.strftime( "%H:%M:%S", time.localtime() )
    try:
        _excp_ = 0
        java.lang.Thread.sleep( (secs * 1000) )
    except:
        _type_, _value_, _tbck_ = sys.exc_info()
        _excp_ = 1
    #endTry
    temp = _excp_
    tdone = time.strftime( "%H:%M:%S", time.localtime() )
    #log(VERBOSE_, ">> sleepDelay seconds="+`secs`+" start="+tstart+" done="+tdone )
#endDef


#------------------------------------------------------------------------------------------
# Verify that the server is stopped
# -> Server = name of server, node = name of node
# Returns true is server is stopped, false if server is in another state
#------------------------------------------------------------------------------------------
def checkServerIsStopped ( server, node ):
    global numRetries
    sid = ""
    length = 1
    retries = 0
    state = "STOPPED"
    
    while ((length > 0) and (retries < numRetries)):
        retries = retries + 1
        try:
            sleepDelay(10)
            sid = AdminControl.completeObjectName("type=Server,node="+node+",name="+server+",*" )
            length = len(sid)
            if (length > 0):
                state = AdminControl.getAttribute(sid,"state")
                log(VERBOSE_, ">> Server: " + server + ", Node: " + node + ", State: " + state)
            #endIf
        except:
            _type_, _value_, _tbck_ = sys.exc_info()
            sd = `_tbck_.dumpStack()`
            log(DEBUG_, sd);
            log(ERROR_, "Unexpected error stopping server/nodeagent for node " + node + ": " + str(sys.exc_info()[0]))
            length = 0
        #endTry
    #endWhile

    if (retries < numRetries): # Server stopped
        return 1
    return 0
    #endIf
#endDef


#------------------------------------------------------------------------------------------
# Restart the deployment manager
#------------------------------------------------------------------------------------------
def restartDeploymentManager():
    try:
        log(VERBOSE_, "Trying to access deployment manager: type=Server,name=dmgr,*")
        dmgr = AdminControl.completeObjectName("type=Server,name=dmgr,*")
        state = AdminControl.getAttribute(dmgr,"state")
        if (state == "STARTED"):
            log(INFO_, "Restarting deployment manager dmgr")
            nname = AdminControl.invoke(dmgr,"getNodeName")
            log(DEBUG_, "Node name retrieved for deployment manager: " + nname)
            AdminControl.invoke(dmgr,"restart")
            running = checkServerIsRunning("dmgr",nname)
            sleepDelay(60) # Pause to allow comms between dmgr and node agents
        else:
            log(WARNING_, "Cannot restart the deployment manager as it is not in STARTED state")
        #endIf
    except:
        _type_, _value_, _tbck_ = sys.exc_info()
        sd = `_tbck_.dumpStack()`
        log(DEBUG_, sd);
        log(ERROR_, "Error trying to restart the deployment manager: " + str(sys.exc_info()[0]))
    #endTry
#endDef


#------------------------------------------------------------------------------------------
# Restart node agent for specified node, followed by node synchronization
# -> node = name of node
# A node agent can only be restarted; currently it is not possible to start a stopped node
# agent using wsadmin:
# http://publib.boulder.ibm.com/infocenter/wasinfo/v6r0/index.jsp?topic=%2Fcom.ibm.websphere.nd.doc%2Finfo%2Fae%2Fae%2Ftxml_restartnodeagent.html
#------------------------------------------------------------------------------------------
def restartNodeAgent(node):
    try:
        nodeagent = AdminControl.completeObjectName("type=Server,node="+node+",name=nodeagent,*")
        sync = AdminControl.completeObjectName("type=NodeSync,node="+node+",*")
        state = AdminControl.getAttribute(nodeagent,"state")
        log(VERBOSE_, "Current state of node agent for node '" + node + "': " + state)
        if (state == "STARTED"):
            log(INFO_, "Restarting node agent for node " + node)
            AdminControl.invoke(nodeagent,"restart")
            running = checkServerIsRunning("nodeagent",node)
            log(INFO_, "Synchronizing configuration changes to " + node)
            AdminControl.invoke(sync, "sync")
        else:
            log(WARNING_, "Cannot restart node agent for node " + node + " as it is not started")
        #endif
    except:
        _type_, _value_, _tbck_ = sys.exc_info()
        sd = `_tbck_.dumpStack()`
        log(DEBUG_, sd);
        log(WARNING_, "Cannot restart node agent for node " + node + " (in stopped state?)")
    #endTry
#endDef


#------------------------------------------------------------------------------------------
# Stop servers
# -> stopServerList = list of node/server pairs
# If restart is true servers are stopped and node agents are restarted
# If restart is false servers are stopped
# Aborts if any servers fail to stop
# No return value
#------------------------------------------------------------------------------------------
def stopServers (stopServerList, restart):
    stoppedServers = []
    nonStoppedServers = []
    restartMsg = ""
    if (restart): restartMsg = " and restarting node agents"

    # If we are doing a restart, we restart the deployment manager here first
    if restart: restartDeploymentManager()

    highlight(INFO_, "Stopping all requested Servers" + restartMsg + "...")

    for nodeServerPair in stopServerList:
        nname = nodeServerPair[0]
        sname = nodeServerPair[1]
        try:
            server = AdminControl.completeObjectName("type=Server,node="+nname+",name="+sname+",*")
            # Stop Server
            state = AdminControl.getAttribute(server,"state")
            log(VERBOSE_, "Current state of server '" + sname + "': " + state)
            if ((state == "STARTED") or (state == "STOPPING")):
                if (state == "STARTED"):
                    log(INFO_, "Stopping server " + sname + " on node " + nname)
                    AdminControl.invoke(server,"stop")
                else:
                    log(VERBOSE_, ">> Server " + sname + ": " + state)
                #endIf
                stopped = checkServerIsStopped(sname,nname)
                if (stopped > 0): # Server stopped
                    stoppedServers.append(sname)
                else:
                    nonStoppedServers.append(sname)
                #endIf
            else:
                log(WARNING_, "Cannot stop server " + sname + " as it is not started")
            #endif
        except:
            _type_, _value_, _tbck_ = sys.exc_info()
            sd = `_tbck_.dumpStack()`
            log(DEBUG_, sd);
            log(WARNING_, "Cannot stop server " + sname + " (already stopped?)")
        #endIf
        if (restart): restartNodeAgent(nname)
    #endFor
    for serv in stoppedServers:
        log(INFO_, "Server " + serv + " stopped")
    #endif
    for serv in nonStoppedServers:
        log(INFO_, "Server " + serv + " not stopped")
    #endIf
#    if (len(nonStoppedServers) > 0):
#        fail("Exiting due to errors listed above")
    #endIf
#endDef


#------------------------------------------------------------------------------------------
# Verify that the server is running
# -> Server = name of server, node = name of node
# Returns true is server is running, false if server is in another state
#------------------------------------------------------------------------------------------
def checkServerIsRunning ( server, node ):
    global numRetries
    sid = ""
    length = 0
    state = ""
    retries = 0
    state = ""

    while ((length == 0) and (state != "STARTED") and (retries < numRetries)):
        retries = retries + 1
        try:
            sleepDelay(10)
            sid = AdminControl.completeObjectName("type=Server,node="+node+",name="+server+",*")
            length = len(sid)
            if (length > 0):
                state = AdminControl.getAttribute(sid,"state")
                if (state != "STARTED"): log(VERBOSE_, ">> Current state of server " + server + ": " + state)
            #endIf
        except:
            _type_, _value_, _tbck_ = sys.exc_info()
            sd = `_tbck_.dumpStack()`
            #log(DEBUG_, sd);
            #log(ERROR_, "Unexpected error: " + str(sys.exc_info()[0]))
        #endTry
    #endWhile
    if (retries < numRetries):
        log(VERBOSE_, ">> Current state of server " + server + ": " + state)
        return 1
    #endIf
    return 0
#endDef


#------------------------------------------------------------------------------------------
# Verify that the node agent for the specified node is started
# -> node = name of node
# Returns true if node agent is running, false if it is in another state
#------------------------------------------------------------------------------------------
def checkNodeIsStarted(node):
    try:
        nodeagent = AdminControl.completeObjectName("type=Server,node="+node+",name=nodeagent,*")
        if (nodeagent == ""):
            log(WARNING_, "Node agent for node " + node + " is not started")
            return 0
        #endIf
        state = AdminControl.getAttribute(nodeagent,"state")
        if (state == "STARTED"):
            log(VERBOSE_, "Node agent for node " + node + " is started")
            return 1
        else:
            log(WARNING_, "Node agent for node " + node + " is not started. Current state: " + state)
            return 0
        #endif
    except:
        _type_, _value_, _tbck_ = sys.exc_info()
        sd = `_tbck_.dumpStack()`
        log(DEBUG_, sd);
        log(WARNING_, "Node agent for node " + node + " is not started")
        return 0
    #endTry
#endDef


#------------------------------------------------------------------------------------------
# Start servers
# -> startServerList = list of node/server pairs
# All servers in the list are started, provided they are in a stopped state
# Aborts if any servers fail to start
# No return value
#------------------------------------------------------------------------------------------
def startServers (startServerList):
    nonStartedServers = []
    startedServers = []

    highlight(INFO_, "Starting all requested Servers...")

    for nodeServerPair in startServerList:
        try:
            nname = nodeServerPair[0]
            sname = nodeServerPair[1]
            if (checkNodeIsStarted(nname)):
                log(INFO_, "Starting server " + sname + " on node " + nname + "...")
                AdminControl.startServer(sname,nname,600)
                running = checkServerIsRunning(sname, nname)
                if (running > 0):
                    startedServers.append(sname)
                else:
                    nonStartedServers.append(sname)
                #endIf
            else:
                log(ERROR_, "Cannot start server " + sname + " as node agent for node " + nname + " is stopped (must be started manually)")
                nonStartedServers.append(sname)
            #endIf
        except:
            _type_, _value_, _tbck_ = sys.exc_info()
            sd = `_tbck_.dumpStack()`
            log(DEBUG_, sd);
            log(WARNING_, "Cannot start server " + sname + " (already started?)")
        #endTry
    #endFor
    for serv in startedServers:
        log(INFO_, "Server " + serv + " started")
    #endFor
    for serv in nonStartedServers:
        log(INFO_, "Server " + serv + " not started")
    #endFor
#    if (len(nonStartedServers) > 0):
#        fail("Exiting due to errors listed above")
    #endIf
#endDef


#------------------------------------------------------------------------------------------
# Generates a dictionary of valid servers in the current deployment
# -> validServers = dictcionary that gets populated with valid server entries
#    validServers[serverName] = serverID
#------------------------------------------------------------------------------------------
def genValidServerDict(validServers):
    serverList = []
    nodeAgentCount = 0
    lineSeparator = java.lang.System.getProperty('line.separator')
    serverList = AdminConfig.getid("/Server:/").split(lineSeparator)
    for server in serverList:
        name = AdminConfig.showAttribute(server,"name")
        if (name == "nodeagent"):
            nodeAgentCount = nodeAgentCount + 1
            name = name + str(nodeAgentCount)
            validServers[name] = server
        elif (name != ""):
            validServers[name] = server
        #endIf
    #endFor
    log(VERBOSE_, "\nList of valid Servers:")
    for k in validServers.keys():
        log(VERBOSE_, "    " + k + " -> " + validServers[k])
    #endFor
#endDef


#------------------------------------------------------------------------------------------
# Generates a dictionary of valid nodes in the current deployment
# -> validNodes = dictcionary that gets populated with valid node entries
#    validNodes[nodeName] = nodeID
#------------------------------------------------------------------------------------------
def genValidNodeDict(validNodes):
    nodeList = []
    lineSeparator = java.lang.System.getProperty('line.separator')
    nodeList = AdminConfig.getid("/Node:/").split(lineSeparator)
    for node in nodeList:
        name = AdminConfig.showAttribute(node,"name")
        if (name != ""):
            validNodes[name] = node
        #endIf
    #endFor
    log(VERBOSE_, "\nList of valid Nodes:")
    for k in validNodes.keys():
        log(VERBOSE_, "    " + k + " -> " + validNodes[k])
    #endFor
#endDef


#------------------------------------------------------------------------------------------
# Verifies that the nodes and servers loaded from the configuration file are valid
# Aborts if any of the entries are invalid
#------------------------------------------------------------------------------------------
def validateServersNodes(validNodes,validServers,slist,type):
    errors = []
    log(VERBOSE_, "\n>> Verifying that " + type + " servers/nodes are valid")
    for nodeServerPair in slist:
        try:
            test = validNodes[nodeServerPair[0]]
        except:
            errors.append("    **** " + nodeServerPair[0] + " is not a valid node ****")
        #endTry
        try:
            test = validServers[nodeServerPair[1]]
        except:
            errors.append("    **** " + nodeServerPair[1] + " is not a valid server ****")
        #endTry
    #endFor
    for err in errors: log(ERROR_, err)
    if (len(errors) > 0):
        fail("Exiting due to errors listed above")
    else:
        log(VERBOSE_, "   All valid\n")
    #endIf
#endDef


#------------------------------------------------------------------------------------------
# Load the configuration settings file
# -> settings = name of config file
# -> startServerList = list of node,server pairs to start
# -> stopServerList = list of node,server pairs to stop
# File should consist of three sections, in this order:
#    [OPTIONS]
#    option1=value1
#    ...
#    [STOPSERVERS]
#    node1,server1
#    node2,server2
#    ...
#    [STARTSERVERS]
#    node1,server1
#    node2,server2
#    ...
#------------------------------------------------------------------------------------------
def loadSettings(settings,stopServerList,startServerList):
    global logLevel
    global numRetries

    log(VERBOSE_, ">> Processing settings file: " + settings)
    try:
        _excp_ = 0
        fd = open( settings, "r" )
    except:
        _type_, _value_, _tbck_ = sys.exc_info()
        fd = `_value_`
        _excp_ = 1
    #endTry
    temp = _excp_
    if (temp != 0): fail("Cannot open settings file: " + settings)

    moreLines = 1
    while (moreLines):
        try:
            line = fd.readline()
            if (len(line) == 0): # EOF
                moreLines = 0
            else:
                line = line.strip()
            #endif
            comment = line.find("#")
            if (comment == 0):
                line = ""
            elif (comment > 0):
                line = line[0:comment].strip()
            #endIf
            secstart = line.find("[")
            if ((secstart == 0) and (line == "[OPTIONS]")): # Process list of options
                log(VERBOSE_, "  Reading section [OPTIONS]")
                while (moreLines):
                    try:
                        line = fd.readline()
                        if (len(line) == 0): # The recommended way to test for EOF
                            moreLines = 0
                        else:
                            line = line.strip()
                        #endif
                        comment = line.find("#")
                        if (comment == 0):
                            line = ""
                        elif (comment > 0):
                            line = line[0:comment].strip()
                        #endIf
                        secstart = line.find("[")
                        if ((secstart == 0) and (line == "[STOPSERVERS]")): # Build stop list of nodes/servers
                            log(VERBOSE_, "  Reading section [STOPSERVERS]")
                            while (moreLines):
                                try:
                                    line = fd.readline()
                                    if (len(line) == 0): # EOF
                                        moreLines = 0
                                    else:
                                        line = line.strip()
                                    #endif
                                    comment = line.find("#")
                                    if (comment == 0):
                                        line = ""
                                    elif (comment > 0):
                                        line = line[0:comment].strip()
                                    #endIf
                                    secstart = line.find("[")
                                    if ((secstart == 0) and (line == "[STARTSERVERS]")):
                                        log(VERBOSE_, "  Reading section [STARTSERVERS]")
                                        while (moreLines): # Build start list of nodes/servers
                                            try:
                                                line = fd.readline()
                                                if (len(line) == 0): # EOF
                                                    moreLines = 0
                                                else:
                                                    line = line.strip()
                                                #endif
                                                comment = line.find("#")
                                                if (comment == 0):
                                                    line = ""
                                                elif (comment > 0):
                                                    line = line[0:comment].strip()
                                                #endIf
                                                secstart = line.find("[")
                                                if (secstart == 0):
                                                    fail("Misplaced section " + line + " in settings file " + settings)
                                                elif (line != ""):
                                                    i = line.find(",") # nodeName,serverName
                                                    if (i > 0):
                                                        node = line[0:i].strip()
                                                        server = line[(i+1):].strip()
                                                        if (server == "dmgr"): # Exclude deployment manager, this will be restarted automatically before node agents
                                                            log(VERBOSE_, "    Ignoring dmgr server. Dmgr will be restarted automatically with 'restart' option")
                                                        else:
                                                            log(VERBOSE_, "    Adding node=" + node + ", server=" + server + " to startServerList")
                                                            startServerList.append((node,server))
                                                        #endIf
                                                    else:
                                                        fail("Unexpected line \"" + line + "\" in settings file " + settings + " [STARTSERVERS] section")        
                                                    #endIf
                                                #endIf
                                            except EOFError:
                                                moreLines = 0
                                            except:
                                                fail("Unexpected error reading settings file: " + settings)
                                            #endTry
                                        #endWhile (more [STARTSERVERS])
                                    elif (secstart == 0):
                                        fail("Misplaced section " + line + " in settings file " + settings)
                                    elif (line != ""):
                                        i = line.find(",") # nodeName,serverName
                                        if (i > 0):
                                            node = line[0:i].strip()
                                            server = line[(i+1):].strip()
                                            log(VERBOSE_, "    Adding node=" + node + ", server=" + server + " to stopServerList")
                                            stopServerList.append((node,server))
                                        else:
                                            fail("Unexpected line \"" + line + "\" in settings file " + settings + " [STOPSERVERS] section")
                                        #endIf
                                    #endIf (start of [STARTSERVERS] section)
                                except EOFError:
                                    moreLines = 0
                                except:
                                    fail("Unexpected error reading settings file: " + settings)
                                #endTry
                            #endWhile (more [STOPSERVERS])
                        elif (secstart == 0):
                            fail("Misplaced section " + line + " in settings file " + settings)
                        elif (line != ""):
                            i = line.find("=") # option=value
                            if (i > 0):
                                option = line[0:i]
                                value = line[(i+1):]
                                log(VERBOSE_, "    Processing option: " + option + "=" + value)
                                if (option == "logLevel"):
                                    if (int(value) > 0 and int(value) <= 4):
                                        logLevel = int(value)
                                    else:
                                        log(ERROR_, "Value for 'logLevel' not in allowed range (1,4). Using default instead")
                                    #endIf
                                elif (option == "numRetries"):
                                    if (int(value) > 0 and int(value) <= 1000):
                                        numRetries = int(value)
                                    else:
                                        log(ERROR_, "Value for 'numRetries' not in allowed range (1,1000). Using default instead")
                                    #endIf
                                else:
                                    log(ERROR_, "Unrecognised option: " + option + " ignored")
                                #endIf
                            else:
                                fail("Unexpected line \"" + line + "\" in settings file " + settings)
                            #endIf
                        #endIf (start of [STOPSERVERS] section)
                    except EOFError:
                        moreLines = 0
                    except:
                        fail("Unexpected error reading settings file: " + settings)
                    #endTry
                #endWhile (more [OPTIONS])
            elif (secstart == 0): # [OPTIONS] section must come first
                fail("Misplaced section " + line + " in settings file " + settings)
            #endIf (start of [OPTIONS] section)
        except EOFError: # End of file
            moreLines = 0
        except:
            fail("Unexpected error reading settings file: " + settings)
        #endTry
    #endWhile
    log(VERBOSE_, ">> Finished processing settings file: " + settings)
    fd.close()
    if (len(stopServerList) == 0):
        log(INFO_, "No node,server pairs found in [STOPSERVERS] section")
    elif (len(startServerList) == 0):
        log(INFO_, "No node,server pairs found in [STARTSERVERS] section")
    #endIf
#endDef


def usage(msg):
    if (msg and msg != ''): print msg
    print "Usage: ManageServers.py configFile (stop|start|restart)\n"
#endDef


def main(argv):
    global logLevel
    global numRetries

    settings = ""
    cmd = ""
    logLevel = VERBOSE_
    numRetries = 100

    if (len(argv) != 2):
        usage('Wrong arguments passed to script')
        sys.exit(2)
    else:
        settings = argv[0]
        cmd = argv[1]
        if (re.search('start|stop|restart', cmd) == None):
            usage("Second parameter must be one of 'start', 'stop', 'restart'")
            sys.exit(2)
        #endif
    #endIf

    stopServerList = []
    startServerList = []
    loadSettings(settings,stopServerList,startServerList)

    validNodes = {}
    validServers = {}
    genValidServerDict(validServers)
    genValidNodeDict(validNodes)

    if (cmd == "stop") or (cmd == "restart"):
        validateServersNodes(validNodes,validServers,stopServerList,"stop")
        stopServers(stopServerList,cmd=="restart")
    #endIf
    if (cmd == "start") or (cmd == "restart"):
        validateServersNodes(validNodes,validServers,startServerList,"start")
        startServers(startServerList)
    #endIf
#endDef

main(sys.argv)
