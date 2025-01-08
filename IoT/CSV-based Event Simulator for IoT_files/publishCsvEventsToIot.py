# Publish events from CSV file to IoT using mqtt protocol
# mooreof@ie.ibm.com, December 2018

import getopt
import signal
import time
import sys
import json
import csv
import logging
import configparser
import datetime
import ibmiotf.application
import pprint


class IoTEventSimulator(object):
    def __init__(self, configFile, eventFile, intervalInMs, loop):
        self.messages = []
        self.logLevels = ["DEBUG", "INFO", "WARN", "ERROR"]
        self.logLevel = "INFO"
        self.eventIntervalInSecs = 60
        self.keepLooping = loop
        self.waitTimeBeforeDisconnect = 10
        self.eventFile = eventFile
        self.eventInputDir = None
        self.eventOutputDir = None
        self.protocol = "mqtt"
        self.successHandler = self.mqttHandler
        self.events = []
        self.successfullyPublishedEvents = 0
        self.inputEvents = 0
        
        if configFile is not None:
            self.parseSimulatorOptions(configFile)
            self.appOptions = self.parseApplicationOptions(configFile)
            self.deviceOptions = self.parseDeviceOptions(configFile)
        else:
            self.fatal("You must specify a config file")
        # end if

        if self.eventFile is None:
            self.fatal("You must specify a CSV event file")
        # end if

        if intervalInMs is not None and intervalInMs == 0:
           self.eventIntervalInSecs = 0.01 # minimum 10 milliseconds
        elif intervalInMs is not None and intervalInMs > 0:
           self.eventIntervalInSecs = intervalInMs / 1000.0
        # end if
        
        self.client = Client(self.appOptions, self.protocol)
    # end def
    
    def resetEvents(self, clearEvents = False):
        self.successfullyPublishedEvents = 0
        if (clearEvents):
            self.events = []
            self.inputEvents = 0
        # end if
    # end def

    def log(self, lvl, msg):
        curLvl = self.logLevels.index(self.logLevel)
        msgLvl = self.logLevels.index(lvl)
        if curLvl <= msgLvl:
            print(msg)
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
        self.log_error(msg)
        self.helpText()
        sys.exit(2)
    # end def


    def run(self):
        keepLooping = True
        self.log_info("\n>>> Press Ctrl+C to stop <<<\n")
        self.getEventsFromCsv()
        self.client.connect()

        while (keepLooping):
            self.publishEvents()
            self.postResults()
            keepLooping = self.keepLooping
            self.resetEvents()
        # end while

        time.sleep(self.waitTimeBeforeDisconnect)
        self.client.disconnect()
    # end def


    def getEventsFromCsv(self):
        self.events = []
        with open(self.eventFile, mode='r') as csvFile:
            csvReader = csv.DictReader(csvFile)
            for event in csvReader:
                self.events.append(self.enrichEvent(self.formatEventByDataType(event)))
            # end for
        # end with
        self.inputEvents = len(self.events)
        return (self.inputEvents > 0)
    # end def
    
    
    def enrichEvent(self, event):
        now = time.strftime('%Y-%m-%d %H:%M:%S')
        
        #if 'lastupdate' not in event or event['lastupdate'] == '':
        #    event['lastupdate'] = now
        # end if
    
        return event
    # end def
    
    
    def formatEventByDataType(self, event):
        formattedEvent = {}
    
        for key in event:
            (dataType,normalisedKey) = self.getDataTypeFromKeyName(key)
            formattedValue = self.formatValueByDataType(dataType,event[key])
            formattedEvent[normalisedKey] = formattedValue
        # end for
    
        if (self.logLevel == 'DEBUG'):
            pp = pprint.PrettyPrinter(indent=4)
            pp.pprint(formattedEvent)
        # end if
    
        return formattedEvent
    # end def


    def getDataTypeFromKeyName(self, key):
        type = 's'
        normalisedKey = key
    
        keyAndType = key.split(' ')
        if (len(keyAndType) > 1):
            normalisedKey = keyAndType[0]
            type = keyAndType[1]
        # end if
    
        return (type,normalisedKey)
    # end def
    
    
    def formatValueByDataType(self, type, value):
        formattedValue = value
    
        if (type == 'i'):
            formattedValue = int(value)
        elif (type == 'f'):
            formattedValue = float(value)
        elif (type == 'd'):
            formattedValue = self.formatDateValue(value)
        # end if
    
        return formattedValue
    # end def
    
    def formatDateValue(self, value):
        return value
    # end def
    
    
    def formatEventDataForIot(self, event):
        return {'d':event}
    # end def
    
    
    def publishEvents(self):
        startTime = datetime.datetime.now()
        self.addMessage("Start Time: %s" % startTime)
    
        for event in self.events:
            eventData = self.formatEventDataForIot(event)
            self.publishEvent(eventData)
            time.sleep(self.eventIntervalInSecs)
        # end for
    
        self.timings(startTime)
    # end def

    
    def addMessage(self, msg):
        self.messages.append(msg)
    # end def

    
    def insertMessage(self, msg):
        self.messages.insert(0,msg)
    # end def


    def outputMessages(self):
        for i in range(len(self.messages)):
            print(self.messages[i])
        # end for
        self.clearMessages()
    # end def

    
    def clearMessages(self):
        self.messages = []
    # end def

    
    def timings(self, startTime):
        delta = datetime.datetime.now() - startTime
        totalEvents = self.inputEvents
        waitTimeSecs = totalEvents * self.eventIntervalInSecs
        self.addMessage("End Time: %s" 
                            % datetime.datetime.now())
        self.addMessage("Total Time to Publish %d Events: %d ms" 
                            % (totalEvents, int(delta.total_seconds() * 1000)))
        self.addMessage("Publish Time excluding wait time: %d ms" 
                            % (int((delta.total_seconds()-waitTimeSecs) * 1000)))
        self.addMessage("Average Publish Time per event (microseconds): %d" 
                            % (((delta.total_seconds() - waitTimeSecs) * 1000000)/totalEvents))
    # end def

    
    def publishEvent(self, data):
        self.log_info(data)
        return self.client.publishEvent(data, self.deviceOptions, self.successHandler)
    # end def

    
    def mqttHandler(self):
        self.successfullyPublishedEvents += 1
        self.log_info(">>>> Mqtt Event published successfully <<<<")
    # end def

    
    def httpHandler(self, response):
        if (response == 200):
            self.successfullyPublishedEvents += 1
            self.log_info(">>>> Http Event published successfully <<<<")
        else:
            self.log_info(">>>> Error publishing http event: %d <<<<" % response)
        # end if
    # end def

    
    def interruptHandler(self, signal, frame):
        self.client.disconnect()
        sys.exit(0)
    # end def
    

    def parseSimulatorOptions(self, configFile):
        parms = configparser.ConfigParser({
            "input-directory": "input",
            "output-directory": "output",
            "protocol": "mqtt",
            "wait-time-before-disconnect-secs": "10",
            "loglevel": "INFO"
        })
        sectionHeader = "simulator"
    
        try:
            with open(configFile) as f:
                parms.read_file(f)
            # end with            
    
            self.eventInputDir = parms.get(sectionHeader, "input-directory")
            self.eventOutputDir = parms.get(sectionHeader, "output-directory")

            protocol = parms.get(sectionHeader, "protocol")
            if protocol == 'http':
                self.protocol = protocol
                self.successHandler = self.httpHandler
            # end if

            self.waitTimeBeforeDisconnect = int(parms.get(sectionHeader, "wait-time-before-disconnect-secs"))

            logLevel = parms.get(sectionHeader, "loglevel")
            try:
                i = self.logLevels.index(logLevel)
                self.logLevel = logLevel
            except ValueError:
                self.log_error("Invalid log level parameter (-l), using default")
            # end try
        except IOError as e:
            self.fatal("Error reading simulator configuration '%s' (%s)" % (configFile,e[1]))
        # end try

    # end def
            
    
    def parseApplicationOptions(self, configFile):
        return ibmiotf.application.ParseConfigFile(configFile)
    # end def
    

    def parseDeviceOptions(self, configFile):
        parms = configparser.ConfigParser({
            "event": "capAlert",
            "type": "CapAlertSender",
            "id": "capAlertSender"
        })
        sectionHeader = "device"
    
        try:
            with open(configFile) as f:
                parms.read_file(f)
            # end with            
    
            event = parms.get(sectionHeader, "event")
            deviceType = parms.get(sectionHeader, "type")
            deviceId = parms.get(sectionHeader, "id")
        except IOError as e:
            self.fatal("Error reading device configuration '%s' (%s)" % (configFile,e[1]))
        # end try
    
        return {'event': event, 'type': deviceType, 'id': deviceId}
    # end def

    
    def postResults(self):
        msgTotals = "\n>>>>>>>>>>>>>>>\nTotal Events Ingested: %d, Events Successfully Published: %d" \
                            % (self.inputEvents, self.successfullyPublishedEvents)
        self.insertMessage(msgTotals)
        self.addMessage("---------------\n")
        self.outputMessages()
    # end def

    
    def helpText(self):
        usage()
    # end def

