import os
import pika
import time
import magic
import pyinotify

from time import gmtime, strftime
from pika.adapters import BlockingConnection
from pika import BasicProperties

pika.log.setup(color=True) # Setup a coloured logger
wm = pyinotify.WatchManager()  # Watch Manager
mask = pyinotify.IN_CLOSE_WRITE # watched events
messages = 0 # Start our counter at 0
started = int(time.time())

class EventHandler(pyinotify.ProcessEvent):
    def process_IN_CLOSE_WRITE(self, event):
        print "Updated:", event.pathname
        pikad = PikaDilly()
        pikad.publisher(event.pathname)

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
        m = magic.Magic(mime=True)
        mtype = str(m.from_file(_file))
        self.channel.basic_publish(exchange=self.exchange_name, routing_key=self.queue, body=_file, properties=BasicProperties(content_type=mtype,delivery_mode=1))

    def consumer(self):
        # Receive a message
        self.channel.basic_consume(self.handle_delivery, self.queue)

    def handle_delivery(self, channel, method_frame, header_frame, body):
        # Receive the data in 3 frames from RabbitMQ
        pika.log.info("Basic.Deliver %s delivery-tag %i: %s", header_frame.content_type, method_frame.delivery_tag, body)
        channel.basic_ack(delivery_tag=method_frame.delivery_tag)

handler = EventHandler()
notifier = pyinotify.Notifier(wm, handler)
wdd = wm.add_watch('/home/undesa/attic/xml_db', mask, rec=True)

if __name__ == "__main__":
    notifier.loop()
