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

import socket


g_server=None

class OSCServer:
    def __init__(self,port,disp):
        self._port=port
        self._dispatcher=disp
        self._running=False
        self._server=None

    def dispatcher(self):
        return self._dispatcher

    def start(self):
        self._running=True
        self._server = osc_server.BlockingOSCUDPServer((socket.gethostbyname(socket.gethostname()),self._port), self._dispatcher)
        while self._running:
            self._server.handle_request()
        self._server.server_close()
        self._server=None

    def stop(self):
        self._running=False
        #self._server.server_close()
        #self._server.shutdown()

    def close(self):
        self._running=False
        if self._server!=None:
            self._server.server_close()

    def addMsgHandler(self,path,func):
        if(len(self._dispatcher._map[path])==0):
            self._dispatcher.map(path,func)

    def removeMsgHandler(self,path):
        self._dispatcher._map.pop(path)

def createServer(port):
    disp = dispatcher.Dispatcher()
    print("Starting server on: {0}:{1}".format(socket.gethostbyname(socket.gethostname()),port))
    disp.map( "/quit", onOSC_quit )
    server=OSCServer(port,disp)
    return server

def createClient(port):
    client = udp_client.SimpleUDPClient( socket.gethostbyname(socket.gethostname()), port )
    return client


def onOSC_quit(*args):
    global g_server
    g_server.stop()

def start_server(server):
    global g_server
    g_server=server
    g_server.start()
