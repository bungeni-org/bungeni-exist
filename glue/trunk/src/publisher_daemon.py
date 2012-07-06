# daemonized rabbitmq messages publisher
# using pyinotify's notifier.

import os
import pika
import time
import sys
import getopt
import magic
import pyinotify

from time import gmtime, strftime
from pika.adapters import BlockingConnection
from pika import BasicProperties

wm = pyinotify.WatchManager()  # Watch Manager
mask = pyinotify.IN_CLOSE_WRITE | pyinotify.IN_CREATE # watched events
started = int(time.time())

class EventHandler(pyinotify.ProcessEvent):
    def process_IN_CLOSE_WRITE(self, event):
        print "Updated:", event.pathname
        pikad = PikaDilly()
        pikad.publisher(event.pathname)

    def process_IN_CREATE(self, event):
        print "Created:", event.pathname
        """
        pikad = PikaDilly()
        basename = os.path.basename(event.pathname)
        if basename.startswith(".goutputstream"):
            pass
        else:
            pikad.publisher(event.pathname)
        """

class PikaDilly:

    def __init__(self):
        self.exchange_name = "bu_outputs"
        self.queue = "glue_script"
        parameters = pika.ConnectionParameters('localhost')
        self.connection = BlockingConnection(parameters) # Open conn to RabbitMQ with default params for localhost
        self.channel = self.connection.channel() # Open the channel
        self.channel.exchange_declare(exchange=self.exchange_name, type='direct', passive=False)
        self.channel.queue_declare(queue=self.queue, durable=True,exclusive=False, auto_delete=False) # Declare a queue
        self.channel.queue_bind(queue=self.queue, exchange=self.exchange_name, routing_key=self.queue)

    def publisher(self, _file):
        # Send a message
        try:
            m = magic.Magic(mime=True)
            mtype = str(m.from_file(_file))
            self.channel.basic_publish(exchange=self.exchange_name, routing_key=self.queue, body=_file, properties=BasicProperties(content_type=mtype,delivery_mode=2))
        except IOError, err:
            pass

if (len(sys.argv) >= 1):
    # process input command line option for a directory to be monitored
    options, params = getopt.getopt(sys.argv[1:], "d:")
    __bungeni_output_folder__ = options[0][1]
else:
    print " bungeni_output_folder to watch must be an input parameter "
    sys.exit()

handler = EventHandler()
notifier = pyinotify.Notifier(wm, handler)
wdd = wm.add_watch(__bungeni_output_folder__, mask, rec=True, auto_add=True)

# Notifier instance spawns a new process when daemonize is set to True. This
# child process' PID is written to /tmp/pyinotify.pid (it also automatically
# deletes it when it exits normally). If no custom pid_file is provided it
# would write it more traditionally under /var/run/. Note that in both cases
# the caller must ensure the pid file doesn't exist when this method is called
# othewise it will raise an exception. /tmp/stdout.txt is used as stdout 
# stream thus traces of events will be written in it. callback is the above 
# function and will be called after each event loop.
try:
    # http://seb-m.github.com/pyinotify/pyinotify.Notifier-class.html
    #notifier.loop(daemonize=True, callback=None, pid_file='/tmp/pyinotify.pid', stdout='/tmp/stdout.txt')
    notifier.loop()
except pyinotify.NotifierError, err:
    print >> sys.stderr, err
