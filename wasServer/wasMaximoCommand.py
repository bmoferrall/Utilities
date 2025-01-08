import sys, os
import getopt
import time
global AdminApp
global AdminConfig

# ----------------------------------------------------------------------------------------
# Invoke commands in WebSphere Application Server
#
# stop:     stop the server
# start:    start the server
# restart:  restart the server
# redeploy: redeploy an application
# ----------------------------------------------------------------------------------------

class WasServer(object):
    def __init__(self, server, node, cell):
        self.server = server
        self.node = node
        self.cell = cell
        
        self.logLevels = ['DEBUG', 'INFO', 'WARN', 'ERROR']
        self.logLevel = 'INFO'
        
        if self.server is None:
            self.fatal('Server name undefined')
        # end if
        
        if self.node is None:
            self.fatal('Node name undefined')
        # end if
        
        if self.cell is None:
            self.fatal('Cell name undefined')
        # end if        
        
        self.log_info("Server: %s, node: %s, cell: %s" % (server, node, cell))
    # end def
    
    def stopServer(self):
        state = self.checkServerState()
        
        if state == 'STARTED':
            self.log_info("Stopping server %s" % self.server)
            AdminControl.stopServer(self.server,self.node)
        elif state == 'STOPPING':
            self.log_info('Server %s is in STOPPING state, will attempt to force stop' % self.server)
            AdminControl.stopServer(self.server,self.node,'immediate')
        #end if
        
        self.pause(5)
        if self.checkServerState() == 'STOPPED':
            self.log_info("Server %s stopped" % self.server)
        else:
            self.log_info("Problem stopping %s" % self.server)
        #end if
    #end def
    
    def startServer(self):
        state = self.checkServerState()
        
        if state == 'STOPPED':
            self.log_info("Starting server %s" % self.server)
            AdminControl.startServer(self.server,self.node)
            
            self.pause(5)
            if self.checkServerState() == 'STARTED':
                self.log_info("Server %s started" % self.server)
            else:
                self.log_info("Problem starting %s" % self.server)
            #end if
        #end if
        else:
            self.log_info('Server cannot be started at this time. Current state: %s' % state)
        #end if
    #end def
    
    def checkServerState(self):
        self.log_debug('Checking server state')
        serverObject = AdminControl.completeObjectName("type=Server,node="+self.node+",name="+self.server+",*")
        
        if len(serverObject) == 0:
            state = 'STOPPED'
        else:
            state = AdminControl.getAttribute(serverObject,'state')
        #end if
        self.log_debug('Server state: %s' % state)
        
        return state
    #end def
    
    def restartServer(self):
        self.stopServer()
        self.startServer()
    #end def

    def saveConfiguration(self):
        self.log_info('Saving the configuration')
        AdminConfig.save()
    #end def
    
    def redeployEar(self,appName,ear,deployCommand):
        self.stopServer()
    
        self.uninstallEar(appName)
        
        self.installEar(appName,ear,deployCommand)
        
        self.pause(120)
        
        self.startServer()
    #end def
    
    def installEar(self,appName,ear,deployCmd):
        self.log_info('Installing the %s application' % appName)
        self.log_debug(deployCmd)
        
        AdminApp.install(ear,deployCmd)
    
        self.saveConfiguration()
        
        if self.appIsInstalled(appName):
            self.log_info('Application %s installed' % appName)
        else:
            self.log_info('Application %s not installed' % appName)
        #end if
    #end def
    
    def uninstallEar(self,appName):        
        if self.appIsInstalled(appName):
            self.log_info('Uninstalling the %s application' % appName)
            AdminApp.uninstall(appName)
            self.saveConfiguration()
        else:
            self.log_info('Application %s not installed' % appName)
        #end if
    #end def
    
    def appIsInstalled(self,appName):
        self.log_info('Checking if application %s is installed' % appName)
        isInstalled = False
        apps = AdminApp.list().split('\n')
        for app in apps:
            self.log_debug('Installed App: %s' % app)
            if app == appName:
                self.log_info('Application %s is installed' % appName)
                isInstalled = True
                break
            #end if
        #end for
        return isInstalled
    #end def
    
    def pause(self,secs):
        self.log_debug("Pausing for %d seconds" % secs)
        time.sleep(secs)
    #end def

    def log(self, lvl, msg):
        prefix = ">>> "
        curLvl = self.logLevels.index(self.logLevel)
        msgLvl = self.logLevels.index(lvl)
        if curLvl <= msgLvl:
            print(prefix + msg)
        # end if
    # end def
    
    def log_debug(self, msg):
        self.log("DEBUG", msg)
    # end def
    
    def log_info(self, msg):
        self.log("INFO", msg)
    # end def
    
    def log_warn(self, msg):
        self.log("WARN", msg)
    # end def
    
    def log_error(self, msg):
        self.log("ERROR", msg)
    # end def
    
    def fatal(self, msg):
        self.helpText(msg)
        sys.exit(2)
    # end def
    
    def helpText(self,msg):
        usage(msg)
    # end def


