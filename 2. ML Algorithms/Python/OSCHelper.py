#from OSC import OSCServer
#from OSC import OSCClient, OSCMessage
from pythonosc import dispatcher
from pythonosc import osc_server

from pythonosc import osc_message_builder
from pythonosc import udp_client

import threading
import sys
from time import sleep
import types

g_server=None

class OSCServer:
    def __init__(self,server,disp):
        self._server=server
        self._dispatcher=disp
        self._running=False

    def start(self):
        self._running=True
        while self._running:
            self._server.handle_request()

    def stop(self):
        self._running=False
        #self._server.server_close()
        #self._server.shutdown()

    def close(self):
        self._running=False
        self._server.server_close()

    def addMsgHandler(self,path,func):
        self._dispatcher.map(path,func)

def createServer(port):
    disp = dispatcher.Dispatcher()
    oscServ = osc_server.BlockingOSCUDPServer(("localhost",port), disp)
    disp.map( "/quit", onOSC_quit )
    server=OSCServer(oscServ,disp)
    return server

def createClient(port):
    client = udp_client.SimpleUDPClient( "localhost", port )
    return client


def onOSC_quit(*args):
    global g_server
    g_server.stop()

def start_server(server):
    global g_server
    g_server=server
    g_server.start()