# end class


class Client(object):
    def __init__(self, options, proto):
        self.protocol = proto
        self.appOptions = options
        self.client = None
        
        if (self.protocol == 'mqtt'):
            self.client = ibmiotf.application.Client(self.appOptions)
        else:
            self.client = ibmiotf.application.HttpClient(self.appOptions)
        # end if
    # end def

    
    def connect(self):
        if (self.protocol == 'mqtt'):
            self.client.connect()
        # end if
    # end def

    
    def disconnect(self):
        if (self.protocol == 'mqtt'):
            self.client.disconnect()
        # end if
    # end def
    

    def publishEvent(self, data, options, handler):
        if (self.protocol == 'mqtt'):
            return self.client.publishEvent(options['type'], options['id'], 
                                            options['event'], 'json', data, 1, handler)
        else:
            response = self.client.publishEvent(options['type'], options['id'], 
                                                options['event'], data, 'json')
            handler(response)
        # end if
    # end def

# end class


def usage():
    print(
        "publishCsvEventsToTopic: Connect to IBM Internet of Things and publish events." + "\n" +
        "\n" +
        "Options: " + "\n" +
        "  -h, --help          Display help information" + "\n" + 
        "  -c, --config        Simulator, application and device configuration file" + "\n" + 
        "  -f, --file          CSV file with event data" + "\n" +
        "  -i, --interval      Gap in milliseconds between events (default=60,000)" + "\n" + 
        "  -l, --loop          Process input file in a loop (until Ctrl-C is pressed) - default False" + "\n"
    )