def usage(msg):
    if (msg and msg != ''):
        print('>>>>>>>>>> ' + msg + ' <<<<<<<<<<')
    # end if
    
    print(
        "\nwasMaximoCommand: Invoke WAS server command.\n" +
        "\n" +
        "Usage: <wsadmin> wasMaximoCommand.py -a Action -s Server -n Node -l Cell -e Ear -p AppName -h\n" +
        "       where <wsadmin> = wsadmin.sh -user wasadmin -password wasadmin_password -lang jython\n" +
        "Required:\n" +
        "  -a, --action    redeploy|stop|start|restart\n" + 
        "  -s, --server    WAS Server name\n" + 
        "  -n, --node      WAS Node name\n" +
        "  -l, --cell      WAS Cell name\n" +
        "\n" +
        "Options:\n" +
        "  -e, --ear       EAR file (required for redeploy option)\n" +
        "  -m, --app       Application Name (required for redeploy option)\n" +
        "\n" +
        "Example: <wsadmin> wasMaximoCommand.py -a restart -s MXServer -n ctgNode01 -l ctgCell01 \n" +
        "Example: <wsadmin> wasMaximoCommand.py -a redeploy -s MXServer -n ctgNode01 -l ctgCell01 \n" +
        "                             -e /opt/IBM/SMP/maximo/deployment/default/maximo.ear -m MAXIMO\n"
    )
    sys.exit(2)
 
#endDef

def getDeployCommand(server,node,cell):
    cmdTemplate = '[ -nopreCompileJSPs -distributeApp -nouseMetaDataFromBinary -deployejb -appname MAXIMO -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema -MapModulesToServers [[ "MBO EJB Module" mboejb.jar,META-INF/ejb-jar.xml WebSphere:cell={cell},node={node},server={server}+WebSphere:cell={cell},node={node},server=webserver1 ][ "MAXIMO Web Application" maximouiweb.war,WEB-INF/web.xml WebSphere:cell={cell},node={node},server={server}+WebSphere:cell={cell},node={node},server=webserver1 ][ "MBO Web Application" mboweb.war,WEB-INF/web.xml WebSphere:cell={cell},node={node},server={server}+WebSphere:cell={cell},node={node},server=webserver1 ][ "MEA Web Application" meaweb.war,WEB-INF/web.xml WebSphere:cell={cell},node={node},server={server}+WebSphere:cell={cell},node={node},server=webserver1 ][ "REST Web Application" maxrestweb.war,WEB-INF/web.xml WebSphere:cell={cell},node={node},server={server}+WebSphere:cell={cell},node={node},server=webserver1 ]] -MapWebModToVH [[ "MAXIMO Web Application" maximouiweb.war,WEB-INF/web.xml maximo_host ][ "MBO Web Application" mboweb.war,WEB-INF/web.xml maximo_host ][ "MEA Web Application" meaweb.war,WEB-INF/web.xml maximo_host ][ "REST Web Application" maxrestweb.war,WEB-INF/web.xml maximo_host ]]]'

    cmd = cmdTemplate.replace("{server}",server)
    cmd = cmd.replace("{node}",node)
    cmd = cmd.replace("{cell}",cell)
    
    return cmd
#end def

def main(argv):
    action = None
    server = None
    node = None
    cell = None
    maximoEar = None
    appName = None
    
    try:
        opts, args = getopt.getopt(argv, "ha:s:n:l:e:m:", 
                                         ["help", "action=", "server=", "node=", "cell=", "ear=", "app="])
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)
    # end try
    
    for opt, arg in opts:
        if opt in ('-a', '--action'):
            action = arg
        elif opt in ('-s', '--server'):
            server = arg
        elif opt in ('-n', '--node'):
            node = arg
        elif opt in ('-l', '--cell'):
            cell = arg
        elif opt in ('-e', '--ear'):
            maximoEar = arg
        elif opt in ('-m', '--app'):
            appName = arg
        elif opt in ('-h', '--help'):
            usage()
        else:
            assert False, 'Unhandled option: ' + opt
        # end if
    # end for
        
    if action is None:
        usage('Missing action parameter')
    #end if
    
    if action == 'redeploy' and (appName is None or maximoEar is None):
        usage('Application name and ear name required for redeploy action')
    #end if
    
    maximoServer = WasServer(server,node,cell)
    
    if action == 'redeploy':
        deployCmd = getDeployCommand(server,node,cell)
        maximoServer.redeployEar(appName,maximoEar,deployCmd)
    elif action == 'stop':
        maximoServer.stopServer()
    elif action == 'start':
        maximoServer.startServer()
    elif action == 'restart':
        maximoServer.restartServer()
    else:
        usage('Unrecognised action parameter: %s' % action)
    #end if

#end def

main(sys.argv)
