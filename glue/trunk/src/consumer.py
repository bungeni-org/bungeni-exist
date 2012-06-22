import sys
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

class RabbitMQClient:

    def __init__(self):
        self.exchangeName = "bu_outputs"
        self.queueName = "glue_script"
        self.factory = ConnectionFactory()
        self.factory.setHost("localhost")
        self.conn = self.factory.newConnection()
        self.channel = self.conn.createChannel()
        self.channel.exchangeDeclare(self.exchangeName,"direct",False)

    def publish_msgs(self, msg_file):
        """
        This is not in use.
        """
        string_msg = msg_file
        self.channel.basicPublish(self.exchangeName, "", AMQP.BasicProperties.Builder().contentType("text/plain").build(), string_msg)

    def consume_msgs(self):
        declareOk = self.channel.queueDeclare(self.queueName, True, False, False, None)
        self.channel.queueBind(self.queueName, self.exchangeName, self.queueName)
        self.consumer = QueueingConsumer(self.channel)
        self.channel.basicConsume(self.queueName, True, self.consumer)
        count = 0
        new_files = []
        while (count < declareOk.messageCount):
            delivery = QueueingConsumer.Delivery
            delivery = self.consumer.nextDelivery()
            message = String(delivery.getBody())
            new_files.append(str(message))
            count = count + 1
        #self.channel.basicAck(delivery.getEnvelope().getDeliveryTag(), True)
        if declareOk.messageCount > 0:
            print "WE GOT " , declareOk.messageCount , " NEW MESSAGES!"
            main_queue("src/config.ini", new_files)
        else:
            print "No messages"
        sys.exit()

rmq = RabbitMQClient();
rmq.consume_msgs()
