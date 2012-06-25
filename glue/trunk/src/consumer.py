import sys
import time
from glue import *

from com.rabbitmq.client import *
import com.rabbitmq.client.AMQP
import com.rabbitmq.client.Connection
import com.rabbitmq.client.Channel

import java.io.IOException
from java.lang import String

__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "0.4"
__maintainer__ = "Anthony Oduor"
__created__ = "20th Jun 2012"
__status__ = "Development"

class Logger(object):
    def __init__(self):
        self.terminal = sys.stdout
        self.log = open("log.txt", "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message) 

class RabbitMQClient:

    def __init__(self):
        self.stdout = Logger()
        self.exchangeName = "bu_outputs"
        self.queueName = "glue_script"
        self.factory = ConnectionFactory()
        self.factory.setHost("localhost")
        self.conn = self.factory.newConnection()
        self.channel = self.conn.createChannel()
        self.channel.exchangeDeclare(self.exchangeName,"direct",False)

    def consume_msgs(self):
        declareOk = self.channel.queueDeclare(self.queueName, True, False, False, None)
        self.channel.queueBind(self.queueName, self.exchangeName, self.queueName)
        self.consumer = QueueingConsumer(self.channel)
        self.channel.basicConsume(self.queueName, False, self.consumer)
        count = 0
        new_files = []
        while (count < declareOk.messageCount):
            delivery = QueueingConsumer.Delivery
            delivery = self.consumer.nextDelivery()
            message = String(delivery.getBody())
            new_files.append(str(message))
            count = count + 1
            self.channel.basicAck(delivery.getEnvelope().getDeliveryTag(), True)
        if declareOk.messageCount > 0:
            self.stdout.write("WE GOT " + str(declareOk.messageCount) + " NEW MESSAGES! \n")
            main_queue("src/config.ini", new_files)
        else:
            self.stdout.write("No messages \n")
        self.channel.close()
        self.conn.close()

while True:
    time.sleep( 10 ) # every 10 seconds.
    try:
        rmq = RabbitMQClient()
        rmq.consume_msgs()
    except:
        pass