#end def

    
def main(arglist):
    configFile = None
    eventFile = None
    interval = None
    loop = False

    try:
        opts, args = getopt.getopt(arglist, "hc:f:p:o:i:lw:", 
                                            ["help", "config=", "file=", "proto=", 
                                             "loglevel=", "interval=", "loop", "wait="])
    except getopt.GetoptError as err:
        print(str(err))
        sys.exit(2)
    # end try
    
    for opt, arg in opts:
        if opt in ("-c", "--config"):
            configFile = arg
        elif opt in ("-f", "--file"):
            eventFile = arg
        elif opt in ("-i", "--interval"):
            interval = int(arg)
        elif opt in ("-l", "--loop"):
            loop = True
        elif opt in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            assert False, "Unhandled option: " + opt
        # end if
    # end for

    simulator = IoTEventSimulator(configFile, eventFile, interval, loop)
    signal.signal(signal.SIGINT, simulator.interruptHandler)
    try:
        simulator.run()
    except ibmiotf.ConfigurationException as e:
        simulator.fatal(str(e))
    except ibmiotf.UnsupportedAuthenticationMethod as e:
        simulator.fatal(str(e))
    except ibmiotf.ConnectionException as e:
        simulator.fatal(str(e))
    # end try
    
# end def


if __name__ == "__main__":
    main(sys.argv[1:])
