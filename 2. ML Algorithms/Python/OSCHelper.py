from OSC import OSCServer
from OSC import OSCClient, OSCMessage
import sys
from time import sleep
import types

osc_run=True
def createServer(port):
    server = OSCServer( ("localhost",port) )
    server.timeout = 0
    def handle_timeout(self):
        self.timed_out = True
    server.handle_timeout = types.MethodType(handle_timeout, server)
    server.addMsgHandler( "/quit", onOSC_quit )
    return server

def createClient(port):
    client = OSCClient()
    client.connect( ("localhost", port) )
    return client

def each_frame(server):
    server.timed_out = False
    while not server.timed_out:
        server.handle_request()


def onOSC_quit(path, tags, args, source):
    global osc_run
    osc_run = False

def start_server(server):
    global osc_run
    osc_run=True
    while osc_run:
        sleep(1)
        each_frame(server)
